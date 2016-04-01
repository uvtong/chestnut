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
	game.g_checkpointmgr = g_checkpointmgr
end

local function load_g_checkpoint_chapter()
	-- body
	assert(game.g_checkpoint_chaptermgr == nil)
	local g_checkpoint_chaptermgr = require "models/g_checkpoint_chaptermgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_checkpoint_chapter")
	for i,v in ipairs(r) do
		local t = g_checkpoint_chaptermgr.create(v)
		g_checkpoint_chaptermgr:add(t)
	end
	game.g_checkpoint_chaptermgr = g_checkpoint_chaptermgr
end

local function load_g_effct()
	-- body
	assert(game.g_effctmgr == nil)
	local g_effctmgr = require "models/g_effctmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_effct")
	for i,v in ipairs(r) do
		local t = g_effctmgr.create(v)
		g_effctmgr:add(t)
	end
	game.g_effctmgr = g_effctmgr
end

local function load_g_role_effect()
	assert( nil == game.g_role_effectmgr )
	local g_role_effectmgr = require "models/g_role_effectmgr"
	local r = skynet.call( util.random_db() , "lua" , "command" , "select" , "g_role_effect" )
	for i,v in ipairs(r) do
		local t = g_role_effectmgr.create(v)
		g_role_effectmgr:add(t)
	end
	game.g_role_effectmgr = g_role_effectmgr
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

local function load_g_equipment_enhance()
	-- body
	assert(game.g_equipment_enhancemgr == nil)
	local g_equipment_enhancemgr = require "models/g_equipment_enhancemgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_equipment_enhance")
	for i,v in ipairs(r) do
		local t = g_equipment_enhancemgr.create(v)
		g_equipment_enhancemgr:add(t)
	end
	game.g_equipment_enhancemgr = g_equipment_enhancemgr
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

local function load_g_kungfu()
	-- body
	assert(game.g_kungfumgr == nil)
	local g_kungfumgr = require "models/g_kungfumgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_kungfu")
	for i,v in ipairs(r) do
		local t = g_kungfumgr.create(v)
		g_kungfumgr:add(t)
	end
	game.g_kungfumgr = g_kungfumgr
end

local function load_g_lilian_level()
	-- body
	assert(game.g_lilian_levelmgr == nil)
	local g_lilian_levelmgr = require "models/g_lilian_levelmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_lilian_level")
	for i,v in ipairs(r) do
		local t = g_lilian_levelmgr.create(v)
		g_lilian_levelmgr:add(t)
	end
	game.g_lilian_levelmgr = g_lilian_levelmgr
end

local function load_g_lilian_event()
	-- body
	assert(game.g_lilian_eventmgr == nil)
	local g_lilian_eventmgr = require "models/g_lilian_eventmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_lilian_event")
	for i,v in ipairs(r) do
		local t = g_lilian_eventmgr.create(v)
		g_lilian_eventmgr:add(t)
	end
	game.g_lilian_eventmgr = g_lilian_eventmgr
end

local function load_g_lilian_quanguan()
	-- body
	assert(game.g_lilian_quanguanmgr == nil)
	local g_lilian_quanguanmgr = require "models/g_lilian_quanguanmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_lilian_quanguan")
	for i,v in ipairs(r) do
		local t = g_lilian_quanguanmgr.create(v)
		g_lilian_quanguanmgr:add(t)
	end
	game.g_lilian_quanguanmgr = g_lilian_quanguanmgr
end

local function load_g_lilian_invitation()
	-- body
	assert(game.g_lilian_invitationmgr == nil)
	local g_lilian_invitationmgr = require "models/g_lilian_invitationmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_lilian_invitation")
	for i,v in ipairs(r) do
		local t = g_lilian_invitationmgr.create(v)
		g_lilian_invitationmgr:add(t)
	end
	game.g_lilian_invitationmgr = g_lilian_invitationmgr
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

