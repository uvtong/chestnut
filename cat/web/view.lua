package.path = "../cat/?.lua;../cat/lualib/?.lua;" .. package.path
local skynet = require "skynet"
require "skynet.manager"
local template = require "resty.template"
template.caching(true)
template.precompile("index.html")

local VIEW = {}

local function path( filename )
	-- body
	assert(type(filename) == "string")
	return "../cat/web/templates/" .. filename
end

local function db()
	-- body
	local r = math.random() % 5 + 1
	local name = string.format("db%d", r)
	return skynet.localname(name)
end

function VIEW.index()
	-- body
	local R = {}
	function R:__get()
		-- body
		-- local query = self.query
		local func = template.compile(path("index.html"))
		local r = func { message = "hello, world."}
		return r
	end
	function R:__post()
		-- body
		-- local body = self.body
	end
	function R:__file()
		-- body
		-- local file = self.file
	end
	return R
end

function VIEW.user()
	-- body
	local R = {}
	function R:__get()
		-- body
		-- local query = self.query
		local func = template.compile(path("user.html"))
		local r = func()
		return r	
	end
	function R:__post()
		-- body
		-- local body = self.body
	end
	function R:__file()
		-- body
		-- local file = self.file
	end
	return R
end

function VIEW.role()
	-- body
	local R = {}
	function R:__get()
		-- body
		-- local query = self.query
		local func = template.compile(path("role.html"))
		local r = func()
		return r
	end
	function R:__post()
		-- body
		-- local body = self.body
	end
	function R:__file()
		-- body
		-- local file = self.file
		print(self.file)
		return "succss"
	end
	return R
end

function VIEW.email()
	-- body
	local R = {}
	function R:__get()
		-- body
		-- local query = self.query
		local func = template.compile(path("email.html"))
		local r = func()
		return r
	end
	function R:__post()
		-- body
		-- local body = self.body
	end
	function R:__file()
		-- body
		-- local file = self.file
		print(self.file)
	end
	return R
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