local lilian_request = {}
local dc = require "datacenter"
local util = require "util"
local errorcode = require "errorcode"
local const = require "const"
local socket = require "socket"
local skynet = require "skynet"
local queue = require "skynet.queue"

local UPDATETIME = 17

local cs
local FIXED_STEP = 60 --sec
local ADAY = 24 * 60 * 60

local send_package
local send_request

local REQUEST = {}
local RESPONSE = {}
local SUBSCRIBE = {}
local client_fd

local game
local user
local dc
local record_date = {}

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end		

function REQUEST:login(u)
	-- body
	assert( u )
	print( "**********************************lilianrequest_login " )
	user = u
	cs = queue()
	assert( cs )
end		
	
-- recover phy_power
local function get_phy_power( date )
	print( "user.lilian_level" , user.lilian_level ) 
	local r = skynet.call( ".game" , "lua" , "query_g_lilian_level" , user.lilian_level )
	assert( r )
	local sign = false
	local left = 0

	if r.phy_power > user.lilian_phy_power then
		
		local diff = ( date - user.u_lilian_submgr.__data[ 1 ].first_lilian_time ) / FIXED_STEP	
	    left = ( date - user.u_lilian_submgr.__data[ 1 ].first_lilian_time ) % FIXED_STEP

		if user.lilian_phy_power + math.floor( diff ) >= r.phy_power then
			user.lilian_phy_power = r.phy_power
		else
			user.lilian_phy_power = user.lilian_phy_power + math.floor( diff )
			user.u_lilian_submgr.__data[ 1 ].first_lilian_time = date
			user.u_lilian_submgr.__data[1].end_lilian_time = date + FIXED_STEP
			user.u_lilian_submgr.__data[1]:__update_db( { "first_lilian_time" , "end_lilian_time" } , const.DB_PRIORITY_2 )
		end

		sign = true
	end 			
		
	return sign , FIXED_STEP - left;
end 	
		
local function add_to_prop( tprop )
	assert( tprop )

	for k , v in ipairs( tprop ) do
		local prop = user.u_propmgr:get_by_csv_id( v.propid )
		if prop then
			prop.num = prop.num + v.propnum
			prop:__update_db( { "num" } )
		else
			local p = game.g_propmgr:get_by_csv_id( v.propid )
			p.user_id = user.csv_id
			p.num = v.propnum
			local prop = user.u_propmgr.create( p )
			user.u_propmgr:add( prop )
			prop:__insert_db( const.DB_PRIORITY_2 )
		end
		-- TRIGGER ACHIEVEMENT
	end
end				
				
local function get_part_reward( sr , tmp , format , D )
	assert( sr and tmp and format and D  )

	local qg_reward =  util.parse_text( sr , format , D )
	for k , v in ipairs( qg_reward ) do
		if tmp[tostring(v[1])] then
			tmp[tostring(v[1])] = tmp[tostring(v[1])] + v[2]
		else
			tmp[tostring(v[1])] = v[2]
		end
	end 
end 			
				
local function get_lilian_reward( quanguan_id , invitation_id )
	local ret = {}
	local tmp = {}
	assert( quanguan_id and invitation_id )
	local r = skynet.call( ".game" , "lua" , "query_g_lilian_quanguan" , quanguan_id )
	assert( r )
	-- quanguan reward
	get_part_reward( r.reward , tmp , "(%d+%*%d+%*?)" , 2 )
	
	--quanguan exp_reward
	user.lilian_exp = user.lilian_exp + r.reward_exp --may trigger level up

	--event reward
	if 1 == if_trigger_event then
		local te = util.parse_text( r.trigger_event , "(%+*?)" , 1 )
		assert( te )

		for k , v in ipairs( te ) do
			local t = skynet.call( ".game" , "lua" , "query_g_lilian_event" , v )
			assert( t )
			get_part_reward( t.reward , tmp , "(%d+%*%d+%*?)" , 2 )
		end 
	end 
	
	--invitation reward
	local ir = skynet.call( ".game" , "lua" , "query_g_lilian_invitation" , invitation_id )
	assert( ir )
	get_part_reward( ir.reward , tmp , "(%d+%*%d+%*?)" , 2 )

	for k , v in pairs( tmp ) do
		table.insert( ret , { propid = tonumber(k) , propnum = v } )	
	end

	add_to_prop( ret )