local function load_g_role_star()
	-- body
	assert(game.g_role_starmgr == nil)
	local g_role_starmgr = require "models/g_role_starmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_role_star")
	for i,v in ipairs(r) do
		local t = g_role_starmgr.create(v)
		g_role_starmgr:add(t)
	end
	game.g_role_starmgr = g_role_starmgr
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

local function load_g_user_level()
	-- body
	assert(game.g_user_levelmgr == nil)
	local g_user_levelmgr = require "models/g_user_levelmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_user_level")
	for i,v in ipairs(r) do
		local t = g_user_levelmgr.create(v)
		g_user_levelmgr:add(t)
	end
	game.g_user_levelmgr = g_user_levelmgr
end

local function load_g_checkin()
	assert( nil == game.g_checkinmgr )

	local g_checkinmgr = require "models/g_checkinmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_checkin")
	for i,v in ipairs(r) do
		local t = g_checkinmgr.create(v)
		g_checkinmgr:add(t)
	end
	game.g_checkinmgr = g_checkinmgr
end

local function load_g_checkin_total()
	assert( nil == game.g_checkin_totalmgr )

	local g_checkin_totalmgr = require "models/g_checkin_totalmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_checkin_total")
	for i,v in ipairs(r) do
		local t = g_checkin_totalmgr.create(v)
		g_checkin_totalmgr:add(t)
	end
	game.g_checkin_totalmgr = g_checkin_totalmgr
end

local function load_g_daily_task()
	assert( nil == game.g_daily_taskmgr )
	local g_daily_taskmgr = require "models/g_daily_taskmgr"
	local r = skynet.call( util.random_db() , "lua" , "command" , "select" , "g_daily_task" )
	for i , v in ipairs( r ) do
		local t = g_daily_taskmgr.create( v )
		g_daily_taskmgr:add( t )
	end
	game.g_daily_taskmgr = g_daily_taskmgr
end

local function load_g_drawcost()
	assert( nil == game.g_drawcostmgr )

	local g_drawcostmgr = require "models/g_drawcostmgr"
	local r = skynet.call(util.random_db() , "lua" , "command" , "select" , "g_drawcost")
	for i , v in ipairs( r ) do
		local t = g_drawcostmgr.create( v )
		g_drawcostmgr:add( t )
	end
	game.g_drawcostmgr = g_drawcostmgr
end

local function load_g_draw_role()
	assert( nil == game.g_draw_rolemgr )

	local g_draw_rolemgr = require "models/g_draw_rolemgr"
	local r = skynet.call(util.random_db() , "lua" , "command" , "select" , "g_draw_role")
	for i , v in ipairs( r ) do
		local t = g_draw_rolemgr.create( v )
		g_draw_rolemgr:add( t )
	end
	game.g_draw_rolemgr = g_draw_rolemgr
end

local function load_g_mainreward()
	assert( nil == game.g_mainrewardmgr )

	local g_mainrewardmgr = require "models/g_mainrewardmgr"
	local r = skynet.call(util.random_db() , "lua" , "command" , "select" , "g_mainreward")
	for i , v in ipairs( r ) do
		local t = g_mainrewardmgr.create( v )
		g_mainrewardmgr:add( t )
	end
	game.g_mainrewardmgr = g_mainrewardmgr
end

local function load_g_subreward()
	assert( nil == game.g_subrewardmgr )

	local g_subrewardmgr = require "models/g_subrewardmgr"
	local r = skynet.call(util.random_db() , "lua" , "command" , "select" , "g_subreward")
	for i , v in ipairs( r ) do
		local t = g_subrewardmgr.create( v )
		g_subrewardmgr:add( t )
	end
	game.g_subrewardmgr = g_subrewardmgr
end

