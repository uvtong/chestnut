local skynet = require "skynet"
local dc = require "datacenter"
local sd = require "sharedata"
local errorcode = require "errorcode"
local const = require "const"
local util = require "util"
local super = require "module"
local cls = class("rechargemodule", super)

function cls:ctor(env, ... )
	-- body
	self._env = env
end

function cls:recharge_vip_reward_all(args)
	-- body
	local ret = {}
	local user = self._env:get_user()
	local game = self._env:get_game()
	local modelmgr = self._env:get_modelmgr()
	local u_recharge_vip_rewardmgr = modelmgr:get_u_recharge_vip_rewardmgr()
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(user)
	local a = skynet.call(game, "lua", "query_g_recharge_vip_reward")
	local l = {}
	for k,v in pairs(a) do
		local item = {}
		item.vip   = v.vip
		item.props = {}
		local r = util.parse_text(v.rewared, "%d+%*%d+%*?", 2)
		for i,vv in ipairs(r) do
			table.insert(item.props, { csv_id=vv[1], num=vv[2]})
		end
		local reward = user.u_recharge_vip_rewardmgr:get_by_vip(v.vip)
		if reward then
			item.collected = (reward.collected == 1) and true or false
			item.purchased = (reward.purchased == 1) and true or false
		else
			local tmp = {}
			tmp.user_id = user:get_field("csv_id")
			tmp.vip = v.vip
			tmp.collected = 0
			tmp.purchased = 0
			tmp.id = genpk_2(tmp.user_id, tmp.vip)
			local entity = u_recharge_vip_rewardmgr:create_entity(tmp)
			u_recharge_vip_rewardmgr:add(entity)
			entity:update_db()
			item.collected = false
			item.purchased = false
		end
		table.insert(l, item)
	end
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.reward = l
	return ret
end

return cls