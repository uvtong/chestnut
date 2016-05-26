local skynet = require "skynet"
local util = require "util"
local query = require "query"

local cls = class("load_user")

function cls:ctor(env, ... )
	-- body
	self._env = env
	self._data = {}
end

function cls:load_user(uid)
	-- body
	self:load_user(uid)
	self:load_u_achievement()
	self:load_u_achievement_rc()
	self:load_u_checkin()
	self:load_u_checkin_month()
	self:load_u_checkpoint()
	self:load_u_checkpoint_rc()
	self:load_u_equipment()
	self:load_u_exercise()
	self:load_u_cgold()
	-- load_u_email( user )
	self:load_u_kungfu()
	self:load_u_draw()
	self:load_u_prop()
	self:load_u_role()
	self:load_u_purchase_goods()
	self:load_u_purchase_reward(user)
	self:load_u_recharge_count(user)
	self:load_u_recharge_record(user)
	self:load_u_recharge_vip_reward(user)
	self:load_u_journal(user)
	self:load_u_goods(user)
	self:load_u_lilian_main(user)
	self:load_u_lilian_sub(user)
	self:load_u_lilian_qg_num(user)
	self:load_u_lilian_phy_power(user)
	--self:load_u_new_friend()
	--self:load_u_new_friendmsg()
	return self:get_user()
end 
	
function cls:load_remote(uid, p )
	-- body
	
end 	
	
function cls:load_enemy_local(uid)
	-- body
	
end 	
	
function cls:load_user_remote(uid, p, ... )
	-- body
	local usersmgr = env:get_usersmgr()
	if usersmgr == nil then
		local cls = require "models/usersmgr"
		local usersmgr = cls.new()
		env:set_usersmgr(usersmgr)
	end
	usersmgr:load_remote()
end 	
	
function cls:load_user(user_id)
	-- body
	local cls = require "models/usersmgr"
	local usersmgr = cls.new()
	env:set_usersmgr(usersmgr)
	usersmgr:load_db("pk", user_id)
	local user = usersmgr:get(user_id)
	self._data["user"] = user
	return user
end 	       
	
function cls:get_user( ... )
	-- body
	return self._data["user"]
end	       
	        
function cls:load_u_new_friend()
	local u = self:get_user()
	local cls = require "models/u_new_friend"
	local u_new_friendmgr = cls.new()
	u_new_friendmgr:load_db("fk", u:get_csv_id())
	self._data["u_new_friendmgr"] = u_new_friendmgr
	u.u_new_friendmgr = u_new_friendmgr
end              
               
function cls:get_u_new_friend()
        return self._data["u_new_friendmgr"]
end              
               
function cls:load_u_new_friendmgs()
        local u = self:get_user()
	local cls = require "models/u_new_friendmsgmgr"
	local u_new_friendmsgmgr = cls.new()
	local sql = string.format("select * from u_new_friendmsg where (fromid = %d and isread = 0) or (toid = %d and isread = 0)", u:get_csv_id())
	local r = query.read(".rdb", "u_new_friendmsg", sql)
	assert(r.errno == nil) --if query failed, return errno, badresult, sqlstate, err
	for k, v in ipairs(r) do
	       	local a = u_new_friendmsgmgr:create_entity( v )
	       	user.u_new_friendmsgmgr:add( a )		
	end    
	self._data["u_new_friendmsgmgr"] = u_new_friendmsgmgr
	u.u_new_friendmsgmgr = u_new_friendmsgmgr
end     
	
function cls:get_u_new_friendmsg()
	return self._data["u_new_friendmsgmgr"]
end 	
				
function cls:load_u_achievement()
	-- body
	local u = self:get_user()
	local cls = require "models/u_achievementmgr"
	local u_achievementmgr = cls.new()
	u_achievementmgr:load_db("fk", u:get_csv_id())
	self._data["u_achievementmgr"] = u_achievementmgr
	u.u_achievementmgr = u_achievementmgr
end

function cls:get_u_achievementmgr( ... )
	-- body
	return self._data["u_achievementmgr"]
end

