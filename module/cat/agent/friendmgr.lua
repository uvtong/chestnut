package.path = "./../cat/?.lua;" .. package.path
	
local skynet = require "skynet"
local errorcode = require "errorcode"	
local util = require "util"

local friendmgr = {}
friendmgr._data = { friendlist = {} , applylist = {} , appliedlist = {} , avaliblelist = {} }
	
local MAXHEARTNUM = 100
local MAXFRIENDNUM = 10
local recvheartnum	= 0
local user
local UPDATETIME = 17
local total = 50 --dai ding
local dc 
local game
local SENDTYPE = 4 -- dai ding 4 presents heart
	
local friend = { csv_id, apply , name , level , viplevel , iconid , sign , fightpower , isonline , online_time , heart , apply , receive }
function friend:_new( ... )
	local t = {}

	setmetatable( t , { __index = friend } )

	return t
end	
	
local msgtype = { APPLY = 1 , DELETE = 2 , ACCEPT = 3 , REFUSE = 4 , SENDHEART = 5 , ACCEPTHEART = 6 , OTHER = 7 }	
local msg = { fromid , toid , type , propid , amount , isreward , csendtime , srecvtime , signtime , isread }
function msg:_new()
	local t = {}
	setmetatable( t , { __index = msg } )

	return t
end	
		
function friendmgr:_createfriend( tfriend )
	assert( tfriend )
	
	local r = friend:_new()
	assert( r )
	--print( "tfriendid is " , tfriend.csv_id )
	r.id = tfriend.csv_id
	r.name = tfriend.uname
	r.level = tfriend.level
	r.viplevel = tfriend.uviplevel
	r.iconid = tfriend.iconid
	r.sign = tfriend.sign
	r.fightpower = tfriend.combat
	print( "combat is *************************************" , r )
	r.online_time = os.date( "%Y%m%d%H%M%S" , tfriend.onlinetime) --tfriend.onlinetime
	r.ifonline = ( tfriend.ifonline == 0 ) and false or true
	r.heartamount = tfriend.heartamount or 0 -- the heart num that sended by another user
	r.heart = tfriend.heart or false
	r.apply = true
	r.receive = tfriend.receive or false
	r.signtime = tfriend.signtime
	
	--TODO
	print( "create friend successfully" )
	return r
end	
	
function friendmgr:_createmsg( tvals )
    assert( tvals )
   -- print("_createmsg is called")
    local nm = msg:_new()
    assert( nm )
    
    nm.fromid = user.csv_id
    nm.toid = tvals.toid
    nm.type = tvals.type
    nm.propid = tvals.propid or 0
    nm.amount = tvals.amount or 0
    nm.srecvtime = os.time()
    nm.csendtime = 0--tvals.csendtime or 0
    nm.signtime = tvals.signtime 
    nm.isread = tvals.isread or 0
    
   -- print( "create msg successfully" )
    return nm
end 
	
local function randomaddr()
	local r = math.random( 1 , 5 )
	-- local addr = skynet.localname( string.format( ".db%d", math.floor( r ) ) )
	local addr = ".db"
	--print("addr is " .. addr )
	assert( addr , "randomaddr failed\n" )
	
	return addr
end	
	
function friendmgr:_db_insertmsg( msg )
	assert( msg )
	--print( "isertmsg is called in mgr" )
	local addr = randomaddr()
	assert( addr )

	skynet.send( addr , "lua" , "command" , "insert_newmsg" , msg )

	print("insert a msg successfully")	
end 
	
	
function friendmgr:_db_loadfriend( uid )
	assert( uid )
	local addr = randomaddr()
	assert( addr )
	
	local t = {}
	t.uid = uid
	
	local result = skynet.call( addr , "lua" , "command" , "select_usermsg" , t )
	
	return result
end		
		
function friendmgr:_db_loadfriend_idlist( uid )
	assert( uid )
	local addr = randomaddr()
	assert( addr )
    
	local t = {}
	t.uid = uid 
    
	local result = skynet.call( addr , "lua" , "command" , "select_friendidlist" , t )
    
	return result
end	
	
function friendmgr:_db_loadavaliblefriend_idlist( uid , lowlevel , uplevel , lastday )
	assert( uid and lowlevel and uplevel and lastday )
	local addr = randomaddr()
	assert( addr )
    local t = {}
    t.lowlevel = lowlevel
    t.uplevel = uplevel
    t.lastday = lastday
    t.uid = uid
    
	local r = skynet.call( addr , "lua" , "command" , "select_loadavaliblefriendids" , t )
   	
   	if #r == nil then
   		print( "avaliblelist is nil ")
   	end
	return r
