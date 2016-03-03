local new_drawrequestrequest = {}
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
local draw_mgr
local record_date = {}

local if_friend_draw = false
local if_free_onetime_draw = false
local freetime = 1
local DAY = 24 * 60 * 60

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
	print( "**********************************new_drawrequestrequest_login " )
	user = u
	draw_mgr = user.u_drawmgr
	assert( draw_mgr )
end		
	
-- msg: **ifnew_drawrequest_t * 1 can check , --0 can not new_drawrequest**
local function get_g_new_drawrequest( type )
	assert( type )
	print( "type is " , type )
	local t = game.g_daily_taskmgr:get_by_type( type )
	assert( t )

	return t
end	
	
local function get_new_drawrequest_reward( t )
	assert( t )
	print( "****************************get_new_drawrequest_reward" )
	local ret = {}
	local tmp = {}
	print( "basic_reward " , t.basic_reward )
	local r = Split( t.basic_reward , "," )
	assert( r )
	print( t.level_up , t.levelup_reward )
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
			print( "propid is " , v.propid )
			local p = game.g_propmgr:get_by_csv_id( v.propid )
			p.user_id = user.id
			p.num = v.amount
			local prop = user.u_propmgr.create(p)
			user.u_propmgr:add(prop)
			prop:__insert_db()
		end
	end		
end			
		
