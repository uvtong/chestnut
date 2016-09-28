local lilian_request = {}

local dc = require "datacenter"
local util = require "util"
local errorcode = require "errorcode"
local const = require "const"
local socket = require "socket"
local skynet = require "skynet"
local queue = require "skynet.queue"
local sd = require "sharedata"

local UPDATETIME = 16 --daily update time 
																																			
local cs
local FIXED_STEP = 60 --sec, used for lilian_phy_power
local ADAY = 24 * 60 * 60
local IF_TRIGGER_EVENT = 0
local MAX_LILIAN_LEVEL = 10
		
local send_package
local send_request
																			
local REQUEST = {}
local RESPONSE = {}
local SUBSCRIBE = {}
local client_fd
local func_gs
local table_gs = {}
		
local game
local user
local dc
local record_date = {}
		
local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end		

--THIS FUNC MEANS LAST UPDATE_TIME, + ADAY GET NEW UPDATE_TIME
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
				
local function update(ctx)
	assert(ctx)

	print( "timeout update is called **************************************" )
	-- local session = func_gs()
	-- table_gs[tostring(session)] = "lilian_update"
	-- send_package( send_request( "lilian_update" , nil, session , _) )
	ctx:send_package("lilian_update")
end 	
	
local function daily_update()
	print( "daily update is called" )
	local date = os.time()
	local settime = getsettime()
          
	skynet.timeout( ( settime + ADAY - date ) * 100, update )
	--skynet.sleep( 5 * 100 )
	--daily_update()
end 	  
		  
function REQUEST:login(u)
	-- body
	assert( u )
	print("**********************************lilianrequest_login")
	user = u
end		  
		
-- recover phy_power
local function get_phy_power(ctx, date )
	print( "user.lilian_level" , ctx:get_user():get_field("lilian_level") , ctx:get_user():get_field("lilian_phy_power") ) 
	local r = skynet.call( ".game" , "lua" , "query_g_lilian_level" , ctx:get_user():get_field("lilian_level") )
	assert( r )
	local iffull = false
	local left = 0
	local helper = ctx:get_helper()
	assert(helper)
	local rs = helper:lilian_sub_get_lilian_sub()
	assert(rs)
	print("r.phy_power is ", r.phy_power, ctx:get_user():get_field("lilian_phy_power"))
	if r.phy_power > ctx:get_user():get_field("lilian_phy_power") then
		local diff = (date - rs:get_field("first_lilian_time")) / FIXED_STEP
		--local diff = ( date - user.u_lilian_submgr.__data[ 1 ].first_lilian_time ) / FIXED_STEP	
	    left = ( date - rs:get_field("first_lilian_time")) % FIXED_STEP

		if ctx:get_user():get_field("lilian_phy_power") + math.floor( diff ) >= r.phy_power then
			ctx:get_user():set_field("lilian_phy_power", r.phy_power)
			iffull = true
		else
			ctx:get_user():set_field("lilian_phy_power", math.floor(diff) + ctx:get_user():get_field("lilian_phy_power"))
		end
		rs:set_field("first_lilian_time", date)
		rs:set_field("end_lilian_time", date + FIXED_STEP)
		rs:update_db()

		print( "get_phy_power is ended*************************************" , ctx:get_user():get_field("lilian_phy_power") , diff , date  , left )
	end 			
	return iffull , FIXED_STEP - left;
end 	
	
local function add_to_prop(ctx, tprop )
	assert( ctx and tprop )

	for k , v in ipairs( tprop ) do
		print( k , v ,v.propnum)
		local prop = ctx:get_modelmgr():get_u_propmgr():get_by_csv_id( v.propid )
		if prop then
			prop:set_field("num", prop:get_field("num") + v.propnum)
		else
			local key = string.format("%s:%d", "g_prop", v.propid)

			local p = sd.query(key)
			assert(p)
			p.user_id = ctx:get_user():get_field("csv_id")
			p.num = v.propnum
			p.id = genpk_2(p.user_id, p.csv_id)
			local prop = ctx:get_modelmgr():get_u_propmgr():create( p )
			ctx:get_modelmgr():get_u_propmgr():add( prop )
		end
		prop:update_db()
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
	assert( tr:get_field("quanguan_id"))
	local r = skynet.call( ".game" , "lua" , "query_g_lilian_quanguan" , tr:get_field("quanguan_id") )
	assert( r )
	-- quanguan reward
	local reward = {}
	local lilian_reward 
	reward , lilian_reward = get_part_reward( r.reward , "(%d+%*%d+%*%d+%*?)" , 3 )
	if lilian_reward then
		tr:set_field("lilian_reward", lilian_reward)
	else
		tr:set_field("lilian_reward", 0)
	end
	tr:set_field("if_lilian_reward", 1)
	tr:update_db()

	return reward
