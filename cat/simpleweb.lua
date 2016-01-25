package.path = "../cat/?.lua;" .. package.path
local skynet = require "skynet"
local socket = require "socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
local table = table
local string = string

local urls = require "web.urls"

local mode = ...

if mode == "agent" then

local function response(id, ...)
	local ok, err = httpd.write_response(sockethelper.writefunc(id), ...)
	if not ok then
		-- if err == sockethelper.socket_error , that means socket closed.
		skynet.error(string.format("fd = %d, %s", id, err))
	end
end

local function route( id, code, url, method, header, body )
	-- body
	if false then
		print("id:", type(id), id)
		print("code:", type(code), code)
		print("url:", type(url), url)
		print("method:", type(method), method)
		print("header:", type(header), header)
		print("body:", type(body), body)
	end	
	
	if method == "GET" then
		local path, query = urllib.parse(url)
		local suffix = string.gsub(path, "(.*)/[^/]*%.(%w+)", "%2")
		-- print(suffix)
		if suffix == "js" or suffix == "css" then
			path = "./../cat/web/statics" .. path
			print(path)
			local f = io.open(path, "r")
			local ret = f:read()
			f:close()
			print(ret)
			return ret
		else
			local k = urls[path]
			if k then
				return response(id, view[k](code, method, query))
			else
				return response(id, code, "don't have mathcing url.")	
			end
		end
	elseif method == "POST" then
		-- local path, query = urllib.parse(url)
		for k,v in pairs(urls) do
			if string.match(url, k) then
				return response(id, view[v](code, method, header, body))
			end
		end
		return response(id, code, "don't have mathcing url.")
	else
		return response(id, code, "don't support mathcing method.")
	end
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