end 
	
local function get_event_reward( quanguan_id , invitation_id )
	local ret = {}
	local tmp = {}
	assert( quanguan_id and invitation_id )

	--event reward
	if 1 == if_trigger_event then
		local te = util.parse_text( r.trigger_event , "(%+*?)" , 1 )
		assert( te )

		for k , v in ipairs( te ) do
			local t = skynet.call( ".game" , "lua" , "query_g_lilian_event" , v )
			assert( t )
			get_part_reward( t.reward , tmp , "(%d+%*%d+%*?)" , 2 )
		end 
	end 

	for k , v in pairs( tmp ) do
		table.insert( ret , { propid = tonumber(k) , propnum = v } )	
	end

	add_to_prop( ret )
end 
	
local function getsettime()
	local date = os.time()
	local year = tonumber( os.date( "%Y" , date ) )
	local month = tonumber( os.date( "%m" , date ) )
	local day = tonumber( os.date( "%d" , date ) )
	local hightime = { year = year , month = month , day = day , hour = UPDATETIME , min = 0 , sec = 0 }
	local hour = tonumber( os.date( "%H" , date ) )
	local settime
	if 0 <= hour and hour < UPDATETIME then
		settime = os.time( hightime ) - 60 * 60 * 24
	else
		settime = os.time( hightime )
	end
		
	return settime
end			

local function deal_finish_lilian( tr )
	print( "deal finish_lilian is called**************************************" )
	assert( tr )
	get_lilian_reward( tr.quanguan_id , tr.invitation_id )

	--judge if can levelup
	assert( user.lilian_level ~= 0 )
	local ll = skynet.call( ".game" , "lua" , "query_g_lilian_level" , user.lilian_level )	
	assert( ll )	
	if user.lilian_exp >= ll.experience then
		user.lilian_level = user.lilian_level + 1
		user.lilian_exp = user.lilian_exp - ll.experience
		tr.iflevel_up = 1
	end
	
	tr.if_lilian_finished = 1
	if 0 == tr.if_trigger_event	then
		tr.iffinished = 1
	end

end

local function deal_finish_event( tr )
	assert( tr )
	get_event_reward( tr.quanguan_id , tr.invitation_id )

	local r = assert( user.u_lilian_submgr.__data[1] )
	--update used queue num
	if r.start_time < tr.start_time and tr.start_time < r.update_time then 
		r.used_queue_num = r.used_queue_num + 1
		print( "finish event is called " , r.used_queue_num )
		r:__update_db( { "used_queue_num" } , const.DB_PRIORITY_2 )
	end
	tr.iffinished = 1
	print( "tr.iffiniseed in deal_finish_event is " , tr.iffiniseed )
		
end

local LL_OVER = { NOTOVER = 0 , OVER = 1 }
local DELAY_TYPE = { LILIAN = 1 , EVENT = 2 }
				
