local skynet = require "skynet"
local util = require "util"
local query = require "query"
local sd = require "sharedata"

local function load_g_achievement(game)
	-- body
	assert(game.g_achievementmgr == nil)
	local cls = require "models/g_achievementmgr"
	game.g_achievementmgr = cls.new()
	game.g_achievementmgr:load_db()
	game.g_achievementmgr:load_data_to_sd()
end

local function load_g_ara_pts(game)
	-- body
	assert(game.g_ara_ptsmgr == nil)
	local cls = require "models/g_ara_ptsmgr"
	game.g_ara_ptsmgr = cls.new()
	game.g_ara_ptsmgr:load_db()
	game.g_ara_ptsmgr:load_data_to_sd()
end

local function load_g_ara_rnk_rwd(game)
	-- body
	assert(game.g_ara_rnk_rwdmgr == nil)
	local cls = require "models/g_ara_rnk_rwdmgr"
	game.g_ara_rnk_rwdmgr = cls.new()
	game.g_ara_rnk_rwdmgr:load_db()
	game.g_ara_rnk_rwdmgr:load_data_to_sd()
end

local function load_g_ara_tms(game)
	-- body
	assert(game.g_ara_tmsmgr == nil)
	local cls = require "models/g_ara_tmsmgr"
	game.g_ara_tmsmgr = cls.new()
	game.g_ara_tmsmgr:load_db()
	game.g_ara_tmsmgr:load_data_to_sd()
end

local function load_g_checkin(game)
	assert( nil == game.g_checkinmgr )
	local cls = require "models/g_checkinmgr"
	game.g_checkinmgr = cls.new()
	game.g_checkinmgr:load_db()
	game.g_checkinmgr:load_data_to_sd()
end

local function load_g_checkin_total(game)
	assert( nil == game.g_checkin_totalmgr )
	local cls = require "models/g_checkin_totalmgr"
	game.g_checkin_totalmgr = cls.new()
	game.g_checkin_totalmgr:load_db()
	game.g_checkin_totalmgr:load_data_to_sd()
end

local function load_g_checkpoint(game)
	-- body
	assert(game.g_checkpointmgr == nil)
	local cls = require "models/g_checkpointmgr"
	game.g_checkpointmgr = cls.new()
	game.g_checkpointmgr:load_db()
	game.g_checkpointmgr:load_data_to_sd()
end

local function load_g_checkpoint_chapter(game)
	-- body
	assert(game.g_checkpoint_chaptermgr == nil)
	local cls = require "models/g_checkpoint_chaptermgr"
	game.g_checkpoint_chaptermgr = cls.new()
	game.g_checkpoint_chaptermgr:load_db()
	game.g_checkpoint_chaptermgr:load_data_to_sd()
end

local function load_g_config(game)
	-- body
	assert(game.g_configmgr == nil)
	local cls = require "models/g_configmgr"
	game.g_configmgr = cls.new()
	game.g_configmgr:load_db()
	game.g_configmgr:load_data_to_sd()
end

local function load_g_daily_task(game)
	assert( nil == game.g_daily_taskmgr )
	local cls = require "models/g_daily_taskmgr"
	game.g_daily_taskmgr = cls.new()
	game.g_daily_taskmgr:load_db()
	game.g_daily_taskmgr:load_data_to_sd()
end

local function load_g_draw_role(game)
	assert( nil == game.g_draw_rolemgr )
	local cls = require "models/g_draw_rolemgr"
	game.g_draw_rolemgr = cls.new()
	game.g_draw_rolemgr:load_db()
	game.g_draw_rolemgr:load_data_to_sd()
end

local function load_g_drawcost(game)
	assert( nil == game.g_drawcostmgr )
	local cls = require "models/g_drawcostmgr"
	game.g_drawcostmgr = cls.new()
	game.g_drawcostmgr:load_db()
	game.g_drawcostmgr:load_data_to_sd()
end

local function load_g_equipment(game)
	-- body
	assert(game.g_equipmentmgr == nil)
	local cls = require "models/g_equipmentmgr"
	game.g_equipmentmgr = cls.new()
	game.g_equipmentmgr:load_db()
	game.g_equipmentmgr:load_data_to_sd()
end

local function load_g_equipment_effect(game)
	-- body
	assert(game.g_equipment_effectmgr == nil)
	local cls = require "models/g_equipment_effectmgr"
	game.g_equipment_effectmgr = cls.new()
	game.g_equipment_effectmgr:load_db()
	game.g_equipment_effectmgr:load_data_to_sd()
end 

local function load_g_equipment_enhance(game)
	-- body
	assert(game.g_equipment_enhancemgr == nil)
	local cls = require "models/g_equipment_enhancemgr"
	game.g_equipment_enhancemgr = cls.new()
	game.g_equipment_enhancemgr:load_db()
	game.g_equipment_enhancemgr:load_data_to_sd()
