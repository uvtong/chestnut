local cgold_request = {}
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
	print( "**********************************cgoldrequest_login " )
	user = u
	cs = queue()
	assert( cs )
end		

local function f1( ... )
	-- body
	send_package()
	if user.lilian_power < 100  then
		skynet.timeout(12000, f1)
	end 
end 
	
local function insc_power(n)
	-- body
	user.lilian_power = user.lilian_power + n
end 
	
local function desc_power(n)
	-- body
	user.lilian_power = user.lilian_power - n
end 
	
local function get_phy_power()
	local r = skyney.call( ".game" , "lua" , "query_g_lilian_level" , user.lilian_level )
	assert( r )
	local date = os.time()

	if r.phy_power > user.phy_power then
		assert( 0 == user.lilian_submgr.first_cpower_time )
		local diff = ( date - user.lilian_submgr[ 1 ].first_cpower_time ) / FIXED_STEP	
		if user.phy_power + diff > r.phy_power then
			user.phy_power = r.phy_power
		else
			user.phy_power = user.phy_power + diff
			user.lilian_submgr[ 1 ].first_cpower_time = 0
		end
	end 			
	return user.phy_power
end 
	
function REQUEST:get_phy_power()
	return  assert( get_phy_power() )
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
	assert( sr and t )

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
	assert( quanguan_id )
	local r = skynet.call( ".game" , "lua" , "query_g_lilian_quqnguan" , quanguan_id )
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

local LL_OVER = { NOTOVER = 0 , OVER = 1 }
				
function REQUEST:get_lilian_info()
	-- body 
	print( "*-------------------------* get_lilian_info is called" )

	local ret = {}
	local ret.basic_info = {}
	local date = os.time()
    
    local r = user.u_lilian_submgr.__data[1]

	--if quanguan can lilian
	for k , v in ipairs( user.u_lilianmgr.__data ) do
		local tmp = {}

		local date = os.time()
        		
		tmp.quanguan_id = v.quanguan_id
		tmp.lilian_num = user.u_lilian_submgr:get_lilian_num_by_id( v.quanguan_id )
					
		if date >= v.end_time then
			tmp.left_cd_time = 0 
			tmp.if_trigger_event = v.if_trigger_event
			tmp.invitation_id = v.invitation_id 

			v.iffinished = 1
			v:__update_db( { "iffinished" } , const.DB_PRIORITY_2 )
			user.u_lilianmgr:delete_by_csv_id( v.quanguan_id )
			get_lilian_reward( v.quanguan_id , v.invitation_id )

			assert( user.lilian_level ~= 0 )
			local ll = skynet.call( ".game" , "lua" , "query_g_lilian_level" , user.lilian_level )	
			assert( ll )	
			if user.lilian_exp >= ll.experience then
				user.lilian_level = user.lilian_level + 1
				user.lilian_exp = user.lilian_exp - ll.experience

				tmp.iflevel_up = 1
			end

			--update used queue num
			if used_queue_num >= 1 then
				r.used_queue_num = r.used_queue_num - 1
			end

			tmp.errorcode = errorcode[1].errorcode
			tmp.msg = errorcode[1].msg 
		else			
			tmp.left_cd_time = v.end_time - date
			tmp.errorcode = errorcode[81].errorcode
			tmp.msg = errorcode[81].msg
		end 		
		table.insert( ret.basic_info , tmp )
	end 		

	ret.level = user.lilian_level
	ret.phy_power = get_phy_power()
	ret.errorcode = errorcode[ 1 ].errorcode
	ret.msg = errorcode[ 1 ].msg

	return ret  
end					
				
