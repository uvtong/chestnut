local skynet = require "skynet"
require "skynet.manager"
local log = require "log"
local query = require "query"
local noret = {}
local users = {}

local cmd = {}

function cmd.start( ... )
	-- body
	return true
end

function cmd.close( ... )
	-- body
	return true
end

function cmd.kill( ... )
	-- body
	skynet.exit()
end

function cmd.login(uid, agent, ... )
	-- body
	users[uid] = agent
	return noret
end

function cmd.logout(uid, ... )
	-- body
end

function cmd.afk(name, ... )
	-- body
	users[name] = nil
	return true
end

function cmd.add_rcard(name, num, ... )
	-- body
	-- 0 success
	-- 1 no one
	-- 2 num is wrong
	local number = math.tointeger(num)
	if number <= 0 then
		return 2
	end
	local agent = users[name]
	if agent then
		skynet.send(agent, "lua", "add_rcard", number)
	else
		local sql = string.format("select * from tg_users where name = %d", name)
		local res = query.select("tg_users", sql)
		if #res > 0 then
			local rcard = res[1].rcard
			rcard = rcard + number
			sql = string.format("update tg_users set rcard=%d where name=%d", rcard, name)
			query.update("tg_users", sql)
			return 0
		else
			return 1
		end
	end
end

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function (_, source, command, ... )
		-- body
		local f = assert(cmd[command])
		local r = f( ... )
		if r ~= noret then
			skynet.retpack(r)
		end
	end)
	skynet.register ".ONLINE_MGR"
end)