local function load_g_randomval()
	assert( nil == game.g_randomvalmgr )

	local g_randomvalmgr = require "models/g_randomvalmgr"
	local r = skynet.call( util.random_db() , "lua" , "command" , "select" , "randomval" )
	for k , v in ipairs( r ) do
		local t = g_randomvalmgr.create( v )
		g_randomvalmgr:add( t )
	end
	print( "load randomval successfully" )
	game.g_randomvalmgr = g_randomvalmgr
end

local function load_g_uid()
	-- body
	assert(nil == game.g_uidmgr)
	local g_uidmgr = require "models/g_uidmgr"
	local r = skynet.call(util.random_db() , "lua" , "command" , "select" , "g_uid")
	for i , v in ipairs( r ) do
		local t = g_uidmgr.create( v )
		g_uidmgr:add( t )
	end
	game.g_uidmgr = g_uidmgr
end

local function load_g_config()
	-- body
	assert(game.g_configmgr == nil)
	local g_configmgr = require "models/g_configmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_config")
	for i,v in ipairs(r) do
		local t = g_configmgr.create(v)
		g_configmgr:add(t)
	end
	game.g_configmgr = g_configmgr
end

local function load_g_xilian_cost()
	-- body
	assert(game.g_xilian_costmgr == nil)
	local g_xilian_costmgr = require "models/g_xilian_costmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_xilian_cost")
	for i,v in ipairs(r) do
		local t = g_xilian_costmgr.create(v)
		g_xilian_costmgr:add(t)
	end
	game.g_xilian_costmgr = g_xilian_costmgr
end

local function load_g_property_pool()
	-- body
	assert(game.g_property_poolmgr == nil)
	local g_property_poolmgr = require "models/g_property_poolmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_property_pool")
	for i,v in ipairs(r) do
		local t = g_property_poolmgr.create(v)
		g_property_poolmgr:add(t)
	end
	game.g_property_poolmgr = g_property_poolmgr
end

local function load_g_property_pool_second()
	-- body
	assert(game.g_property_pool_secondmgr == nil)
	local g_property_pool_secondmgr = require "models/g_property_pool_secondmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_property_pool_second")
	for i,v in ipairs(r) do
		local t = g_property_pool_secondmgr.create(v)
		g_property_pool_secondmgr:add(t)
	end
	game.g_property_pool_secondmgr = g_property_pool_secondmgr
end

local function load_g_equipment_effect()
	-- body
	assert(game.g_equipment_effectmgr == nil)
	local g_equipment_effectmgr = require "models/g_equipment_effectmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_equipment_effect")
	for i,v in ipairs(r) do
		local t = g_equipment_effectmgr.create(v)
		g_equipment_effectmgr:add(t)
	end
	game.g_equipment_effectmgr = g_equipment_effectmgr
end

local function load_u_achievement(user)
	-- body
	local u_achievementmgr = require "models/u_achievementmgr"
	local addr = util.random_db()
	local r = skynet.call(addr, "lua", "command", "select", "u_achievement", {{ user_id = user.csv_id}})
	for i,v in ipairs(r) do
		local a = u_achievementmgr.create(v)
		u_achievementmgr:add(a)
	end
	u_achievementmgr.__user_id = user.csv_id
	user.u_achievementmgr = u_achievementmgr
end

local function load_u_achievement_rc(user)
	-- body
	local u_achievement_rcmgr = require "models/u_achievement_rcmgr"
	local addr = util.random_db()
	local r = skynet.call(addr, "lua", "command", "select", "u_achievement_rc", {{ user_id = user.csv_id}})
	for i,v in ipairs(r) do
		local a = u_achievement_rcmgr.create(v)
		u_achievement_rcmgr:add(a)
	end
	u_achievement_rcmgr.__user_id = user.csv_id
	user.u_achievement_rcmgr = u_achievement_rcmgr
end

