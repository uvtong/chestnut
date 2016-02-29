local skynet = require "skynet"
local util = require "util"
local gamemgr = require "models/gamemgr"
local game = gamemgr.create()

local loader = {}

local function load_g_achievement()
	-- body
	assert(game.g_achievementmgr == nil)
	local g_achievementmgr = require "models/g_achievementmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_achievement")
	for i,v in ipairs(r) do
		local t = g_achievementmgr.create(v)
		g_achievementmgr:add(t)
	end
	for k,v in pairs(g_achievementmgr) do
		print(k,v)
	end
	game.g_achievementmgr = g_achievementmgr
end

local function load_g_checkpoint()
	-- body
	assert(game.g_checkpointmgr == nil)
	local g_checkpointmgr = require "models/g_checkpointmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_checkpoint")
	for i,v in ipairs(r) do
		local t = g_checkpointmgr.create(v)
		g_checkpointmgr:add(t)
	end
	game.g_achievementmgr = g_achievementmgr
end

local function load_g_equipment()
	-- body
	assert(game.g_equipmentmgr == nil)
	local g_equipmentmgr = require "models/g_equipmentmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_equipment")
	for i,v in ipairs(r) do
		local t = g_equipmentmgr.create(v)
		g_equipmentmgr:add(t)
	end
	game.g_equipmentmgr = g_equipmentmgr
end

local function load_g_goods()
	-- body
	assert(game.g_goodsmgr == nil)
	local g_goodsmgr = require "models/g_goodsmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_goods")
	for i,v in ipairs(r) do
		local t = g_goodsmgr.create(v)
		g_goodsmgr:add(t)
	end
	game.g_goodsmgr = g_goodsmgr
end

local function load_g_goods_refresh_cost()
	-- body
	assert(game.g_goods_refresh_costmgr == nil)
	local g_goods_refresh_costmgr = require "models/g_goods_refresh_costmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_goods_refresh_cost")
	for i,v in ipairs(r) do
		local t = g_goods_refresh_costmgr.create(v)
		g_goods_refresh_costmgr:add(t)
	end
	game.g_goods_refresh_costmgr = g_goods_refresh_costmgr
end

local function load_g_prop()
	-- body
	assert(game.g_propmgr == nil)
	local g_propmgr = require "models/g_propmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_prop")
	for i,v in ipairs(r) do
		local t = g_propmgr.create(v)
		g_propmgr:add(t)
	end
	game.g_propmgr = g_propmgr
end

local function load_g_recharge()
	-- body
	assert(game.g_rechargemgr == nil)
	local g_rechargemgr = require "models/g_rechargemgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_recharge")
	for i,v in ipairs(r) do
		local t = g_rechargemgr.create(v)
		g_rechargemgr:add(t)
	end
	game.g_rechargemgr = g_rechargemgr
end

local function load_g_recharge_vip_reward()
	-- body
	assert(game.g_recharge_vip_rewardmgr == nil)
	local g_recharge_vip_rewardmgr = require "models/g_recharge_vip_rewardmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_recharge_vip_reward")
	for i,v in ipairs(r) do
		local t = g_recharge_vip_rewardmgr.create(v)
		g_recharge_vip_rewardmgr:add(t)
	end
	game.g_recharge_vip_rewardmgr = g_recharge_vip_rewardmgr
end

local function load_g_role()
	-- body
	assert(game.g_rolemgr == nil)
	local g_rolemgr = require "models/g_rolemgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_role")
	for i,v in ipairs(r) do
		local t = g_rolemgr.create(v)
		g_rolemgr:add(t)
	end
	game.g_rolemgr = g_rolemgr
end

local function load_g_shop()
	-- body
	assert(game.g_shopmgr == nil)
	local g_shopmgr = require "models/g_shopmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_shop")
	for i,v in ipairs(r) do
		local t = g_shopmgr.create(v)
		g_shopmgr:add(t)
	end
	game.g_shopmgr = g_shopmgr
end

local function load_u_achievement(user)
	-- body
	local u_achievementmgr = require "models/u_achievementmgr"
	local addr = util.random_db()
	local r = skynet.call(addr, "lua", "command", "select", "u_achievement", {{ user_id = user.id}})
	for i,v in ipairs(r) do
		local a = u_achievementmgr.create(v)
		u_achievementmgr:add(a)
	end
	user.u_achievementmgr = u_achievementmgr
end

local function load_u_achievement_rc(user)
	-- body
	local u_achievement_rcmgr = require "models/u_achievement_rcmgr"
	local addr = util.random_db()
	local r = skynet.call(addr, "lua", "command", "select", "u_achievement_rc", {{ user_id = user.id}})
	for i,v in ipairs(r) do
		local a = u_achievement_rcmgr.create(v)
		u_achievement_rcmgr:add(a)
	end
	user.u_achievement_rcmgr = u_achievement_rcmgr
end

local function load_u_checkin(user)
	-- body
	assert(user.u_checkinmgr == nil)
	local u_checkinmgr = require "models/u_checkinmgr"
	local addr = util.random_db()
	local r = skynet.call(addr, "lua", "command", "select", "u_checkin", {{ user_id = user.id }})
	for i,v in ipairs(r) do
		local a = u_checkinmgr.create(v)
		u_checkinmgr:add(a)
	end
	user.u_checkinmgr = u_checkinmgr
