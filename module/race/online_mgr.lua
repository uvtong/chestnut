local skynet = require "skynet"
require "skynet.manager"
local log = require "skynet.log"
local query = require "query"
local context = require "context"
local errorcode = require "errorcode"

local ctx = context.new()
local noret = {}
local users = {}
local subusers = {}

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

function cmd.login(uid, subid, agent, ... )
	-- body
	assert(uid and subid and agent)
	local u = {}
	u.uid = uid
	u.subid = subid
	u.agent = agent

	users[uid] = u
	subusers[subid] = u

	return true
end

function cmd.logout(uid, subid, ... )
	-- body
	local u = users[uid]
	assert(u.subid == subid)
	users[uid] = nil
	subusers[subid] = nil	
end

function cmd.authed(uid, subid, fd, ... )
	-- body
	assert(uid and subid and fd)
	local u = users[uid]
	assert(u.subid == subid, string.format("u.subid = %d, subid = %d", u.subid, subid))
	u.fd = fd

	return true
end

function cmd.afk(uid, subid, ... )
	-- body
	local u = users[uid]
	assert(u.subid == subid)
	u.fd = nil
	
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

function cmd.toast1(args, ... )
	-- body
	local res = {}
	res.errorcode = errorcode.SUCCESS
	res.text = "hello toast1"
	return res
end

function cmd.toast2(args, ... )
	-- body
	local res = {}
	res.errorcode = errorcode.SUCCESS
	res.text = "hello toast2"
	return res
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