function REQUEST:get_lilian_info()
	-- body 
	print( "*-------------------------* get_lilian_info is called" )

	local ret = {}
	ret.basic_info = {}
	local date = os.time()
    	
    local r = user.u_lilian_submgr:get_lilian_sub()
	--if quanguan can lilian
	for k , v in pairs( user.u_lilian_mainmgr.__data ) do
		local tmp = {}

		local date = os.time()
		print( "date is , v.end_time is " , date , v.end_time , date >= v.end_time )
		
		if date >= v.end_time then
			print( "if_lilian_reward" , v.if_lilian_finished  , v.if_lilian_finished )
			if 0 == v.if_lilian_finished then
				deal_finish_lilian( v )
				tmp.if_lilian_reward = 0
			else
				tmp.if_lilian_reward = 1
			end

			if 1 == v.if_trigger_event then
				if date >= v.event_end_time then
				print( "both finished *******************************" )
					deal_finish_event( v )
					tmp.left_cd_time = 0
					
					tmp.if_event_reward = 0
					tmp.errorcode = errorcode[1].code
				else
					print( "lilian finished , event not finished*******************************" )
					tmp.left_cd_time = v.event_end_time - date
					tmp.delay_type = DELAY_TYPE.EVENT
					tmp.errorcode = errorcode[85].code
				end 
			else	
				deal_finish_lilian( v )
				tmp.errorcode = errorcode[1].code
			end
			
			if 0 == tmp.if_lilian_reward then
				tmp.invitation_id = v.invitation_id
			end	
			tmp.if_trigger_event = v.if_trigger_event
			

			if 1 == v.if_lilian_finished then
				v:__update_db( { "if_lilian_finished" } , const.DB_PRIORITY_2 )
				--user.u_lilian_mainmgr:delete_by_csv_id( v.quanguan_id )
			end

			if 1 == v.iffinished then
				v:__update_db( { "iffinished" } , const.DB_PRIORITY_2 )
				user.u_lilian_mainmgr:delete_by_csv_id( v.quanguan_id )
			end
			print( "v.iffinished is ***********************" , v.iffinished )
		else
			print( "lilian not finished *******************************", DELAY_TYPE.LILIAN )
			tmp.delay_type = DELAY_TYPE.LILIAN
			tmp.left_cd_time = v.end_time - date
			tmp.invitation_id = v.invitation_id
			tmp.errorcode = errorcode[81].code
		end
 		tmp.quanguan_id = v.quanguan_id

		table.insert( ret.basic_info , tmp )
	end 		

	local settime = getsettime()
	if r then
		--time to update 
		if r.start_time < settime then
			local fqn = skynet.call( ".game" , "lua" , "query_g_lilian_level" , user.lilian_level )
			r.start_time = settime
			r.update_time = r.start_time + ADAY
			r.used_queue_num = fqn.queue
			r:__update_db( { "used_queue_num" } , const.DB_PRIORITY_2 )
			user.u_lilian_qg_nummgr:clear_by_settime( settime )
		-- else
		-- 	if 0 ~= finished_num then
		-- 		r.used_queue_num = r.used_queue_num + finished_num
		-- 		r:__update_db( { "used_queue_num" } , const.DB_PRIORITY_2 )
		-- 	end
		-- 	print( "r.userd_queue_num is " , r.used_queue_num  , finished_num )
		-- 	assert( r.used_queue_num >= 0 )
		end

		if date >= r.end_lilian_time then
			local _ , left = get_phy_power(date)
			ret.phy_power_left_cd_time = left
		else
			ret.phy_power_left_cd_time = r.end_lilian_time - date
		end 
	end

	ret.lilian_num_list = user.u_lilian_qg_nummgr:get_lilian_num_list()

	ret.level = user.lilian_level
	
	ret.phy_power = user.lilian_phy_power
	ret.lilian_exp = user.lilian_exp
	print( "error is called ********************************" , errorcode[1].code , user.lilian_phy_power )
	ret.purch_phy_power_num = user.u_lilian_phy_powermgr:get_count()
	ret.errorcode = errorcode[ 1 ].code
	ret.msg = errorcode[ 1 ].msg

	return ret  
end					
				
local function get_total_delay_time( lq , fqn )
	assert( lq and fqn )

	--lilian delay
	local ld = lq.time * ( ( 100 - fqn.dec_lilian_time ) / 100 )
	local ed = 0
	local iftrigger = 0

	local rand_num = math.random( 10000 ) % 100 

	print( "randnom is *************************" , rand_num )
	if 0 < rand_num and rand_num < lq.trigger_event_prop then
		print( "trigger_event is ************************" , lq.trigger_event )
		local te = util.parse_text( lq.trigger_event , "(%d+%*?)" , 1 )
		assert( te )

		for k , v in ipairs( te ) do
			print( "te v is ****************" , type(v) , v )
			local t = skynet.call( ".game" , "lua" , "query_g_lilian_event" , tonumber(v[1]) )
			assert( t )

			ed = ed + t.cd_time
		end 
		print( "ed is ************************************" , ed )
		iftrigger = 1
	end
	
	return iftrigger , math.floor( ld + ed * ( ( 100 - fqn.dec_weikun_time ) / 100 ) )
