local skynet = require "skynet"
local util = require "util"
local query = require "query"

local function load_g_achievement(game)
	-- body
	assert(game.g_achievementmgr == nil)
	local cls = require "models/g_achievementmgr"
	local g_achievementmgr = cls.new()
	for k,v in pairs(g_achievementmgr) do
		print(k,v)
	end
	game.g_achievementmgr = cls.new()
	game.g_achievementmgr:load_db()
end

local function load_g_ara_pts(game)
	-- body
	assert(game.g_ara_ptsmgr == nil)
	local g_ara_ptsmgr = require "models/g_ara_ptsmgr"
	game.g_ara_ptsmgr = g_ara_ptsmgr()
	game.g_ara_ptsmgr("load_db")
	
end

local function load_g_ara_rnk_rwd(game)
	-- body
	assert(game.g_ara_rnk_rwdmgr == nil)
	local g_ara_rnk_rwdmgr = require "models/g_ara_rnk_rwdmgr"
	game.g_ara_rnk_rwdmgr = g_ara_rnk_rwdmgr()
	game.g_ara_rnk_rwdmgr("load_db")
end

local function load_g_ara_tms(game)
	-- body
	assert(game.g_ara_tmsmgr == nil)
	local g_ara_tmsmgr = require "models/g_ara_tmsmgr"
	game.g_ara_tmsmgr = g_ara_tmsmgr()
	game.g_ara_tmsmgr("load_db")
end

local function load_g_checkin(game)
	assert( nil == game.g_checkinmgr )
	local g_checkinmgr = require "models/g_checkinmgr"
	game.g_checkinmgr = g_checkinmgr()
	game.g_checkinmgr("load_db")
end

local function load_g_checkin_total(game)
	assert( nil == game.g_checkin_totalmgr )
	local g_checkin_totalmgr = require "models/g_checkin_totalmgr"
	game.g_checkin_totalmgr = g_checkin_totalmgr()
	game.g_checkin_totalmgr("load_db")
end

local function load_g_checkpoint(game)
	-- body
	assert(game.g_checkpointmgr == nil)
	local g_checkpointmgr = require "models/g_checkpointmgr"
	game.g_checkpointmgr = g_checkpointmgr()
	game.g_checkpointmgr("load_db")
end

local function load_g_checkpoint_chapter(game)
	-- body
	assert(game.g_checkpoint_chaptermgr == nil)
	local g_checkpoint_chaptermgr = require "models/g_checkpoint_chaptermgr"
	game.g_checkpoint_chaptermgr = g_checkpoint_chaptermgr()
	game.g_checkpoint_chaptermgr("load_db")	
end

local function load_g_config(game)
	-- body
	assert(game.g_configmgr == nil)
	local g_configmgr = require "models/g_configmgr"
	game.g_configmgr = g_configmgr()
	game.g_configmgr("load_db")
end

local function load_g_daily_task(game)
	assert( nil == game.g_daily_taskmgr )
	local g_daily_taskmgr = require "models/g_daily_taskmgr"
	game.g_daily_taskmgr = g_daily_taskmgr()
	game.g_daily_taskmgr("load_db")
end

local function load_g_draw_role(game)
	assert( nil == game.g_draw_rolemgr )
	local g_draw_rolemgr = require "models/g_draw_rolemgr"
	game.g_draw_rolemgr = g_draw_rolemgr()
	game.g_draw_rolemgr("load_db")
end

local function load_g_drawcost(game)
	assert( nil == game.g_drawcostmgr )
	local g_drawcostmgr = require "models/g_drawcostmgr"
	game.g_drawcostmgr = g_drawcostmgr()
	game.g_drawcostmgr("load_db")
end

local function load_g_equipment(game)
	-- body
	assert(game.g_equipmentmgr == nil)
	local g_equipmentmgr = require "models/g_equipmentmgr"
	game.g_equipmentmgr = g_equipmentmgr()
	game.g_equipmentmgr("load_db")
end

local function load_g_equipment_effect(game)
	-- body
	assert(game.g_equipment_effectmgr == nil)
	local g_equipment_effectmgr = require "models/g_equipment_effectmgr"
	game.g_equipment_effectmgr = g_equipment_effectmgr()
	game.g_equipment_effectmgr("load_db")
end 

