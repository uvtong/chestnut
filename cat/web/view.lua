-- local T = require "web.template"
package.path = "../cat/?.lua;../cat/lualib/?.lua;" .. package.path
local skynet = require "skynet"
require "skynet.manager"
local template = require "resty.template"

local VIEW = {}

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

local function parse_file( boundary, body )
	-- body
	local last = body
	function getline( s )
		-- body
		local p = string.find(s, "\n")	
		local r = string.sub(s, 1, p - 1)
		last = string.sub(s, p + 1)
		return r
	end
	
end

-- analysis header, judge post or file.
local function parse_header( header, body )
	-- body
	if string.match(header["content-type"], "^multipart/form-data") ~= nil then
		local p = string.find(header["content-type"], ";")
		local s = string.sub(header["content-type"], p + 2)
		p = string.find(s, "=")
		local boundary = string.sub(s, p + 1)
		return "file", parse_file(boundary, body)
	else
		return "post", parse(body)
	end
end

local function wrap( code, method , t, ... )
	-- body
	if method == "GET" then
		local query = {...}
		return code, t["_get"](query)
	elseif method == "POST" then
		local arg = { ... }
		local header = arg[1]
		local body = arg[2]
		local flag, body = parse_header(header, body)
		if flag == 'file' then 
			return code , t["_file"](header, body)
		else
			-- return code, t["_post"](body), header
			return code, t["_post"](header, body)
		end
	end
end

local function filename( f )
	-- body
	assert(type(f) == "string")
	return "./../cat/web/templates/" .. f
end

local function db()
	-- body
	local r = math.random() % 5 + 1
	local name = string.format("db%d", r)
	return skynet.localname(name)
end

function VIEW._(code, method, ... )
	-- body
	local function get( query )
		-- body
		local func = template.compile(filename("index.html"))
		local r = func { message = "hello, world."}
		return r
	end
	local function post( header, body )
		-- body
		return "hello, world"
	end
	return wrap(code, method, { _get = get, _post = post }, ...)
end

function VIEW.user( code, method, ... )
	-- body
	local function get( query )
		-- body
		local func = template.compile(filename("user.html"))
		local r = func()
		return r	
	end
	local function post( header, body )
		-- body
		local t = parse(body)
		for k,v in pairs(t) do
			print(k,v)
		end
		-- skynet.call(db(), "command", "create_user", )
		return "sunnkajfla"
	end
	return wrap(code, method, { _get = get, _post = post }, ...)
end

function VIEW.role( code, method, ... )
	-- body
	local function get( query )
		-- body
		local func = template.compile(filename("role.html"))
		local r = func()
		return r	
	end
	local function file( header, body )
		-- body
		print "i'm sep------------------------------------------"
		for k,v in pairs(header) do
			print(k,v)
		end
		print "i'm sep------------------------------------------"
		print(body)
		print "i'm sep------------------------------------------"
		return "hello world."
	end 
	return wrap(code, method, { _get = get, _file = file }, ...)
end

function VIEW._admin(id, code, url, method, header, body )
	-- body
	assert(type(header) == "table")
	local tmp = {}
	if header.host then
	table.insert(tmp, string.format("host: %s", header.host))
	end
	local path, query = urllib.parse(url)
	table.insert(tmp, string.format("path: %s", path))
	if query then
		local q = urllib.parse_query(query)
		for k, v in pairs(q) do
			table.insert(tmp, string.format("query: %s= %s", k,v))
		end
	end
	table.insert(tmp, "-----header----")
	for k,v in pairs(header) do
		table.insert(tmp, string.format("%s = %s",k,v))
	end
	table.insert(tmp, "-----body----\n" .. body)
	return response(id, code, table.concat(tmp,"\n"))
end

return VIEW