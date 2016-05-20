local skynet = require "skynet"
local util = require "util"
local query = require "query"

local function load_user(user_id)
	-- body
	local cls = require "models/usersmgr"
	local usersmgr = cls.new()
	usersmgr:load_db("pk", user_id)
	local user = usersmgr:get(user_id)
	return user
end

local function load_u_achievement(user)
	-- body
	local cls = require "models/u_achievementmgr"
	user.u_achievementmgr = cls.new()
	user.u_achievementmgr:load_db("fk", user.csv_id)
end

local function load_u_achievement_rc(user)
	-- body
	local cls = require "models/u_achievement_rcmgr"
	user.u_achievement_rcmgr = cls.new()
	user.u_achievement_rcmgr:load_db("fk", user.csv_id)
end

local function load_u_checkin(user)
	-- body
	assert( user.u_checkinmgr == nil )
	local cls = require "models/u_checkinmgr"
	user.u_checkinmgr = cls.new()
	local addr = util.random_db()
	local sql = string.format( "select * from u_checkin where u_checkin_time = ( select u_checkin_time from u_checkin where user_id = %s ORDER BY u_checkin_time DESC limit 1 )" , user.csv_id)
	local r = query.read(".rdb", "u_checkin", sql)
	for i,v in ipairs( r ) do
		local a = user.u_checkinmgr:create( v )
		user.u_checkinmgr:add( a )
	end
end

local function load_u_checkin_month( user )
	-- body
	assert( user.u_checkin_monthmgr == nil )
	local cls = require "models/u_checkin_monthmgr"
	user.u_checkin_monthmgr = cls.new()
	user.u_checkin_monthmgr:load_db("fk", user.csv_id)
end

local function load_u_exercise( user )
	assert( nil == user.u_exercise_mgr )
	local cls = require "models/u_exercisemgr"
	user.u_exercise_mgr = cls.new()
	local sql = string.format( "select * from u_exercise where exercise_time = ( select exercise_time from u_exercise where user_id = %s ORDER BY exercise_time DESC limit 1 )" , user.csv_id)
	local r = query.read(".rdb", "u_exercise", sql)
	-- local r = skynet.call( util.random_db() , "lua" , "command" , "query" , sql )
	for i , v in ipairs( r ) do
		local a = user.u_exercise_mgr:create( v )
		user.u_exercise_mgr:add( a )
	end
end

local function load_u_cgold( user )
	assert( nil == user.u_cgoldmgr )
	local cls = require "models/u_cgoldmgr"
	user.u_cgoldmgr = cls.new()
	local sql = string.format( "select * from u_cgold where cgold_time = ( select cgold_time from u_cgold where user_id = %s ORDER BY cgold_time DESC limit 1 )" , user.csv_id)
	local r = query.read(".rdb", "u_cgold", sql)
	-- local r = skynet.call( util.random_db() , "lua" , "command" , "query" , sql )
	for i , v in ipairs( r ) do
		local a = user.u_cgoldmgr:create( v )
		user.u_cgoldmgr:add( a )
	end
end

local function load_u_checkpoint(user)
	-- body
	assert(user.u_checkpointmgr == nil)
	local cls = require "models/u_checkpointmgr"
	user.u_checkpointmgr = cls.new()
	user.u_checkpointmgr:load_db("fk", user.csv_id)
end

local function load_u_checkpoint_rc(user)
	-- body
	assert(user.u_checkpoint_rcmgr == nil)
	local cls = require "models/u_checkpoint_rcmgr"
	user.u_checkpoint_rcmgr = cls.new()
	user.u_checkpoint_rcmgr:load_db("fk", user.csv_id)
end

local function load_u_equipment(user)
	-- body
	assert(user.u_equipmentmgr == nil)
	local cls = require "models/u_equipmentmgr"
	user.u_equipmentmgr = cls.new()
	user.u_equipmentmgr:load_db("fk", user.csv_id)
end 
	
local function load_u_kungfu(user)
	-- body
	assert(user.u_kungfumgr == nil)
	local cls = require "models/u_kungfumgr"
	user.u_kungfumgr = cls.new()
	user.u_kungfumgr:set_user(user)
	user.u_kungfumgr:load_db("fk", user.csv_id)