local function load_u_checkin(user)
	-- body
	assert( user.u_checkinmgr == nil )
	local u_checkinmgr = require "models/u_checkinmgr"
	local addr = util.random_db()
	local sql = string.format( "select * from u_checkin where u_checkin_time = ( select u_checkin_time from u_checkin where user_id = %s ORDER BY u_checkin_time DESC limit 1 )" , user.csv_id)
	local r = skynet.call( addr, "lua", "command", "query", sql )

	for i,v in ipairs( r ) do
		local a = u_checkinmgr.create( v )
		u_checkinmgr:add( a )
	end
	u_checkinmgr.__user_id = user.csv_id
	user.u_checkinmgr = u_checkinmgr
end

local function load_u_checkin_month( user )
	-- body
	assert( user.u_checkin_monthmgr == nil )
	local u_checkin_monthmgr = require "models/u_checkin_monthmgr"
	local addr = util.random_db()
	local r = skynet.call( addr, "lua", "command", "select", "u_checkin_month" , { { user_id = user.csv_id } } )
	for i,v in ipairs( r ) do
		local a = u_checkin_monthmgr.create( v )
		u_checkin_monthmgr:add( a )
	end
	u_checkin_monthmgr.__user_id = user.csv_id
	user.u_checkin_monthmgr = u_checkin_monthmgr
end

local function load_u_exercise( user )
	assert( nil == user.u_exercise_mgr )

	local u_exercise_mgr = require "models/u_exercise_mgr"
	local sql = string.format( "select * from u_exercise where exercise_time = ( select exercise_time from u_exercise where user_id = %s ORDER BY exercise_time DESC limit 1 )" , user.csv_id)
	local r = skynet.call( util.random_db() , "lua" , "command" , "query" , sql )
	for i , v in ipairs( r ) do
		local a = u_exercise_mgr.create( v )
		u_exercise_mgr:add( a )
	end
	u_exercise_mgr.user_id = user.csv_id
	user.u_exercise_mgr = u_exercise_mgr
end

local function load_u_cgold( user )
	assert( nil == user.u_cgoldmgr )

	local u_cgoldmgr = require "models/u_cgoldmgr"
	local sql = string.format( "select * from u_cgold where cgold_time = ( select cgold_time from u_cgold where user_id = %s ORDER BY cgold_time DESC limit 1 )" , user.csv_id)
	local r = skynet.call( util.random_db() , "lua" , "command" , "query" , sql )
	for i , v in ipairs( r ) do
		local a = u_cgoldmgr.create( v )
		u_cgoldmgr:add( a )
	end
	u_cgoldmgr.user_id = user.csv_id
	user.u_cgoldmgr = u_cgoldmgr
end

local function load_u_checkpoint(user)
	-- body
	assert(user.u_checkpointmgr == nil)
	local u_checkpointmgr = require "models/u_checkpointmgr"
	local addr = util.random_db()
	local r = skynet.call(addr, "lua", "command", "select", "u_checkpoint", {{ user_id = user.csv_id }})
	for i,v in ipairs(r) do
		local a = u_checkpointmgr.create(v)
		u_checkpointmgr:add(a)
	end
	u_checkpointmgr.__user_id = user.csv_id
	user.u_checkpointmgr = u_checkpointmgr
end

local function load_u_checkpoint_rc(user)
	-- body
	assert(user.u_checkpoint_rcmgr == nil)
	local u_checkpoint_rcmgr = require "models/u_checkpoint_rcmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "u_checkpoint_rc", {{ user_id=user.csv_id}})
	for i,v in ipairs(r) do
		local a = u_checkpoint_rcmgr.create(v)
		u_checkpoint_rcmgr:add(a)
	end
	u_checkpoint_rcmgr.__user_id = user.csv_id
	user.u_checkpoint_rcmgr = u_checkpoint_rcmgr
end

