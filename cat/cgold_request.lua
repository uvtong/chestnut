local cgold_request = {}
local dc = require "datacenter"
local util = require "util"
local errorcode = require "errorcode"

local send_package
local send_request
	
local REQUEST = {}
local RESPONSE = {}
local SUBSCRIBE = {}
local client_fd
	
local game
local user
local dc
local cgold_mgr
local record_date = {}

local time_first
local time_second
local time_third
local cgold_time
local ifcgold = 0 -- judge if can cgold , 0 cannot , 1 can
local errorcode = { WAI_GUA = 1 , NOT_ENOUGH_MONEY = 2 }

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
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

function REQUEST:login(u)
	-- body
	assert( u )
	print( "**********************************cgoldrequest_login " )
	user = u
	cgold_mgr = user.u_cgoldmgr
	assert( cgold_mgr )
	--print( game.g_daily_taskmgr:get_count() )
	local t = game.g_daily_taskmgr:get_one() -- may be changed
	assert( t )
	record_date = Split( t.update_time , "|" )
	--print( record_date[ 1 ] , record_date[ 2 ] , record_date[ 3 ] )
	time_first = tonumber( string.sub( record_date[ 1 ] , 1 , 2 ) )
	time_second = tonumber( string.sub( record_date[ 2 ] , 1 , 2 ) )

	cgold_time = #record_date
	

	if 3 == cgold_time then
		time_third = tonumber( string.sub( record_date[ 3 ] , 1 , 2 ) )
	end 

	--print( time_first , time_second , time_third )
end		
	
-- msg: **ifcgold_t * 1 can check , --0 can not cgold**
local function get_g_cgold( type )
	assert( type )
	print( "type is " , type )
	local t = game.g_daily_taskmgr:get_by_type( type )
	assert( t )

	return t
end	


						
local function get_cgold_reward( t )
	assert( t )
	print( "****************************get_cgold_reward" )
	local ret = {}
	local tmp = {}
	print( "basic_reward " , t.basic_reward )
	local r = Split( t.basic_reward , "," )
	assert( r )
	--print( t.level_up , t.levelup_reward )
	local sub = Split( r[ 1 ] , "*" )
	assert( sub )
	tmp.propid = tonumber( sub[ 1 ] )
	tmp.amount = tonumber( sub[ 2 ] ) + t.level_up * t.levelup_reward 

	table.insert( ret , tmp )

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
			--print( "propid is " , v.propid )
			local p = game.g_propmgr:get_by_csv_id( v.propid )
			p.user_id = user.csv_id
			p.num = v.amount
			local prop = user.u_propmgr.create(p)
			user.u_propmgr:add(prop)
			prop:__insert_db()
		end
	end		
end			
		
local function judge_time_quantum( time , lastlength ) -- msg: judge which time_quantum does last_cgold_time in 
	--[[ 
		lastlength is the update_time_qauntum in g_cgold 2 or 3
		
		time < first stage = 0 
		first <= time < second , stage = 1
		second <= time < third , stage = 2
		third <= time < forth , stage = 3
	--]]

	assert( time and lastlength )
	local stage
	local lefttime	

	local date = os.date( "%Y%m%d" , os.time() )
	print( "date is " , date )
	local year = string.sub( date , 1 , 4 )
	local month = string.sub( date , 5 , 6 )
	local day = string.sub( date , 7 , 8 )

	local first = os.time( { year = year , month = month , day = day , hour = 0 , min = 0 , sec = 0 } )

	local second = first + time_first * 60 * 60 --os.time( { year = year , month = month , day = day , hour = time_first , min = 0 , sec = 0 } )
	local third 
	local forth

	--[[ judge lasttime belongs to which time quantum --]]
	print( "cgold_time is " , lastlength , cgold_time )
	if lastlength ~= cgold_time then -- if update_time in g_cgold changed , the default is can cgold
		stage = 0 
		lefttime = 0
	else 
		if time < first then
			stage = 0
			lefttime = 0
		elseif first <= time and time < second then
			stage = 1
			lefttime = second - time
		else
			if 2 == cgold_time then
				third = first + ( time_second - 1 ) * 60 * 60 + 59 * 60 + 59  --os.time( { year = year , month = month , day = day  , hour = time_second - 1 , min = 59 , sec = 59 } )
				stage = 2				
				lefttime = third - time + 1
			elseif 3 == cgold_time then
				third = first + time_second * 60 * 60  --os.time( { year = year , month = month , day = day , hour = time_second , min = 0 , sec = 0 } )
				forth = first + ( time_third - 1 ) * 60 * 60 + 59 * 60 + 59  --os.time( { year = year , month = month , day = day , hour = time_third - 1 , min = 59 , sec = 59 } )
				
				if second <= time and time < third then
					stage = 2
					lefttime = third - time + 1
				else
					stage = 3
					print( time_second , forth , time , forth - time )
					lefttime = forth - time
				end	
			else
				assert( nil )
			end
		end
	end	

	assert( stage and lefttime )
	return stage , lefttime 
