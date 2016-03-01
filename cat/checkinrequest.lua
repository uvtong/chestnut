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

	
local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end		
	
function REQUEST:login(u)
	-- body
	assert( u )
	print( "**********************************checkinrequest_login " )
	user = u
	
	checkin_mgr = user.u_checkinmgr
	checkin_month_mgr = user.u_checkin_monthmgr
	assert( checkin_mgr )
	assert( checkin_month_mgr )
end		
	
-- msg: **ifcheckin_t * 1 can check , --0 can not checkin**
	
local function get_g_checkin_by_csv_id( checkin_time , checkin_month )
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
	
local function get_g_checkin_month_by_reward_num( reward_num )
	assert( reward_num )
	print( "reward_num is " , reward_num )
	local t = game.g_checkin_totalmgr:get_by_id( reward_num )
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
	
	print( "*********************************get_accumulate_reward" )
	local r = Split( t.prop_id_num , "," )
	assert( r )

	for k , v in ipairs( r ) do
		local tmp = {}
		local sub = Split( v , "*" )
		assert( sub )
		tmp.propid = tonumber( sub[ 1 ] )
		tmp.amount = tonumber( sub[ 2 ] )
		print( k , v , sub[ 1 ] , sub[ 2 ] )
		table.insert( ret , tmp )
	end	

	return ret
end	
		
local function add_to_prop( t )
	assert( t )

	for k , v in ipairs( t ) do
		local prop = user.u_propmgr:get_by_csv_id( v.propid )
		if prop then
			prop.num = prop.num + v.amount
			prop:__update_db({"num"})
		else
			print( "propid is " , v.propid )
			local p = game.g_propmgr:get_by_csv_id( v.propid )
			p.user_id = user.csv_id
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
	--local today_start_time 

	local tcheckin = checkin_mgr:get_checkin()
	local tcheckin_month = checkin_month_mgr:get_checkin_month()
	--assert( tcheckin )
	print( tcheckin , tcheckin_month )
	if not tcheckin then
		print ( "*********************** both nill " )
		ret.ifcheckin_t = true
		ret.monthamount = 0 
		--[[local n = {}
		n.csv_id = 0
		n.user_id = user.csv_id
		n.u_checkin_time = 0
		n.ifcheck_in = 1
		--add checkin
		local u = checkin_mgr.create( n )
		assert( u )
		checkin_mgr:add( u )
		tcheckin = u
		tcheckin:__insert_db()

		n = {}
		n.checkin_month = 0
		n.user_id = user.csv_id
		-- add checkin_month
		u = checkin_month_mgr.create( n )
		assert( u )
		checkin_month_mgr:add( u )

		tcheckin_month = u
		tcheckin_month:__insert_db()
		
		--]]
	else
		if tcheckin.u_checkin_time ~= 0 then
			local changed = false
			local date = tonumber( os.date( "%Y%m%d" , tcheckin.u_checkin_time ) )
			print( "date is " , date )
			local y = string.sub( date , 1 , 4 )
			local m = string.sub( date , 5 , 6 )
			
			if year ~= y then
				changed = true	
			elseif month ~= m then
				changed = true
			end

			if changed then
				tcheckin_month.checkin_month = 0
				tcheckin_month:__update_db( { "checkin_month" } )
			end	
		end -- msg "UPDATE month_checkin each month"
		

		if tcheckin.u_checkin_time < today_start_time then
			ret.ifcheckin_t = true
			tcheckin.ifcheck_in = 1
		else
			ret.ifcheckin_t = false
			tcheckin.ifcheck_in = 0
		end
		
		ret.monthamount = tcheckin_month.checkin_month 
	end
	--print( user.checkin_num , ret.rewardnum)
	ret.totalamount = user.checkin_num
	ret.rewardnum = user.checkin_reward_num

	return ret
end	
	
function REQUEST:checkin_aday()
	print( "*-----------------------------* checkin_day is called" )

	local ret = {}
	
	local notexeit = false

	local time = os.time()
	local tcheckin = checkin_mgr:get_checkin()
	local tcheckin_month = checkin_month_mgr:get_checkin_month()
	if not tcheckin then
		tcheckin = {}
		tcheckin_month = {}

		notexeit = true
	end

	if 0 == tcheckin.ifcheck_in then
		if 0 == counter then
			ret.ok = false
			ret.msg = "you wai gua"
			--if this case happens , maybe waigua . then logout game should be callled
		else
			ret.ok = false
			ret.msg = "checkin already"
		end
	else
		counter = counter + 1

		tcheckin.u_checkin_time = time
		tcheckin.ifcheck_in = 0
		tcheckin.user_id = user.csv_id
		tcheckin.csv_id = 0

		if notexeit then
			tcheckin = checkin_mgr.create( tcheckin )
			assert( tcheckin )
			checkin_mgr:add( tcheckin )

			tcheckin_month.checkin_month = 0
			tcheckin_month.user_id = user.csv_id
			tcheckin_month = checkin_month_mgr.create( tcheckin_month )
			assert( tcheckin_month )
			checkin_month_mgr:add( tcheckin_month )
			tcheckin_month:__insert_db()
		end

		print( tcheckin.u_checkin_time )
		tcheckin:__insert_db()

		user.checkin_num  = user.checkin_num + 1
		tcheckin_month.checkin_month = tcheckin_month.checkin_month + 1
		print( "*********************************user_checkin_num " , user.checkin_num )
		local t = get_g_checkin_by_csv_id( time , tcheckin_month.checkin_month )
		add_to_prop( get_aday_reward( t ) )

		user:__update_db( { "checkin_num" } )
		tcheckin_month:__update_db( { "checkin_month" } )	

		ret.ok = true				
	end	

	return ret
end				
		
function REQUEST:checkin_reward()
	assert( self.totalamount and self.rewardnum )
	local ret = {}
	if user.checkin_num ~= self.totalamount or user.checkin_reward_num ~= self.rewardnum then
		ret.ok = false
		ret.msg = "donot match the server totalmount"
		-- logout
	else	
		local t = get_g_checkin_month_by_reward_num( self.rewardnum + 1 )
		
		if  t.totalamount > user.checkin_num  then
			ret.ok = false
			ret.msg = "can not reward"
			-- should logout
		else
			print( "******************************************checkin_reward" )
			user.checkin_reward_num = user.checkin_reward_num + 1
			user:__update_db( { "checkin_reward_num" } )
						
			add_to_prop( get_accumulate_reward( t ) )

			ret.ok = true
		end	
	end		
			
	return ret
end			
			
function RESPONSE:abc()
	-- body	
end			
			
function checkinrequest.start(c, s, g, ...)
	-- body	
	print( "*********************************checkin_start" )
	client_fd = c
	send_request = s
	game = g
end			
			
function checkinrequest.disconnect()
	-- body	
end			
			
checkinrequest.REQUEST = REQUEST
checkinrequest.RESPONSE = RESPONSE
checkinrequest.SUBSCRIBE = SUBSCRIBE

return checkinrequest