local function judge_time_quantum( time , lastlength ) -- msg: judge which time_quantum does last_new_drawrequest_time in 
	--[[ 
		lastlength is the update_time_qauntum in g_new_drawrequest 2 or 3
		
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
	print( "new_drawrequest_time is " , lastlength , new_drawrequest_time )
	if lastlength ~= new_drawrequest_time then -- if update_time in g_new_drawrequest changed , the default is can new_drawrequest
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
			if 2 == new_drawrequest_time then
				third = os.time( { year = year , month = month , day = day  , hour = time_second - 1 , min = 59 , sec = 59 } )
				stage = 2				
				lefttime = third - time + 1
			elseif 3 == new_drawrequest_time then
				third = os.time( { year = year , month = month , day = day , hour = time_second , min = 0 , sec = 0 } )
				forth = os.time( { year = year , month = month , day = day , hour = time_third - 1 , min = 59 , sec = 59 } )
				
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

function REQUEST:draw()
	-- body
	print( "applydraw is called in drawmgr" )
	local ret = {}
	ret.list = {}
	
	local tfrienddraw = draw_mgr:get_by_type( drawtype.FRIEND )

	local settime = getsettime()
	
	local v = {}
	if not tfrienddraw or ( tfrienddraw.srecvtime < settime - 60 * 60 * 24 ) or ( tfrienddraw.srecvtime < settime  and os.time() > settime ) then
		v.drawtype = drawtype.FRIEND
		v.drawnum = 0
		isfriend = true
	else 
		v.drawtype = drawtype.FRIEND
		v.drawnum = 1
		isfriend = false
	end 

	table.insert( ret.list , v )

	local t = {}
	local tonetime = draw_mgr:get_by_type( drawtype.ONETIME )
	if not tonetime then
		print( "has not draw_onetime yet" )
		t.drawnum = 0
		t.lefttime = 0
		if_free_onetime_draw = true
	else
		print( "find the onetime draw" )
		t.drawtype = drawtype.ONETIME
		local line = game.g_drawcostmgr:get_by_csv_id( drawtype.ONETIME * 1000 )	
		assert( line )
		
		local nowtime = os.time() 
		if nowtime >= ( tonetime.srecvtime + line.cdtime ) then
			t.lefttime = 0
			t.drawnum = 1
			if_free_onetime_draw = true
		else
			if_free_onetime_draw = false
			t.lefttime = tonetime.srecvtime + line.cdtime - os.time() -- nowtime - srecvtime
		end
	end	
	table.insert( ret.list , t )			
	          
	return ret
end			

local ERROR = { WAI_GUA = 1 , NOT_ENOUGH_MONEY = 2 }

local function frienddraw( tv )
	assert( tv )
	local proplist = {}

	if false == isfriend then
		proplist.ok = false
		proplist.errorcode = ERROR.WAI_GUA
		return proplist
	end

	local dm = drawmgr:_create( tv ) 
	assert( dm )
	drawmgr:_db_insert_drawmsg( dm )
	print( "insert drawmsg over" )
	frecvtime = dm.srecvtime

	local line = game.g_drawcostmgr:get_by_csv_id( drawtype.ONETIME * 1000 )	
	assert( line )

	local prop = user.u_propmgr:get_by_csv_id( tonumber( line.cointype ) )
	print( "***************************line.cointype is " , line.cointype )

	if not prop or prop.num < line.price then
		print( "money is less then price" )
		local ret = {}
		ret.ok = false
		ret.errorcode = ERROR.NOT_ENOUGH_MONEY
		ret.msg = "not enough money"

		return ret
	else
		print( "line price is " , line.price )
		prop.num = prop.num - line.price
		proplist = getpropidlist( drawtype.FRIEND )

		prop:__update_db( {"num"} )
		isfriend = false
		print( "update prop successfully in tentimedraw" )
	end	
		
	return proplist
end 	
		
local function splitsubreward_bytype( typeid )
	assert( typeid )

	local sublist = {}
	for k , v in pairs( game.u_mainrewardmgr.__data )
		if v.csv_id == typeid then
			table.insert( sublist , v )
		end
	end

	print( "splitsubreward_bytype i called" )
	return sublist
end	
	
local function getgroupid( list , val )
	assert( val and list )

	local len = #list
	local sub = tonumber( list[len].probid )
	print( "sub and val is " )

	for i = len , 1 , -1 do
		if sub < val  then
			i = i - 1
			sub = sub + tonumber( list[i].probid )
		else    
			return list[i].groupid
		end 		
	end
end 
	
local function getpropidlist( dtype )
	print( "get[rp[od is called" )
	assert( dtype )
	local propidlist = {}
	propidlist.list = {}
		
	local subreward = csvReader.getcont( "subreward" )
	local mainreward = csvReader.getcont( "mainreward" )
	assert( subreward and mainreward )

	local sublist = splitsubreward_bytype( dtype * 1000 )
	assert( sublist )

	if drawtype.TENTIME == dtype then
		print( "dtype id in getpropidlis is " .. dtype )
		for i = 1 , 10 do
			local r = skynet.call( ".randomdraw" , "lua" , "command" , "draw" , dtype ) --drawmgr:_db_getrandomid( dtype )
			local id = getgroupid( sublist , r )
			for i = 1 , #subreward do
				if subreward[ i ].id == id then
					table.insert( propidlist.list , { propid = tonumber( subreward[ i ].propid ) ,
					propnum = tonumber( subreward[ i ].propnum ) } )
			 	end 	
			end	
		end	  
	else 	 
		print( "dtype id in getpropidlis is " .. dtype )
		local r = skynet.call( ".randomdraw" , "lua" , "command" , "draw" , dtype )
		print( r )
		print( "here" )
		local id = getgroupid( sublist , r )
		print( "groupid is >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" .. id )
		print( type( id ) )
		for i = 1 , #subreward do
			if subreward[i].id == id then
				print( type( subreward[i].id ) , type( id ) , subreward[i].id , id )
				table.insert( propidlist.list , { propid = tonumber( subreward[ i ].propid ) ,
						propnum = tonumber( subreward[ i ].propnum ) } )
				break
			end
		end
	end		

	assert( propidlist )
	propidlist.ok = true

	for k , v in ipairs( propidlist.list ) do
		local prop = user.u_propmgr:get_by_csv_id( v.propid )
		if prop then
			prop.num = prop.num + v.propnum
			prop:__update_db({"num"})
		else
			local p = game.g_propmgr:get_by_csv_id( v.propid )
			p.user_id = user.csv_id
			p.num = v.propnum
			local prop = user.u_propmgr.create(p)
			user.u_propmgr:add(prop)
			prop:__insert_db()
		end
	end

	print( "get propidlist successfully" )
	return propidlist
end				
	
local function tentimedraw( tv )
	assert( tv )

	local proplist = {}
	local dm = drawmgr:_create( tv ) 
	assert( dm )
		
	local line = game.g_drawcostmgr:get_by_csv_id( drawtype.TENTIME * 1000 )
	assert( line )

    local prop = user.u_propmgr:get_by_csv_id( line.cointype )

	if not prop or prop.num < line.price then
		print( "not enough money in tentime" )
		local ret = {}
		ret.ok = false
		ret.errorcode = ERROR.NOT_ENOUGH_MONEY
		ret.msg = "not enough money"

		return ret
	else 
		--drawmgr:_db_insert_drawmsg( dm )
		print( "insert drawmsg over" )

		prop.num = prop.num - line.price
		prop:__update_db( { "num" } )

		proplist = getpropidlist( drawtype.TENTIME )		
	end 

	print( "ten time draw is over" )

	return proplist
end 	
	
local function onetimedraw( tv )
	assert( tv )
	--local id = tv.drawtype
	        
	local proplist = {}
	local dm = drawmgr:_create( tv ) ------------------------------------------------------------------dai gai
	assert( dm )
	        
	print( tv.freetime )
	print( "dm.srecvtime is " , dm.srecvtime )
	        
	if true == tv.iffree then
		drawmgr:_db_insert_drawmsg( dm )
            
		print( "is free" )
		if freetime > 1 then
			proplist.ok = false
			proplist.errorcode = ERROR.WAI_GUA
			return proplist 
		else
			freetime = freetime + 1
		end  
		proplist = getpropidlist( drawtype.ONETIME )
		assert( proplist )
		print( "get for free successfully" )
		proplist.lefttime = DAY
		recvtime = dm.srecvtime
		print( "________________recvtime is " .. recvtime )
		return proplist
	else	
		print( "not free" )
		local t = {}
		local line = game.g_drawcostmgr:get_by_csv_id( drawtype.ONETIME * 1000 )
		assert( line )
            
    	local prop = user.u_propmgr:get_by_csv_id( line.cointype )

    	print( "get prop" )
		if not prop or prop.num < line.price then
			local ret = {}
			ret.ok = false
			ret.errorcode = ERROR.NOT_ENOUGH_MONEY
			ret.msg = "not enough money"
			
			return ret
		else
			--drawmgr:_db_insert_drawmsg( dm )
			print( "update prop is called in" )
			prop.num = prop.num - line.price
			proplist = getpropidlist( drawtype.ONETIME )
			
			local now = os.time()			
			print( "*******************" , now , recvtime , recvtime + day - now )

			if now > recvtime + day then
				print( " >>>>>>>>" )
				proplist.lefttime = 0
			else
				print( "<<<<<<<<" )
				proplist.lefttime = recvtime + day - now
			end 
			print("**********************")
			prop:__update_db( { "num" } )
			
			print( "update prop successfully in tentimedraw" )
		end	
	end
	return proplist
end
		
		
function REQUEST:applydraw()
	print( "*-----------------------------* new_drawrequest_day is called" )

	local ret = {}
	local time = os.time()
	local notexist = false

	local tnew_drawrequest = new_drawrequest_mgr:get_new_drawrequest()
	if not tnew_drawrequest then
		notexist = true
		tnew_drawrequest = {}
	end 
	
	print( "esercise_level is *********************" ,  self.new_drawrequest_level )
	
	if 0 == ifnew_drawrequest or self.new_drawrequest_level ~= user.new_drawrequest_level then
		ret.ok = false
		ret.msg = "you wai gua"
		--should logout
	else 	
		tnew_drawrequest.user_id = user.id
		tnew_drawrequest.new_drawrequest_time = time
		tnew_drawrequest.new_drawrequest_type = self.new_drawrequest_type
		tnew_drawrequest.time_length = new_drawrequest_time
			
		if notexist then
			tnew_drawrequest = new_drawrequest_mgr.create( tnew_drawrequest )
			assert( tnew_drawrequest )
			new_drawrequest_mgr:add( tnew_drawrequest )
		end 

		tnew_drawrequest:__insert_db()

		local t = get_g_new_drawrequest( self.daily_type * 10 + self.new_drawrequest_type )
		local prop = user.u_propmgr:get_by_csv_id( t.cost_id )
		if not prop or prop.num < t.cost_amount then
			ret.ok = false
			ret.error = 2
			ret.msg = "not enough money"
		else
			print( "************************************can new_drawrequest reward" )
			ifnew_drawrequest = 0

			prop.num = prop.num - t.cost_amount
			prop:__update_db( { "num" } )

			
			add_to_prop( get_new_drawrequest_reward( t ) )	
			user.new_drawrequest_level = user.new_drawrequest_level + t.level_up
			user:__update_db( { "new_drawrequest_level" } )
			
			ret.ok = true 
			local sta , lefttime = judge_time_quantum( time , tnew_drawrequest.time_length )
			print( sta , lefttime )
			ret.lefttime = lefttime 
		end 
	end 	

	return ret
end					
			

function RESPONSE:abc()
	-- body	
end			
			
function new_drawrequestrequest.start(c, s, g, ...)
	-- body	
	print( "*********************************new_drawrequest_start" )
	client_fd = c
	send_request = s
	game = g
end			
			
function new_drawrequestrequest.disconnect()
	-- body	
end			
			
new_drawrequestrequest.REQUEST = REQUEST
new_drawrequestrequest.RESPONSE = RESPONSE
new_drawrequestrequest.SUBSCRIBE = SUBSCRIBE
		
return new_drawrequestrequest
