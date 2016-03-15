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

local function raise_achievement(type, user)
	-- body
	if type == "combat" then
	elseif type == const.A_T_GOLD then -- 2
		repeat
			local a = assert(user.u_achievementmgr:get_by_type(const.A_T_GOLD))
			if a.is_valid == 0 then
				break
			end
			local gold = user.u_propmgr:get_by_csv_id(const.GOLD) -- abain prop by type (type -- csv_id -- prop.id)		
			local progress = gold.num / a.c_num
			if progress >= 1 then -- success
				a.finished = 100
				a.reward_collected = 0			
				-- insert achievement rc	
				local rc = user.u_achievement_rcmgr.create(a)
				user.u_achievement_rcmgr:add(rc)
				rc:__insert_db()

				if string.match(a.unlock_next_csv_id, "%d*%*%d*") then
					local k1 = string.gsub(a.unlock_next_csv_id, "(%d*)%*(%d*)", "%1")
					local k2 = string.gsub(a.unlock_next_csv_id, "(%d*)%*(%d*)", "%2")
					
					local a1 = skynet.call(game, "lua", "query_g_achievement", k1)
					a1.user_id = user.csv_id
					a1.finished = 100
					a1.is_unlock = 1
					a1.reward_collected = 0
					a1 = user.u_achievement_rcmgr.create(a1)
					user.u_achievement_rcmgr:add(a1)
					a1:__insert_db()

					if tonumber(k2) == 0 then
						a.is_valid = 0
						a:__update_db({"is_valid"})	
						break
					else
						local ga = assert(game.g_achievementmgr:get_by_csv_id(k2))
						a.csv_id = ga.csv_id
						a.finished = 0
						a.c_num = ga.c_num
						a.unlock_next_csv_id = ga.unlock_next_csv_id
						-- a.is_unlock = 1
						a:__update_db({"csv_id", "finished", "c_num", "unlock_next_csv_id", "is_valid"})	
					end
				else
					local ga = assert(game.g_achievementmgr:get_by_csv_id(a.unlock_next_csv_id))
					a.csv_id = ga.csv_id
					a.finished = 0
					a.c_num = ga.c_num
					a.unlock_next_csv_id = ga.unlock_next_csv_id
					a.is_unlock = 1
					a:__update_db({"csv_id", "finished", "c_num", "unlock_next_csv_id", "is_unlock"})	
				end
			else
				a.finished = progress * 100
				a.finished = math.floor(a.finished)
				a:__update_db({"finished"})
				break
			end
		until false
	elseif type == const.A_T_EXP then
		repeat
			local a = assert(user.u_achievementmgr:get_by_type(type))
			if a.is_valid == 0 then
				break
			end
			local prop = user.u_propmgr:get_by_csv_id(const.EXP) -- abain prop by type (type -- csv_id -- prop.id)		
			local progress = prop.num / a.c_num
			if progress >= 1 then -- success
				a.finished = 100
				a.reward_collected = 0
				push_achievement(a)
				
				-- insert achievement rc	
				local rc = user.u_achievement_rcmgr.create(a)
				user.u_achievement_rcmgr:add(rc)
				rc:__insert_db()

				if string.match(a.unlock_next_csv_id, "%d*%*%d*") then
					local k1 = string.gsub(a.unlock_next_csv_id, "(%d*)%*(%d*)", "%1")
					local k2 = string.gsub(a.unlock_next_csv_id, "(%d*)%*(%d*)", "%2")
					
					local a1 = game.g_achievementmgr:get_by_csv_id(k1)
					a1.user_id = user.csv_id
					a1.finished = 100
					a1.is_unlock = 1
					a1.reward_collected = 0
					a1 = user.u_achievement_rcmgr.create(a1)
					user.u_achievement_rcmgr:add(a1)
					a1:__insert_db()

					if tonumber(k2) == 0 then
						a.is_valid = 0
						a:__update_db({"is_valid"})	
						break
					else
						local ga = assert(game.g_achievementmgr:get_by_csv_id(k2))
						a.csv_id = ga.csv_id
						a.finished = 0
						a.c_num = ga.c_num
						a.unlock_next_csv_id = ga.unlock_next_csv_id
						-- a.is_unlock = 1
						a:__update_db({"csv_id", "finished", "c_num", "unlock_next_csv_id", "is_valid"})	
					end

				else
					local ga = assert(game.g_achievementmgr:get_by_csv_id(a.unlock_next_csv_id))
					a.csv_id = ga.csv_id
					a.finished = 0
					a.c_num = ga.c_num
					a.unlock_next_csv_id = ga.unlock_next_csv_id
					a.is_unlock = 1
					a:__update_db({"csv_id", "finished", "c_num", "unlock_next_csv_id", "is_unlock"})	
				end
			else
				a.finished = progress * 100
				a.finished = math.floor(a.finished)
				a:__update_db({"finished"})
				break
			end
		until false
	elseif type == "level" then
	end
