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
local IF_TRIGGER_EVENT = 0
	
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
	
local function update()
	print( "timeout update is called **************************************" )
	send_package( send_request( "lilian_update" ) )
end 
	
local function daily_update()
	print( "daily update is called" )
	local date = os.time()
	local settime = getsettime()

	skynet.timeout( ( settime + ADAY - date ) * 100 , update )
	skynet.sleep( 5 * 100 )
	daily_update()
end 

function REQUEST:login(u)
	-- body
	assert( u )
	print( "**********************************lilianrequest_login " )
	user = u
	--cs = queue()
	--assert( cs )
end		

-- recover phy_power
local function get_phy_power( date )
	print( "user.lilian_level" , user.lilian_level , user.lilian_phy_power ) 
	local r = skynet.call( ".game" , "lua" , "query_g_lilian_level" , user.lilian_level )
	assert( r )
	local iffull = false
	local left = 0

	if r.phy_power > user.lilian_phy_power then
		local diff = ( date - user.u_lilian_submgr.__data[ 1 ].first_lilian_time ) / FIXED_STEP	
	    left = ( date - user.u_lilian_submgr.__data[ 1 ].first_lilian_time ) % FIXED_STEP

		if user.lilian_phy_power + math.floor( diff ) >= r.phy_power then
			user.lilian_phy_power = r.phy_power
			iffull = true
		else
			user.lilian_phy_power = user.lilian_phy_power + math.floor( diff )
		end
		user.u_lilian_submgr.__data[ 1 ].first_lilian_time = date
		user.u_lilian_submgr.__data[1].end_lilian_time = date + FIXED_STEP
		user.u_lilian_submgr.__data[1]:__update_db( { "first_lilian_time" , "end_lilian_time" } , const.DB_PRIORITY_2 )
		print( "get_phy_power is ended*************************************" , user.lilian_phy_power , diff , date , user.u_lilian_submgr.__data[ 1 ].first_lilian_time , left )
	end 			

	return iffull , FIXED_STEP - left;
end 	
		
local function add_to_prop( tprop )
	assert( tprop )

	for k , v in ipairs( tprop ) do
		print( k , v )
		local prop = user.u_propmgr:get_by_csv_id( v.propid )
		if prop then
			prop.num = prop.num + v.propnum
			--prop:__update_db( { "num" } )
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

local function get_part_reward( sr ,format , D )
	assert( sr and format and D  )
	print( "get part reward is called******************************************************" ,sr , format , D) 
	local qg_reward =  util.parse_text( sr , format , D )
	local ret = {}
	local t = {}

	for k , v in ipairs( qg_reward ) do
		print( v[1] , v[2] , v[3] , D, sr)
		if 3 == D then
			local random = math.random( 1000 )
			print( random )
			if 0 <= random and random <= tonumber( v[3] ) then
				print( "get the reward in when finish lilian *****************************" , v[1] , v[2] , v[3] )
				
				table.insert( t , ( v[1] .. "*" .. v[2] ) )
				table.insert( ret , { propid = tonumber( v[1] ) , propnum = tonumber( v[2] ) } )
			end	
		else
			table.insert( ret , { propid = tonumber( v[1] ) , propnum = tonumber( v[2] ) } )
		end 	
	end

	local str_reward = ""
	if 3 == D and #t > 0 then
		str_reward = table.concat(t, "*")
	end

	return ret , str_reward;
end 				
				
local function get_lilian_reward( tr )
	local ret = {}
	assert( tr.quanguan_id )
	local r = skynet.call( ".game" , "lua" , "query_g_lilian_quanguan" , tr.quanguan_id )
	assert( r )
	-- quanguan reward
	local reward = {}
	reward , tr.lilian_reward = get_part_reward( r.reward , "(%d+%*%d+%*%d+%*?)" , 3 )
	tr.if_lilian_reward = 1
	tr:__update_db( { "if_lilian_reward" , "lilian_reward" }, const.DB_PRIORITY_1 )

	return reward
end 	
		
