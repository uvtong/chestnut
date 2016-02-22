local battlerequest = {}
local dc = require "datacenter"
local util = require "util"

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
	print("****************************achievement")
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
		local rc = user.u_achievement_rcmgr:get_by_csv_id(v.csv_id)
		if rc then
			a.finished = rc.finished
			a.reward_collected = rc.reward_collected and true or false
		end
		rc = user.u_achievementmgr:get_by_csv_id(v.csv_id)
		if rc then
			a.finished = rc.finished
			a.reward_collected = false
		end
		l[idx] = a
		idx	= idx + 1
	end
	-- send_achi(2, 40)
	ret.errorcode = 0
    ret.msg = "yes"
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