local function load_u_equipment(user)
	-- body
	assert(user.u_equipmentmgr == nil)
	local u_equipmentmgr = require "models/u_equipmentmgr"
	local addr = util.random_db()
	local r = skynet.call(addr, "lua", "command", "select", "u_equipment", {{ user_id = assert(user.csv_id) }})
	for i,v in ipairs(r) do
		local a = u_equipmentmgr.create(v)
		u_equipmentmgr:add(a)
	end
	u_equipmentmgr.__user_id = user.csv_id
	user.u_equipmentmgr = u_equipmentmgr
end 
	
local function load_u_kungfu(user)
	-- body
	assert(user.u_kungfumgr == nil)
	local u_kungfumgr = require "models/u_kungfumgr"
	local addr = util.random_db()
	local r = skynet.call(addr, "lua", "command", "select", "u_kungfu", { { user_id = assert( user.csv_id ) } } )
	for i,v in ipairs(r) do
		local a = u_kungfumgr.create(v)
		u_kungfumgr:add(a)
	end
	u_kungfumgr.__user_id = user.csv_id
	user.u_kungfumgr = u_kungfumgr
end 
	
local function load_u_draw( user )
	assert( nil == user.u_drawmgr )

	local u_drawmgr = require "models/u_drawmgr"
	local sql1 = string.format( "select * from u_new_draw where srecvtime = ( select srecvtime from u_new_draw where uid = %s and drawtype = 1 ORDER BY srecvtime DESC limit 1 )" , user.csv_id )
	local r = skynet.call( util.random_db() , "lua" , "command" , "query" , sql1 )

	for i , v in ipairs( r ) do
		--print( " has number" )
		local draw = u_drawmgr.create( v )
		assert( draw )
		u_drawmgr:add( draw )
	end

	local sql2 = string.format( "select * from u_new_draw where srecvtime = ( select srecvtime from u_new_draw where uid = %s and drawtype = 2 ORDER BY srecvtime DESC limit 1 )" , user.csv_id )
	local t = skynet.call( util.random_db() , "lua" , "command" , "query" , sql2 )

	for i , v in ipairs( t ) do
		--print( " has number" )
		local draw = u_drawmgr.create( v )
		assert( draw )
		u_drawmgr:add( draw )
	end
	u_drawmgr.__user_id = user.csv_id
	user.u_drawmgr = u_drawmgr
end	
	