end 	
		
function REQUEST:c_gold()
	-- body
	print( "*-------------------------* cgold is called")

	local ret = {}
	local tcgold = cgold_mgr:get_cgold()

	if not tcgold then
		print( "***********************not exist tcgold" )
		ret.ifc_gold = true
		ret.lefttime = 0
		ret.c_gold_level = 0
		ifcgold = 1
	else 	
		print( "***********************exist tcgold" )
		local time = os.time()
		local laststage = judge_time_quantum( tcgold.cgold_time , tcgold.time_length )
		local newstage , lefttime = judge_time_quantum( time , tcgold.time_length )
			
		if 0 == laststage or newstage ~= laststage then
			ret.ifc_gold = true
			ret.lefttime = 0
			print( "user.cgold_level" , user.cgold_level  )
			ret.c_gold_level = user.cgold_level
			ifcgold = 1
		else
			ret.ifc_gold = false
			ret.lefttime = lefttime
			print( "user.cgold_level" , user.cgold_level  )
			ret.c_gold_level = user.cgold_level
			ifcgold = 0
		end 
	end     

	return ret
end			
			
function REQUEST:c_gold_once()
	print( "*-----------------------------* cgold_day is called" )

	local ret = {}
	local time = os.time()
	local notexist = false

	local tcgold = cgold_mgr:get_cgold()
	if not tcgold then
		notexist = true
		tcgold = {}
	end 
	
	print( ifcgold , self , self.c_gold_type ,  self.c_gold_level , user.cgold_level )
	if 0 == ifcgold or self.c_gold_level ~= user.cgold_level then
		ret.ok = false
		ret.msg = "you wai gua"
		--should logout
	else 	
		tcgold.user_id = user.csv_id
		tcgold.cgold_time = time
		tcgold.cgold_type = self.c_gold_type
		tcgold.time_length = cgold_time
			
		if notexist then
			tcgold = cgold_mgr.create( tcgold )
			assert( tcgold )
			cgold_mgr:add( tcgold )
		end 

		tcgold:__insert_db()

		local t = get_g_cgold( self.daily_type * 10 + self.c_gold_type )
		local prop = user.u_propmgr:get_by_csv_id( t.cost_id )
		if not prop or prop.num < t.cost_amount then
			ret.ok = false
			ret.errorcode = errorcode[ 16 ].code
			ret.msg = errorcode[ 16 ].msg
		else
			print( "************************************can cgold reward" )
			ifcgold = 0

			prop.num = prop.num - t.cost_amount
			prop:__update_db( { "num" } )

			
			add_to_prop( get_cgold_reward( t ) )	
			user.cgold_level = user.cgold_level + t.level_up
			user:__update_db( { "cgold_level" } )
			
			ret.ok = true 
			local sta , lefttime = judge_time_quantum( time , tcgold.time_length )
			--print( sta , lefttime )
			ret.lefttime = lefttime 
		end 
	end 	

	return ret
end					
			
function RESPONSE:abc()
	-- body	
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