end 
	
local function load_u_draw( user )
	assert( nil == user.u_drawmgr )
	local cls = require "models/u_new_drawmgr"
	user.u_drawmgr = cls.new()
	user.u_drawmgr:set_user(user)

	local sql1 = string.format( "select * from u_new_draw where srecvtime = ( select srecvtime from u_new_draw where uid = %s and drawtype = 1 ORDER BY srecvtime DESC limit 1 )" , user.csv_id )
	local r = query.read(".rdb", "u_new_draw", sql1)
	for i , v in ipairs( r ) do
		--print( " has number" )
		local draw = user.u_drawmgr:create( v )
		assert( draw )
		user.u_drawmgr:add( draw )
	end

	local sql2 = string.format( "select * from u_new_draw where srecvtime = ( select srecvtime from u_new_draw where uid = %s and drawtype = 2 ORDER BY srecvtime DESC limit 1 )" , user.csv_id )
	-- local t = skynet.call( util.random_db() , "lua" , "command" , "query" , sql2 )
	local t = query.read(".rdb", "u_new_draw", sql2)
	for i , v in ipairs( t ) do
		--print( " has number" )
		local draw = user.u_drawmgr:create( v )
		assert( draw )
		user.u_drawmgr:add( draw )
	end
end	
	
-- local function load_u_email( user )
-- 	assert( nil == user.u_emailmgr )
-- 	local u_emailmgr = require "models/u_emailmgr"
-- 	user.u_emailmgr = u_emailmgr()

-- 	local r = skynet.call( util.random_db() , "lua", "command" , "select" , "u_new_email", { { uid = user.csv_id , isdel = 0 } } )
-- 	for i , v in ipairs( r ) do
-- 		local a = user.u_emailmgr:create( v )
-- 		user.u_emailmgr:add( a )
-- 	end
-- 	print( "u_emailmgr:get_count" , u_emailmgr:get_count() )
-- 	if user.u_emailmgr:get_count() > user.u_emailmgr.__MAXEMAILNUM then
-- 		print( "sysdelemail is called *********************************************" , u_emailmgr:get_count() )
-- 		user.u_emailmgr:sysdelemail()
-- 	end
-- 	u_emailmgr.__user_id = user.csv_id
	
-- end

local function load_u_lilian_main(user)
	assert(user)
	local cls = require "models/u_lilian_mainmgr"
	user.u_lilian_mainmgr = cls.new()
	user.u_lilian_mainmgr:set_user(user)
	user.u_lilian_mainmgr:load_db({ user_id = user.csv_id , iffinished = 0 })
	-- local nr = skynet.call( util.random_db() , "lua" , "command" , "select" , "u_lilian_main" , { { user_id = user.csv_id , iffinished = 0 } } )
	-- for i , v in ipairs( nr ) do
	-- 	local a = user.u_lilian_mainmgr:create( v )
	-- 	user.u_lilian_mainmgr:add( a )
	-- end
end

local function load_u_lilian_sub(user)
	assert(user)
	local cls = require "models/u_lilian_submgr"
	user.u_lilian_submgr = cls.new()
	user.u_lilian_submgr:set_user(user)
	user.u_lilian_submgr:load_db("fk", user.csv_id)
end

local function load_u_lilian_qg_num(user)
	assert(user)
	local cls = require "models/u_lilian_qg_nummgr"
	user.u_lilian_qg_nummgr = cls.new()
	user.u_lilian_qg_nummgr:set_user(user)
	local date = os.time()
	local sql = string.format( "select * from u_lilian_qg_num where user_id = %s and start_time < %s and %s < end_time" , user.csv_id , date , date)
	-- local nr = skynet.call( util.random_db() , "lua" , "command" , "query" , sql )
	local nr = query.read(user.u_lilian_qg_nummgr.__rdb, "u_lilian_qg_num", sql)
	for i , v in ipairs( nr ) do
		local a = user.u_lilian_qg_nummgr:create( v )
		user.u_lilian_qg_nummgr:add( a )
	end
end

