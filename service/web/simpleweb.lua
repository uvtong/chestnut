package.path = "./../../service/web/?.lua;./../../service/web/lualib/?.lua;./../../lualib/?.lua;"..package.path
package.cpath = "../lua-cjson/?.so;" .. package.cpath
local skynet = require "skynet"
local socket = require "socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
local urls = require "urls"
local json = require "cjson"
local log = require "log"
local pcall = skynet.pcall
local error = skynet.error
local assert = assert
local table = table
local string = string
local static_cache = {}

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
		return 
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

	-- headerd
	local headerd = {}
	-- for k,v in pairs(header) do
	-- 	headerd[k] = v
	-- end
	-- if header.host then
	-- 	table.insert(headerd, string.format("host: %s", header.host))
	-- end
	-- table.insert(headerd, string.format("connection: %s", "close"))

	-- body
	local bodyfunc
	local path, query = urllib.parse(url)
	error(string.format("simpleweb, %s", path))
	if method == "GET" then
		if string.match(path, "^/[%w%./-]+%.%w+") then
			if false and static_cache[path] then
				bodyfunc = assert(static_cache[path])
			else
				local fpath = "../../service/web/statics" .. path
				local fd = io.open(fpath, "r")
				if fd == nil then
					log.error(string.format("fpath is wrong, %s", fpath))
				else
					local ret = fd:read("a")
					fd:close()
					bodyfunc = ret	
					static_cache[path] = bodyfunc
				end
			end
		else
			for k,v in pairs(urls) do
				if string.match(path, k) then
					local q = urllib.parse_query(query)
					local args = {}
					args.method = "get"
					args.query = q
					local ok, res = pcall(v, args)
					if ok then
						bodyfunc = res
					else
						statuscode = 500
						bodyfunc = string.fromat("error from server %s", res)
					end
					break
				end
			end
			if not bodyfunc then
				assert(false)
				log.error("no matching url")
				statuscode = 500
				bodyfunc = "error"
			end
		end
	elseif method == "POST" then
		local m, c = parse_header(header, body)
		for k,v in pairs(urls) do
			if string.match(path, k) then
				if m == "file" then
					local args = {}
					args.method = m
					args.file = c
					local ok, res = pcall(v, args)
					if ok then
						bodyfunc = res
					else
						statuscode = 500
						-- bodyfunc = string.fromat("error from server %s", res)
					end
				elseif m == "post" then
					local args = {}
					args.method = m
					args.body = c
					local ok, res = pcall(v, args)
					if ok then
						bodyfunc = res
					else
						statuscode = 500
						-- bodyfunc = string.fromat("error from server %s", res)
					end
				else
					assert(false)
				end
				break
			end
		end
		if bodyfunc == nil then
			assert(false)
			skynet.error("no matching url.")
			statuscode = 500
		end
	else
		error "now don't support others method"
		statuscode = 301
		bodyfunc = "404"
		headerd["Location"] = "/404"
	end
	if type(bodyfunc) == "table" then
		bodyfunc = json.encode(bodyfunc)
		assert(type(bodyfunc) == "string")
	elseif type(bodyfunc) == "string" then
	elseif type(bodyfunc) == "function" then
		assert(false)
	else
		error(string.format("path: %s, now don't support others type: %s.", path, type(bodyfunc)))
		assert(false, "you should check these .")
		statuscode = 500
	end
	error("simpleweb", statuscode)
	response(id, statuscode, bodyfunc, headerd)
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
				route(id, code, url, method, header, body)				
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