end

local function load_u_checkpoint(user)
	-- body
	assert(user.u_checkpointmgr == nil)
	local u_checkpointmgr = require "models/u_checkpointmgr"
	local addr = util.random_db()
	local r = skynet.call(addr, "lua", "command", "select", "u_checkpoint", {{ user_id = user.id }})
	for i,v in ipairs(r) do
		local a = u_checkpointmgr.create(v)
		u_checkpointmgr:add(a)
	end
	user.u_checkinmgr = u_checkpointmgr
end

local function load_u_equipment(user)
	-- body
	assert(user.u_equipment == nil)
	local u_equipmentmgr = require "models/u_equipmentmgr"
	local addr = util.random_db()
	local r = skynet.call(addr, "lua", "command", "select", "u_equipment", {{ user_id = user.id}})
	for i,v in ipairs(r) do
		local a = u_equipmentmgr.create(v)
		u_equipmentmgr:add(a)
	end
	user.u_equipmentmgr = u_equipmentmgr
end

local function load_u_prop(user)
	-- body
	local u_propmgr = require "models/u_propmgr"
	local addr = util.random_db()
	local nr = skynet.call(addr, "lua", "command", "select", "u_prop", {{ user_id = user.id }})
	for i,v in ipairs(nr) do
		local prop = u_propmgr.create( v )
		u_propmgr:add(prop)
	end
	user.u_propmgr = u_propmgr
end

local function load_u_role(user)
	-- body
	print("***********************", user.id)
	local u_rolemgr = require "models/u_rolemgr"
	local addr = util.random_db()
	local nr = skynet.call(addr, "lua", "command", "select", "u_role", {{ user_id = user.id }})
	for i,v in ipairs(nr) do
		print("*******************", i)
		
		local role = u_rolemgr.create( v )
		for k,v in pairs(role) do
			print(k,v)
		end
		u_rolemgr:add(role)
	end
	user.u_rolemgr = u_rolemgr
end

local function load_u_purchase_goods(user)
	-- body
	local u_purchase_goodsmgr = require "models/u_purchase_goodsmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "u_purchase_goods", {{ user_id = user.id}})
	for i,v in ipairs(r) do
		local t = u_purchase_goodsmgr.create(v)
		u_purchase_goodsmgr:add(t)
	end
	user.u_purchase_goodsmgr = u_purchase_goodsmgr
end

local function load_u_purchase_reward(user)
	-- body
	local u_purchase_rewardmgr = require "models/u_purchase_rewardmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "u_purchase_reward")
	for i,v in ipairs(r) do
		local t = u_purchase_rewardmgr.create(v)
		u_purchase_rewardmgr:add(t)
	end
	user.u_purchase_rewardmgr = u_purchase_rewardmgr
end

local function load_u_recharge_count(user)
	-- body
	local u_recharge_countmgr = require "models/u_recharge_countmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "u_recharge_count")
	assert(r)
	for i,v in ipairs(r) do
		local t = u_recharge_countmgr.create(v)
		u_recharge_countmgr:add(t)
	end
	user.u_recharge_countmgr = u_recharge_countmgr
end

local function load_u_recharge_record(user)
	-- body
	local u_recharge_recordmgr = require "models/u_recharge_recordmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "u_recharge_record")
	assert(r)
	for i,v in ipairs(r) do
		local t = u_recharge_recordmgr.create(v)
		u_recharge_recordmgr:add(t)
	end
	user.u_recharge_recordmgr = u_recharge_recordmgr
end

local function load_u_recharge_reward(user)
	-- body
	local u_recharge_recordmgr = require "models/u_recharge_rewardmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "u_recharge_reward")
	assert(r)
	for i,v in ipairs(r) do
		local t = u_recharge_recordmgr.create(v)
		u_recharge_recordmgr:add(t)
	end
	user.u_recharge_recordmgr = u_recharge_recordmgr
end

local function load_u_recharge_vip_reward(user)
	-- body
	local u_recharge_vip_rewardmgr = require "models/u_recharge_vip_rewardmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "u_recharge_vip_reward")
	assert(r)
	for i,v in ipairs(r) do
		local t = u_recharge_vip_rewardmgr.create(v)
		u_recharge_vip_rewardmgr:add(t)
	end
	user.u_recharge_vip_rewardmgr = u_recharge_vip_rewardmgr
end

function loader.load_game()
	-- body
	local f = function ()
		-- body
		load_g_achievement()
		load_g_checkpoint()
		load_g_equipment()
		load_g_goods()
		load_g_goods_refresh_cost()
		load_g_prop()
		load_g_recharge()
		load_g_recharge_vip_reward()
		load_g_role()
		load_g_shop()
	end
	skynet.fork(f)
	return game
end

function loader.load_user(user)
	-- body
	load_u_achievement(user)
	load_u_achievement_rc(user)
	load_u_checkin(user)
	load_u_checkpoint(user)
	load_u_equipment(user)
	load_u_prop(user)
	load_u_role(user)
	load_u_purchase_goods(user)
	load_u_purchase_reward(user)
	load_u_recharge_count(user)
	load_u_recharge_record(user)
	load_u_recharge_vip_reward(user)
	return user
end

function loader.load_all()
	-- body
	load_g_achievement()
	return game, user
end

return loader