local function get_total_delay_time( lq , fqn )
	assert( lq and fqn )

	--lilian delay
	local ld = lq.time * ( fqn.dec_lilian_time / 100 )
	local ed = 0
	local iftrigger = false

	local rand_num = math.floor( math.randomseed(tostring(os.time()):reverse():sub(1 , 100 ) ) )
	print( "randnom is *************************" , rand_num )
	if 0 < rand_num and rand_num < lq.trigger_event_prop then
		local te = util.parse_text( lq.trigger_event , "(%+*?)" , 1 )
		assert( te )

		for k , v in ipairs( te ) do
			local t = skynet.call( ".game" , "lua" , "query_g_lilian_event" , v )
			assert( t )

			ed = ed + t.cd_time
		end 

		iftrigger = true
	end
	
	return iftrigger , math.floor( ld + ed * ( fqn.dec_weikun_time / 100 ) )
end 
	
function REQUEST:start_lilian()
	assert( self.quanguan_id )
	local ret = {}	

	local rm = user.u_lilian_mainmgr:get_by_csv_id( self.quanguan_id )
	local rs = user.u_lilian_submgr:get_by_csv_id( user.csv_id )
	local lq = skynet.call( ".game" , "lua" , "query_g_lilian_quanguan" , self.quanguan_id )
	local fqn = skynet.call( ".game" , "lua" , "query_g_lilian_level" , user.lilian_level )
	assert( fqn )
	
	local date = os.time()
	local settime = getsettime()

	if rm then    
		ret.errorcode = errorcode[81].errorcode
		ret.msg = errorcode[81].msg

		return ret
	else        		
		if user.lilian_level < lq.open_level or user.phy_power < lq.need_phy_power then  -- leck a invitation condigion judge.
			ret.errorcode = errorcode[82].errorcode
			ret.msg = errorcode[82].msg

			return ret
		else	
			
			if not rs then
				rs = {}
				
				rs.csv_id = user.csv_id
				rs.start_time = date
				rs.update_time = settime + ADAY
				--rs.fixed_queue_num = fqn.queue
				rs.used_queue_num = 0
				for i = 1 , 5 do
					local quanguan_id = "quanguan_id" .. i
					local value = "value" .. i
					rs[ quanguan_id ] = 0
					rs[ value ] = 0
				end
				rs["quanguan_id1"] = self.quanguan_id
				rs["value1"] = 1

				rs = user.u_lilian_submgr.create( rs )
				assert( rs )
				user.u_lilian_submgr:add( rs )
				rs:__insert_db()
			else    
				if rs.used_queue_num >= fqn.queue then
					ret.errorcode = errorcode[84].errorcode
					ret.msg = errorcode[84].msg

					return ret
				else
					if date >= rs.update_time then
						rs.update_time = settime + ADAY
						user.u_lilian_submgr:__reset_quanguan_num()       --set all id and value to 0
						rs.used_queue_num = 0
					end
					local num = user.u_lilian_submgr:__get_num_by_quanguan_id( self.quanguan_id )
					if num < lq.day_finish_time then
						user.u_lilian_submgr:__set_num_by_quanguan_id( self.quanguan_id )
					else
						ret.errorcode = errorcode[83].errorcode
						ret.msg = errorcode[83].msg

						return ret
					end 		
				end
			end     

			--start deal with lilian_main
			local nr = {}
			nr.csv_id = 0
			nr.user_id = user.csv_id
			nr.quanguan_id = self.quanguan_id
			nr.start_time = date
			nr.iffinished = 0
			nr.invitation_id = self.invitation_id
			nr.if_trigger_event , nr.end_time = get_total_delay_time( lq , fqn )
			nr.end_time = nr.end_time + nr.start_time

			nr = user.u_lilian_mainmgr.create( nr )
			user.u_lilian_mainmgr:__add( nr )
			nr:__insert_db()

		end 		
	end 			
end					
					
function REQUEST:lilian_get_phy_power()

end					
					
function REQUEST:lilian_get_reward_list()

end			
			
function cgold_request.start(c, s, g, ...)
	-- body	
	print( "*********************************cgold_start" )
	client_fd = c
	send_request = s
	game = g
end			
			
function cgold_request.disconnect()
	-- body	
end			
			
cgold_request.REQUEST = REQUEST
cgold_request.RESPONSE = RESPONSE
cgold_request.SUBSCRIBE = SUBSCRIBE
		
return cgold_request