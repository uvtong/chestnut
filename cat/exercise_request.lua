local exerciserequest = {}
local dc = require "datacenter"
local util = require "util"
local errorcode = require "errorcode"	
local const = require "const"
local socket = require "socket"
local skynet = require "skynet"
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

local time_first
local time_second
local time_third
local exercise_time
local ifexercise = 0 -- judge if can exercise , 0 cannot , 1 can

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

local function push_achievement(achievement)
	-- body
	ret = {}
	ret.which = {
		csv_id = achievement.csv_id,
		finished = achievement.finished
	}
	send_package(send_request("finish_achi", ret))
end

function REQUEST:login(u)
	-- body
	assert( u )
	print( "**********************************exerciserequest_login " )
	user = u

	local t = skynet.call(".game", "lua", "query_g_daily_task")
	assert( t )
	record_date = Split( t.update_time , "|" )
	--print( record_date[ 1 ] , record_date[ 2 ] , record_date[ 3 ] )
	time_first = tonumber( string.sub( record_date[ 1 ] , 1 , 2 ) )
	time_second = tonumber( string.sub( record_date[ 2 ] , 1 , 2 ) )

	exercise_time = #record_date
	assert(exercise_time > 0)

	if 3 == exercise_time then
		time_third = tonumber( string.sub( record_date[ 3 ] , 1 , 2 ) )
	end 


end		
	
-- msg: **ifexercise_t * 1 can check , --0 can not exercise**
local function get_g_exercise( type )
	assert( type )
	print( "type is " , type )
	local t = skynet.call(".game", "lua", "query_g_daily_task_by_id", type)

	--local t = game.g_daily_taskmgr:get_by_type( type )
	assert( t )

	return t
end	


						
local function get_exercise_reward( t )
	assert( t )
	print( "****************************get_exercise_reward" )
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
		
local function add_to_prop(ctx, t)
	assert(ctx and t)

	for k , v in ipairs( t ) do
		local prop = ctx:get_modelmgr():get_u_propmgr():get_by_csv_id( v.propid )
		if prop then
			prop:set_field("num", prop:get_field("num") + v.amount)
			prop:update_db()
			-- prop:__update_db({"num"})
		else
			print( "propid is " , v.propid )
			local p = skynet.call(".game", "lua", "query_g_prop", v.propid)
			--local p = game.g_propmgr:get_by_csv_id( v.propid )
			assert(p)
			p.user_id = ctx:get_user():get_field("csv_id")
			p.num = v.amount
			p.id = genpk_2(p.user_id, p.csv_id)
			local prop = ctx:get_modelmgr():get_u_propmgr():create(p)
			ctx:get_modelmgr():get_u_propmgr():add(prop)
			prop:update_db()
		end
		--[[if v.propid == const.A_T_GOLD or v.propid == const.A_T_EXP then
			raise_achievement( v.propid , user )
		end--]]
	end		
end	
		