end 
	
function REQUEST:start_lilian()
	print( "*******************************************start_lilian is called" )
	assert( self.quanguan_id )
	local ret = {}	

	local rm = user.u_lilian_mainmgr:get_by_csv_id( self.quanguan_id )
	local rs = user.u_lilian_submgr:get_lilian_sub()
	local lq = skynet.call( ".game" , "lua" , "query_g_lilian_quanguan" , self.quanguan_id )
	local fqn = skynet.call( ".game" , "lua" , "query_g_lilian_level" , user.lilian_level )
	assert( fqn and lq )
	
	local date = os.time()
	local settime = getsettime()
	local total_delay_time = 0

	if rm then    
		ret.errorcode = errorcode[81].code
		ret.msg = errorcode[81].msg

		return ret
	else    
		local prop = user.u_propmgr:get_by_csv_id( self.invitation_id )

		if user.lilian_level < lq.open_level or user.lilian_phy_power < lq.need_phy_power or not prop or prop.num <= 0 then  -- leck a invitation condigion judge.
			ret.errorcode = errorcode[82].code
			ret.msg = errorcode[82].msg

			return ret
		else	
			if not rs then
				rs = {}
				
				rs.csv_id = user.csv_id
				rs.start_time = settime
				rs.first_lilian_time = date
				rs.end_lilian_time = date + FIXED_STEP
				rs.update_time = settime + ADAY
				print( "queue num in level is " , fqn.queue )
				rs.used_queue_num = fqn.queue
			
				rs = user.u_lilian_submgr.create( rs )
				assert( rs )
				user.u_lilian_submgr:add( rs )
				rs:__insert_db( const.DB_PRIORITY_1 )
			else    
				if settime > rs.start_time then
					rs.start_time = settime
					rs.update_time = rs.start_time + ADAY
					rs.used_queue_num = fqn.queue
					rs:__update_db( { "used_queue_num" } , const.DB_PRIORITY_2 )
				end
				print( "compared used_queue_num*******************************" )
				if rs.used_queue_num <= 0 then
					ret.errorcode = errorcode[84].code
					ret.msg = errorcode[84].msg

					return ret
				end
			end     

			--start deal with lilian_mai 
			local lilian_num = 0

			local t = user.u_lilian_qg_nummgr:get_by_csv_id( self.quanguan_id )
			if t and t.start_time == settime then
				t.num = t.num + 1
				lilian_num = t.num
			else
				local lqgn = {}
				lqgn.user_id = user.csv_id
				lqgn.start_time = settime
				lqgn.end_time = settime + ADAY
				lqgn.num = 1
				lqgn.quanguan_id = self.quanguan_id
				lqgn.csv_id = self.quanguan_id  + lqgn.start_time

				lqgn = user.u_lilian_qg_nummgr.create( lqgn )
				user.u_lilian_qg_nummgr:add( lqgn )
				lqgn:__insert_db( const.DB_PRIORITY_2 )

				lilian_num = lqgn.num
			end 

			local nr = {}
			
			nr.user_id = user.csv_id
			nr.quanguan_id = self.quanguan_id
			nr.start_time = date
			nr.iffinished = 0
			nr.invitation_id = self.invitation_id
			nr.end_time = nr.start_time + math.floor( lq.time * ( 1 - fqn.dec_lilian_time / 100 ) )
			nr.if_trigger_event , nr.event_end_time = get_total_delay_time( lq , fqn )
			nr.event_end_time = nr.event_end_time + nr.start_time
			nr.iflevel_up = 0
			nr.csv_id = self.quanguan_id + nr.start_time + lilian_num
			nr.event_start_time = 0
			nr.if_lilian_finished = 0
			print( "start_time and end_time is " , nr.start_time , nr.end_time  , os.time() )
			nr = user.u_lilian_mainmgr.create( nr )
			user.u_lilian_mainmgr:add( nr )
			nr:__insert_db( const.DB_PRIORITY_2 )
         
		 	--get_phy_power(date)
		 	if date >= rs.end_lilian_time then
		 		get_phy_power(date)
		 	end
         
		 	prop.num = prop.num - 1
		 	rs.used_queue_num = rs.used_queue_num - 1
		 	print( "start_lilian is called sub**********" , rs.used_queue_num )
		 	rs:__update_db( { "used_queue_num" } , const.DB_PRIORITY_2 )
		 	user.lilian_phy_power = user.lilian_phy_power - lq.need_phy_power
		 	print( "user.lilian_phy_power is **********************************" , user.lilian_phy_power , rs.used_queue_num , lq.need_phy_power)
		end 		
	end  	
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg		
	ret.left_cd_time = math.floor( lq.time * ( 1 - fqn.dec_lilian_time / 100 ) )
	print( "ret.left_cd_time is ********************************" , ret.left_cd_time )
	return ret                     
