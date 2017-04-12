package.path = "./../../lualib/?.lua;" .. package.path
local skynet = require "skynet"
require "skynet.manager"
local log = require "log"
local query = require "query"
local leaderboard = require "leaderboard"
local assert = assert

local users = {}
local ld 

local function comp(_1, _2, ... )
	-- body
	if _1.key > _2.key then
		return 1
	elseif _1.key == _2.key then
		return 0
	elseif _1.key == _2.key then
		return -1
	end
end

local function comp_u(u1, u2, ... )
	-- body
	return comp(u1.key, u2.key)
end

local CMD = {}

function CMD.login(uid, agent, key, ... )
	-- body
	local u = users[uid]
	if u then
		u.agent = agent
		u.key = key
	else
		u = {
			uid = uid,
			agent = agent,
			key = key
		}
		users[uid] = u
		ld:push(u)
	end
end

function CMD.push(uid, key)
	-- body
	local u = users[uid]
	if u then
		u.key = key
	else
		assert(false)
	end
	ld:sort()
	return ld:bsearch(u)
end

function CMD.bsearch(uid, ... )
	-- body
	local u = users[uid]
	return ld:bsearch(u)
end

function CMD.range(start, stop)
	-- body
	return ld:range(start, stop)
end

function CMD.nearby(rank)
	-- body
	return ld:nearby(rank)
end

skynet.start(function ()
	-- body
	skynet.dispatch("lua", function(_,_, cmd, subcmd, ...)
		local f = CMD[cmd]
		if f then
			local r = f(subcmd, ... )
			if r then
				skynet.ret(skynet.pack(r))
			end
		else
			log.error(string.format("command %s is wrong", cmd))
		end
	end)
	ld = leaderboard.new(100, comp_u)
	skynet.register ".LEADERBOARD"
end)