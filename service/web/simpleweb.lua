package.path = "./../../service/web/?.lua;./../../service/web/lualib/?.lua;./../../lualib/?.lua;"..package.path
package.cpath = "../lua-cjson/?.so;" .. package.cpath
local skynet = require "skynet"
local socket = require "socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
local urls = require "urls"
local log = require "log"
local pcall = skynet.pcall
local error = skynet.error
local assert = assert
local table = table
local string = string
local errorcode = require "errorcode"
local crypt = require "crypt"
local mime = require "mime"
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

local function handle_static(path, ... )
	-- body
	local res
	if false and static_cache[path] then
		res = assert(static_cache[path])
	else
		local fpath = "../../service/web/statics" .. path
		local fd = io.open(fpath, "r")
		if fd == nil then
			error(string.format("fpath is wrong, %s", fpath))
		else
			local r = fd:read("a")
			fd:close()
			static_cache[path] = r
			res = r
		end
	end
	return res
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
	error(string.format("simpleweb path: %s", path))
	if method == "GET" then
		-- is statics
		local ok, result = mime.handle_static(path, header, query, handle_static)
		if ok then
			bodyfunc = result
		else
			if string.match(path, "^/[%w%./-]+%.%w+") then
				bodyfunc = handle_static(path)
			else
				local rsp = false
				for k,v in pairs(urls) do
					if string.match(path, k) then
						rsp = true
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
				if rsp then	
					if not bodyfunc then
						local ret = {}
						ret.errorcode = errorcode.E_FAIL
						return ret
					end	
				else
					skynet.error("no matching url")
					statuscode = 500
				end
			end
		end
	elseif method == "POST" then
		local rsp = false
		for k,v in pairs(urls) do
			if string.match(path, k) then
				rsp = true
				local function post_handler(m, b, ... )
					-- body
					local args = {}
					args.method = m
					args.body = b
					local ok, res = pcall(v, args)
					return ok, res
				end
				local ok, result = mime.handle_post(path, header, body, post_handler)
				if ok then
					skynet.error(result)
					bodyfunc = result
				else
					skynet.error(result)
					statuscode = 500
				end
				break
			end
		end
		if rsp then
		else
			skynet.error("no matching url:", path)
		end
	else
		error "now don't support others method"
		statuscode = 301
		bodyfunc = "404"
		headerd["Location"] = "/404"
	end

	if type(bodyfunc) == "table" then
		assert(false)
	elseif type(bodyfunc) == "string" then
	elseif type(bodyfunc) == "nil" then
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