function cls:load_u_achievement_rc()
	-- body
	local u = self:get_user()
	local cls = require "models/u_achievement_rcmgr"
	local u_achievement_rcmgr = cls.new()
	u_achievement_rcmgr:load_db("fk", u:get_csv_id())
	self._data["u_achievement_rcmgr"] = u_achievement_rcmgr
	u.u_achievement_rcmgr = u_achievement_rcmgr
end

function cls:get_u_achievement_rcmgr( ... )
	-- body
	return self._data["u_achievement_rcmgr"]
end

function cls:load_u_checkin()
	-- body
	local u = self:get_user()
	local cls = require "models/u_checkinmgr"
	local u_checkinmgr = cls.new()
	local addr = util.random_db()
	local sql = string.format( "select * from u_checkin where u_checkin_time = ( select u_checkin_time from u_checkin where user_id = %s ORDER BY u_checkin_time DESC limit 1 )" , u:get_csv_id())
	local r = query.read(".rdb", "u_checkin", sql)
	for i,v in ipairs( r ) do
		local a = u_checkinmgr:create( v )
		user.u_checkinmgr:add( a )
	end
	self._data['u_checkinmgr'] = u_checkinmgr
	u.u_checkinmgr = u_checkinmgr
end

function cls:get_u_checkinmgr( ... )
	-- body
	return self._data['u_checkinmgr']
end

function cls:load_u_checkin_month()
	-- body
	local u = self:get_user()
	local cls = require "models/u_checkin_monthmgr"
	local u_checkin_monthmgr = cls.new()
	u_checkin_monthmgr:load_db("fk", u:get_csv_id())
	self._data["u_checkin_monthmgr"] = u_checkin_monthmgr
	u.u_checkin_monthmgr = u_checkin_monthmgr
end

function cls:get_u_checkin_monthmgr( ... )
	-- body
	return self._data["u_checkin_monthmgr"]
end

function cls:load_u_exercise()
	local u = self:get_user()
	local cls = require "models/u_exercisemgr"
	local u_exercise_mgr = cls.new()
	local sql = string.format( "select * from u_exercise where exercise_time = ( select exercise_time from u_exercise where user_id = %s ORDER BY exercise_time DESC limit 1 )" , u:get_csv_id())
	local r = query.read(".rdb", "u_exercise", sql)
	-- local r = skynet.call( util.random_db() , "lua" , "command" , "query" , sql )
	for i , v in ipairs( r ) do
		local a = u_exercise_mgr:create( v )
		u_exercise_mgr:add( a )
	end
	self._data["u_exercise_mgr"] = u_exercise_mgr
	u.u_exercise_mgr = u_exercise_mgr
end

function cls:get_u_exercise( ... )
	-- body
	return self._data["u_exercise_mgr"]
end

function cls:load_u_cgold()
	local u = self:get_user()
	local cls = require "models/u_cgoldmgr"
	local u_cgoldmgr = cls.new()
	local sql = string.format( "select * from u_cgold where cgold_time = ( select cgold_time from u_cgold where user_id = %s ORDER BY cgold_time DESC limit 1 )" , u:get_csv_id())
	local r = query.read(".rdb", "u_cgold", sql)
	-- local r = skynet.call( util.random_db() , "lua" , "command" , "query" , sql )
	for i , v in ipairs( r ) do
		local a = u_cgoldmgr:create( v )
		u_cgoldmgr:add( a )
	end
	self._data["u_cgoldmgr"] = u_cgoldmgr
end

function cls:get_u_cgoldmgr( ... )
	-- body
	return self._data["u_cgoldmgr"]
end

function cls:load_u_checkpoint()
	-- body
	local u = self:get_user()
	local cls = require "models/u_checkpointmgr"
	local u_checkpointmgr = cls.new()
	u_checkpointmgr:load_db("fk", u:get_csv_id())
	self._data["u_checkpointmgr"] = u_checkpointmgr
	u.u_checkpointmgr = u_checkpointmgr
end

function cls:get_u_checkpointmgr( ... )
	-- body
	return self._data["u_checkpointmgr"]
end