end 	
	
local function get_event_reward( tr )
	local ret = {}
	local reward = {}

	assert( tr:get_field("quanguan_id") and tr:get_field("invitation_id") )
	assert(tr:get_field("if_trigger_event") == 1)
	print( "get_event_reward is called" , tr:get_field("quanguan_id") , tr:get_field("invitation_id") )
	--event reward
	local r = skynet.call( ".game" , "lua" , "query_g_lilian_quanguan" , tr:get_field("quanguan_id") )
	assert( r )

	if 1 == tr:get_field("if_trigger_event") then
		local te = util.parse_text( r.trigger_event , "(%d+%*?)" , 1 )
		assert( te )

		local random = math.random( #te )
		local t = skynet.call( ".game" , "lua" , "query_g_lilian_event" , te[random][1] )
		assert( t )
		local event_reward

		reward , event_reward = get_part_reward( t.reward ,"(%d+%*%d+%*%d+%*?)" , 3 )
		
		tr:set_field("event_reward", event_reward)	
		tr:set_field("if_event_reward", 1)
		print( "ifeventreward and eventreazrd is " , tr:get_field("if_event_reward") , tr:get_field("event_reward") )
		tr:update_db()
	end 

	return reward
end 
	
local function deal_finish_lilian(ctx, tr )
	print( "deal finish_lilian is called**************************************" )
	assert(ctx and tr and tr:get_field("if_lilian_reward") ~= 0 )

	local r = skynet.call( ".game" , "lua" , "query_g_lilian_quanguan" , tr:get_field("quanguan_id") )
	assert( r )

	local reward = get_part_reward( tr:get_field("lilian_reward") , "(%d+%*%d+%*?)" , 2)
	print("get_part_reward is over")

	add_to_prop(ctx, reward)
	print("add_to_prop is over")
	ctx:get_user():set_field("lilian_exp", ctx:get_user():get_field("lilian_exp") + r.reward_exp)

	--invitation reward
	local ir = skynet.call( ".game" , "lua" , "query_g_lilian_invitation" , tr:get_field("invitation_id") )
	assert( ir )
	reward = {}
	reward = get_part_reward( ir.reward , "(%d+%*%d+%*?)" , 2 )
	add_to_prop(ctx, reward )

	--judge if can levelup
	assert( ctx:get_user():get_field("lilian_level") ~= 0 )
	local ll = skynet.call( ".game" , "lua" , "query_g_lilian_level" , ctx:get_user():get_field("lilian_level") )	
	assert( ll )	
	print( "user.lilain_exp , ll.experience" , ctx:get_user():get_field("lilian_exp") , ll.experience )
	if ctx:get_user():get_field("lilian_exp") >= ll.experience then
		if ctx:get_user():get_field("lilian_level") < MAX_LILIAN_LEVEL then

			ctx:get_user():set_field("lilian_level", ctx:get_user():get_field("lilian_level") + 1)
			ctx:get_user():set_field("lilian_exp", ctx:get_user():get_field("lilian_exp") + 1)
			tr:set_field("iflevel_up", 1)
			tr:update_db()
		end
	end
	
	return reward
end 
		
local function deal_finish_event(ctx, tr )
	assert(ctx and tr)
	local reward = get_event_reward( tr )
	add_to_prop(ctx, reward)
	local helper = ctx:get_helper()
	assert(helper)

	local r = helper:lilian_sub_get_lilian_sub()
	assert(r)

	--update used queue num
	if r:get_field("start_time") <= tr:get_field("start_time") and tr:get_field("start_time") <= r:get_field("update_time") then 
		r:set_field("used_queue_num", r:get_field("used_queue_num") - 1)
		print( "finish event is called " , r:get_field("used_queue_num") )
		r:update_db()
	end 
	print("tr.iffiniseed in deal_finish_event is " , tr:get_field("iffinised"))
		
	return reward
end 	
		
local function trigger_event(ctx, tr)
	assert(ctx and tr)
	local rand_num = math.random( 10000 ) % 100 
	local iftrigger = false
	local lq = skynet.call( ".game" , "lua" , "query_g_lilian_quanguan" , tr:get_field("quanguan_id") )
	assert( lq )	

	print( "randnom is *************************" , rand_num )
	if 0 <= rand_num and rand_num <= lq.trigger_event_prop then
		print( "trigger_event is ************************" , lq.trigger_event )
	    local te = util.parse_text( lq.trigger_event , "(%d+%*?)" , 1 )
		assert( te )
				
		random = math.random( #te )
	    local t = skynet.call( ".game" , "lua" , "query_g_lilian_event" , te[random][1] )
		assert( t )
		local ll = skynet.call( ".game" , "lua" , "query_g_lilian_level" , ctx:get_user():get_field("lilian_level") )
		assert( ll )
		
		tr:set_field("if_trigger_event", 1)
		tr:set_field("eventid", te[random][1])
		tr:set_field("event_end_time", math.floor( t.cd_time * (1 - ll.dec_weikun_time / 100 )))		
		tr:update_db()

		iftrigger = true
		print( "trigger a event *******************************************" , tr:get_field("eventid") )
	end 	

	return iftrigger        
end 		
			
local function get_reward_lilist(ctx, tr , rtype )
	assert(ctx and tr and rtype)
	local reward = {}
	if 1 == rtype then
		if 0 == tr:get_field("if_lilian_reward") then
			reward = get_lilian_reward(tr)
		else
			reward = get_part_reward(tr:get_field("lilian_reward") , "(%d+%*%d+%*?)" , 2)
		end 
		local helper = ctx:get_helper()
		assert(helper)
		local tmp = helper:lilian_sub_get_lilian_sub()
		assert(tmp)

		tmp:set_field("used_queue_num", tmp:get_field("used_queue_num") - 1)
		tmp:update_db()

	elseif 2 == rtype then
		if 0 == tr:get_field("if_event_reward") then
			assert( 1 == tr:get_field("if_trigger_event") )
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
	
function REQUEST:get_lilian_info(ctx)
	assert(ctx)
	-- body 
	print( "*-------------------------* get_lilian_info is called" )
						
	local ret = {}
	ret.basic_info = {}
	local date = os.time()
    local settime = getsettime()
    local helper = ctx:get_helper()
    assert(helper)

    local r = helper:lilian_sub_get_lilian_sub()

    --judge if there is a lilian that triggered a event not finished,only one can trigger event
    for k , v in pairs( ctx:get_modelmgr():get_u_lilian_mainmgr().__data ) do
    	local t = v.__fields
    	assert(t)
    	if 1 == t.if_trigger_event and date < t.event_end_time then
    		IF_TRIGGER_EVENT = 1
    		break                                               
    	end 		
    end      		

	--if quanguan can lilian
	--u_lilian_mainmgr records each lilian that is not finised 
	for k , v in pairs( ctx:get_modelmgr():get_u_lilian_mainmgr().__data ) do
		local f = v.__fields
		local tmp = {}
		local date = os.time()
		print( "date is , v.end_time is " , date , f.end_time , f.event_end_time, date >= f.end_time , f.quanguan_id , f.if_trigger_event)
						
		if date >= f.end_time then
			print( "if_lilian_reward" , f.if_lilian_finished , f.if_trigger_event)
			if 0 == f.if_lilian_finished then
				print( "send lilian reward **************************************" )
				tmp.reward = get_reward_lilist(ctx,  v , 1 )
				tmp.if_lilian_reward = 1				
				tmp.invitation_id = f.invitation_id			
				tmp.left_cd_time = 0
				
				tmp.if_trigger_event = 0		   	
				tmp.delay_type = DELAY_TYPE.LILIAN_FINISH    
			else    	
				if date >= f.event_end_time then
					print( "if_event_reward" , f.if_lilian_finished , f.if_trigger_event)
					tmp.reward = get_reward_lilist(ctx, v, 2)
					IF_TRIGGER_EVENT = 0
					print( "both finished *******************************" , f.eventid )
					tmp.delay_type = DELAY_TYPE.EVENT_FINISH
					tmp.if_event_reward = 1
					tmp.eventid = f.eventid
					tmp.left_cd_time = 0
					tmp.errorcode = errorcode[1].code
				else     
					IF_TRIGGER_EVENT = 1
					print( "lilian finished , event not finished*******************************" )
					tmp.left_cd_time = f.event_end_time - date
					tmp.delay_type = DELAY_TYPE.EVENT
					tmp.errorcode = errorcode[85].code
				end 						
			end    	    					
		else        	
			print( "lilian not finished *******************************", DELAY_TYPE.LILIAN )
			tmp.delay_type = DELAY_TYPE.LILIAN
			tmp.left_cd_time = f.end_time - date
			tmp.invitation_id = f.invitation_id
			tmp.errorcode = errorcode[81].code
		end        		
 		tmp.quanguan_id = f.quanguan_id
 						
		table.insert( ret.basic_info , tmp )
	end          		

	local settime = getsettime()
	if r then 			
		--time to update 
		if r:get_start_time() < settime then
			
			local fqn = skynet.call( ".game" , "lua" , "query_g_lilian_level" , ctx:get_user():get_field("lilian_level") )
			r:set_start_time (settime)
			r:set_update_time(r:get_start_time() + ADAY)
			r:set_used_queue_num(0)
			r:update_db()
			helper:lilian_qg_num_clear_by_settime( settime )
		end       		
		print("get liain laievel************", ctx:get_user():get_field("lilian_level"))
		local t = skynet.call( ".game" , "lua" , "query_g_lilian_level" , ctx:get_user():get_field("lilian_level") )
		assert( t )		
		if ctx:get_user():get_field("lilian_phy_power") >= t.phy_power then
			ret.phy_power_left_cd_time = 0
		else       		
			if date >= r:get_field("end_lilian_time") then
				local _ , left = get_phy_power(ctx, date)
				ret.phy_power_left_cd_time = left
			else 			
				ret.phy_power_left_cd_time = r:get_field("end_lilian_time")- date
			end 			
		end     
	end         
    		
	ret.lilian_num_list = helper:lilian_qg_num_get_lilian_num_list()
            
	ret.level = ctx:get_user():get_field("lilian_level")
			
	ret.phy_power = ctx:get_user():get_field("lilian_phy_power") + ctx:get_user():get_field("purch_lilian_phy_power")
	ret.lilian_exp = ctx:get_user():get_field("lilian_exp")
	print( "error is called ********************************" , errorcode[1].code , ctx:get_user():get_field("lilian_phy_power") )
	ret.purch_phy_power_num = ctx:get_modelmgr():get_u_lilian_phy_powermgr():get_count()
	ret.present_phy_power_num = ctx:get_user():get_field("lilian_phy_power")
	ret.errorcode = errorcode[ 1 ].code
	ret.msg = errorcode[ 1 ].msg

	--daily_update()

	return ret  
end			
			
function REQUEST:start_lilian(ctx)
	assert(ctx)
	print( "*******************************************start_lilian is called" )
	assert( self.quanguan_id )
	local ret = {}	
	local helper = ctx:get_helper()
	assert(helper)

	local rm = helper:lilian_main_get_by_quanguan_id( self.quanguan_id )
	local rs = helper:lilian_sub_get_lilian_sub()
	local lq = skynet.call( ".game" , "lua" , "query_g_lilian_quanguan" , self.quanguan_id )
	local fqn = skynet.call( ".game" , "lua" , "query_g_lilian_level" , ctx:get_user():get_field("lilian_level") )
	assert( fqn and lq )

	local date = os.time()
	local settime = getsettime()
	local total_delay_time = 0

	if rm then   
	print("1111111111111111111111111111111111111") 	
		ret.errorcode = errorcode[81].code
		ret.msg = errorcode[81].msg

		return ret  
	else 			
		print("22222222222222222222222222222222222222222")
		if 1 == IF_TRIGGER_EVENT then
			ret.errorcode = errorcode[85].code
			ret.msg = errorcode[85].msg

			return ret 	
		else 			
			print("3333333333333333333333333333333333333333333333")
			local prop = ctx:get_modelmgr():get_u_propmgr():get_by_csv_id( self.invitation_id )

			if ctx:get_user():get_field("lilian_level") < lq.open_level or ctx:get_user():get_field("lilian_phy_power") + ctx:get_user():get_field("purch_lilian_phy_power") < lq.need_phy_power or not prop or prop:get_field("num") <= 0 then  -- leck an invitation condigion judge.
				print("444444444444444444444444444444444444444444444")
				ret.errorcode = errorcode[82].code
				ret.msg = errorcode[82].msg

				return ret
			else		
				print("5555555555555555555555555555555555555555555555555555")
				if not rs then
					print("66666666666666666666666666666666666666666666666666")
					rs = {}
					rs.id = skynet.call(".game", "lua", "guid", const.LILIAN_SUB)
					rs.csv_id = ctx:get_user():get_field("csv_id")
					rs.start_time = settime
					rs.first_lilian_time = date
					rs.end_lilian_time = date + FIXED_STEP
					rs.update_time = settime + ADAY
					print( "queue num in level is " , fqn.queue )
					rs.used_queue_num = 0 --fqn.queue

					rs = ctx:get_modelmgr():get_u_lilian_submgr():create( rs )
					assert( rs )
					ctx:get_modelmgr():get_u_lilian_submgr():add( rs )
					rs:update_db()

				else 	
					print("77777777777777777777777777777777777777777777777")
					if settime > rs:get_field("start_time") then
						print("8888888888888888888888888888888888888888888888888")
						rs:set_field("start_time", settime)
						rs:set_field("update_time", rs:get_field("start_time") + ADAY)
						rs:set_field("used_queue_num", 0)
						rs:update_db()
					end  
					print( "compared used_queue_num*******************************" , rs:get_field("used_queue_num"), fqn.queue )
					if rs:get_field("used_queue_num") >= fqn.queue then
						print("9999999999999999999999999999999999999999999999999999999")
						ret.errorcode = errorcode[84].code
						ret.msg = errorcode[84].msg
                                   
						return ret 
					end            
				end 	            
                
			--start deal with lilian_mai 
			--TODO leck judge       
				
				local lilian_num = 0
			 					   	
				local t = helper:lilian_qg_num_get_by_quanguan_id( self.quanguan_id )
				if t and t:get_field("start_time") == settime then
					print("10101010101010101010101101010101010101")
					t:set_field("num", t:get_field("num") + 1)
					lilian_num = t:get_field("num")
				else   
				print("11 11 11 11 11 11 11 11 11 11 11 11 ")             
					local lqgn = {}
					lqgn.id = skynet.call(".game", "lua", "guid", const.LILIAN_QG_NUM)
					lqgn.user_id = ctx:get_user():get_field("csv_id")
					lqgn.start_time = settime
					lqgn.end_time = settime + ADAY
					lqgn.num = 1    
					lqgn.quanguan_id = self.quanguan_id
					lqgn.csv_id = self.quanguan_id  + lqgn.start_time
					lqgn.reset_num = 0

					lqgn = ctx:get_modelmgr():get_u_lilian_qg_nummgr():create( lqgn )
					assert(lqgn)
					ctx:get_modelmgr():get_u_lilian_qg_nummgr():add( lqgn )
					lqgn:update_db()

					lilian_num = lqgn:get_field("num")
				end 	

				local nr = {}
				nr.id = skynet.call(".game", "lua", "guid", const.LILIAN_MAIN)
				nr.user_id = ctx:get_user():get_field("csv_id")
				nr.quanguan_id = self.quanguan_id
				nr.start_time = date
				nr.iffinished = 0
				nr.invitation_id = self.invitation_id
				nr.end_time = nr.start_time + math.floor( lq.time * ( 1 - fqn.dec_lilian_time / 100 ) )
				nr.if_trigger_event = 0
				nr.event_end_time = 0
				nr.eventid = 0   
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
				nr = ctx:get_modelmgr():get_u_lilian_mainmgr():create( nr )
				ctx:get_modelmgr():get_u_lilian_mainmgr():add( nr )
				nr:update_db()
         	    prop:set_field("num", prop:get_field("num") - 1)
		 		prop:update_db()

		 		rs:set_field("used_queue_num", rs:get_field("used_queue_num") + 1)
		 		print( "start_lilian is called sub**********" , rs:get_field("used_queue_num"))
		 		rs:update_db()

		 		if ctx:get_user():get_field("lilian_phy_power") >= lq.need_phy_power then
		 			ctx:get_user():set_field("lilian_phy_power", ctx:get_user():get_field("lilian_phy_power") - lq.need_phy_power)
		 		else
		 			ctx:get_user():set_purch_lilian_phy_power(ctx:get_user():get_field("purch_lilian_phy_power") + lq.need_phy_power)
		 			ctx:get_user():set_lilian_phy_power(0) 
		 		end
		 		ctx:get_user():update_db()
		 		print( "user.lilian_phy_power is **********************************" , ctx:get_user():get_field("lilian_phy_power") , rs:get_field("used_queue_num") , lq.need_phy_power)
			end 	
		end  	
	end 
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg		
	ret.left_cd_time = math.floor(lq.time * (1 - fqn.dec_lilian_time / 100))

	print("ret.left_cd_time is ********************************" , ret.left_cd_time , ret.lilian_phy_power, ret.lilian_level)
	return ret                     
end		 			              
	
function REQUEST:lilian_get_phy_power(ctx)
	assert(ctx)

	local ret = {}
	local date = os.time() 
	local helper = ctx:get_helper()
	local r = helper:lilian_sub_get_lilian_sub()

	print( "lilian_get_phy_power is called********************" , date , r:get_field("end_lilian_time"))

	if r then
		if date >= r:get_field("end_lilian_time") then
			ret.errorcode = errorcode[1].code
			local sign , left = get_phy_power(ctx, date)
			print( sign , left )
			if sign then 
				ret.left_cd_time = 0
			else
				ret.left_cd_time = left
			end
		else
			ret.errorcode = errorcode[85].code          
			ret.left_cd_time = r:get_field("end_lilian_time") - date
		end  
	else
		ret.errorcode = errorcode[1].code
		ret.left_cd_time = 0		
	end 
	ret.phy_power = ctx:get_user():get_field("lilian_phy_power") + ctx:get_user():get_field("purch_lilian_phy_power")
    print( "user.lilian_phy_power is " , ctx:get_user():get_field("lilian_phy_power") , ctx:get_user():get_field("purch_lilian_phy_power"))
	return ret        
end	     			
	     			
local function inc_lilian(ctx, r , date )
	assert( ctx and r and date )		

	local ret = {}	

	if 1 == r:get_field("if_lilian_finished") then
			ret.errorcode = errorcode[86].code
			ret.msg = errorcode[86].msg
			return ret
	else    	     
		print( "in lilian_reward********************************", ctx:get_user():get_field("lilian_level") )
		ret.reward = get_lilian_reward( r )
                       
		ret.errorcode = errorcode[1].code
		ret.invitation_id = r:get_field("invitation_id")
                      
		r:set_field("if_canceled", 1)
		r:set_field("end_time", date)
		r:update_db()
	end 			 
                     
	return ret       
end 	
	
local function inc_event(ctx, r , date )
	assert( ctx and r and date )
	local ret = {}

	if 1 == r:get_field("iffinished") then
		ret.errorcode = errorcode[87].code
		ret.msg = errorcode[87].msg
		return ret
	else
		print( "in event_reward********************************" )
		ret.reward = get_event_reward( r )
		
		IF_TRIGGER_EVENT = 0
		ret.if_event_reward = 1
		ret.eventid = r:get_field("eventid")
		ret.errorcode = errorcode[1].code

		r:set_field("if_event_canceled", 1)
		r:set_field("event_end_time", date)
		r:update_db()
	end 	

	return ret
end 		
			
function REQUEST:lilian_rewared_list(ctx)
	print( "lilian_reward_list is called&&&&&&&&&&&&&&&&&&&&&&&&" , self.quanguan_id , self.rtype )
	assert( ctx and self.quanguan_id and self.rtype )
	local ret = {}
	local date = os.time()
	local helper = ctx:get_helper()
	assert(helper)
	local r = helper:lilian_main_get_by_quanguan_id( self.quanguan_id )
	assert( r )

	if DELAY_TYPE.LILIAN == self.rtype then
		if date >= r:get_field("end_time") then
			ret.reward = get_reward_lilist(ctx, r, self.rtype)
			ret.invitation_id = r:get_field("invitation_id")
			ret.errorcode = errorcode[1].code
		else
			ret.errorcode = errorcode[81].code
			ret.left_cd_time = r:get_field("end_time") - date
		end 
	elseif DELAY_TYPE.EVENT == self.rtype then
		if date >= r:get_field("event_end_time") then
			IF_TRIGGER_EVENT = 0

			ret.reward = get_reward_lilist(ctx, r , self.rtype)
			print( "get reward in event ***********************" , ret.reward[1].propid , ret.reward[1].propnum )
			ret.errorcode = errorcode[1].code
		else
			ret.errorcode = errorcode[81].code
			ret.left_cd_time = r:get_field("event_end_time") - date
		end 
	else    
		assert(false)
	end 		

	return ret
end         	      
			
function REQUEST:lilian_get_reward_list(ctx)
	print( "lilian_get_reward_list is called **************" , self.quanguan_id , self.reward_type )
	assert( ctx and self.quanguan_id and self.reward_type )
	local ret = {}
	local date = os.time()

	local helper = ctx:get_helper()
	assert(helper)
	local r = helper:lilian_main_get_by_quanguan_id( self.quanguan_id )
	assert( r ) 

	if DELAY_TYPE.LILIAN == self.reward_type then
		if 1 == r:get_field("if_lilian_finished") then
			print("lilian is finished*********************************************")
			ret.errorcode = errorcode[86].code
			ret.msg = errorcode[86].msg
			return ret
		else    
			if date >= r:get_field("end_time") then
				print( "in lilian_reward********************************", ctx:get_user():get_field("lilian_level"))
				deal_finish_lilian(ctx,  r )
				print( "deal_finish_lilian in reward" )
				local sign = false

				if 0 == IF_TRIGGER_EVENT then
					sign = trigger_event(ctx, r )

					if sign then
						print( "trigger event finished " , sign , IF_TRIGGER_EVENT)
						IF_TRIGGER_EVENT = 1
						ret.if_trigger_event = 1
						ret.left_cd_time = r:get_field("event_end_time")
						r:set_field("event_end_time", r:get_field("event_end_time") + date)

						r:update_db() 
					end 
				end

				if not sign then
					ret.if_trigger_event = 0
					r:set_field("iffinished", 1)
				end
				print( "finished is " , r:get_field("iffinished"))
				ret.if_lilian_finished = r:get_field("if_lilian_finished")
				ret.if_lilian_reward = 1
				ret.lilian_level = ctx:get_user():get_field("lilian_level")
				print( "in lilian_reward********************************", ctx:get_user():get_field("lilian_level"))
				ret.lilian_exp = ctx:get_user():get_field("lilian_exp")
				ret.errorcode = errorcode[1].code
			else
				print("noet end**************************")
				ret.errorcode = errorcode[81].code
				ret.left_cd_time = r:get_field("end_time") - date
			end 

			r:set_field("if_lilian_finished", 1)
			r:update_db()

			if 1 == r:get_field("iffinished") then
				print( "delete finished is called8888888****************************" )
				r:update_db()
				helper:lilian_main_delete_by_id(r:get_field("id"))
			end 
		end 	
	elseif DELAY_TYPE.EVENT == self.reward_type then
		if 1 == r:get_field("iffinished") then
			print("event is finished*********************************************")
			ret.errorcode = errorcode[87].code
			ret.msg = errorcode[87].msg
			return ret
		else    
			print( "in event_reward********************************")
			if date >= r:get_field("event_end_time") then
				deal_finish_event(ctx,  r )
				print( "deal_finish_event is finished ********************************" )
				ret.iffinished = 1
				ret.if_event_reward = 1
				ret.eventid = r:get_field("eventid")
				ret.errorcode = errorcode[1].code

				print( "delete finished is called8888888****************************" )
				r:set_field("iffinished", 1)
				r:update_db()
				helper:lilian_main_delete_by_id(r:get_field("id"))
			else
				ret.errorcode = errorcode[81].code
				ret.left_cd_time = r:get_field("event_end_time") - date
			end 
		end 	
	else     	
		print("noet end**************************")
		ret.errorcode = errorcode[88].code
		ret.msg = errorcode[88].msg
	end    		
				
	return ret
end			
	--should change from here
function REQUEST:lilian_purch_phy_power(ctx)
	assert(ctx)          
	print( "lilian_purch_phy_power is called *******************************" )
	local ret = {}       
	local date = os.time()
	local ifpurch = false
	local helper = ctx:get_helper()
	assert(helper)		 	

	local pn = ctx:get_modelmgr():get_u_lilian_phy_powermgr():get_count()
	local settime = getsettime()
	local prop = ctx:get_modelmgr():get_u_propmgr():get_by_csv_id( const.DIAMOND )
	local t = skynet.call( ".game" , "lua" , "query_g_lilian_phy_power" , pn + 1 )
	local date = os.time()
								
	assert( t ) 		
	print( "pn is *********************************************************" , pn )
	if 0 == pn then
		ifpurch = true
	else 		
		local r = helper:lilian_phy_power_get_one()
		assert( r )
		if r:get_field("start_time") < settime then
			helper:lilian_phy_power_clear()
			ifpurch = true
		else    
			if pn >= ctx:get_user():get_field("purchase_hp_count_max") then
				ret.errorcode = errorcode[89].code
				ret.msg = errorcode[89].msg

				return ret
			else
				if prop:get_num() < t.dioment then
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
	p.id = skynet.call(".game", "lua", "guid", const.LILIAN_PHY_POWER)
	p.user_id = ctx:get_user():get_field("csv_id")
	p.csv_id = date + pn + 1
	p.start_time = settime
	p.end_time = settime + ADAY
	p.purch_time = date
	p.num = pn + 1 
	
	p = ctx:get_modelmgr():get_u_lilian_phy_powermgr():create( p )
	assert( p )
	ctx:get_modelmgr():get_u_lilian_phy_powermgr():add( p )
	p:update_db()
	
	prop:set_field("num", prop:get_field("num") - t.dioment)	

	local r = skynet.call( ".game" , "lua" , "query_g_config" , "purch_phy_power" )
	assert( r )
	local g = skynet.call( ".game" , "lua" , "query_g_lilian_level" , ctx:get_user():get_field("lilian_level") )
	assert( g )
	
	print("user.lilian_phy_power + r" ,ctx:get_user():get_field("lilian_phy_power") , ctx:get_user():get_field("lilian_phy_power") + r , g.phy_power )
	
	ctx:get_user():set_field("purch_lilian_phy_power", ctx:get_user():get_field("purch_lilian_phy_power") + r)
	
	prop:update_db()
	ctx:get_user():update_db()

	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.phy_power = ctx:get_user():get_field("lilian_phy_power") + ctx:get_user():get_field("purch_lilian_phy_power")
	print( "lilian_purch_phy_power is called**********************************sdasdasd" , ctx:get_user():get_field("lilian_phy_power") , ctx:get_user():get_field("purch_lilian_phy_power"),ret.phy_power )
	return ret
end 
	
local INC_TYPE = { LILIAN = 1 , EVENT = 2 }
local CONSUMU_PER_SEC = 2
	
function REQUEST:lilian_inc(ctx)
	assert(ctx)
			
	assert( self.quanguan_id and self.inc_type )
	print( "lilian_inc is called*****************************" , self.quanguan_id , self.inc_type )
	local ret = {}
	local date = os.time()
	local helper = ctx:get_helper()
			
	local r = helper:lilian_main_get_by_quanguan_id(self.quanguan_id)
	assert( r ) 
			
	local not_enough_prop = false
	--cost 	
	local prop = ctx:get_modelmgr():get_u_propmgr():get_by_csv_id( const.DIAMOND )
	local total_consume = 0
	local tl = 0
			
	if self.inc_type == INC_TYPE.LILIAN then
		if date > r:get_field("end_time") then
			ret.errorcode = errorcode[91].code
			
			return ret
		else
			tl = r:get_field("end_time") - date
			print("in lilian *************************************")
			
			assert( tl >= 0 )
			total_consume = tl * CONSUMU_PER_SEC

			if not prop or prop:get_field("num") < total_consume then
				not_enough_prop = true
			else
				ret = inc_lilian(ctx, r , date)
			end 
		end
	else    
		print( "in event *************************************" , r:get_field("event_end_time") , date , r:get_field("event_end_time") - date )
		if date > r:get_field("event_end_time") then
			ret.errorcode = errorcode[91].code
			return ret
		else
			tl = r:get_field("event_end_time") - date
			assert( tl >= 0 )
			total_consume = tl * CONSUMU_PER_SEC 
			if not prop or prop:get_field("num") < total_consume then
				not_enough_prop = true
			else
				ret = inc_event(ctx, r , date )
			end	
		end
	end 

	if not_enough_prop then
		ret.errorcode = errorcode[6].code
		ret.msg = errorcode[6].msg
	else
		prop:set_field("num", prop:get_field("num") - total_consume)
		ret.diamond_num = prop:get_field("num")
	end
	print( "ret.diamond_num is , prop.num is " , ret.diamond_num, prop:get_field("num"))

	return ret
end 		
				
function REQUEST:lilian_reset_quanguan(ctx)
	assert( ctx and self.quanguan_id )
	print( "lilian_reset_quanguan is called**********************************" )

	local ret = {}
	local t = ctx:get_modelmgr():get_u_lilian_qg_nummgr():get_by_csv_id( self.quanguan_id )
	local r = skynet.call( ".game" , "lua" , "query_g_lilian_quanguan" , self.quanguan_id )
	print( t.num , r.day_finish_time , t.reset_num , ctx:get_user():get_field("purchase_hp_count_max"))
	if not t or t:get_field("num") < r.day_finish_time or t:get_field("reset_num") >= ctx:get_user():get_field("purchase_hp_count_max") then
		ret.errorcode = errorcode[90].code
		ret.msg = errorcode[90].msg
	else      
		local cd = skynet.call( ".game" , "lua" , "query_g_lilian_phy_power" , t:get_field("reset_num") + 1 )
		assert( cd )
		local prop = ctx:get_user():get_u_propmgr():get_by_csv_id( const.DIAMOND )
		if not prop or prop:get_field("num") < cd.reset_quanguan_dioment then
			ret.errorcode = errorcode[6].code
			ret.msg = errorcode[6].msg
		else
			t:set_field("reset_num", t:get_field("reset_num") + 1)
			t:set_field("num", 0)
			prop:set_field("num", prop:get_field("num") - cd.reset_quanguan_dioment)

			ret.reset_num = t:get_field("reset_num")
			ret.errorcode = errorcode[1].code
			ret.msg = errorcode[1].msg
			print( "reset quanguan is caleld " , prop:get_field("num") , cd.reset_quanguan_dioment )
			t:update_db()
			prop:update_db()	
		end 
	end 	

	return ret	
end

function lilian_request.start(c, s, g, fgs, tgs, ...)
	-- body	
	print( "*********************************lilianjkh_start" )
	client_fd = c
	send_request = s
	game = g
	func_gs = fgs
	table_gs = tgs
end			

function RESPONSE:lilian_update()
	print( "REQUEST LILISN_UPDATE = ********************" )
	assert(false)
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