local function judge_time_quantum( time , lastlength ) -- msg: judge which time_quantum does last_exercise_time in 
	--[[ 
		lastlength is the update_time_qauntum in g_exercise 2 or 3
		
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
	local second = os.time( { year = year , month = month , day = day , hour = time_first , min = 0 , sec = 0 } )
	local third 
	local forth

	--[[ judge lasttime belongs to which time quantum --]]
	print( "exercise_time is " , lastlength , exercise_time )
	if lastlength ~= exercise_time then -- if update_time in g_exercise changed , the default is can exercise
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
			if 2 == exercise_time then
				third = os.time( { year = year , month = month , day = day  , hour = time_second - 1 , min = 59 , sec = 59 } )
				stage = 2				
				lefttime = third - time + 1
			elseif 3 == exercise_time then
				third = os.time( { year = year , month = month , day = day , hour = time_second , min = 0 , sec = 0 } )
				forth = os.time( { year = year , month = month , day = day , hour = time_third - 1 , min = 59 , sec = 59 } )
				
				if second <= time and time < third then
					stage = 2
					lefttime = third - time + 1
				else
					stage = 3
					--print( time_second , forth , time , forth - time )
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
		
function REQUEST:exercise(ctx)
	assert(ctx)

	-- body
	print( "*-------------------------* exercise is called")

	local ret = {}
	local helper = ctx:get_helper()
	assert(helper)
	local texercise = helper:exercise_get_exercise()
		
	if not texercise then
		print( "***********************not exist texercise" )
		ret.ifexercise = true
		ret.lefttime = 0
		ret.exercise_level = ctx:get_user():get_field("exercise_level")
		ifexercise = 1
	else 	
		print( "***********************exist texercise" )
		local time = os.time()
		local laststage = judge_time_quantum( texercise:get_exercise_time() , texercise:get_field("time_length"))
		local newstage , lefttime = judge_time_quantum( time , texercise:get_field("time_length"))
		
		if 0 == laststage or newstage ~= laststage then
			ret.ifexercise = true
			ret.lefttime = 0
			ret.exercise_level = ctx:get_user():get_field("exercise_level")
			ifexercise = 1
		else
			ret.ifexercise = false
			ret.lefttime = lefttime
			ret.exercise_level = ctx:get_user():get_field("exercise_level")
			ifexercise = 0
		end 
	end     
	print( "lefttime is >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" , ret.lefttime )
	return ret
end			
				
function REQUEST:exercise_once(ctx)
	assert(ctx)
	print( "*-----------------------------* exercise_day is called" )

	local ret = {}
	local time = os.time()
	local notexist = false

	local helper = ctx:get_helper()
	assert(helper)
	local texercise = helper:exercise_get_exercise()

	print( "esercise_level is *********************" ,  self.exercise_level , ifexercise )
	if 0 == ifexercise or self.exercise_level ~= ctx:get_user():get_field("exercise_level") then
		ret.errorcode = errorcode[ 61 ].code
		ret.msg = errorcode[ 61 ].msg
		--should logout
	else
		if texercise then
			texercise:set_if_latest(0)
			texercise:update_db()
			ctx:get_modelmgr():get_u_exercisemgr():delete(texercise:get_field("id"))
		end 

		texercise = {}
		texercise.id = skynet.call(".game", "lua", "guid", const.EXERCISE)
		texercise.user_id = ctx:get_user():get_field("csv_id")
		texercise.exercise_time = time
		texercise.exercise_type = self.exercise_type
		texercise.time_length = exercise_time
		texercise.if_latest = 1
					
		texercise = ctx:get_modelmgr():get_u_exercisemgr():create( texercise )
		assert( texercise )
		ctx:get_modelmgr():get_u_exercisemgr():add( texercise )
		texercise:update_db()

		local t = get_g_exercise( self.daily_type * 10 + self.exercise_type )
		local prop = ctx:get_modelmgr():get_u_propmgr():get_by_csv_id( t.cost_id )
		if not prop or prop.num < t.cost_amount then
			ret.errorcode = errorcode[ 16 ].code
			ret.msg = errorcode[ 16 ].msg
		else 
			print( "************************************can exercise reward" )
			ifexercise = 0
			print( "cost money is ********************************" , t.cost_id , t.cost_amount , t.level_up  )
			prop:set_field("num", prop:get_field("num") - t.cost_amount)
			prop:update_db()

			add_to_prop(ctx, get_exercise_reward( t ) )	

			ctx:get_user():set_exercise_level(ctx:get_user():get_field("exercise_level") + t.level_up)
			--ctx:get_user().exercise_level = ctx:get_user().exercise_level + t.level_up

			--ctx:get_user():update_db()
			ret.errorcode = errorcode[ 1 ].code
			ret.msg = errorcode[ 1 ].msg 
			local sta , lefttime = judge_time_quantum( time , texercise:get_field("time_length"))
			print( sta , lefttime )
			ret.lefttime = lefttime 
		end 
	end 	

	return ret
end					
			
function RESPONSE:abc()
	-- body	
end			
			
function exerciserequest.start(c, s, g, ...)
	-- body	
	print( "*********************************exercise_start" )
	client_fd = c
	send_request = s
	game = g
end			
			
function exerciserequest.disconnect()
	-- body	
end			
			
exerciserequest.REQUEST = REQUEST
exerciserequest.RESPONSE = RESPONSE
exerciserequest.SUBSCRIBE = SUBSCRIBE
		
return exerciserequest