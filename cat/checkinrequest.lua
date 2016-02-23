local checkinrequest = {}
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
local dc
local checkin_mgr
local checkin_month_mgr
local REWARD_STEP = 10

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end		
		
function REQUEST:login(user)
	-- body
	assert( user )
	user = user
	checkin_mgr = user.u_checkinmgr
	checkin_month_mgr = user.u_checkin_monthmgr
end		

-- msg: **ifcheckin_t * 1 can check , --0 can not checkin**

	
		
local function get_g_checkin_by_csv_id( checkin_time , checkin_month)
	assert( checkin_time and checkin_month )
			
	local mon = tonumber( os.date( "%m" , checkin_time ) )
			
	-- msg : "below op is for temprory , when the checkin table changes codes change"
	if 12 ~= mon then
		mon = 0
	end

	local t = game.g_checkinmgr:get_by_csv_id( mon * 1000 + checkin_month )
	assert( t )

	return t
end	
	
local function get_aday_reward( t )
	assert( t )
			
	local ret = {}
	local tmp = {}
	tmp.propid = t.g_prop_csv_id
	tmp.amount = t.g_prop_num

	if user.uviplevel ~= 0 and user.uviplevel == t.vip then
		tmp.amount = tmp.amount + t.vip_g_prop_num
	end	

	table.insert( ret , tmp )
	return ret
end	
	
local function get_g_checkin_month_by_totalamount( totalamount )
	assert( totalamount )

	local t = game.g_checkin_totalmgr:get_by_totalamount( totalamount )
	assert( t )

	return t
end	

local function Split(szFullString, szSeparator)  
	local nFindStartIndex = 1  
	local nSplitIndex = 1  
	local nSplitArray = {}  
	while true do  
   		local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)  
   		if not nFindLastIndex then  
    		nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))  
    		break  
   		end  
   		nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)  
   		nFindStartIndex = nFindLastIndex + string.len(szSeparator)  
   		nSplitIndex = nSplitIndex + 1  
	end  
	return nSplitArray  
end
						
local function get_accumulate_reward( t )
	assert( t )

	local ret = {}
	local tmp = {}

	local r = Split( t.prop_id_num , "," )
	assert( r )

	for k , v in ipairs( r ) do
		local sub = Split( v , "*" )
		assert( sub )
		tmp.propid = tonumber( sub[ 1 ] )
		tmp.amount = tonumber( sub[ 2 ] )
		table.insert( ret , tmp )
	end	

	return ret
end	
		
local function add_to_prop( t )
	assert( t )

	for k , v in ipairs( t ) do
		local prop = user.propmgr:get_by_csvid( v.propid )
		if prop then
			prop.num = prop.num + v.amount
			prop:__update_db({"num"})
		else
			local p = game.g_propmgr:get_by_csv_id( v.propid )
			p.user_id = user.id
			p.num = v.amount
			local prop = user.u_propmgr.create(p)
			user.u_propmgr:add(prop)
			prop:__insert_db()
		end
	end		
end		
	
local counter = 0 
	
function REQUEST:checkin()
	-- body
	print( "*-------------------------* checkin is called")

	local ret = {}

	local date = tonumber( os.date( "%Y%m%d" , os.time() ) )
	print( "date is " , date )
	local year = string.sub( date , 1 , 4 )
	local month = string.sub( date , 5 , 6 )
	local day = string.sub( date , 7 , 8 )

	local today_start_time = os.time( { year = year , month = month , day = day , hour = 0 , min = 0 , sec = 0 } )

	local tcheckin = checkin_mgr:get_checkin()
	local tcheckin_month = checkin_month_mgr:get_checkin_month()

	if not tcheckin then
		local n = {}
		n.csv_id = 0
		n.user_id = user.id
		n.u_checkin_time = 0
		n.ifcheckin = 1
		--add checkin
		local u = checkin_mgr.create( n )
		assert( u )
		checkin_mgr:add( u )

		n = {}
		n.user_id = user.id
		n.checkin_month = 0
		-- add checkin_month
		u = checkin_month_mgr.create( n )
		assert( u )
		checkin_month_mgr:add( u )

		ret.ifcheckin_t = true

	else
		if tcheckin.u_checkin_time ~= 0 then
			local changed = false

			if year ~= tonumber( os.date( "%Y" , tcheckin.u_checkin_time ) ) then
				changed = true	
			elseif month ~= tonumber( os.date( "%m" , tcheckin.u_checkin_time ) ) then
				changed = true
			end

			if changed then
				tcheckin_month.checkin_month = 0
				tcheckin_month:__update_db( { "checkin_month" } )
			end	
		end -- msg "UPDATE month_checkin each month"
		
		if tcheckin.u_checkin_time < today_start_time then
			ret.ifcheckin_t = true
			tcheckin.ifcheckin = 1
		else
			ret.ifcheckin_t = false
			tcheckin.ifcheckin = 0
		end
	end

	ret.totalamount = user.check_num
	ret.monthamount = tcheckin_month.checkin_month
	ret.rewardnum = user.get_reward_num

	return ret
end	
	
function REQUEST:checkin_aday()
	print( "*-----------------------------* checkin_day is called" )

	local time = os.time()
	local tcheckin = checkin_mgr:get_checkin()
	local tcheckin_month = checkin_month_mgr:get_checkin_month()
	assert( tcheckin and tcheckin_month )

	if 0 == tcheckin.ifcheckin then
		if 0 == counter then
			ret.ok = false
			ret.msg = "you wai gua"
			--if this case happens , maybe waigua . then logout game should be callled
		else
			ret.ok = false
			ret.msg = "checkin already"
		end
	else
		local ret = {}

		counter = counter + 1
		tcheckin.u_checkin_time = time
		tcheckin.ifcheckin = 0

		user.checkin_num  = user.checkin_num + 1
		tcheckin_month.checkin_month = tcheckin_month.checkin_month + 1

		local t = get_g_checkin_by_csv_id( time , tcheckin_month )
		ret = get_aday_reward( t )
		add_to_prop( ret )

		user:__update_db( { "checkin_num" } )
		tcheckin_month:__update_db( { "checkin_month" } )	

		ret.ok = true				
	end	

	return ret
end				
		
function REQUEST:checkin_get_reward()
	assert( self.totalamount and self.rewardnum )

	local ret = {}
	if user.checkin_num ~= self.totalamount or user.get_reward_num ~= self.rewardnum then
		ret.ok = false
		ret.msg = "donot match the server totalmount"
		-- logout
	else	
		if ( self.rewardnum + 1 ) * REWARD_STEP > user.checkin_num then
			ret.ok = false
			ret.msg = "can not reward"
			-- should logout
		else
			user.get_reward_num = user.get_reward_num + 1
			user.__update_db( { "get_reward_num" } )
			
			local t = get_g_checkin_month_by_totalamount( user.get_reward_num * REWARD_STEP )
			ret = get_accumulate_reward( t )
			add_to_prop( ret )

			ret.ok = true
		end
	end	
	
	return ret
end			
		
function RESPONSE:abc()
	-- body
end			
		
function checkinrequest.start(conf, send_request, game, ...)
	-- body
	client_fd = conf.client
	send_request = send_request
	game = game
	dc = dc 
end		
		
function checkinrequest.disconnect()
	-- body
end		
		
checkinrequest.REQUEST = REQUEST
checkinrequest.RESPONSE = RESPONSE
checkinrequest.SUBSCRIBE = SUBSCRIBE

return checkinrequest