end		
	
function friendmgr:_db_applied_idlist( uid , msgtype )
	assert( uid and msgtype )
	
	local t = {}
	t.uid = uid
	t.type = msgtype

	local addr = randomaddr()
	assert( addr )

	local r = skynet.call( addr , "lua" , "command" , "select_applied_idlist" , t )

	return r
end	
	
function friendmgr:_db_apply_idlist( uid , msgtype )
	assert( uid and msgtype )

	local t = {}
	t.uid = uid
	t.type = msgtype

	local addr = randomaddr()
	assert( addr )

	local r = skynet.call( addr , "lua" , "command" , "select_apply_idlist" , t )

	print( "load apply_inlist successfully" )
	return r
end		
		
function friendmgr:_db_delete_friend( t )
	assert( t )

	local addr = randomaddr()
	assert( addr )

	skynet.send( addr , "lua" , "command" , "delete_friend" , t ) 
	print( "delete a friend successfully" )
end	 	
	
function friendmgr:_db_updatefriend( t )
	assert( t )

	local addr = randomaddr()
	assert( addr )

	skynet.send( addr , "lua" , "command" , "update_friend" , t )

	print( "update friend successfully" )
end	
		
function friendmgr:loadfriend( u , datacenter , g )
	user = u
    dc = datacenter
    game = g
			
	friendmgr._data.friendlist = friendmgr:_db_loadfriend_idlist( user.csv_id )
	--[[for i = 1 , #friendmgr._data.friendlist do
		friendmgr._data.friendlist[i] = friendmgr._data.friendlist[i]
	end--]]

	local i = 1
	local step = 20
	local lastday = os.time() - 24 * 60 * 60
	local ok = false
	-- select friend on different condition
	while i <= 3 do
		friendmgr._data.avaliblelist = friendmgr:_db_loadavaliblefriend_idlist( user.csv_id , user.level - step , user.level + step , lastday )
		print( "avaliblelist is *********************************" , #friendmgr._data.avaliblelist )
		if #friendmgr._data.avaliblelist < 10 then
			friendmgr._data.avaliblelist = {}
			step = step + 10
		else 
			ok = true
			break
		end 

		i = i + 1
	end        

	if not ok then
		step = 20
		i = 1

		while i <= 3 do
			friendmgr._data.avaliblelist = friendmgr:_db_loadavaliblefriend_idlist( user.csv_id , user.level - step , user.level + step , 0 )
			print( "avaliblelist2 is *********************************" , #friendmgr._data.avaliblelist )
			if #friendmgr._data.avaliblelist < 10 then
				friendmgr._data.avaliblelist = {}
				step = step + 10
			else 
				break
			end
			
			i = i + 1
		end 
	end     

	for i = 1 , #friendmgr._data.avaliblelist do
	--print( friendmgr._data.avaliblelist[i] , friendmgr._data.avaliblelist[i].csv_id)
		friendmgr._data.avaliblelist[i] = friendmgr._data.avaliblelist[i].csv_id
	end	
		
	friendmgr._data.appliedlist = friendmgr:_db_applied_idlist( user.csv_id , msgtype.APPLY )
	--[[for i = 1 , #friendmgr._data.appliedlist do
		friendmgr._data.appliedlist[i] = friendmgr._data.appliedlist[i]
	end--]]
	friendmgr._data.applylist = friendmgr:_db_apply_idlist( user.csv_id , msgtype.APPLY )
	for i = 1 , #friendmgr._data.applylist do
		friendmgr._data.applylist[i] = friendmgr._data.applylist[i].toid
	end 
	--TODO get applied list
	print( "load all idlist over" )

	if nil == #friendmgr._data.friendlist then
	   	print( "no friend in friendidlist , dbloadfriend\n" )
	end 
    if #friendmgr._data.avaliblelist == nil then
		print(" avalible is no ")
	end 
	if #friendmgr._data.avaliblelist < MAXFRIENDNUM then
	   	print( "avalible friends num < 10" )
	end		
    print("________________________load friend over")

   	return friendmgr
end			
	
function friendmgr:_db_get_recvheart( lowtime , hightime , uid )
	assert( lowtime , hightime )

	local addr = randomaddr()
	assert( addr )

	local t = {}
	t.lowtime = lowtime
	t.hightime = hightime
	t.uid = uid

	local r = skynet.call( addr , "lua" , "command" , "select_getheart" , t )
	print( "get heart successfully" )

	return r
				
end	


	
local function getsettime()
	local year = tonumber( os.date( "%Y" , os.time() ) )
	local month = tonumber( os.date( "%m" , os.time() ) )
	local day = tonumber( os.date( "%d" , os.time() ) )
	local hightime = { year = year , month = month , day = day , hour = UPDATETIME , min = 0 , sec = 0 }
	local hour = tonumber( os.date( "%H" , os.time() ) )
	local settime
	if 0 <= hour and hour < UPDATETIME then
		settime = os.time( hightime ) - 60 * 60 * 24
	else
		settime = os.time( hightime )
	end
		
	return settime
end	
		
local function gettodayheart()
	local daysec = 60 * 60 * 24

	local settime = getsettime()
	local lowtime = settime - daysec
	local hightime = os.time()

	if hightime > settime then
		lowtime = settime
	end	
	--local lowtime = { year = year , month = month , day = day , hour = 0 , min = 0 , sec = 1 }
	local r = friendmgr:_db_get_recvheart( lowtime , hightime , user.csv_id )

	local heart = 0
	if #r then
		for k , v in pairs( r ) do
			heart = heart + v.amount
		end
	end
	print( "heart is " .. heart )
	return heart
end		
		
--local function count_fightpower()
--	local total_combat = 0
--	total_combat = user.combat
--end 
	


function friendmgr:apply_friendlist()
	recvheartnum = gettodayheart()
	print( "recvheartnum is " .. recvheartnum )
	local receive 
	if recvheartnum < MAXHEARTNUM  then
		receive = true
	else
		receive = false
	end		
    		
    local fl = {}  
    print( "friend mgr date is " .. #friendmgr._data.friendlist )
	if 0 == #friendmgr._data.friendlist then
		print( "no friendmgr._data.friendlist in friendmgr._data.friendlist" )
		return nil , MAXHEARTNUM - recvheartnum
	else
		local settime = getsettime()
		local lowtime = settime - 60 * 60 * 24

		for k , v in pairs( friendmgr._data.friendlist ) do
			local tmp 
			--print( k , v.friendid , v.recvtime , v.sendtime )

			local t = dc.get( v.friendid )
			if t then -- if online
				print( "online" )
				tmp = skynet.call( t.addr , "lua" , "friend" , "agent_friendmsg")
				assert( tmp )
			else
				print( "not online" )
   				local r = friendmgr:_db_loadfriend( v.friendid )
   				assert( r )
   				tmp = r[1]
   				local t = util.get_total_property( nil , tmp.csv_id )
   				assert( t )
   				tmp.combat = t[ 1 ]
   			end
   			
   			tmp.receive = receive
   			--print( v.recvtime , v.sendtime , settime , v.heartamount)
   			
   				if os.time() >= settime then
   					tmp.heartamount = ( v.recvtime > settime ) and v.heartamount or 0
   					print("bigger than heart amolunt is " .. tmp.heartamount)
   				else
   					tmp.heartamount = ( v.recvtime < lowtime ) and 0 or v.heartamount
   					print("smaller then heart amolunt is " .. tmp.heartamount)
   				end

   			if nil == v.sendtime or 0 == v.sendtime or ( v.sendtime < settime and os.time() > settime ) then
   				tmp.heart = true
   			else                                                                                                                                                                                                                                                            
   				tmp.heart = false
   			end
   			tmp.signtime = v.recvtime -- '0' represents that i never sent heart to others , and used for sendheart and recvheart
   			print( "tmp.signtime is **************************" , tmp.signtime )
   	 		local f = friendmgr:_createfriend( tmp )
   			assert( f )

			table.insert( fl , f )

   			print( "build a friend successfully" )

   		end	
   		print( MAXHEARTNUM ,  MAXHEARTNUM - recvheartnum , recvheartnum )
   		return fl , ( MAXHEARTNUM - recvheartnum ) -- today_heart is the heart amount user gets today
   	end		
end			

--[[function friendmgr:noticeonline( dc )
	dc = dc	
	
	for k , v in pairs( self._data.friendlist ) do
		local r = dc.get( v )
		if r then
			print( r.client_fd , r.addr )
			local t = {}
			t.uid = tonumber( k )
			t.onlinetime = os.date( "%c" , os.time() )
			t.ifonline = true

			skynet.send( r.addr , "lua" , "command" , "sendonlinenotice" , t )
		end	
	end		
end			
--]] -- maybe used in the future 
	
function friendmgr:apply_appliedlist()
	
	local appliedlist = {}
	if 0 == #friendmgr._data.appliedlist then
		print( "applied is null" )
		return nil
	else
		print( "not nil" , #friendmgr._data.appliedlist )
		for k , v in pairs( friendmgr._data.appliedlist ) do
			--print( v.fromid )
			local tmp
			local t = dc.get( v.fromid )
			if t then -- if online
				print( "online" )
				tmp = skynet.call( t.addr , "lua" , "friend" , "agent_friendmsg")
				assert( tmp )
			else
				print( "not online" )
   				local r = friendmgr:_db_loadfriend( v.fromid )
   				assert( r )
   				tmp = r[1]
   				local t = util.get_total_property( nil , tmp.csv_id )
   				assert( t )
   				tmp.combat = t[ 1 ]
   			end

    		tmp.signtime = v.srecvtime
    		print( "v.srecvtime is " .. v.srecvtime )
			local n = friendmgr:_createfriend( tmp )
			assert( n )
    
			table.insert( appliedlist , n ) 
		end
		return appliedlist
	end
end	
	
local function findexist( idlist , id )
	assert( idlist , id )
    
    for k , v in pairs( idlist ) do
    	if type( v ) == "table" then
    		if v.friendid == id or v.fromid == id or v.toid == id then
    			return true
    		end
    	else
			if v == id then
				return true
			end	
		end
	end		

	return false 
end			
	
local function pickfriends()
   	local f = {}
   	local index 
   	local counter = 0
   	local tmp = {}

   	for k , v in pairs( friendmgr._data.avaliblelist ) do
   		if false == findexist( friendmgr._data.friendlist , v ) and false == findexist( friendmgr._data.appliedlist , v ) then
   		--	print( v )
   			table.insert( tmp , v )
		end 
   	end		
   	
   	if not tmp then
   		--TODO lower the fileter condition
   		return nil	
   	end		

   	friendmgr._data.avaliblelist = tmp

   	if #friendmgr._data.avaliblelist < MAXFRIENDNUM then
   		print( "avalible friends is less than 10" )
   		return friendmgr._data.avaliblelist
   	else	
   		while true do
	    	index = math.floor( math.random(1 , #friendmgr._data.avaliblelist ) )
	    	local uid = friendmgr._data.avaliblelist[index]
    		if not f[index] then
				table.insert( f , uid )
				counter = counter + 1
				if counter >= MAXFRIENDNUM then
					break
				end
			end
		end 	
    end		

	return f
end 		
			
function friendmgr:apply_otherfriendlist()
	local avaliblefriends = {}

	local a = pickfriends()
	assert( a )
	print( "getback from pickfriends" )
	for  k , v in pairs( a ) do
	--	print( k , v )
		local tmp
		local t = dc.get( v )
		if t then -- if online
			print( "online" )
			tmp = skynet.call( t.addr , "lua" , "friend" , "agent_friendmsg")
			assert( tmp )
		else
			print( "not online" )
   			local r = friendmgr:_db_loadfriend( v )
   			assert( r )
   			tmp = r[1]
   			local t = util.get_total_property( nil , tmp.csv_id )
   			assert( t )
   			tmp.combat = t[ 1 ]
   		end

		local n = friendmgr:_createfriend( tmp )
		assert( n )
        	
		table.insert( avaliblefriends , n )
	end 	
			
	return avaliblefriends
end			
		 	
function friendmgr:applyfriend( friendlist )
	assert( friendlist )
	local ret = {}
    
	for k , v in pairs( friendlist ) do
		local isfind = false
		print( v.friendid )
		if v.friendid == user.csv_id then
			print( "can not apply youself" )

			ret.errorcode = errorcode[63].code
			ret.msg =  errorcode[63].msg  --"can not apply yourself"
        	
			return ret
		end	
        	
		for sk , sv in pairs( friendmgr._data.applylist ) do
			if sv == v.friendid then
				print( "find friend1" ) 
				isfind = true 
				break        
			end
		end			
        	
		for sk , sv in pairs( friendmgr._data.appliedlist ) do
			if sv.fromid == v.friendid then
				print( "find friend1" ) 
				isfind = true 
				break        
			end
		end	
        	
		if isfind ~= true then
			table.insert( friendmgr._data.applylist , v.friendid )
			print( "v.friendid is " .. v.friendid )
			local t = v
			t.toid = v.friendid
			t.type = msgtype.APPLY
				
			local nm = friendmgr:_createmsg( t )
			assert( nm )

			local r = dc.get( v.friendid )
			--print( "r.addr is " .. r.addr )
			if r then
				skynet.send( r.addr , "lua" , "friend", "agent_request_handle" , nm )
				print( "notify an agent " , v.friendid ) 
			else
				friendmgr:_db_insertmsg( nm )
				print( "insert a new msg to db" )
			end

			ret.errorcode = errorcode[ 1 ].code
			ret.msg = errorcode[ 1 ].msg
			print( "apply end******************************" )
			return ret
		end	
	end		

	ret.errorcode = errorcode[ 70 ].code
	ret.msg = errorcode[ 70 ].msg

	return ret
end			

function friendmgr:_db_insert_newfriend( uid , friendid )
	assert( uid and friendid )

	local t = {}
   	t.uid = uid
   	t.friendid = friendid

   	local addr = randomaddr()
   	assert( addr )

   	skynet.send( addr , "lua" , "command" , "insert_newfriend" , t )

   	print( "insert a new friend successfully" )
end		 	
	     
function friendmgr:_db_updatemsg( t )
	assert( t )
            
	local addr = randomaddr()
	assert( addr )

	skynet.send( addr , "lua" , "command" , "update_msg" , t )
	print( "update a msg successfully" )  
end		 	
		
function friendmgr:recvfriend( friendlist )
	assert( friendlist )

	for k , v in pairs( friendlist ) do
		print( "**************************************** " , v.signtime , v.friendid)
		local r = friendmgr:_db_loadfriend( v.friendid )
   		assert( r )
   		print("redvtive friend " .. v.friendid)
   	 	table.insert( friendmgr._data.friendlist , { friendid = v.friendid , recvtime = 0  , heartamount = 0 , sendtime = 0 } )
   		
   		friendmgr:_db_insert_newfriend( user.csv_id , v.friendid )

   		local tmp = {}
		for sk , sv in pairs( friendmgr._data.appliedlist ) do
			if sv.fromid ~= v.friendid then
				table.insert( tmp , sv )
			end
		end
		friendmgr._data.appliedlist = tmp

		local t = v
		t.toid = v.friendid
		t.type = msgtype.ACCEPT
		t.signtime = v.signtime

		local nm = friendmgr:_createmsg( t )
		assert( nm )

		local r = dc.get( v.friendid )
		print( r )
		if r then
			print( "friend dc is called" )
			skynet.send( r.addr , "lua" , "friend", "agent_request_handle" , nm )
			print( "notify an agent " , v.friendid ) 
		else
			print( v.friendid , user.csv_id )
			friendmgr:_db_insert_newfriend( v.friendid , user.csv_id )
			friendmgr:_db_insertmsg( nm )
			local t = {}
			t.tname = "u_friendmsg"
			t.content = { isread = 1 }
			t.condition = { fromid = v.friendid , toid = user.csv_id , type = msgtype.APPLY , srecvtime = v.signtime }
			friendmgr:_db_updatemsg( t )

			print( "insert a new msg to db and update a msg" )
		end 
	end	
end	
 	
function friendmgr:refusefriend( friendlist )
	assert( friendlist )

	for k , v in pairs( friendlist ) do
		local tmp = {}
		for sk , sv in pairs( friendmgr._data.appliedlist ) do
			if sv.fromid ~= v.friendid then
				table.insert( tmp , sv )
			end
		end
		friendmgr._data.appliedlist = tmp
    	
		local t = v
		t.toid = v.friendid
		t.type = msgtype.REFUSE
		t.signtime = v.signtime
         
		local nm = friendmgr:_createmsg( t )
		assert( nm )
         
		local r = dc.get( v.friendid )
         
		if r then
			skynet.send( r.addr , "lua" , "friend", "agent_request_handle" , nm )
			print( "notify an agent " , v.friendid ) 
		else
			friendmgr:_db_insertmsg( nm )
			
			local t = {}
			t.tname = "u_friendmsg"
			t.content = { isread = 1 }
			t.condition = { fromid = v.friendid , toid = user.csv_id , type = msgtype.APPLY , srecvtime = v.signtime }
			friendmgr:_db_updatemsg( t )

			print( "insert a new msg to db and update a msg" )
		end 
	end				
end			
		

function friendmgr:deletefriend( friendid )
	assert( friendid )
	local ret = {}
	local tmp = {}
	for sk , sv in pairs( friendmgr._data.friendlist ) do
		if sv.friendid ~= friendid then
			table.insert( tmp , sv )
		end
	end

	friendmgr._data.friendlist = tmp -- delete friend data in memory first 
	
	print( "called" )
	local t = {}
	t.toid = friendid
	t.type = msgtype.DELETE
	t.signtime = 0
    print( "called" )
	local nm = friendmgr:_createmsg( t ) 
	assert( nm )

  	local t = {}
	t.tname = "u_friend"
	t.content = { isdel = 1 }
	t.condition = { uid = user.csv_id , friendid = friendid }

	friendmgr:_db_updatefriend( t ) -- delete friend data in db set isdel '1'
	local r = dc.get( friendid )
    
	if r then -- if online notice the friend 
		skynet.send( r.addr , "lua" , "friend", "agent_request_handle" , nm )
		print( "notify an agent " , friendid ) 
	else 										
		friendmgr:_db_insertmsg( nm ) -- insert a msg to friendmsg 
		print( "insertmag successfully" )

		local t = {}
		t.tname = "u_friend"
		t.content = { isdel = 1 }
		t.condition = { uid = friendid , friendid = user.csv_id }
		friendmgr:_db_updatefriend( t ) -- 

		print( "insert a new msg to db and update a msg" )
	end	

	ret.errorcode = errorcode[ 1 ].code
	ret.msg = errorcode[ 1 ].msg
	return ret
end			
	
function friendmgr:findfriend( id )
	assert( id )
	local ret = {}
	print( id )

	local r 

	local t = dc.get( id )

	if t then -- if online
		print( "online" )
		r = skynet.call( t.addr , "lua" , "friend" , "agent_friendmsg")
		assert( r )
	else      --not online
		print( "not online" )
   		local tmp = friendmgr:_db_loadfriend( v.friendid )
   		assert( tmp )
   		r = tmp[ 1 ]
   		local t = util.get_total_property( nil , tmp.csv_id )
   		assert( t )
   		r.combat = t[ 1 ]
   	end 

	
	if id == user.csv_id then
		ret.errorcode = errorcode[ 65 ].code
		ret.msg = errorcode[ 65 ].msg   --"can not add yourself"
		
		return ret 
	end	

	for k , v in pairs( friendmgr._data.friendlist ) do
		if v.friendid == id then
			ret.errorcode = errorcode[ 66 ].code
			ret.msg = errorcode[ 66 ].msg  --"already friend"

			return ret
		end
	end

	for k , v in pairs( friendmgr._data.appliedlist ) do
		if v.fromid == id then
			ret.errorcode = errorcode[ 67 ].code
			ret.msg = errorcode[ 67 ].msg  --"in the appliedlist "

			return ret
		end
	end
	
	local f = friendmgr:_createfriend( r )
	assert( f )
	ret.errorcode = errorcode[ 1 ].code
	ret.msg = errorcode[ 1 ].msg
	ret.friend = {}
	print( "**************************************************findfriend " , f.id )
	table.insert( ret.friend , f )
	return ret
end			
			
function friendmgr:recvheart( heartlist , totalamount )
	assert( heartlist and totalamount )
	local ret = {}
	print( "recvheartnum , totalamount " , recvheartnum , totalamount , MAXHEARTNUM )
	if recvheartnum + totalamount > MAXHEARTNUM then 
		ret.errorcode = errorcode[ 69 ].code 
		ret.msg = errorcode[ 69 ].msg
		return ret
	end		

	local prop = user.u_propmgr:get_by_csv_id( SENDTYPE )
	print( "sizeof heartlist is ******************************" , #heartlist )
	--print( "total num is " .. total.num )
	for k , v in pairs( heartlist ) do
			recvheartnum = recvheartnum + v.amount
			if prop then
					prop.num = prop.num + v.amount
					prop:__update_db( { "num" } )
			else
				local p = game.g_propmgr:get_by_csv_id( SENDTYPE )
				p.user_id = user.csv_id
				p.num = v.amount
				local prop = user.u_propmgr.create( p )
				user.u_propmgr:add( prop )
				prop:__insert_db()
			end		
					
			for sk , sv in ipairs( friendmgr._data.friendlist ) do
				if v.friendid == sv.friendid then
					sv.heartamount = 0
					local t = {}

					t.tname = "u_friend"
					t.content = { heartamount = 0 }
					t.condition = { uid = user.csv_id , friendid = v.friendid }
					friendmgr:_db_updatefriend( t ) 

					print( "update 0 finished ..........................." )
					break
				end
			end

			local t = v
			t.toid = v.friendid
			t.type = msgtype.ACCEPTHEART
			t.signtime = v.signtime

			local nm = friendmgr:_createmsg( t ) 
			assert( nm )
        	
			local r = dc.get( v.friendid )
         	
			if r then -- if online notice the friend 
				print( "online *************************************" )
				skynet.send( r.addr , "lua" , "friend", "agent_request_handle" , nm )
				print( "notify an agent " , v.friendid ) 
			else 
				print( "not online *****************************" )
				friendmgr:_db_insertmsg( nm ) -- insert a msg to friendmsg 
				--friendmgr:_db_updaterecv( user.csv_id , v.friendid , )
				--friendmgr:_db_delete_friend( v.friendid , user.csv_id ) -- 
				local t = {}
				t.tname = "u_friendmsg"
				t.content = { isread = 1 }
				t.condition = { fromid = v.friendid , toid = user.csv_id , type = msgtype.SENDHEART , srecvtime = v.signtime }
				friendmgr:_db_updatemsg( t )	
				print( "insert a new msg to db and update a msg" )
			end	
	end		

	--prop:__update_db( {"num"} )

	ret.errorcode = errorcode[ 1 ].code
	ret.msg = errorcode[ 1 ].msg

	return ret
end			
		
function friendmgr:sendheart( heartlist , totalamount ) 
	assert( heartlist )
	print(	"heartamount = " .. totalamount )

	local ret = {}
	local prop = user.u_propmgr:get_by_csv_id( SENDTYPE )
	--assert( total )
	--print( "total num is " .. total.num )
	if nil == prop or prop.num - totalamount < 0 then -- not enough heart then return error
		ret.errorcode = errorcode[ 68 ].code
		ret.msg = errorcode[ 68 ].msg

		return ret
	end  

	for k , v in pairs( heartlist ) do

		prop.num = prop.num - v.amount
		prop:__update_db( { "num" } )

		local t = v
		t.toid = v.friendid
		t.type = msgtype.SENDHEART
		t.signtime = v.signtime

		local nm = friendmgr:_createmsg( t ) 
		assert( nm )
        	
		for sk , sv in ipairs( friendmgr._data.friendlist ) do
			if sv.friendid == v.friendid then
				print("find friend" .. nm.srecvtime )
				sv.sendtime = nm.srecvtime
				break
			end
		end

		local r = dc.get( v.friendid )
        
        local t = {}
		t.tname = "u_friend"
		t.content = { sendtime = nm.srecvtime }
		t.condition = { uid = user.csv_id , friendid = v.friendid }
		friendmgr:_db_updatefriend( t ) 
		
		if r then -- if online notice the friend 
			print( "online **************************************************" )
			skynet.send( r.addr , "lua" , "friend", "agent_request_handle" , nm )
			print( "notify an agent " , v.friendid ) 
		else 
			print( "not online ********************************************" )
			friendmgr:_db_insertmsg( nm ) -- insert a msg to friendmsg 	
			t = {}
			t.tname = "u_friend"
			t.content = { heartamount = v.amount , recvtime = nm.srecvtime }
			t.condition = { uid = v.friendid , friendid = user.csv_id }
			friendmgr:_db_updatefriend( t )
			print( "insert a new msg to db and update a msg" )
		end	
	end	

	ret.errorcode = errorcode[ 1 ].code
	ret.msg = errorcode[ 1 ].msg

	return ret
end		
			
function friendmgr:agent_request_handle( msg )
	assert( msg )
			
	local ret = {}
	--local ret.friendmsg = {}
	if msg.type == msgtype.APPLY then
		friendmgr:_db_insertmsg( msg )
		print( "******************************************msgtype.APPLY" , msg.fromid )
		table.insert( friendmgr._data.appliedlist , { fromid = msg.fromid , srecvtime = msg.srecvtime } )

	elseif msg.type == msgtype.DELETE then
		friendmgr:_db_insertmsg( msg ) -- insert a msg to friendmsg 

		local tmp = {}
		for k , v in pairs( friendmgr._data.friendlist ) do
			if msg.fromid ~= v.friendid then
				table.insert( tmp , v )
			end
		end

		friendmgr._data.friendlist = tmp
		local t = {}
		t.tname = "u_friend"
		t.content = { isdel = 1 }
		t.condition = { uid = user.csv_id , friendid = msg.fromid }
		friendmgr:_db_updatefriend( t )
		--TODO
	elseif msg.type == msgtype.ACCEPT then
		friendmgr:_db_insertmsg( msg )
		print( "insert successfully in msgtype.ACCEPT" )
		friendmgr:_db_insert_newfriend( user.csv_id , msg.fromid )
		table.insert( friendmgr._data.friendlist , { friendid = msg.fromid , recvtime = 0 , heartamount = 0 , sendtime = 0 } )
		local tmp = {}
		for k , v in pairs( friendmgr._data.applylist ) do
			if msg.fromid ~= v then
				table.insert( tmp , v )
			end
		end
		friendmgr._data.applylist = tmp

		local t = {}
		t.tname = "u_friendmsg"
		t.content = { isread = 1 }
		print( "msg.signtime is ......................." , msg.signtime )
		t.condition = { fromid = user.csv_id , toid = msg.fromid , type = msgtype.APPLY , srecvtime = msg.signtime }
		friendmgr:_db_updatemsg( t )
		
		--local ret = {}
		--ret.type = msgtype.ACCEPT
		--ret.ok = true

		--return ret	
	elseif msg.type == msgtype.REFUSE then 
		friendmgr:_db_insertmsg( msg )
		print( "insert successfully in msgtype.REFUSE" )
		local tmp = {}
		for k , v in pairs( friendmgr._data.applylist ) do
			if msg.fromid ~= v then
				table.insert( tmp , v )
			end
		end
		
		friendmgr._data.applylist = tmp
		
		local t = {}
		t.tname = "u_friendmsg"
		t.content = { isread = 1 }
		t.condition = { fromid = user.csv_id , toid = msg.fromid , type = msgtype.APPLY , srecvtime = msg.signtime }
		friendmgr:_db_insertmsg( msg )
		friendmgr:_db_updatemsg( t )
		--TODO maybe should send some msg to client for redpoint
	elseif msg.type == msgtype.SENDHEART then
		
		friendmgr:_db_insertmsg( msg )
		print( "insert successfully in msgtype.SENDHEART" )

		for k , v in ipairs( friendmgr._data.friendlist ) do
			if v.friendid == msg.fromid then
				v.recvtime = msg.srecvtime
				v.heartamount = msg.amount

				print( "agent heartamount is ___________________________" , friendmgr._data.friendlist[k].recvtime ,  friendmgr._data.friendlist[k].heartamount)
				break
			end
		end

		local t = {}
		t.tname = "u_friend"
		t.content = { heartamount = msg.amount , recvtime = msg.srecvtime }
		t.condition = { uid = user.csv_id , friendid = msg.friendid }
		friendmgr:_db_updatefriend( t )

	elseif msg.type == msgtype.ACCEPTHEART then

		local t = {}
		t.tname = "u_friendmsg"
		t.content = { isread = 1 }
		t.condition = { fromid = user.csv_id , toid = msg.friendid , type = msgtype.SENDHEART , srecvtime = msg.signtime }
		friendmgr:_db_insertmsg( msg )
		friendmgr:_db_updatemsg( t )
	end	
end 		
		
function friendmgr:agent_friendmsg()
	print( "get online user msg !!!!!!!!!!!!!!!!!!" )
	local r = {}
	local tmp = util.get_total_property( user , _ )
	assert( tmp )
	r.csv_id = user.csv_id
	r.name = user.uname
	r.level = user.level
	r.viplevel = user.uviplevel
	r.iconid = user.iconid
	r.sign = user.sign
	r.combat = tmp[ 1 ]
	r.online_time = os.date( "%Y%m%d%H%M%S" , user.onlinetime) --user.onlinetime
	r.ifonline = true

	return r

end

return friendmgr
		
