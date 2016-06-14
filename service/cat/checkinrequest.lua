local checkinrequest = {}
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

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end	
	
function REQUEST:login(u)
	-- body
	assert( u )
	print( "**********************************checkinrequest_login " )
	user = u
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

-- msg: **ifcheckin_t * 1 can check , --0 can not checkin**
	
local function get_g_checkin_by_csv_id( checkin_time , checkin_month )
	assert( checkin_time and checkin_month )
			
	local mon = tonumber( os.date( "%m" , checkin_time ) )
	-- msg : "below op is for temprory , when the checkin table changes codes change"
	if 12 ~= mon then
		mon = 0
	end

	local t = skynet.call(".game", "lua", "query_g_checkin", mon * 1000 + checkin_month)
	assert(t)
	-- local t = game.g_checkinmgr:get_by_csv_id( mon * 1000 + checkin_month )
	-- assert( t )

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

	local t = skynet.call(".game", "lua", "query_g_checkin_total", reward_num)
	--local t = game.g_checkin_totalmgr:get_by_id( reward_num )
	assert( t )

	return t
end	
	
--[[local function Split(szFullString, szSeparator)  
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
end --]]
	
local function get_accumulate_reward( t )
	assert( t )

	local ret = {}
		
	print( "*********************************get_accumulate_reward" )
	local r = util.parse_text( t.prop_id_num , "(%d+%*%d+%*?)" , 2 )

	for _ , sub in ipairs( r ) do
		local tmp = {}
		tmp.propid = tonumber( sub[ 1 ] )
		tmp.amount = tonumber( sub[ 2 ] )
		print( k , v , sub[ 1 ] , sub[ 2 ] )
		table.insert( ret , tmp )
	end	

	--[[local r = Split( t.prop_id_num , "," )
	assert( r )
	
	print( "size of r in checkinrequest is ******************************* " , #r )
	--local length = r / 2
	
	for k , v in ipairs( r ) do
		local tmp = {}
		local sub = Split( v , "*" )
		assert( sub )
		tmp.propid = tonumber( sub[ 1 ] )
		tmp.amount = tonumber( sub[ 2 ] )
		print( k , v , sub[ 1 ] , sub[ 2 ] )
		table.insert( ret , tmp )
	end	
--]]
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
			p.user_id = user.csv_id
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
		
local counter = 0 
		
function REQUEST:checkin(ctx)
	assert(ctx)
	-- body
	print( "*-------------------------* checkin is called")
	local factory = ctx:get_myfactory()
	assert(factory)

	local ret = {}

	local date = tonumber( os.date( "%Y%m%d" , os.time() ) )
	print( "date is " , date )
	local year = string.sub( date , 1 , 4 )
	local month = string.sub( date , 5 , 6 )
	local day = string.sub( date , 7 , 8 )

	local today_start_time = os.time( { year = year , month = month , day = day , hour = 0 , min = 0 , sec = 0 } )
	--local today_start_time 
	print( "sizeof checkin is ################################" , user.u_checkinmgr:get_count() )
	local tcheckin = factory:checkin_get_checkin()
	local tcheckin_month = factory:checkin_month_get_checkin_month()

	-- local tcheckin = user.u_checkinmgr:checkin_get_checkin()
	-- local tcheckin_month = user.u_checkin_monthmgr:get_checkin_month()
	--assert( tcheckin )
	print( tcheckin , tcheckin_month )
	if not tcheckin then
		print ( "*********************** both nill " )
		ret.ifcheckin_t = true
		ret.monthamount = 0 
	else
		if tcheckin.__fields.u_checkin_time ~= 0 then
			local changed = false
			local date = tonumber( os.date( "%Y%m%d" , tcheckin.__fields.u_checkin_time ) )
			print( "date is " , date )
			local y = string.sub( date , 1 , 4 )
			local m = string.sub( date , 5 , 6 )
				
			if year ~= y then
				changed = true	
			elseif month ~= m then
				changed = true
			end

			if changed then
				tcheckin_month.__fields.checkin_month = 0
				--tcheckin_month:__update_db( { "checkin_month" } , const.DB_PRIORITY_2 )
			end	
		end -- msg "UPDATE month_checkin each month"
		
		local date = os.time()

		--if tcheckin.update_time < date then
		if tcheckin.__fields.u_checkin_time + 30 < os.time() then -- tmp 30 sec can checkin 
			print("************************************************1", tcheckin.__fields.u_checkin_time)
			ret.ifcheckin_t = true
			--tcheckin.ifcheck_in = 1
		else
			print("************************************************2", tcheckin.__fields.u_checkin_time)
			ret.ifcheckin_t = false
			--tcheckin.ifcheck_in = 0
		end
		
		ret.monthamount = tcheckin_month.__fields.checkin_month 
	end 
	print( ctx:get_user().checkin_num , ret.rewardnum )
	ret.totalamount = ctx:get_user().checkin_num
	ret.rewardnum = ctx:get_user().checkin_reward_num

	return ret
end		
		
function REQUEST:checkin_aday(ctx)
	assert(ctx)

	print( "*-----------------------------* checkin_day is called" )

	local ret = {}
			
	local notexeit = false

	local time = os.time()
	local factory = ctx:get_myfactory()
	assert(factory)

	local tcheckin = factory:checkin_get_checkin()
	local tcheckin_month = factory:checkin_month_get_checkin_month()

	-- if not tcheckin then
	-- 	tcheckin = {}
	-- 	tcheckin_month = {}

	-- 	notexeit = true
	-- end 			

	--if tcheckin and tcheckin.__fields.update_time >= time then
	if false then
		if 0 == counter then
			ret.errorcode = errorcode[ 61 ].code
			ret.msg = errorcode[ 61 ].msg
			--if this case happens , maybe waigua . then logout game should be callled
		else 		
			ret.errorcode = errorcode[ 62 ].code
			ret.msg = errorcode[ 62 ].msg
		end 		
	else 	
		if tcheckin then
			assert(tcheckin_month)
			tcheckin:set_if_latest(0)
			tcheckin:update_db()
			ctx:get_modelmgr():get_u_checkinmgr():delete(tcheckin:get_id())

			tcheckin_month.__fields.checkin_month = tcheckin_month.__fields.checkin_month + 1
			tcheckin_month:update_db()
		else
			assert(tcheckin_month == nil)

			tcheckin_month = {}
			tcheckin_month.id = skynet.call(".game", "lua", "guid", const.CHECKIN_MONTH)
			tcheckin_month.checkin_month = 1
			tcheckin_month.user_id = ctx:get_user():get_csv_id()
			tcheckin_month = ctx:get_modelmgr():get_u_checkin_monthmgr():create( tcheckin_month )
			assert( tcheckin_month )
			user.u_checkin_monthmgr:add( tcheckin_month )
		end 
			counter = counter + 1
			
			local date = tonumber( os.date( "%Y%m%d" , time ) )
			print( "date is " , date )
			local year = string.sub( date , 1 , 4 )
			local month = string.sub( date , 5 , 6 )
			local day = string.sub( date , 7 , 8 )

			local update_time = os.time( { year = year , month = month , day = day , hour = 23 , min = 59 , sec = 59 } )
			print("update_time is ", update_time)

			local nc = {}
			nc.id = skynet.call(".game", "lua", "guid", const.CHECKIN)
			nc.u_checkin_time = time
			nc.update_time = update_time
			nc.user_id = ctx:get_user():get_csv_id()
			nc.if_latest = 1

			nc = ctx:get_modelmgr():get_u_checkinmgr():create(nc)
			assert(nc)
			ctx:get_modelmgr():get_u_checkinmgr():add(nc)	
			nc:update_db()
			tcheckin_month:update_db()

			-- if notexeit then
			-- 	tcheckin = user.u_checkinmgr:create( tcheckin )
			-- 	assert( tcheckin )
			-- 	user.u_checkinmgr:add( tcheckin )

			-- 	tcheckin_month.checkin_month = 1
			-- 	tcheckin_month.user_id = user.csv_id
			-- 	tcheckin_month = user.u_checkin_monthmgr.create( tcheckin_month )
			-- 	assert( tcheckin_month )
			-- 	user.u_checkin_monthmgr:add( tcheckin_month )
			-- 	tcheckin_month:__insert_db( const.DB_PRIORITY_2 )
			-- else
			-- 	tcheckin_month.checkin_month = tcheckin_month.checkin_month + 1
			-- 	--tcheckin_month:__update_db( { "checkin_month" } )	
			-- end

			-- print( tcheckin.u_checkin_time )
			-- tcheckin:__insert_db( const.DB_PRIORITY_2 )
			ctx:get_user():set_checkin_num(ctx:get_user():get_checkin_num() + 1)
			--user.checkin_num  = user.checkin_num + 1
			
			print( "*********************************user_checkin_num " , user.checkin_num )
			local t = get_g_checkin_by_csv_id( time , tcheckin_month.__fields.checkin_month )
			add_to_prop(ctx, get_aday_reward( t ) )


			ret.errorcode = errorcode[ 1 ].code
			ret.msg = errorcode[ 1 ].msg				
	end	

	return ret
end				
		
function REQUEST:checkin_reward(ctx)
	assert(ctx)

	print( "checkin_reward is called" )
	assert( self.totalamount and self.rewardnum )
	print( "checkin_reward is called" , self.totalamount , self.rewardnum )
	local ret = {}
	if ctx:get_user():get_checkin_num() ~= self.totalamount or ctx:get_user():get_checkin_reward_num() ~= self.rewardnum then
		print( "donot match the server totalmount" )
		ret.errorcode = errorcode[ 71 ].code
		ret.msg = errorcode[ 71 ].msg
		-- logout
	else	
		local t = get_g_checkin_month_by_reward_num( self.rewardnum + 1 )
		
		if  t.totalamount > ctx:get_user():get_checkin_num()  then
			ret.errorcode = errorcode[ 72 ].code
			ret.msg = errorcode[ 72 ].msg
			-- should logout
		else
			print( "******************************************checkin_reward" )
			user.checkin_reward_num = user.checkin_reward_num + 1
			user:update_db()
			add_to_prop(ctx, get_accumulate_reward( t ) )

			ret.errorcode = errorcode[ 1 ].code
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