function cls:load_u_checkpoint_rc()
	-- body
	local u = self:get_user()
	local cls = require "models/u_checkpoint_rcmgr"
	local u_checkpoint_rcmgr = cls.new()
	u_checkpoint_rcmgr:load_db("fk", u:get_csv_id())
	self._data["u_checkpoint_rcmgr"] = u_checkpoint_rcmgr
	u.u_checkpoint_rcmgr = u_checkpoint_rcmgr
end

function cls:get_u_checkpoint_rcmgr( ... )
	-- body
	return self._data["u_checkpoint_rcmgr"]
end

function cls:load_u_equipment()
	-- body
	local u = self:get_user()
	local cls = require "models/u_equipmentmgr"
	local u_equipmentmgr = cls.new()
	u_equipmentmgr:load_db("fk", u:get_csv_id())
	self._data["u_equipmentmgr"] = u_equipmentmgr
	u.u_equipmentmgr = u_equipmentmgr
end 

function cls:get_u_equipmentmgr( ... )
	-- body
	return self._data["u_equipmentmgr"]
end

function cls:load_u_kungfu()
	-- body
	local u = self:get_user()
	local cls = require "models/u_kungfumgr"
	local u_kungfumgr = cls.new()
	u_kungfumgr:set_user(user)
	u_kungfumgr:load_db("fk", u:get_csv_id())
	self._data["u_kungfumgr"] = u_kungfumgr
	u.u_kungfumgr = u_kungfumgr
end

function cls:get_u_kunfumgr( ... )
 	-- body
 	return self._data["u_kungfumgr"]
 end 
	
function cls:load_u_draw()
	local u = self:get_user()
	local cls = require "models/u_new_drawmgr"
	local u_drawmgr = cls.new()
	u_drawmgr:set_user(user)

	local sql1 = string.format( "select * from u_new_draw where srecvtime = ( select srecvtime from u_new_draw where uid = %s and drawtype = 1 ORDER BY srecvtime DESC limit 1 )" , u:get_csv_id())
	local r = query.read(".rdb", "u_new_draw", sql1)
	for i , v in ipairs( r ) do
		--print( " has number" )
		local draw = u_drawmgr:create( v )
		assert( draw )
		u_drawmgr:add( draw )
	end

	local sql2 = string.format( "select * from u_new_draw where srecvtime = ( select srecvtime from u_new_draw where uid = %s and drawtype = 2 ORDER BY srecvtime DESC limit 1 )" , u:get_csv_id())
	-- local t = skynet.call( util.random_db() , "lua" , "command" , "query" , sql2 )
	local t = query.read(".rdb", "u_new_draw", sql2)
	for i , v in ipairs( t ) do
		--print( " has number" )
		local draw = u_drawmgr:create( v )
		assert( draw )
		u_drawmgr:add( draw )
	end
	self._data["u_drawmgr"] = u_drawmgr
	u.u_drawmgr = u_drawmgr
end	

function cls:get_u_drawmgr( ... )
	-- body
	return self._data["u_drawmgr"]
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

function cls:load_u_lilian_main()
	local u = self:get_user()
	local cls = require "models/u_lilian_mainmgr"
	local u_lilian_mainmgr = cls.new()
	u_lilian_mainmgr:set_user(user)
	u_lilian_mainmgr:load_db({ user_id = u:get_csv_id(), iffinished = 0 })
	self._data["u_lilian_mainmgr"] = u_lilian_mainmgr
	u.u_lilian_mainmgr = u_lilian_mainmgr
	-- local nr = skynet.call( util.random_db() , "lua" , "command" , "select" , "u_lilian_main" , { { user_id = user.csv_id , iffinished = 0 } } )
	-- for i , v in ipairs( nr ) do
	-- 	local a = user.u_lilian_mainmgr:create( v )
	-- 	user.u_lilian_mainmgr:add( a )
	-- end
end

function cls:get_u_lilian_mainmgr( ... )
	-- body
	return self._data["u_lilian_mainmgr"]
end

