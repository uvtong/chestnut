package.path = "../web/?.lua;../web/lualib/?.lua;../lualib/?.lua;"..package.path
package.cpath = "../lua-cjson/?.so;" .. package.cpath
local skynet = require "skynet"
local socket = require "socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
local urls = require "urls"
local json = require "cjson"
local table = table
local string = string

local mode = ...

if mode == "agent" then

local function response(id, ...)
	local ok, err = httpd.write_response(sockethelper.writefunc(id), ...)
	if not ok then
		-- if err == sockethelper.socket_error , that means socket closed.
		skynet.error(string.format("fd = %d, %s", id, err))
	end
end

local function parse( ... )
	-- body
	local str = tostring( ... )
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

-- analysis header, judge post or file.
local function parse_header( header, body )
	-- body
	local function unpack_seg(text, s)
		local from = text:find(s, 1, true)
		if from then
			return text:sub(1, from-1), text:sub(from+1)
		end
		return nil, text
	end
	if not header["content-type"] then
		return "post", parse(body)
	end
	local t, c = unpack_seg(header["content-type"], ";")
	if t == "application/x-www-form-urlencoded" then
		return "post", parse(body)
	elseif t == "multipart/form-data" then
		local idx = string.find(c, "=")
		local boundary = string.sub(c, idx+1)
	 	return "file", parse_file(header, boundary, body)
	else
	 	assert(false)
	end
end

local function route( id, code, url, method, header, body )
	-- body
	local statuscode = code
	local headerd = {}
	headerd["connection"] = "close"
	local bodyfunc
	local path, query = urllib.parse(url)
	if method == "GET" then
		local suffix = string.gsub(path, "(.*)/[^/]*%.(%w+)", "%2")
		if suffix == "js" or suffix == "css" then
			path = "../web/statics" .. path
			local fd = io.open(path, "r")
			local ret = fd:read("*a")
			fd:close()
			bodyfunc = ret
		else
			for k,v in pairs(urls) do
				if string.match(path, k) then
					local args = {}
					args.method = "get"
					args.query = query
					local ok, res = pcall(v, args)
					if ok then
						bodyfunc = res
					else
						bodyfunc = res
					end
					break
				end
			end
			if not bodyfunc then
				bodyfunc = "404"
				statuscode = 301
				headerd["Location"] = "/404"
			end
		end
	elseif method == "POST" then
		local flag
		flag, body, header = parse_header(header, body)
		for k,v in pairs(urls) do
			if string.match(path, k) then
				if flag == "file" then
					local args = {}
					args.method = flag
					args.file = body
					local ok, res = pcall(v, args)
					if ok then
						bodyfunc = res
					else
						bodyfunc = res
					end
				elseif flag == "post" then
					local args = {}
					args.method = flag
					args.body = body
					local ok, res = pcall(v, args)
					if ok then
						bodyfunc = res
					else
						bodyfunc = res
					end
				else
					assert(false)
				end
				break
			end
		end
		if not bodyfunc then
			bodyfunc = "404"
		end
	else
		bodyfunc = "handle default."
	end
	if type(bodyfunc) == "table" then
		bodyfunc = json.encode(bodyfunc)
	end
	assert(type(bodyfunc) == "string" or type(bodyfunc) == "function")
	return response(id, statuscode, bodyfunc, headerd)
end 

skynet.start(function()
	skynet.dispatch("lua", function (_,_,id)
		socket.start(id)
		-- limit request body size to 8192 (you can pass nil to unlimit)
		local code, url, method, header, body = httpd.read_request(sockethelper.readfunc(id), 8192)
		if code then
			if code ~= 200 then
				response(id, code)
			else
				return route(id, code, url, method, header, body)				
			end
		else
			if url == sockethelper.socket_error then
				skynet.error("socket closed")
			else
				skynet.error(url)
			end
		end
		socket.close(id)
	end)
end)

else

skynet.start(function()
	local agent = {}
	for i= 1, 20 do
		agent[i] = skynet.newservice(SERVICE_NAME, "agent")
	end
	local balance = 1
	local id = socket.listen("0.0.0.0", 8181)
	skynet.error("Listen web port 8181")
	socket.start(id , function(id, addr)
		skynet.error(string.format("%s connected, pass it to agent :%08x", addr, agent[balance]))
		skynet.send(agent[balance], "lua", id)
		balance = balance + 1
		if balance > #agent then
			balance = 1
		end
	end)
end)

end
