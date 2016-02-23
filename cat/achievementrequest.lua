local battlerequest = {}
local dc = require "datacenter"
local util = require "util"
local wash = require "wash"

local send_package
local send_request

local REQUEST = {}
local RESPONSE = {}
local SUBSCRIBE = {}
local client_fd

local game
local user

function REQUEST:login(u)
	-- body
	user = u
end

function REQUEST:logout()
	-- body
	user = nil
end

function REQUEST:achievement()
	-- body
	-- 1 not online
	-- 2
	local ret = {}
	if not user then
		ret.errorcode = 1
		ret.msg = "not online"
		return ret
	end
	assert(user)
	local l = {}
	local idx = 1
	for k,v in pairs(game) do
		print(k,v)
	end
	for k,v in pairs(game.g_achievementmgr.__data) do
		local a = {
			csv_id = v.csv_id,
		}
		local rc1 = user.u_achievement_rcmgr:get_by_csv_id(v.csv_id)
		if rc1 then
			a.finished = rc1.finished
			a.reward_collected = (rc1.reward_collected == 1) and true or false
			a.is_unlock = (rc1.is_unlock == 1) and true or false
		end
		local rc2 = user.u_achievementmgr:get_by_csv_id(v.csv_id)
		if rc2 then
			a.finished = rc2.finished
			a.reward_collected = false
			a.is_unlock = (rc2.is_unlock == 1) and true or false
		else
			if v.is_init == 1 then
				local t = v:__serialize()
				t.user_id = user.id
				t.finished = 0         -- [0, 100]
				t.reward_collected = 1
				t.is_unlock = 1
				local achievement = user.u_achievementmgr.create(t)
				user.u_achievementmgr:add(achievement)
				achievement:__insert_db()
				a.finished = 0
				a.reward_collected = false
				a.is_unlock = false
				wash.raise_achievement(v.type, user, game)
			end
		end
		if a.finished == nil then
			a.finished = 0
		end
		if a.reward_collected == nil then
			a.reward_collected = false
		end
		if a.is_unlock == nil then
			a.is_unlock = false
		end
		
		l[idx] = a
		idx	= idx + 1
	end
	ret.errorcode = 0
    ret.msg = "this is all achievemtn."
    ret.achis = l
    return ret
end

function REQUEST:achievement_reward_collect()
	-- body
	-- 1 not online
	local ret = {}
	if not user then
		ret.errorcode = 1
		ret.msg = "not online"
		return ret
	end
	assert(user)
	local a = user.u_achievement_rcmgr:get_by_csv_id(self.csv_id)
	if a and a.finished == 100 and a.reward_collected == 0 then
		a.collected = 1
		a:__update_db({"reward_collected"})
		local a_src = game.g_achievementmgr:get_by_csv_id(a.csv_id)
		assert(a_src)
		if a_src.type == 2 then
			local csv_id1 = string.gsub(a_src.reward, "(%d*)%*(%d*)", "%1")
			local num1 = string.gsub(a_src.reward, "(%d*)%*(%d*)", "%2")
			local prop = user.u_propmgr:get_by_csv_id(csv_id1)
			if prop then
				prop.num = prop.num + num1
				prop:__update_db({"num"})
			else
				prop = game.g_propmgr:get_by_csv_id(csv_id1)
				prop.user_id = user.id
				prop.num = num1
				prop = user.u_propmgr.create(prop)
				prop:__insert_db()
			end
		end
		ret.errorcode = 0
		ret.msg = "yes"
		return ret
	end
	ret.errorcode = 2
	ret.msg = "no"
	return ret
end

function RESPONSE:abc()
	-- body
end

function battlerequest.start(conf, s_r, g, ...)
	-- body
	print("****************")
	client_fd = conf.client
	send_request = a_r
	game = g
	send_package = util.send_package
end

function battlerequest.disconnect()
	-- body
end

battlerequest.REQUEST = REQUEST
battlerequest.RESPONSE = RESPONSE
battlerequest.SUBSCRIBE = SUBSCRIBE
return battlerequest