end

local function load_g_goods(game)
	-- body
	assert(game.g_goodsmgr == nil)
	local cls = require "models/g_goodsmgr"
	game.g_goodsmgr = cls.new()
	game.g_goodsmgr:load_db()
	game.g_goodsmgr:load_data_to_sd()
end

local function load_g_goods_refresh_cost(game)
	-- body
	assert(game.g_goods_refresh_costmgr == nil)
	local cls = require "models/g_goods_refresh_costmgr"
	game.g_goods_refresh_costmgr = cls.new()
	game.g_goods_refresh_costmgr:load_db()
	game.g_goods_refresh_costmgr:load_data_to_sd()
end

local function load_g_kungfu(game)
	-- body
	assert(game.g_kungfumgr == nil)
	local cls = require "models/g_kungfumgr"
	game.g_kungfumgr = cls.new()
	game.g_kungfumgr:load_db()
	game.g_kungfumgr:load_data_to_sd()
end

local function load_g_lilian_event(game)
	-- body
	assert(game.g_lilian_eventmgr == nil)
	local cls = require "models/g_lilian_eventmgr"
	game.g_lilian_eventmgr = cls.new()
	game.g_lilian_eventmgr:load_db()
	game.g_lilian_eventmgr:load_data_to_sd()
end

local function load_g_lilian_invitation(game)
	-- body
	assert(game.g_lilian_invitationmgr == nil)
	local cls = require "models/g_lilian_invitationmgr"
	game.g_lilian_invitationmgr = cls.new()
	game.g_lilian_invitationmgr:load_db()
	game.g_lilian_invitationmgr:load_data_to_sd()
end

local function load_g_lilian_level(game)
	-- body
	assert(game.g_lilian_levelmgr == nil)
	local cls = require "models/g_lilian_levelmgr"
	game.g_lilian_levelmgr = cls.new()
	game.g_lilian_levelmgr:load_db()
	game.g_lilian_levelmgr:load_data_to_sd()
end

local function  load_g_lilian_phy_power(game)
	-- body
	assert( nil == game.g_lilian_phy_powermgr )
	local cls = require "models/g_lilian_phy_powermgr"
	game.g_lilian_phy_powermgr = cls.new()
	game.g_lilian_phy_powermgr:load_db()
	game.g_lilian_phy_powermgr:load_data_to_sd()
end

local function load_g_lilian_quanguan(game)
	-- body
	assert(game.g_lilian_quanguanmgr == nil)
	local cls = require "models/g_lilian_quanguanmgr"
	game.g_lilian_quanguanmgr = cls.new()
	game.g_lilian_quanguanmgr:load_db()
	game.g_lilian_quanguanmgr:load_data_to_sd()
end

local function load_g_mainreward(game)
	assert( nil == game.g_mainrewardmgr )
	local cls = require "models/g_mainrewardmgr"
	game.g_mainrewardmgr = cls.new()
	game.g_mainrewardmgr:load_db()
	game.g_mainrewardmgr:load_data_to_sd()
end

local function load_g_monster(game)
	assert(nil == game.g_monstermgr)
	local cls = require "models/g_monstermgr"
	game.g_monstermgr = cls.new()
	game.g_monstermgr:load_db()
	game.g_monstermgr:load_data_to_sd()
end 

local function load_g_prop(game)
	-- body
	assert(game.g_propmgr == nil)
	local cls = require "models/g_propmgr"
	game.g_propmgr = cls.new()
	game.g_propmgr:load_db()
	game.g_propmgr:load_data_to_sd()
end

local function load_g_property_pool(game)
	-- body
	assert(game.g_property_poolmgr == nil)
	local cls = require "models/g_property_poolmgr"
	game.g_property_poolmgr = cls.new()
	game.g_property_poolmgr:load_db()
	game.g_property_poolmgr:load_data_to_sd()
end

local function load_g_property_pool_second(game)
	-- body
	assert(game.g_property_pool_secondmgr == nil)
	local cls = require "models/g_property_pool_secondmgr"
	game.g_property_pool_secondmgr = cls.new()
	game.g_property_pool_secondmgr:load_db()
	game.g_property_pool_secondmgr:load_data_to_sd()
end 

local function load_g_recharge(game)
	-- body
	assert(game.g_rechargemgr == nil)
	local cls = require "models/g_rechargemgr"
	game.g_rechargemgr = cls.new()
	game.g_rechargemgr:load_db()
	game.g_rechargemgr:load_data_to_sd()
end