function cls:load_u_lilian_sub(user)
	local u = self:get_user()
	local cls = require "models/u_lilian_submgr"
	local u_lilian_submgr = cls.new()
	u_lilian_submgr:set_user(user)
	u_lilian_submgr:load_db("fk", user.csv_id)
	self._data["u_lilian_submgr"] = u_lilian_submgr
	u.u_lilian_submgr = u_lilian_submgr
end

function cls:get_u_lilian_submgr( ... )
	-- body
	return self._data["u_lilian_submgr"]
end

function cls:load_u_lilian_qg_num()
	local u = self:get_user()
	local cls = require "models/u_lilian_qg_nummgr"
	local u_lilian_qg_nummgr = cls.new()
	u_lilian_qg_nummgr:set_user(user)
	local date = os.time()
	local sql = string.format( "select * from u_lilian_qg_num where user_id = %s and start_time < %s and %s < end_time" , u:get_csv_id(), date , date)
	-- local nr = skynet.call( util.random_db() , "lua" , "command" , "query" , sql )
	local nr = query.read(user.u_lilian_qg_nummgr.__rdb, "u_lilian_qg_num", sql)
	for i , v in ipairs( nr ) do
		local a = u_lilian_qg_nummgr:create( v )
		u_lilian_qg_nummgr:add( a )
	end
	self._data["u_lilian_qg_nummgr"] = u_lilian_qg_nummgr
	u.u_lilian_qg_nummgr = u_lilian_qg_nummgr
end

function cls:get_u_lilian_qg_nummgr( ... )
	-- body
	return self._data["u_lilian_qg_nummgr"]
end

function cls:load_u_lilian_phy_power()
	local u = self:get_user()
	local cls = require "models/u_lilian_phy_powermgr"
	local u_lilian_phy_powermgr = cls.new()
	u_lilian_phy_powermgr:set_user(user)
	local date = os.time()
	local sql = string.format( "select * from u_lilian_phy_power where user_id = %s and start_time < %s and %s < end_time", u:get_csv_id(), date , date)
	-- local nr = skynet.call( util.random_db() , "lua" , "command" , "query" , sql )
	local nr = query.read(user.u_lilian_phy_powermgr.__rdb, "u_lilian_phy_power", sql)
	for i , v in ipairs( nr ) do
		local a = u_lilian_phy_powermgr:create( v )
		u_lilian_phy_powermgr:add( a )
	end
	self._data["u_lilian_phy_powermgr"] = u_lilian_phy_powermgr
	u.u_lilian_phy_powermgr = u_lilian_phy_powermgr
end 

function cls:get_u_lilian_phy_powermgr( ... )
		-- body
	return self._data["u_lilian_phy_powermgr"]
end	

function cls:load_u_prop()
	-- body
	local u = self:get_user()
	local cls = require "models/u_propmgr"
	local u_propmgr = cls.new()
	u_propmgr:set_user(user)
	u_propmgr:load_db("fk", user.csv_id)
	self._data["u_propmgr"] = u_propmgr
	u.u_propmgr = u_propmgr
end

function cls:get_u_propmgr( ... )
	-- body
	return self._data["u_propmgr"]
end

function cls:load_u_purchase_goods(user)
	-- body
	local u = self:get_user()
	local cls = require "models/u_purchase_goodsmgr"
	local u_purchase_goodsmgr = cls.new()
	u_purchase_goodsmgr:set_user(user)
	u_purchase_goodsmgr:load_db("fk", u:get_csv_id())
	self._data["u_purchase_goodsmgr"] = u_purchase_goodsmgr
	u.u_purchase_goodsmgr = u_purchase_goodsmgr
end

function cls:get_u_purchase_goodsmgr( ... )
	-- body
	return self._data["u_purchase_goodsmgr"]
end

function cls:load_u_purchase_reward()
	-- body
	local u = self:get_user()
	local cls = require "models/u_purchase_rewardmgr"
	local u_purchase_rewardmgr = cls.new()
	u_purchase_rewardmgr:set_user(user)
	u_purchase_rewardmgr:load_db("fk", u:get_csv_id())
	self._data["u_purchase_rewardmgr"] = u_purchase_rewardmgr
	u.u_purchase_rewardmgr = u_purchase_rewardmgr