local function load_u_lilian_phy_power(user)
	assert(user)
	local cls = require "models/u_lilian_phy_powermgr"
	user.u_lilian_phy_powermgr = cls.new()
	user.u_lilian_phy_powermgr:set_user(user)
	local date = os.time()
	local sql = string.format( "select * from u_lilian_phy_power where user_id = %s and start_time < %s and %s < end_time" , user.csv_id , date , date)
	-- local nr = skynet.call( util.random_db() , "lua" , "command" , "query" , sql )
	local nr = query.read(user.u_lilian_phy_powermgr.__rdb, "u_lilian_phy_power", sql)
	for i , v in ipairs( nr ) do
		local a = user.u_lilian_phy_powermgr:create( v )
		user.u_lilian_phy_powermgr:add( a )
	end
end 
	
local function load_u_prop(user)
	-- body
	local cls = require "models/u_propmgr"
	user.u_propmgr = cls.new()
	user.u_propmgr:set_user(user)
	user.u_propmgr:load_db("fk", user.csv_id)
end

local function load_u_purchase_goods(user)
	-- body
	local cls = require "models/u_purchase_goodsmgr"
	user.u_purchase_goodsmgr = cls.new()
	user.u_purchase_goodsmgr:set_user(user)
	user.u_purchase_goodsmgr:load_db("fk", user.csv_id)
end

local function load_u_purchase_reward(user)
	-- body
	local cls = require "models/u_purchase_rewardmgr"
	user.u_purchase_rewardmgr = cls.new()
	user.u_purchase_rewardmgr:set_user(user)
	user.u_purchase_rewardmgr:load_db("fk", user.csv_id)
end

local function load_u_recharge_count(user)
	-- body
	local cls = require "models/u_recharge_countmgr"
	user.u_recharge_countmgr = cls.new()
	user.u_recharge_countmgr:set_user(user)
	user.u_recharge_countmgr:load_db("fk", user.csv_id)
end

local function load_u_recharge_record(user)
	-- body
	local cls = require "models/u_recharge_recordmgr"
	user.u_recharge_recordmgr = cls.new()
	user.u_recharge_recordmgr:set_user(user)
	user.u_recharge_recordmgr:load_db("fk", user.csv_id)
end

local function load_u_recharge_reward(user)
	-- body
	local cls = require "models/u_recharge_rewardmgr"
	user.u_recharge_rewardmgr = cls.new()
	user.u_recharge_rewardmgr:set_user(user)
	user.u_recharge_rewardmgr:load_db("fk", user.csv_id)
end

local function load_u_recharge_vip_reward(user)
	-- body
	local cls = require "models/u_recharge_vip_rewardmgr"
	user.u_recharge_vip_rewardmgr = cls.new()
	user.u_recharge_vip_rewardmgr:set_user(user)
	user.u_recharge_vip_rewardmgr:load_db("fk", user.csv_id)
end

local function load_u_role(user)
	-- body
	local cls = require "models/u_rolemgr"
	user.u_rolemgr = cls.new()
	user.u_rolemgr:set_user(user)
	user.u_rolemgr:load_db("fk", user.csv_id)
end

local function load_u_journal(user)
	-- body
	local cls = require "models/u_journalmgr"
	user.u_journalmgr = cls.new()
	user.u_journalmgr:set_user(user)
	user.u_journalmgr:load_db("fk", user.csv_id)
end

local function load_u_goods(user)
	-- body
	local cls = require "models/u_goodsmgr"
	user.u_goodsmgr = cls.new()
	user.u_goodsmgr:set_user(user)
	user.u_goodsmgr:load_db("fk", user.csv_id)
end

local _M = {}

function _M.load_user(uid)
	-- body
	local user = load_user(uid)
	load_u_achievement(user)
	load_u_achievement_rc(user)
	load_u_checkin(user)
	load_u_checkin_month( user )
	load_u_checkpoint(user)
	load_u_checkpoint_rc(user)
	load_u_equipment(user)
	load_u_exercise( user)
	load_u_cgold( user )
	-- load_u_email( user )
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
	load_u_lilian_phy_power(user)
	return user
end

return _M
