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
local FIXED_STEP = 360 --sec
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
local function get_phy_power()
	print( "user.lilian_level" , user.lilian_level ) 
	local r = skynet.call( ".game" , "lua" , "query_g_lilian_level" , user.lilian_level )
	assert( r )
	local date = os.time()
	local sign = false

	if r.phy_power > user.lilian_phy_power then
		
		local diff = ( date - user.u_lilian_submgr.__data[ 1 ].first_lilian_time ) / FIXED_STEP	
		if user.lilian_phy_power + diff > r.phy_power then
			user.lilian_phy_power = r.phy_power
		else
			user.lilian_phy_power = user.lilian_phy_power + math.floor( diff )
			user.u_lilian_submgr.__data[ 1 ].first_lilian_time = 0
		end

		sign = true
	end 			
		
	return sign , user.lilian_phy_power;
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
	print( "*************************************count" , user.u_lilian_submgr:get_count() )
	local r = assert( user.u_lilian_submgr.__data[1] )
	--update used queue num
	if r.start_time < tr.start_time and tr.start_time < r.update_time then 
		r.used_queue_num = r.used_queue_num - 1
	end
end


local LL_OVER = { NOTOVER = 0 , OVER = 1 }
				
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
        
		tmp.quanguan_id = v.quanguan_id
		print( "date is , v.end_time is " , date , v.end_time , date >= v.end_time )
		if date >= v.event_end_time then
			tmp.left_cd_time = 0
		end

		if date >= v.end_time then
			tmp.left_cd_time = 0 
		--	tmp.if_trigger_event = v.if_trigger_event
			tmp.invitation_id = v.invitation_id 

			deal_finish_lilian( v )  
			
			tmp.iflevel_up = v.iflevel_up
			tmp.code = errorcode[1].code
			tmp.msg = errorcode[1].msg

			--delete this record

			v.iffinished = 1
			v:__update_db( { "iffinished" } , const.DB_PRIORITY_2 )
			user.u_lilian_mainmgr:delete_by_csv_id( v.quanguan_id ) 
		else			
			tmp.left_cd_time = v.end_time - date
			tmp.code = errorcode[81].code
			tmp.msg = errorcode[81].msg
		end 		
		table.insert( ret.basic_info , tmp )
	end 		

	local settime = getsettime()
	if r then
		--time to update 
		if r.start_time < settime then
			r.start_time = settime
			r.update_time = start_time + ADAY
			r.used_queue_num = 0

			user.u_lilian_qg_nummgr:clear_by_settime( settime )
		end
	end

	ret.lilian_num_list = user.u_lilian_qg_nummgr:get_lilian_num_list()

	ret.level = user.lilian_level
	local _ , p = get_phy_power()
	ret.phy_power = p
	ret.lilian_exp = user.lilian_exp
	print( "error is called ********************************" , errorcode[1].code )
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
		if user.lilian_level < lq.open_level or user.lilian_phy_power < lq.need_phy_power then  -- leck a invitation condigion judge.
			ret.errorcode = errorcode[82].code
			ret.msg = errorcode[82].msg

			return ret
		else	
			if not rs then
				rs = {}
				
				rs.csv_id = user.csv_id
				rs.start_time = settime
				rs.first_lilian_time = date
				rs.update_time = settime + ADAY
				rs.used_queue_num = 0
			
				rs = user.u_lilian_submgr.create( rs )
				assert( rs )
				user.u_lilian_submgr:add( rs )
				rs:__insert_db( const.DB_PRIORITY_2 )
			else    
				if settime > rs.start_time then
					rs.start_time = settime
					rs.update_time = rs.start_time + ADAY
					rs.used_queue_num = 0
				end

				if rs.used_queue_num >= fqn.queue then
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
			nr.if_trigger_event , nr.end_time = get_total_delay_time( lq , fqn )
			total_delay_time = nr.end_time
			nr.end_time = nr.end_time + nr.start_time
			nr.iflevel_up = 0
			nr.csv_id = self.quanguan_id + nr.start_time + lilian_num
			nr.event_start_time = 0
			nr.event_end_time = 0
			if_lilian_finished = 0

			nr = user.u_lilian_mainmgr.create( nr )
			user.u_lilian_mainmgr:add( nr )
			nr:__insert_db( const.DB_PRIORITY_2 )

			if user.lilian_phy_power == fqn.phy_power then
				rs.first_lilian_time = date
			end
			rs.used_queue_num = rs.used_queue_num - 1
			user.lilian_phy_power = user.lilian_phy_power - lq.need_phy_power
		end 		
	end 	
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg		
	ret.left_cd_time = total_delay_time

	return ret
end					
				
function REQUEST:lilian_get_phy_power()
	print( "lilian_get_phy_power is called********************" )
	local ret = {}
	local date = os.time()

	local sign , power = get_phy_power()
	if not sign then
		ret.left_cd_time = 0
	else
		local r = assert( user.u_lilian_submgr.__data[1] )
		ret.left_cd_time = FIXED_STEP
		r.first_lilian_time = date
	end	

	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.power = power	
	return ret
end	
	
function REQUEST:lilian_get_reward_list()
	print( "lilian_get_reward_list is called **************" , self.quanguan_id )
	assert( self.quanguan_id )
	local ret = {}
	local date = os.time()

	for k , v in pairs( user.u_lilian_mainmgr.__data ) do
		print( k , v )
	end
	local r = user.u_lilian_mainmgr:get_by_csv_id( self.quanguan_id )
	assert( r )
	if date >= r.end_time then
		deal_finish_lilian( r )
		ret.iffinished = r.iffinished
		ret.if_trigger_event = r.if_trigger_event
		ret.left_cd_time = 0
		ret.invitation_id = r.invitation_id
		ret.iflevel_up = r.iflevel_up
		ret.errorcode = errorcode[1].code
		
	else
		ret.errorcode = errorcode[81].code
		ret.left_cd_time = r.end_time - date
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
			
function lilian_request.disconnect()
	-- body	
end			
			
lilian_request.REQUEST = REQUEST
lilian_request.RESPONSE = RESPONSE
lilian_request.SUBSCRIBE = SUBSCRIBE
		
return lilian_request