local function load_g_equipment_enhance(game)
	-- body
	assert(game.g_equipment_enhancemgr == nil)
	local g_equipment_enhancemgr = require "models/g_equipment_enhancemgr"
	game.g_equipment_enhancemgr = g_equipment_enhancemgr();
	game.g_equipment_enhancemgr("load_db")	
end

local function load_g_goods(game)
	-- body
	assert(game.g_goodsmgr == nil)
	local g_goodsmgr = require "models/g_goodsmgr"
	game.g_goodsmgr = g_goodsmgr()
	game.g_goodsmgr("load_db")
end

local function load_g_goods_refresh_cost(game)
	-- body
	assert(game.g_goods_refresh_costmgr == nil)
	local g_goods_refresh_costmgr = require "models/g_goods_refresh_costmgr"
	game.g_goods_refresh_costmgr = g_goods_refresh_costmgr()
	game.g_goods_refresh_costmgr("load_db")
end

local function load_g_kungfu(game)
	-- body
	assert(game.g_kungfumgr == nil)
	local g_kungfumgr = require "models/g_kungfumgr"
	game.g_kungfumgr = g_kungfumgr()
	game.g_kungfumgr("load_db")
end

local function load_g_lilian_event(game)
	-- body
	assert(game.g_lilian_eventmgr == nil)
	local g_lilian_eventmgr = require "models/g_lilian_eventmgr"
	game.g_lilian_eventmgr = g_lilian_eventmgr()
	game.g_lilian_eventmgr("load_db")
end

local function load_g_lilian_invitation(game)
	-- body
	assert(game.g_lilian_invitationmgr == nil)
	local g_lilian_invitationmgr = require "models/g_lilian_invitationmgr"
	game.g_lilian_invitationmgr = g_lilian_invitationmgr()
	game.g_lilian_invitationmgr("load_db")
end

local function load_g_lilian_level(game)
	-- body
	assert(game.g_lilian_levelmgr == nil)
	local g_lilian_levelmgr = require "models/g_lilian_levelmgr"
	game.g_lilian_levelmgr = g_lilian_levelmgr()
	game.g_lilian_levelmgr("load_db")
end

local function  load_g_lilian_phy_power(game)
	-- body
	assert( nil == game.g_lilian_phy_powermgr )
	local g_lilian_phy_powermgr = require "models/g_lilian_phy_powermgr"
	game.g_lilian_phy_powermgr = g_lilian_phy_powermgr()
	game.g_lilian_phy_powermgr("load_db")
end

local function load_g_lilian_quanguan(game)
	-- body
	assert(game.g_lilian_quanguanmgr == nil)
	local g_lilian_quanguanmgr = require "models/g_lilian_quanguanmgr"
	game.g_lilian_quanguanmgr = g_lilian_quanguanmgr
	game.g_lilian_quanguanmgr("load_db")
end

local function load_g_mainreward(game)
	assert( nil == game.g_mainrewardmgr )
	local g_mainrewardmgr = require "models/g_mainrewardmgr"
	game.g_mainrewardmgr = g_mainrewardmgr()
	game.g_mainrewardmgr("load_db")
end

local function load_g_monster(game)
	assert(nil == game.g_monstermgr)
	local g_monstermgr = require "models/g_monstermgr"
	game.g_monstermgr = g_monstermgr()
	game.g_monstermgr("load_db")
end 

local function load_g_prop(game)
	-- body
	assert(game.g_propmgr == nil)
	local g_propmgr = require "models/g_propmgr"
	game.g_propmgr = g_propmgr()
	game.g_propmgr("load_db")
end

local function load_g_property_pool(game)
	-- body
	assert(game.g_property_poolmgr == nil)
	local g_property_poolmgr = require "models/g_property_poolmgr"
	game.g_property_poolmgr = g_property_poolmgr()
	game.g_property_poolmgr("load_db")
end

local function load_g_property_pool_second(game)
	-- body
	assert(game.g_property_pool_secondmgr == nil)
	local g_property_pool_secondmgr = require "models/g_property_pool_secondmgr"
	game.g_property_pool_secondmgr = g_property_pool_secondmgr()
	game.g_property_pool_secondmgr("load_db")	
end 

local function load_g_recharge(game)
	-- body
	assert(game.g_rechargemgr == nil)
	local g_rechargemgr = require "models/g_rechargemgr"
	game.g_rechargemgr = g_rechargemgr()
	game.g_rechargemgr("load_db")
end