end		 			               
		 		                   
function REQUEST:lilian_get_phy_power()
	print(  )
	local ret = {}                
	local date = os.time() 
	local r = user.u_lilian_submgr:get_lilian_sub()

	print( "lilian_get_phy_power is called********************" , date , r.end_lilian_time )

	if r then        
		if date >= r.end_lilian_time then
			ret.errorcode = errorcode[1].code
			local sign , left = get_phy_power(date)
			print( sign , left )
			ret.left_cd_time = left
		else
			ret.errorcode = errorcode[85].code          
			ret.left_cd_time = r.end_lilian_time - date
		end  
	else
		ret.errorcode = errorcode[1].code
		ret.left_cd_time = 0		
	end
	ret.phy_power = user.lilian_phy_power
    print( "user.lilian_phy_power is " , user.lilian_phy_power )
	return ret
end	     
	     
function REQUEST:lilian_get_reward_list()
	print( "lilian_get_reward_list is called **************" , self.quanguan_id , self.reward_type )
	assert( self.quanguan_id and self.reward_type )
	local ret = {}
	local date = os.time()
	for k , v in pairs( user.u_lilian_mainmgr.__data ) do
		print( k , v )
	end  
	local r = user.u_lilian_mainmgr:get_by_csv_id( self.quanguan_id )
	assert( r )
	if DELAY_TYPE.LILIAN == self.reward_type then
		if 1 == r.if_lilian_finished then
			ret.errorcode = errorcode[86].code
			ret.msg = errorcode[86].msg
			return ret
		else
			if date >= r.end_time then
				print( "in lilian_reward********************************" )
				deal_finish_lilian( r )
				ret.if_lilian_finished = r.if_lilian_finished
				if 0 == r.if_trigger_event then
					ret.iffinished = 1
					ret.left_cd_time = 0
				else
					ret.left_cd_time = r.event_end_time - date
				end 
				ret.if_trigger_event = r.if_trigger_event
				ret.if_lilian_reward = 0
				ret.if_event_reward = 1
				ret.invitation_id = r.invitation_id
				ret.iflevel_up = r.iflevel_up
				ret.lilian_level = user.lilian_level
				ret.errorcode = errorcode[1].code
			else
				ret.errorcode = errorcode[81].code
				ret.left_cd_time = r.end_time - date
			end

			if 1 == r.if_lilian_finished then
				r:__update_db( { "if_lilian_finished" } , const.DB_PRIORITY_1 )
				--user.u_lilian_mainmgr:delete_by_csv_id( r.quanguan_id )
			end

			if 1 == r.iffinished then
				r:__update_db( { "iffinished" } , const.DB_PRIORITY_1 )
				user.u_lilian_mainmgr:delete_by_csv_id( r.quanguan_id )
			end
		end 
	elseif DELAY_TYPE.EVENT == self.reward_type then
		if 1 == r.iffinished then
			ret.errorcode = errorcode[87].code
			ret.msg = errorcode[87].msg
			return ret
		else
			print( "in event_reward********************************" )
			if date >= r.event_end_time then
				deal_finish_event( r )
				
				ret.iffinished = 1
				ret.if_lilian_reward = 1
				ret.if_event_reward = 0
				ret.left_cd_time = 0
				ret.errorcode = errorcode[1].code
			else
				ret.errorcode = errorcode[81].code
				ret.left_cd_time = r.event_end_time - date
			end

			if 1 == r.iffinished then
				r:__update_db( { "iffinished" } , const.DB_PRIORITY_2 )
				user.u_lilian_mainmgr:delete_by_csv_id( r.quanguan_id )
			end	
		end
	else
		ret.errorcode = errorcode[88].code
		ret.msg = errorcode[88].msg
	end

	return ret
