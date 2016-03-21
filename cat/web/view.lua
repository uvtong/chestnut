package.path = "../cat/?.lua;../cat/lualib/?.lua;../cat/luaclib/?.so;" .. package.path
local skynet = require "skynet"
require "skynet.manager"
local util = require "util"
local json = require "json"
local errorcode = require "errorcode"
local template = require "resty.template"
template.caching(true)
template.precompile("index.html")

local VIEW = {}

local function path( filename )
	-- body
	assert(type(filename) == "string")
	return "../cat/web/templates/" .. filename
end

function VIEW.index()
	-- body
	local R = {}
	function R:__get()
		-- body
		-- local query = self.query
		--for i = 1 , 100 do
		--end
		local func = template.compile( path( "index.html" ) )
		local r = func { message = "hello, world."}
		return r
	end
	function R:__post()
		-- body
		-- local body = self.body
		
				--skynet.send(".channel", "lua", "fire", 1, {head="sljd", content="jksldfj", })
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
		return func { message = "EMAIL"}
	end
	function R:__post()
		-- body
		-- local body = self.body
		for k,v in pairs(self.body) do
			print(k,v, type(v))
		end
		local send_type = tonumber(self.body["send_type"])
		local c = {}
		c["type"] = tonumber(self.body["type"])  -- 1 or 2
		c["title"] = self.body["title"]
		c["content"] = self.body["content"]
		c["itemsn1"] = tonumber(self.body["itemsn1"])
		c["itemnum1"] = tonumber(self.body["itemnum1"])
		c["itemsn2"] = tonumber(self.body["itemsn2"])
		c["itemnum2"] = tonumber(self.body["itemnum2"])
		c["itemsn3"] = tonumber(self.body["itemsn3"])
		c["itemnum3"] = assert(tonumber(self.body["itemnum3"]))
		c["iconid"] = assert(tonumber(self.body["iconid"]))
		local receiver = tonumber(self.body["receiver"])
		if send_type == 1 then
			skynet.send(".channel", "lua", "send_email_to_group", c, {{ uid = receiver }})
			local ret = {}
			ret.errorcode = errorcode[1].code
			ret.msg = errorcode[1].msg
			return json.encode(ret)
		elseif send_type == 2 then
			-- assert(false)
			skynet.send(".channel", "lua", "send_public_email_to_all", c)
			local ret = {}
			ret.errorcode = errorcode[1].code
			ret.msg = errorcode[1].msg
			return json.encode(ret)
		end
	end
	function R:__file()
		-- body
		-- local file = self.file
		print(self.file)
	end
	return R
end

function VIEW.props()
	-- body
	local R = {}
	function R:__get()
		-- body
		-- local query = self.query
		local users = skynet.call(util.random_db(), "lua", "command", "select_and", "users")
		for i,v in ipairs(users) do
			for kk,vv in pairs(v) do
				print(kk,vv)
			end
		end
		local func = template.compile(path("props.html"))
		return func { message = "fill in the blank text.", users = users }
	end
	function R:__post()
		-- body
		-- local body = self.body
		local uaccount = self.body["uaccount"]
		local csv_id = tonumber(self.body["csv_id"])
		local num = tonumber(self.body["num"])
		if not csv_id and not num then
			local ret = {
				ok = 0,
				msg = "failture",
			}
			return json.encode(ret)
		end
		local user = skynet.call(util.random_db(), "lua", "command", "select_user", { uaccount = uaccount})
		print(user.id, csv_id, num)
		skynet.send(util.random_db(), "lua", "command", "insert_prop", user.id, csv_id, num)
		local ret = {
			ok = 1,
			msg = "send succss."
		}
		return json.encode(ret)
	end
	function R:__file()
		-- body
		-- local file = self.file
		print(self.file)
	end
	return R
end

function VIEW.equipments()
	-- body
	local R = {}
	function R:__get()
		-- body
		-- local query = self.query
		local users = skynet.call(util.random_db(), "lua", "command", "select_and", "users")
		local func = template.compile(path("equipments.html"))
		return func { message = "fill in the blank text.", users = users }
	end
	function R:__post()
		-- body
		-- local body = self.body
		if self.body["cmd"] == "user" then
			local uaccount = self.body["uaccount"]
			local user = skynet.call(util.random_db(), "lua", "command", "select_user", { uaccount = uaccount})
			local achievements = skynet.call(util.random_db(), "lua", "command", "select_and", "equipments", { user_id = user.id })
			local ret = {
				errorcode = 0,
				msg = "succss",
				achievements = achievements
			}
			return json.encode(ret)
		elseif self.body["cmd"] == "equip" then
			local user = skynet.call(util.random_db(), "lua", "command", "select_user", { uaccount = uaccount})
			skynet.send(util.random_db(), "lua", "command", "insert", { user_id = user.id, achievement_id = achievement_id, level = level})
			local ret = {
				ok = 1,
				msg = "send succss."
			}
			return json.encode(ret)
		end
	end
	function R:__file()
		-- body
		-- local file = self.file
		print(self.file)
	end
	return R
end

return VIEW