end

function cls:get_u_purchase_rewardmgr( ... )
	-- body
	return self._data["u_purchase_rewardmgr"]
end

function cls:load_u_recharge_count(user)
	-- body
	local u = self:get_user()
	local cls = require "models/u_recharge_countmgr"
	local u_recharge_countmgr = cls.new()
	u_recharge_countmgr:set_user(user)
	u_recharge_countmgr:load_db("fk", user.csv_id)
	self._data["u_recharge_countmgr"] = u_recharge_countmgr
	u.u_recharge_countmgr = u_recharge_countmgr
end

function cls:get_u_recharge_countmgr( ... )
	-- body
	return self._data["u_recharge_countmgr"]
end

function cls:load_u_recharge_record(user)
	-- body
	local u = self:get_user()
	local cls = require "models/u_recharge_recordmgr"
	local u_recharge_recordmgr = cls.new()
	u_recharge_recordmgr:set_user(user)
	u_recharge_recordmgr:load_db("fk", user.csv_id)
	self._data["u_recharge_recordmgr"] = u_recharge_recordmgr
	u.u_recharge_recordmgr = u_recharge_recordmgr
end

function cls:get_u_recharge_recordmgr( ... )
	-- body
	return self._data["u_recharge_recordmgr"]
end

function cls:load_u_recharge_reward()
	-- body
	local u = self:get_user()
	local cls = require "models/u_recharge_rewardmgr"
	local u_recharge_rewardmgr = cls.new()
	u_recharge_rewardmgr:set_user(user)
	u_recharge_rewardmgr:load_db("fk", user.csv_id)
	self._data["u_recharge_rewardmgr"] = u_recharge_rewardmgr
	u.u_recharge_rewardmgr = u_recharge_rewardmgr
end

function cls:get_u_recharge_recordmgr( ... )
	-- body
	return self._data["u_recharge_rewardmgr"]
end

function cls:load_u_recharge_vip_reward()
	-- body
	local u = self:get_user()
	local cls = require "models/u_recharge_vip_rewardmgr"
	local u_recharge_vip_rewardmgr = cls.new()
	u_recharge_vip_rewardmgr:set_user(u)
	u_recharge_vip_rewardmgr:load_db("fk", user.csv_id)
	self._data["u_recharge_vip_rewardmgr"] = u_recharge_vip_rewardmgr
	u.u_recharge_vip_rewardmgr = u_recharge_vip_rewardmgr
end

function cls:get_u_recharge_vip_rewardmgr( ... )
	-- body
	return self._data["u_recharge_vip_rewardmgr"]
end

function cls:load_u_role(user)
	-- body
	local u = self:get_user()
	local cls = require "models/u_rolemgr"
	local u_rolemgr = cls.new()
	u_rolemgr:set_user(user)
	u_rolemgr:load_db("fk", user.csv_id)
	self._data["u_rolemgr"] = u_rolemgr
	u.u_rolemgr = u_rolemgr
end

function cls:get_u_rolemgr( ... )
	-- body
	return self._data["u_rolemgr"]
end

function cls:load_u_journal(user)
	-- body
	local u = self:get_user()
	local cls = require "models/u_journalmgr"
	local u_journalmgr = cls.new()
	u_journalmgr:set_user(user)
	u_journalmgr:load_db("fk", u:get_user())
	self._data["u_journalmgr"] = u_journalmgr
	u.u_journalmgr = u_journalmgr
end

function cls:get_u_journal( ... )
	-- body
	return self._data["u_journalmgr"]
end

function cls:load_u_goods(user)
	-- body
	local u = self:get_user()
	local cls = require "models/u_goodsmgr"
	local u_goodsmgr = cls.new()
	u_goodsmgr:set_user(user)
	u_goodsmgr:load_db("fk", user.csv_id)
	self._data["u_goodsmgr"] = u_goodsmgr
	u.u_goodsmgr = u_goodsmgr
end

function cls:get_u_goodsmgr( ... )
	-- body
	return self._data["u_goodsmgr"]
end

return cls
