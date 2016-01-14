-- local T = require "web.template"
package.path = "../cat/?.lua;../cat/lualib/?.lua;" .. package.path
local template = require "resty.template"

local VIEW = {}

local function wrap( code, method , t, ... )
	-- body
	if method == "GET" then
		local query = {...}
		return code, t["_get"](query)
	elseif method == "POST" then
		local arg = { ... }
		header = arg[1]
		body = arg[2]
		return code, t["_post"](header, body)
	end
end

local function filename( f )
	-- body
	assert(type(f) == "string")
	return "./../cat/web/templates/" .. f
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
	end
	return wrap(code, method, { _get = get, _post = post }, ...)
end

function VIEW.user( code, method, ... )
	-- body
	local function get( query )
		-- body
		-- return T["index"]()
		return T.render("user.html")
	end
	local function post( header, body )
		-- body
	end
	return wrap(code, method, { _get = get, _post = post }, ...)
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