local function load_g_recharge_vip_reward(game)
	-- body
	assert(game.g_recharge_vip_rewardmgr == nil)
	local g_recharge_vip_rewardmgr = require "models/g_recharge_vip_rewardmgr"
	game.g_recharge_vip_rewardmgr = g_recharge_vip_rewardmgr()
	game.g_recharge_vip_rewardmgr("load_db")
end

local function load_g_role(game)
	-- body
	assert(game.g_rolemgr == nil)
	local g_rolemgr = require "models/g_rolemgr"
	game.g_rolemgr = g_rolemgr()
	game.g_rolemgr("load_db")
end

local function load_g_role_effect(game)
	assert( nil == game.g_role_effectmgr )
	local g_role_effectmgr = require "models/g_role_effectmgr"
	game.g_role_effectmgr = g_role_effectmgr()
	game.g_role_effectmgr("load_db")
end

local function load_g_role_star(game)
	-- body
	assert(game.g_role_starmgr == nil)
	local g_role_starmgr = require "models/g_role_starmgr"
	game.g_role_starmgr = g_role_starmgr()
	game.g_role_starmgr("load_db")
end

local function load_g_shop(game)
	-- body
	assert(game.g_shopmgr == nil)
	local g_shopmgr = require "models/g_shopmgr"
	game.g_shopmgr = g_shopmgr()
	game.g_shopmgr("load_db")
end

local function load_g_subreward(game)
	assert( nil == game.g_subrewardmgr )
	local g_subrewardmgr = require "models/g_subrewardmgr"
	game.g_subrewardmgr = g_subrewardmgr()
	game.g_subrewardmgr("load_db")
end

local function load_g_uid(game)
	-- body
	assert(nil == game.g_uidmgr)
	local g_uidmgr = require "models/g_uidmgr"
	game.g_uidmgr = g_uidmgr()
	game.g_uidmgr("load_db")
end

local function load_g_user_level(game)
	-- body
	assert(game.g_user_levelmgr == nil)
	local g_user_levelmgr = require "models/g_user_levelmgr"
	game.g_user_levelmgr = g_user_levelmgr()
	game.g_user_levelmgr("load_db")
end

local function load_g_xilian_cost(game)
	-- body
	assert(game.g_xilian_costmgr == nil)
	local g_xilian_costmgr = require "models/g_xilian_costmgr"
	game.g_xilian_costmgr = g_xilian_costmgr()
	game.g_xilian_costmgr("load_db")
end

local function load_g_randomval(game)
	assert( nil == game.g_randomvalmgr )
	local g_randomvalmgr = require "models/g_randomvalmgr"
	game.g_randomvalmgr = g_randomvalmgr()
	game.g_randomvalmgr("load_db")
end

local _M = {}

function _M.load_randomval()
	-- body
	load_g_randomval()
	return game
end

function _M.load_game()
	-- body
	local game = {}
	load_g_achievement(game)
	-- load_g_ara_pts(game)
	-- load_g_ara_rnk_rwd(game)
	-- load_g_ara_tms(game)
	-- load_g_checkpoint(game)
	-- load_g_checkpoint_chapter(game)
	-- load_g_checkin(game)
	-- load_g_checkin_total(game)
	-- load_g_equipment(game)
	-- load_g_equipment_enhance(game)
	-- load_g_daily_task(game)
	-- load_g_goods(game)
	-- load_g_goods_refresh_cost(game)
	-- load_g_kungfu(game)
	-- load_g_drawcost(game)
	-- load_g_mainreward(game)
	-- load_g_subreward(game)
	-- load_g_prop(game)
	-- load_g_recharge(game)
	-- load_g_lilian_invitation(game)
	-- load_g_lilian_level(game)
	-- load_g_lilian_event(game)
	-- load_g_lilian_quanguan(game)
	-- load_g_recharge_vip_reward(game)
	-- load_g_role(game)
	-- load_g_role_star(game)
	-- load_g_shop(game)
	-- load_g_user_level(game)
	-- load_g_uid(game)
	-- load_g_config(game)
	-- load_g_draw_role(game)
	-- load_g_xilian_cost(game)
	-- load_g_property_pool(game)
	-- load_g_property_pool_second(game)
	-- load_g_role_effect(game)
	-- load_g_equipment_effect(game)
	-- load_g_lilian_phy_power(game)
	-- load_g_monster()
	return game
end

return _M