local function load_u_email( user )
	assert( nil == user.u_emailmgr )
	
	local u_emailmgr = require "models/u_emailmgr"
	local r = skynet.call( util.random_db() , "lua", "command" , "select" , "u_new_email", { { uid = user.csv_id , isdel = 0 } } )
	print( "sizeof r is ************************************************************" , #r )
	for i , v in ipairs( r ) do
		local a = u_emailmgr.create( v )
		u_emailmgr:add( a )
	end
	print( "u_emailmgr:get_count" , u_emailmgr:get_count() )
	if u_emailmgr:get_count() > u_emailmgr.__MAXEMAILNUM then
		print( "sysdelemail is called *********************************************" , u_emailmgr:get_count() )
		u_emailmgr:sysdelemail()
	end
	u_emailmgr.__user_id = user.csv_id
	user.u_emailmgr = u_emailmgr
end

local function load_u_lilian_main(user)
	assert(user)
	local u_lilian_mainmgr = require "models/u_lilian_mainmgr"
	local nr = skynet.call( util.random_db() , "lua" , "command" , "select" , "u_lilian_main" , { { user_id = user.csv_id , iffinished = 0 } } )

	for i , v in ipairs( nr ) do
		local a = u_lilian_mainmgr.create( v )
		u_lilian_mainmgr:add( a )
	end
	
	u_lilian_mainmgr.__user_id = user.csv_id
	user.u_lilian_mainmgr = u_lilian_mainmgr
end

local function load_u_lilian_sub(user)
	assert(user)
	local u_lilian_submgr = require "models/u_lilian_submgr"
	local nr = skynet.call( util.random_db() , "lua" , "command" , "select" , "u_lilian_sub" , { { csv_id = user.csv_id } } )

	for i , v in ipairs( nr ) do
		local a = u_lilian_submgr.create( v )
		u_lilian_submgr:add( a )
	end

	u_lilian_submgr.__user_id = user.csv_id
	user.u_lilian_submgr = u_lilian_submgr
end

local function load_u_lilian_qg_num(user)
	assert(user)
	local u_lilian_qg_nummgr = require "models/u_lilian_qg_nummgr"
	local date = os.time()
	local sql = string.format( "select * from u_lilian_qg_num where user_id = %s and start_time < %s and %s < end_time" , user.csv_id , date , date)
	local nr = skynet.call( util.random_db() , "lua" , "command" , "query" , sql )

	for i , v in ipairs( nr ) do
		local a = u_lilian_qg_nummgr.create( v )
		u_lilian_qg_nummgr:add( a )
	end

	u_lilian_qg_nummgr.__user_id = user.csv_id
	user.u_lilian_qg_nummgr = u_lilian_qg_nummgr
end

local function load_u_prop(user)
	-- body
	local u_propmgr = require "models/u_propmgr"
	local addr = util.random_db()
	local nr = skynet.call(addr, "lua", "command", "select", "u_prop", {{ user_id = user.csv_id }})
	for i,v in ipairs(nr) do
		local prop = u_propmgr.create( v )
		u_propmgr:add(prop)
	end
	u_propmgr.__user_id = user.csv_id
	user.u_propmgr = u_propmgr
end

local function load_u_purchase_goods(user)
	-- body
	local u_purchase_goodsmgr = require "models/u_purchase_goodsmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "u_purchase_goods", {{ user_id = user.csv_id}})
	for i,v in ipairs(r) do
		local t = u_purchase_goodsmgr.create(v)
		u_purchase_goodsmgr:add(t)
	end
	u_purchase_goodsmgr.__user_id = user.csv_id
	user.u_purchase_goodsmgr = u_purchase_goodsmgr
end

local function load_u_purchase_reward(user)
	-- body
	local u_purchase_rewardmgr = require "models/u_purchase_rewardmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "u_purchase_reward", {{ user_id=user.csv_id}})
	for i,v in ipairs(r) do
		local t = u_purchase_rewardmgr.create(v)
		u_purchase_rewardmgr:add(t)
	end
	u_purchase_rewardmgr.__user_id = user.csv_id
	user.u_purchase_rewardmgr = u_purchase_rewardmgr
end

local function load_u_recharge_count(user)
	-- body
	local u_recharge_countmgr = require "models/u_recharge_countmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "u_recharge_count", {{ user_id=user.csv_id}})
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
	local r = skynet.call(util.random_db(), "lua", "command", "select", "u_recharge_record", {{ user_id=user.csv_id}})
	assert(r)
	for i,v in ipairs(r) do
		local t = u_recharge_recordmgr.create(v)
		u_recharge_recordmgr:add(t)
	end
	user.u_recharge_recordmgr = u_recharge_recordmgr
end

local function load_u_recharge_reward(user)
	-- body
	local u_recharge_rewardmgr = require "models/u_recharge_rewardmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "u_recharge_reward", {{ user_id=user.csv_id}})
	assert(r)
	for i,v in ipairs(r) do
		local t = u_recharge_rewardmgr.create(v)
		u_recharge_rewardmgr:add(t)
	end
	u_recharge_rewardmgr.__user_id = user.csv_id
	user.u_recharge_rewardmgr = u_recharge_rewardmgr
end

local function load_u_recharge_vip_reward(user)
	-- body
	local u_recharge_vip_rewardmgr = require "models/u_recharge_vip_rewardmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "u_recharge_vip_reward", {{ user_id=user.csv_id}})
	assert(r)
	for i,v in ipairs(r) do
		local t = u_recharge_vip_rewardmgr.create(v)
		u_recharge_vip_rewardmgr:add(t)
	end
	u_recharge_vip_rewardmgr.__user_id = user.csv_id
	user.u_recharge_vip_rewardmgr = u_recharge_vip_rewardmgr
end

local function load_u_role(user)
	-- body
	local u_rolemgr = require "models/u_rolemgr"
	local addr = util.random_db()
	local nr = skynet.call(addr, "lua", "command", "select", "u_role", {{ user_id = user.csv_id }})
	for i,v in ipairs(nr) do
		local role = u_rolemgr.create( v )
		u_rolemgr:add(role)
	end
	u_rolemgr.__user_id = user.csv_id
	user.u_rolemgr = u_rolemgr
end

local function load_u_journal(user)
	-- body
	local u_journalmgr = require "models/u_journalmgr"
	local addr = util.random_db()
	local r = skynet.call(addr, "lua", "command", "select", "u_journal", {{ user_id = user.csv_id}})
	for i,v in ipairs(r) do
		local t = u_journalmgr.create(v)
		u_journalmgr:add(t)
	end
	u_journalmgr.__user_id = user.csv_id
	user.u_journalmgr = u_journalmgr
end

local function load_u_goods(user)
	-- body
	local u_goodsmgr = require "models/u_goodsmgr"
	local addr = util.random_db()
	local r = skynet.call(addr, "lua", "command", "select", "u_goods", {{ user_id = user.csv_id}})
	for i,v in ipairs(r) do
		local t = u_goodsmgr.create(v)
		u_goodsmgr:add(t)
	end
	u_goodsmgr.__user_id = user.csv_id
	user.u_goodsmgr = u_goodsmgr
end

function loader.load_randomval()
	-- body
	load_g_randomval()
	return game
end

function loader.load_game()
	-- body
	local f = function ()
		-- body
		load_g_achievement()
		load_g_checkpoint()
		load_g_checkpoint_chapter()
		load_g_checkin()
		load_g_checkin_total()
		load_g_equipment()
		load_g_equipment_enhance()
		load_g_daily_task()
		load_g_goods()
		load_g_goods_refresh_cost()
		load_g_kungfu()
		load_g_drawcost()
		load_g_mainreward()
		load_g_subreward()
		load_g_prop()
		load_g_recharge()
		load_g_lilian_invitation()
		load_g_lilian_level()
		load_g_lilian_event()
		load_g_lilian_quanguan()
		load_g_randomval()
		load_g_recharge_vip_reward()
		load_g_role()
		load_g_role_star()
		load_g_shop()
		load_g_user_level()
		load_g_uid()
		load_g_config()
		load_g_draw_role()
		load_g_xilian_cost()
		load_g_property_pool()
		load_g_property_pool_second()
		load_g_role_effect()
		load_g_equipment_effect()
	end
	skynet.fork(f)
	return game
end


function loader.load_user(user)
	-- body
	load_u_achievement(user)
	load_u_achievement_rc(user)
	load_u_checkin(user)
	load_u_checkin_month( user )
	load_u_checkpoint(user)
	load_u_checkpoint_rc(user)
	load_u_equipment(user)
	load_u_exercise( user)
	load_u_cgold( user )
	load_u_email( user )
	load_u_kungfu(user)
	load_u_draw( user )
	load_u_prop(user)
	load_u_role(user)
	load_u_purchase_goods(user)
	load_u_purchase_reward(user)
	load_u_recharge_count(user)
	load_u_recharge_record(user)
	load_u_recharge_vip_reward(user)
	load_u_journal(user)
	load_u_goods(user)
	load_u_lilian_main(user)
	load_u_lilian_sub(user)
	load_u_lilian_qg_num(user)
	return user
end

function loader.clear(user)
	-- body
	for k,v in pairs(user) do
		if string.match(k, "^u_%w+mgr$") then
			print(k)
			v:clear()
		end
	end
end

return loader