local function get_event_reward( tr )
	local ret = {}
	local reward = {}

	assert( tr.quanguan_id and tr.invitation_id )
	assert(tr.if_trigger_event == 1)
	print( "get_event_reward is called" , tr.quanguan_id , tr.invitation_id )
	--event reward
	local r = skynet.call( ".game" , "lua" , "query_g_lilian_quanguan" , tr.quanguan_id )
	assert( r )

	if 1 == tr.if_trigger_event then
		local te = util.parse_text( r.trigger_event , "(%d+%*?)" , 1 )
		assert( te )

		local random = math.random( #te )
		local t = skynet.call( ".game" , "lua" , "query_g_lilian_event" , te[random][1] )
		assert( t )

		reward , tr.event_reward = get_part_reward( t.reward ,"(%d+%*%d+%*%d+%*?)" , 3 )
		tr.if_event_reward = 1
		print( "ifeventreward and eventreazrd is " , tr.if_event_reward , tr.event_reward )
		tr:__update_db( { "if_event_reward", "event_reward" }, const.DB_PRIORITY_1 )
	end 

	return reward
end 

local function deal_finish_lilian( tr )
	print( "deal finish_lilian is called**************************************" )
	assert( tr and tr.if_lilian_reward ~= 0 )

	local r = skynet.call( ".game" , "lua" , "query_g_lilian_quanguan" , tr.quanguan_id )
	assert( r )

	local reward = get_part_reward( tr.lilian_reward , "(%d+%*%d+%*?)" , 2 )
	add_to_prop( reward )

	user.lilian_exp = user.lilian_exp + r.reward_exp --may trigger level up
	
	--invitation reward
	local ir = skynet.call( ".game" , "lua" , "query_g_lilian_invitation" , tr.invitation_id )
	assert( ir )
	reward = {}
	reward = get_part_reward( ir.reward , "(%d+%*%d+%*?)" , 2 )
	add_to_prop( reward )

	--judge if can levelup
	assert( user.lilian_level ~= 0 )
	local ll = skynet.call( ".game" , "lua" , "query_g_lilian_level" , user.lilian_level )	
	assert( ll )	
	print( "user.lilain_exp , ll.experience" , user.lilian_exp , ll.experience )
	if user.lilian_exp >= ll.experience then
		user.lilian_level = user.lilian_level + 1
		user.lilian_exp = user.lilian_exp - ll.experience
		tr.iflevel_up = 1
		tr:__update_db( { "iflevel_up" }, const.DB_PRIORITY_1 )
	end

	return reward
end 
	
local function deal_finish_event( tr )
	assert( tr )
	local reward = get_event_reward( tr )
	add_to_prop(reward)
	local r = assert( user.u_lilian_submgr.__data[1] )
	--update used queue num
	if r.start_time <= tr.start_time and tr.start_time <= r.update_time then 
		r.used_queue_num = r.used_queue_num - 1
		print( "finish event is called " , r.used_queue_num )
		r:__update_db( { "used_queue_num" } , const.DB_PRIORITY_2 )
	end 
	print( "tr.iffiniseed in deal_finish_event is " , tr.iffiniseed )
	
	return reward
end 	
		
local function trigger_event( tr )
	assert( tr )
	local rand_num = math.random( 10000 ) % 100 
	local iftrigger = false
	local lq = skynet.call( ".game" , "lua" , "query_g_lilian_quanguan" , tr.quanguan_id )
	assert( lq )	

	print( "randnom is *************************" , rand_num )
	if 0 <= rand_num and rand_num <= lq.trigger_event_prop then
		print( "trigger_event is ************************" , lq.trigger_event )
	    local te = util.parse_text( lq.trigger_event , "(%d+%*?)" , 1 )
		assert( te )
		
		random = math.random( #te )
	    local t = skynet.call( ".game" , "lua" , "query_g_lilian_event" , te[random][1] )
		assert( t )
		local ll = skynet.call( ".game" , "lua" , "query_g_lilian_level" , user.lilian_level )
		assert( ll )
		
		tr.if_trigger_event = 1
		tr.eventid = te[random][1]
		tr:__update_db( { "if_trigger_event" , "eventid" } , const.DB_PRIORITY_2 ) 
		tr.event_end_time = math.floor( t.cd_time * ( 1 - ll.dec_weikun_time / 100 ) )                --get final eventtime
		iftrigger = true
		print( "trigger a event *******************************************" , tr.eventid )
	end 

	return iftrigger        
end 	

local function get_reward_lilist( tr , rtype )
	assert( tr and rtype )	
	local reward = {}
	if 1 == rtype then
		if 0 == tr.if_lilian_reward then
			reward = get_lilian_reward( tr )
		else
			reward = get_part_reward( tr.lilian_reward , "(%d+%*%d+%*?)" , 2 )
		end
	elseif 2 == rtype then
		if 0 == tr.if_event_reward then
			reward = get_event_reward( tr )
		else
			reward = get_part_reward( tr.event_reward , "(%d+%*%d+%*?)" , 2 )
		end
	else
		assert(false)
	end

	return reward
end

local LL_OVER = { NOTOVER = 0 , OVER = 1 }
local DELAY_TYPE = { LILIAN = 1 , EVENT = 2 , LILIAN_FINISH = 3 , EVENT_FINISH = 4 }
	
function REQUEST:get_lilian_info()
	-- body 
	print( "*-------------------------* get_lilian_info is called" )

	local ret = {}
	ret.basic_info = {}
	local date = os.time()
    local settime = getsettime()
    local r = user.u_lilian_submgr:get_lilian_sub()

    --judge if there is a lilian that triggered a event not finished,only one can trigger event
    for k , v in pairs( user.u_lilian_mainmgr.__data ) do
    	if 1 == v.if_trigger_event and date < v.event_end_time then
    		IF_TRIGGER_EVENT = 1
    		break                                               
    	end 	
    end      	

	--if quanguan can lilian
	--u_lilian_mainmgr records each lilian that is not finised 
	for k , v in pairs( user.u_lilian_mainmgr.__data ) do
		local tmp = {}

		local date = os.time()
		print( "date is , v.end_time is " , date , v.end_time , date >= v.end_time )
						
		if date >= v.end_time then
			print( "if_lilian_reward" , v.if_lilian_finished )
			if 0 == v.if_lilian_finished then
				--tmp.reward = deal_finish_lilian( v )
				print( "send lilian reward **************************************" )
				tmp.reward = get_reward_lilist( v , 1 )
				tmp.if_lilian_reward = 1				
				tmp.invitation_id = v.invitation_id			
				tmp.left_cd_time = 0
				
				tmp.if_trigger_event = 0		   	
				tmp.delay_type = DELAY_TYPE.LILIAN_FINISH    
			else    	
				if date >= v.event_end_time then
					tmp.reward = get_reward_lilist(v, 2)
					--IF_TRIGGER_EVENT = 0
					print( "both finished *******************************" , v.eventid )
					tmp.delay_type = DELAY_TYPE.EVENT_FINISH
					tmp.if_event_reward = 1
					tmp.eventid = v.eventid
					tmp.left_cd_time = 0
					tmp.errorcode = errorcode[1].code
				else     
					IF_TRIGGER_EVENT = 1
					print( "lilian finished , event not finished*******************************" )
					tmp.left_cd_time = v.event_end_time - date
					tmp.delay_type = DELAY_TYPE.EVENT
					tmp.errorcode = errorcode[85].code
				end 						
			end    	    					
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
			r.used_queue_num = 0
			r:__update_db( { "used_queue_num" } , const.DB_PRIORITY_2 )
			user.u_lilian_qg_nummgr:clear_by_settime( settime )
		end      

		local t = skynet.call( ".game" , "lua" , "query_g_lilian_level" , user.lilian_level )
		assert( t )
		if user.lilian_phy_power >= t.phy_power then
			ret.phy_power_left_cd_time = 0
		else       
			if date >= r.end_lilian_time then
				local _ , left = get_phy_power(date)
				ret.phy_power_left_cd_time = left
			else
				ret.phy_power_left_cd_time = r.end_lilian_time - date
			end 
		end     
	end         
                
	ret.lilian_num_list = user.u_lilian_qg_nummgr:get_lilian_num_list()
                
	ret.level = user.lilian_level
			
	ret.phy_power = user.lilian_phy_power + user.purch_lilian_phy_power
	ret.lilian_exp = user.lilian_exp
	print( "error is called ********************************" , errorcode[1].code , user.lilian_phy_power )
	ret.purch_phy_power_num = user.u_lilian_phy_powermgr:get_count()
	ret.present_phy_power_num = user.lilian_phy_power
	ret.errorcode = errorcode[ 1 ].code
	ret.msg = errorcode[ 1 ].msg

	daily_update()

	return ret  
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

		if user.lilian_level < lq.open_level or user.lilian_phy_power + user.purch_lilian_phy_power < lq.need_phy_power or not prop or prop.num <= 0 then  -- leck an invitation condigion judge.
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
				rs.used_queue_num = 0 --fqn.queue
					
				rs = user.u_lilian_submgr.create( rs )
				assert( rs )
				user.u_lilian_submgr:add( rs )
				rs:__insert_db( const.DB_PRIORITY_1 )
			else    
				if settime > rs.start_time then
					rs.start_time = settime
					rs.update_time = rs.start_time + ADAY
					rs.used_queue_num = 0 --fqn.queue
					rs:__update_db( { "used_queue_num" } , const.DB_PRIORITY_2 )
				end  
				print( "compared used_queue_num*******************************" , rs.used_queue_num , fqn.queue )
				if rs.used_queue_num >= fqn.queue then
					ret.errorcode = errorcode[84].code
					ret.msg = errorcode[84].msg

					return ret
				end 
			end     

			--start deal with lilian_mai 
			--TODO leck judge
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
				lqgn.reset_num = 0

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
			nr.if_trigger_event = 0
			nr.event_end_time = 0
			nr.eventid = 0   
			--nr.if_trigger_event , nr.event_end_time , nr.eventid = get_total_delay_time( lq , fqn )
			nr.iflevel_up = 0
			nr.csv_id = self.quanguan_id + nr.start_time + lilian_num
			nr.event_start_time = 0
			nr.if_lilian_finished = 0
			nr.if_canceled = 0
			nr.if_event_canceled = 0
			nr.if_lilian_reward = 0
			nr.if_event_reward = 0
			nr.lilian_reward = 0
			nr.event_reward = 0

			print( "start_time and end_time is " , nr.start_time , nr.end_time  , os.time() )
			nr = user.u_lilian_mainmgr.create( nr )
			user.u_lilian_mainmgr:add( nr )
			nr:__insert_db( const.DB_PRIORITY_2 )
         	        
		 	prop.num = prop.num - 1
		 	rs.used_queue_num = rs.used_queue_num + 1
		 	print( "start_lilian is called sub**********" , rs.used_queue_num )
		 	rs:__update_db( { "used_queue_num" } , const.DB_PRIORITY_2 )
		 	if user.lilian_phy_power >= lq.need_phy_power then
		 		user.lilian_phy_power = user.lilian_phy_power - lq.need_phy_power
		 	else
		 		user.purch_lilian_phy_power = user.purch_lilian_phy_power + user.lilian_phy_power - lq.need_phy_power 
		 		user.lilian_phy_power = 0 
		 	end
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
	local ret = {}                
	local date = os.time() 
	local r = user.u_lilian_submgr:get_lilian_sub()

	print( "lilian_get_phy_power is called********************" , date , r.end_lilian_time )

	if r then        
		if date >= r.end_lilian_time then
			ret.errorcode = errorcode[1].code
			local sign , left = get_phy_power(date)
			print( sign , left )
			if sign then 
				ret.left_cd_time = 0
			else
				ret.left_cd_time = left
			end
		else
			ret.errorcode = errorcode[85].code          
			ret.left_cd_time = r.end_lilian_time - date
		end  
	else
		ret.errorcode = errorcode[1].code
		ret.left_cd_time = 0		
	end 
	ret.phy_power = user.lilian_phy_power + user.purch_lilian_phy_power
    print( "user.lilian_phy_power is " , user.lilian_phy_power , user.purch_lilian_phy_power)
	return ret        
end	     			
	     			
local function inc_lilian( r , date )
	assert( r and date )		

	local ret = {}	

	if 1 == r.if_lilian_finished then
			ret.errorcode = errorcode[86].code
			ret.msg = errorcode[86].msg
			return ret
	else    	
		print( "in lilian_reward********************************", user.lilian_level )
		ret.reward = get_lilian_reward( r )

		ret.errorcode = errorcode[1].code
		ret.invitation_id = r.invitation_id

		r.if_canceled = 1
		r.end_time = date
		r:__update_db( { "if_canceled" , "end_time" } , const.DB_PRIORITY_1 )
	end 

	return ret
end 	

local function inc_event( r , date )
	assert( r and date )
	local ret = {}

	if 1 == r.iffinished then
		ret.errorcode = errorcode[87].code
		ret.msg = errorcode[87].msg
		return ret
	else
		print( "in event_reward********************************" )
		ret.reward = get_event_reward( r )
		
		IF_TRIGGER_EVENT = 0
		ret.if_event_reward = 1
		ret.eventid = r.eventid
		ret.errorcode = errorcode[1].code

		r.if_event_canceled = 1
		r.event_end_time = date 
		r:__update_db( { "if_event_canceled" , "event_end_time" } , const.DB_PRIORITY_1 )
	end 
		
	return ret
end 
	
function REQUEST:lilian_rewared_list()
	print( "lilian_reward_list is called&&&&&&&&&&&&&&&&&&&&&&&&" , self.quanguan_id , self.rtype )
	assert( self.quanguan_id and self.rtype )
	local ret = {}
	local date = os.time()

	local r = user.u_lilian_mainmgr:get_by_csv_id( self.quanguan_id )
	assert( r )

	if DELAY_TYPE.LILIAN == self.rtype then

		if date >= r.end_time then
			ret.reward = get_reward_lilist(r, self.rtype)
			ret.invitation_id = r.invitation_id
			ret.errorcode = errorcode[1].code
		else
			ret.errorcode = errorcode[81].code
			ret.left_cd_time = r.end_time - date
		end
	elseif DELAY_TYPE.EVENT == self.rtype then
		if date >= r.event_end_time then
			ret.reward = get_reward_lilist(r , self.rtype)
			print( "get reward in event ***********************" , ret.reward[1].propid , ret.reward[1].propnum )
			IF_TRIGGER_EVENT = 0
			ret.errorcode = errorcode[1].code
		else
			ret.errorcode = errorcode[81].code
			ret.left_cd_time = r.event_end_time - date
		end
	else
		assert(false)
	end

	return ret
end 
		
function REQUEST:lilian_get_reward_list()
	print( "lilian_get_reward_list is called **************" , self.quanguan_id , self.reward_type )
	assert( self.quanguan_id and self.reward_type )
	local ret = {}
	local date = os.time()
	
	local r = user.u_lilian_mainmgr:get_by_csv_id( self.quanguan_id )
	assert( r ) 

	if DELAY_TYPE.LILIAN == self.reward_type then
		if 1 == r.if_lilian_finished then
			ret.errorcode = errorcode[86].code
			ret.msg = errorcode[86].msg
			return ret
		else    
			if date >= r.end_time then
				print( "in lilian_reward********************************", user.lilian_level )
				deal_finish_lilian( r )
				print( "deal_finish_lilian in reward" )
				local sign = false

				if 0 == IF_TRIGGER_EVENT then
					sign = trigger_event( r )
					
					if sign then
						print( "trigger event finished " , sign , IF_TRIGGER_EVENT)
						IF_TRIGGER_EVENT = 1
						ret.if_trigger_event = 1
						ret.left_cd_time = r.event_end_time
						r.event_end_time = r.event_end_time + date

						r:__update_db( { "event_end_time" } , const.DB_PRIORITY_2 ) 
					end 
				end

				if not sign then
					local tmp = assert( user.u_lilian_submgr.__data[1] )
					tmp.used_queue_num = tmp.used_queue_num - 1
					tmp:__update_db( { "used_queue_num" } , const.DB_PRIORITY_2 )
					ret.if_trigger_event = 0
					r.iffinished = 1
				end
				print( "finished is " , r.iffinished )
				ret.if_lilian_finished = r.if_lilian_finished
				ret.if_lilian_reward = 1
				ret.lilian_level = user.lilian_level
				print( "in lilian_reward********************************", user.lilian_level )
				ret.lilian_exp = user.lilian_exp
				ret.errorcode = errorcode[1].code
			else
				ret.errorcode = errorcode[81].code
				ret.left_cd_time = r.end_time - date
			end 

			r.if_lilian_finished = 1
			r:__update_db( { "if_lilian_finished" } , const.DB_PRIORITY_2 )

			if 1 == r.iffinished then
				print( "delete finished is called8888888****************************" )
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
			print( "in event_reward********************************" , date , r.event_end_time , date >= r.event_end_time )
			if date >= r.event_end_time then
				deal_finish_event( r )
				print( "deal_finish_event is finished ********************************" )
				--IF_TRIGGER_EVENT = 0
				ret.iffinished = 1
				ret.if_event_reward = 1
				ret.eventid = r.eventid
				ret.errorcode = errorcode[1].code

				print( "delete finished is called8888888****************************" )
				r.iffinished = 1
				r:__update_db( { "iffinished" } , const.DB_PRIORITY_1 )
				user.u_lilian_mainmgr:delete_by_csv_id( r.quanguan_id )
			else
				ret.errorcode = errorcode[81].code
				ret.left_cd_time = r.event_end_time - date
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
	print( "pn is *********************************************************" , pn )
	if 0 == pn then
		ifpurch = true
	else
		local r = user.u_lilian_phy_powermgr:get_one()
		assert( r )
		if r.start_time < settime then
			user.u_lilian_phy_powermgr:clear()
			ifpurch = true
		else    
			if pn >= user.purchase_hp_count_max then
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

	--local _, left =  get_phy_power(date)
	print("user.lilian_phy_power + r" ,user.lilian_phy_power , user.lilian_phy_power + r , g.phy_power )
	
	user.purch_lilian_phy_power = user.purch_lilian_phy_power + r
	
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.phy_power = user.lilian_phy_power + user.purch_lilian_phy_power
	--ret.left_cd_time = left
	print( "lilian_purch_phy_power is called**********************************sdasdasd" , user.lilian_phy_power , user.purch_lilian_phy_power,ret.phy_power )
	return ret
end 
	
local INC_TYPE = { LILIAN = 1 , EVENT = 2 }
local CONSUMU_PER_SEC = 2

function REQUEST:lilian_inc()
	assert( self.quanguan_id and self.inc_type )
	print( "lilian_inc is called*****************************" , self.quanguan_id , self.inc_type)
	local ret = {}	
	local date = os.time()

	local r = user.u_lilian_mainmgr:get_by_csv_id( self.quanguan_id )
	assert( r ) 
	if date >= r.end_time

	local not_enough_prop = false
	--cost 	
	local prop = user.u_propmgr:get_by_csv_id( const.DIAMOND )
	local total_consume = 0
	local tl = 0

	if self.inc_type == INC_TYPE.LILIAN then
		if date > r.end_time then
			ret.errorcode = errorcode[91].code

			return ret
		else
			tl = r.end_time - date
			print( "in lilian *************************************" , r.end_time , date , r.end_time - date , CONSUMU_PER_SEC , tl, total_consume )

			assert( tl >= 0 )
			total_consume = tl * CONSUMU_PER_SEC

			if not prop or prop.num < total_consume then
				not_enough_prop = true
			else
				ret = inc_lilian( r , date )
			end 
		end
	else    
		print( "in event *************************************" , r.event_end_time , date , r.event_end_time - date )
		if date > r.event_end_time then
			ret.errorcode = errorcode[91].code
			return ret
		else
			tl = r.event_end_time - date
			assert( tl >= 0 )
			total_consume = tl * CONSUMU_PER_SEC 
			if not prop or prop.num < total_consume then
				not_enough_prop = true
			else
				ret = inc_event( r , date )
			end	
		end
	end 

	if not_enough_prop then
		ret.errorcode = errorcode[6].code
		ret.msg = errorcode[6].msg
	else
		prop.num = prop.num - total_consume
		ret.diamond_num = prop.num
	end
	print( "ret.diamond_num is , prop.num is " , ret.diamond_num, prop.num )

	return ret
end
				
function REQUEST:lilian_reset_quanguan()
	assert( self.quanguan_id )
	print( "lilian_reset_quanguan is called**********************************" )

	local ret = {}
	local t = user.u_lilian_qg_nummgr:get_by_csv_id( self.quanguan_id )
	local r = skynet.call( ".game" , "lua" , "query_g_lilian_quanguan" , self.quanguan_id )
	print( t.num , r.day_finish_time , t.reset_num , user.purchase_hp_count_max)
	if not t or t.num < r.day_finish_time or t.reset_num >= user.purchase_hp_count_max then
		ret.errorcode = errorcode[90].code
		ret.msg = errorcode[90].msg
	else      
		local cd = skynet.call( ".game" , "lua" , "query_g_lilian_phy_power" , t.reset_num + 1 )
		assert( cd )
		local prop = user.u_propmgr:get_by_csv_id( const.DIAMOND )
		if not prop or prop.num < cd.reset_quanguan_dioment then
			ret.errorcode = errorcode[6].code
			ret.msg = errorcode[6].msg
		else
			t.reset_num = t.reset_num + 1
			t.num = 0
			prop.num = prop.num - cd.reset_quanguan_dioment
			ret.reset_num = t.reset_num
			ret.errorcode = errorcode[1].code
			ret.msg = errorcode[1].msg
			print( "reset quanguan is caleld " , prop.num , cd.reset_quanguan_dioment )
		end 
	end 	

	return ret	
end

function lilian_request.start(c, s, g, ...)
	-- body	
	print( "*********************************lilian_start" )
	client_fd = c
	send_request = s
	game = g
end			

function RESPONSE:lilian_update()
	assert( self.errorcode and self.msg )
	if errorcode[1].errorcode ~= self.errorcode then
		daily_update()
	end
end
			
function lilian_request.disconnect()
	-- body	
end			
			
lilian_request.REQUEST = REQUEST
lilian_request.RESPONSE = RESPONSE
lilian_request.SUBSCRIBE = SUBSCRIBE
		
return lilian_request