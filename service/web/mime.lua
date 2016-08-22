local skynet = require "skynet"
local json = require "cjson"
local _M = {}

local default_mime_types = {
	{"html",	4,	"text/html"			},
	{"htm",		3,	"text/html"			},
	{"txt",		3,	"text/plain"			},
	{"css",		3,	"text/css"			},
	{"ico",		3,	"image/x-icon"			},
	{"gif",		3,	"image/gif"			},
	{"jpg",		3,	"image/jpeg"			},
	{"jpeg",	4,	"image/jpeg"			},
	{"png",		3,	"image/png"			},
	{"svg",		3,	"image/svg+xml"			},
	{"torrent",	7,	"application/x-bittorrent"	},
	{"wav",		3,	"audio/x-wav"			},
	{"mp3",		3,	"audio/x-mp3"			},
	{"mid",		3,	"audio/mid"			},
	{"m3u",		3,	"audio/x-mpegurl"		},
	{"ram",		3,	"audio/x-pn-realaudio"		},
	{"ra",		2,	"audio/x-pn-realaudio"		},
	{"doc",		3,	"application/msword",		},
	{"exe",		3,	"application/octet-stream"	},
	{"zip",		3,	"application/x-zip-compressed"	},
	{"xls",		3,	"application/excel"		},
	{"tgz",		3,	"application/x-tar-gz"		},
	{"tar.gz",	6,	"application/x-tar-gz"		},
	{"tar",		3,	"application/x-tar"		},
	{"gz",		2,	"application/x-gunzip"		},
	{"arj",		3,	"application/x-arj-compressed"	},
	{"rar",		3,	"application/x-arj-compressed"	},
	{"rtf",		3,	"application/rtf"		},
	{"pdf",		3,	"application/pdf"		},
	{"mpg",		3,	"video/mpeg"			},
	{"mpeg",	4,	"video/mpeg"			},
	{"asf",		3,	"video/x-ms-asf"		},
	{"avi",		3,	"video/x-msvideo"		},
	{"bmp",		3,	"image/bmp"			},
}

local function parse( ... )
	-- body
	local str = tostring( ... )
	if str and #str > 0 then
		local r = {}	
		local function split( str )
			-- body
			local p = string.find(str, "=")
			local key = string.sub(str, 1, p - 1)
			local value = string.sub(str, p + 1)
			r[key] = value
	 	end
		local s = 1
		repeat
			local p = string.find(str, "&", s)
			if p ~= nil then 
				local frg =	string.sub(str, s, p - 1)
				s = p + 1
				split(frg)
			else
				local frg =	string.sub(str, s)
				split(frg)
				break
			end
		until false
		return r
	else
		return str
	end
end

local function parse_file( header, boundary, body )
	-- body
	local line = ""
	local file = ""
	local last = body
	local function unpack_line(text)
		local from = text:find("\n", 1, true)
		if from then
			return text:sub(1, from-1), text:sub(from+1)
		end
		return nil, text
	end
	local mark = string.gsub(boundary, "^-*(%d+)-*", "%1")
	line, last = unpack_line(last)
	assert(string.match(line, string.format("^-*(%s)-*", mark)))
	line, last = unpack_line(last)
	line, last = unpack_line(last)
	line, last = unpack_line(last)
	line, last = unpack_line(last)
	while line do
		if string.match(line, string.format("^-*(%s)-*", mark)) then
			break
		else
			file = file .. line .. "\n" 
			line, last = unpack_line(last)
		end
	end
	header["content-type"] = nil
	return file, header
end

local function unpack_seg(text, s)
	assert(text and s)
	local from = text:find(s, 1, true)
	if from then
		return text:sub(1, from-1), text:sub(from+1)
	else
		return text
	end
end

local function parse_content_type(content_type, ... )
	-- body
	assert(content_type)
	local res = {}
	local t, param = unpack_seg(content_type, ";")
	if t then
		res.type = t
		if t == "multipart/form-data" then
			local idx = string.find(c, "=")
			local boundary = string.sub(c, idx+1)
			res.boundary = boundary
			return res
		else
			local parameter = {}
			while param do
				local p, e = unpack_seg(param, ";")
				if p then
					local k, v = unpack_seg(p, "=")
					k = tostring(k)
					parameter[k] = v
					param = e
				else
				end
			end
			res.parameter = parameter
			return res
		end
	else
		assert(t)
	end
end

function _M.handle_post(path, header, body, post_handler, ... )
	-- body
	local mime_version = header["mime-version"]
	local content_type = header["content-type"]
	local content_transfer_encoding = header["content-transfer-encoding"]
	local content_disposition = header["content-disposition"]
	local content_length = header["content-length"]
	local res = parse_content_type(content_type)
	local t = res.type
	if t == "application/x-www-form-urlencoded" then
		local body = parse(body)
		return post_handler("post", body)
	elseif t == "application/json" then
		local res = json.decode(body)
		return post_handler("post", res)
	elseif t == "multipart/form-data" then
		local boundary = res.boundary
		local res = parse_file(header, boundary, body)
		return post_handler("file", res)
	else
		local res = body
		return post_handler("post", res)
	end
end

function _M.handle_static(path, header, body, handle_static, ... )
	-- body
	local mime_version = header["mime-version"]
	local content_type = header["content-type"]
	local content_transfer_encoding = header["content-transfer-encoding"]
	local content_disposition = header["content-disposition"]
	local content_length = header["content-length"]
	if content_type then
		local res = parse_content_type(content_type)
		local t = res.type
		for i,v in ipairs(default_mime_types) do
			if t == v[3] then
				return true, handle_static(path)
			end
		end
		return false
	else
		return false
	end
end

return _M