local function load_g_recharge_vip_reward(game)
	-- body
	assert(game.g_recharge_vip_rewardmgr == nil)
	local cls = require "models/g_recharge_vip_rewardmgr"
	game.g_recharge_vip_rewardmgr = cls.new()
	game.g_recharge_vip_rewardmgr:load_db()
	game.g_recharge_vip_rewardmgr:load_data_to_sd()
end

local function load_g_role(game)
	-- body
	assert(game.g_rolemgr == nil)
	local cls = require "models/g_rolemgr"
	game.g_rolemgr = cls.new()
	game.g_rolemgr:load_db()
	game.g_rolemgr:load_data_to_sd()
end

local function load_g_role_effect(game)
	assert( nil == game.g_role_effectmgr )
	local cls = require "models/g_role_effectmgr"
	game.g_role_effectmgr = cls.new()
	game.g_role_effectmgr:load_db()
	game.g_role_effectmgr:load_data_to_sd()
end

local function load_g_role_star(game)
	-- body
	assert(game.g_role_starmgr == nil)
	local cls = require "models/g_role_starmgr"
	game.g_role_starmgr = cls.new()
	game.g_role_starmgr:load_db()
	game.g_role_starmgr:load_data_to_sd()
end

local function load_g_shop(game)
	-- body
	assert(game.g_shopmgr == nil)
	local cls = require "models/g_shopmgr"
	game.g_shopmgr = cls.new()
	game.g_shopmgr:load_db()
	game.g_shopmgr:load_data_to_sd()
end

local function load_g_subreward(game)
	assert( nil == game.g_subrewardmgr )
	local cls = require "models/g_subrewardmgr"
	game.g_subrewardmgr = cls.new()
	game.g_subrewardmgr:load_db()
	game.g_subrewardmgr:load_data_to_sd()
end

local function load_g_uid(game)
	-- body
	assert(nil == game.g_uidmgr)
	local cls = require "models/g_uidmgr"
	game.g_uidmgr = cls.new()
	game.g_uidmgr:load_db()
	game.g_uidmgr:load_data_to_sd()
end

local function load_g_user_level(game)
	-- body
	assert(game.g_user_levelmgr == nil)
	local cls = require "models/g_user_levelmgr"
	game.g_user_levelmgr = cls.new()
	game.g_user_levelmgr:load_db()
	game.g_user_levelmgr:load_data_to_sd()
end

local function load_g_xilian_cost(game)
	-- body
	assert(game.g_xilian_costmgr == nil)
	local cls = require "models/g_xilian_costmgr"
	game.g_xilian_costmgr = cls.new()
	game.g_xilian_costmgr:load_db()
	game.g_xilian_costmgr:load_data_to_sd()
end

local function load_g_randomval(game)
	assert( nil == game.g_randomvalmgr )
	local cls = require "models/randomvalmgr"
	game.g_randomvalmgr = cls.new()
	game.g_randomvalmgr:load_db()
	game.g_randomvalmgr:load_data_to_sd()
end

local function load_g_role_coppy(game)
	-- body
	assert(nil == game.g_role_coppymgr)
	local cls = require "models/g_role_coppymgr"
	game.g_role_coppymgr = cls.new()
	game.g_role_coppymgr:load_db()
	game.g_role_coppymgr:load_data_to_sd()
end

local _M = {}

function _M.load_randomval()
	-- body
	local game = {}
	load_g_randomval(game)
	return game
end

function _M.load_game()
	-- body
	local game = {}
	load_g_achievement(game)
	load_g_ara_pts(game)
	load_g_ara_rnk_rwd(game)
	load_g_ara_tms(game)
	load_g_checkpoint(game)
	load_g_checkpoint_chapter(game)
	load_g_checkin(game)
	load_g_checkin_total(game)
	load_g_equipment(game)
	load_g_equipment_enhance(game)
	load_g_daily_task(game)
	load_g_goods(game)
	load_g_goods_refresh_cost(game)
	load_g_kungfu(game)
	load_g_drawcost(game)
	load_g_mainreward(game)
	load_g_subreward(game)
	load_g_prop(game)
	load_g_recharge(game)
	load_g_lilian_invitation(game)
	load_g_lilian_level(game)
	load_g_lilian_event(game)
	load_g_lilian_quanguan(game)
	load_g_recharge_vip_reward(game)
	load_g_role(game)
	load_g_role_star(game)
	load_g_shop(game)
	load_g_user_level(game)
	load_g_uid(game)
	load_g_config(game)
	load_g_draw_role(game)
	load_g_xilian_cost(game)
	load_g_property_pool(game)
	load_g_property_pool_second(game)
	load_g_role_effect(game)
	load_g_equipment_effect(game)
	load_g_lilian_phy_power(game)
	load_g_monster(game)
	load_g_role_coppy(game)
	return game
end

return _M