end


function REQUEST:login(u)
	-- body
	assert( u )
	print( "**********************************exerciserequest_login " )
	user = u
	print( game.g_daily_taskmgr:get_count() )
	local t = game.g_daily_taskmgr:get_one() -- may be changed
	assert( t )
	record_date = Split( t.update_time , "|" )
	time_first = tonumber( string.sub( record_date[ 1 ] , 1 , 2 ) )
	time_second = tonumber( string.sub( record_date[ 2 ] , 1 , 2 ) )

	exercise_time = #record_date
	

	if 3 == exercise_time then
		time_third = tonumber( string.sub( record_date[ 3 ] , 1 , 2 ) )
	end 

	print( time_first , time_second , time_third )
end		
	
-- msg: **ifexercise_t * 1 can check , --0 can not exercise**
local function get_g_exercise( type )
	assert( type )
	print( "type is " , type )
	local t = game.g_daily_taskmgr:get_by_type( type )
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

		if v.propid == const.A_T_GOLD or v.propid == const.A_T_EXP then
			raise_achievement( v.propid , user )
		end
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
		
function REQUEST:exercise()
	-- body
	print( "*-------------------------* exercise is called")

	local ret = {}
	local texercise = user.u_exercise_mgr:get_exercise()

	if not texercise then
		print( "***********************not exist texercise" )
		ret.ifexercise = true
		ret.lefttime = 0
		ret.exercise_level = 0
		ifexercise = 1
	else 	
		print( "***********************exist texercise" )
		local time = os.time()
		local laststage = judge_time_quantum( texercise.exercise_time , texercise.time_length )
		local newstage , lefttime = judge_time_quantum( time , texercise.time_length )
			
		if 0 == laststage or newstage ~= laststage then
			ret.ifexercise = true
			ret.lefttime = 0
			ret.exercise_level = user.exercise_level
			ifexercise = 1
		else
			ret.ifexercise = false
			ret.lefttime = lefttime
			ret.exercise_level = user.exercise_level
			ifexercise = 0
		end 
	end     
	print( "lefttime is >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" , ret.lefttime )
	return ret
end			
			
function REQUEST:exercise_once()
	print( "*-----------------------------* exercise_day is called" )

	local ret = {}
	local time = os.time()
	local notexist = false

	local texercise = user.u_exercise_mgr:get_exercise()
	if not texercise then
		notexist = true
		texercise = {}
	end 
	print( "esercise_level is *********************" ,  self.exercise_level , ifexercise )
	if 0 == ifexercise or self.exercise_level ~= user.exercise_level then
		ret.errorcode = errorcode[ 61 ].code
		ret.msg = errorcode[ 61 ].msg
		--should logout
	else 	                           
		texercise.user_id = user.csv_id
		texercise.exercise_time = time
		texercise.exercise_type = self.exercise_type
		texercise.time_length = exercise_time
			
		if notexist then
			texercise = user.u_exercise_mgr.create( texercise )
			assert( texercise )
			user.u_exercise_mgr:add( texercise )
		end 

		texercise:__insert_db()

		local t = get_g_exercise( self.daily_type * 10 + self.exercise_type )
		local prop = user.u_propmgr:get_by_csv_id( t.cost_id )
		if not prop or prop.num < t.cost_amount then
			ret.errorcode = errorcode[ 16 ].code
			ret.msg = errorcode[ 16 ].msg
		else
			print( "************************************can exercise reward" )
			ifexercise = 0
			print( "cost money is ********************************" , t.cost_id , t.cost_amount , t.level_up  )
			prop.num = prop.num - t.cost_amount
			prop:__update_db( { "num" } )

			
			add_to_prop( get_exercise_reward( t ) )	
			user.exercise_level = user.exercise_level + t.level_up
			user:__update_db( { "exercise_level" } )
			
			ret.errorcode = errorcode[ 1 ].code
			ret.msg = errorcode[ 1 ].msg 
			local sta , lefttime = judge_time_quantum( time , texercise.time_length )
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