end			
	
function REQUEST:lilian_purch_phy_power()
	print( "lilian_purch_phy_power is called *******************************" )
	local ret = {}
	local date = os.time()
	local ifpurch = false

	local pn = user.u_lilian_phy_powermgr:get_count()
	local settime = getsettime()
	local prop = user.u_propmgr:get_by_csv_id( const.DIAMOND )
	local t = skynet.call( ".game" , "lua" , "query_g_lilian_phy_power" , pn + 1 )
	local date = os.time()

	assert( t )

	if 0 == pn then
		ifpurch = true
	else
		local r = user.u_lilian_phy_powermgr:get_one()
		assert( r )
		if r.start_time < settime then
			user.u_lilian_phy_powermgr:clear()
			ifpurch = true
		else    
			if pn >= 5 then --user.purchase_hp_count_max then
				ret.errorcode = errorcode[89].code
				ret.msg = errorcode[89].msg

				return ret
			else
				if prop.num < t.dioment then
					ret.errorcode = errorcode[16].code
					ret.msg = errorcode[16].msg
					
					return ret
				else
					ifpurch = true
				end 
			end
		end
	end     

	assert( ifpurch == true )
	local p = {}
	p.user_id = user.csv_id
	p.csv_id = date + pn + 1
	p.start_time = settime
	p.end_time = settime + ADAY
	p.purch_time = date
	p.num = pn + 1 

	p = user.u_lilian_phy_powermgr.create( p )
	assert( p )
	user.u_lilian_phy_powermgr:add( p )
	p:__insert_db( const.DB_PRIORITY_1 )

	prop.num = prop.num - t.dioment	
	local r = skynet.call( ".game" , "lua" , "query_g_config" , "purch_phy_power" )
	assert( r )
	local g = skynet.call( ".game" , "lua" , "query_g_lilian_level" , user.lilian_level )
	assert( g )

	local _, left =  get_phy_power(date)
	print("user.lilian_phy_power + r" ,user.lilian_phy_power , user.lilian_phy_power + r , g.phy_power )
	if user.lilian_phy_power + r > g.phy_power then
		user.lilian_phy_power = g.phy_power
	else
		user.lilian_phy_power = user.lilian_phy_power + r
	end

	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.phy_power = user.lilian_phy_power
	ret.left_cd_time = left
	print( "lilian_purch_phy_power is called**********************************sdasdasd" , user.lilian_phy_power,ret.phy_power )
	return ret
end 	
			
function lilian_request.start(c, s, g, ...)
	-- body	
	print( "*********************************lilian_start" )
	client_fd = c
	send_request = s
	game = g
end			
			
function lilian_request.disconnect()
	-- body	
end			
			
lilian_request.REQUEST = REQUEST
lilian_request.RESPONSE = RESPONSE
lilian_request.SUBSCRIBE = SUBSCRIBE
		
return lilian_request