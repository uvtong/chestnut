package.path = "./../cat/?.lua;" .. package.path
	
local skynet = require "skynet"
	
local friendmgr = {}
friendmgr._data = { friendlist = {} , applylist = {} , appliedlist = {} , avaliblelist = {} }
	
local MAXHEARTNUM = 100
local MAXFRIENDNUM = 10
local recvheartnum	= 0
local user
local updatetime = 17
local total = 50 --dai ding
local dc 
	
local friend = { id, apply , name , level , viplevel , iconid , sign , fightpower , isonline , online_time , heart , apply , receive }
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
	print( "tfriendid is " , tfriend.id )
	r.id = tfriend.id
	r.name = tfriend.uname
	r.level = tfriend.level
	r.viplevel = tfriend.viplevel
	r.iconid = tfriend.iconid
	r.sign = tfriend.sign
	r.combat = tfriend.combat
	r.online_time = os.date( "%Y%m%d%H%M%S" , tfriend.onlinetime) --tfriend.onlinetime
	r.ifonline = ( tfriend.ifonline == 0 ) and false or true
	r.heartamount = tfriend.heartamount or 0
	r.heart = tfriend.heart or false
	r.apply = true
	r.receive = tfriend.receive or false
	--TODO
	print( "create friend successfully" )
	return r
end	
	
function friendmgr:_createmsg( tvals )
    assert( tvals )
    print("_createmsg is called")
    local nm = msg:_new()
    assert( nm )

    nm.fromid = user.id
    nm.toid = tvals.toid
    nm.type = tvals.type
    nm.propid = tvals.propid or 0
    nm.amount = tvals.amount or 0
    nm.srecvtime = os.time()
    nm.csendtime = 0--tvals.csendtime or 0
    nm.signtime = tvals.signtime 
    nm.isread = tvals.isread or 0
    
    print( "create msg successfully" )
    return nm
end 
	
local function randomaddr()
	local r = math.random( 1 , 5 )
	local addr = skynet.localname( string.format( ".db%d", math.floor( r ) ) )
	print("addr is " .. addr )
	assert( addr , "randomaddr failed\n" )

	return addr
end	
	
function friendmgr:_db_insertmsg( msg )
	assert( msg )
	print( "isertmsg is called in mgr" )
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
	
function friendmgr:_db_loadavaliblefriend_idlist( uid , level )
	assert( level )
	local addr = randomaddr()
	assert( addr )
    local t = {}
    t.level = level
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
	
function friendmgr:loadfriend( u , datacenter )
	user = u
    dc = datacenter
	
	friendmgr._data.friendlist = friendmgr:_db_loadfriend_idlist( user.id )
	--[[for i = 1 , #friendmgr._data.friendlist do
		friendmgr._data.friendlist[i] = friendmgr._data.friendlist[i]
	end--]]
	friendmgr._data.avaliblelist = friendmgr:_db_loadavaliblefriend_idlist( user.id , user.level )
	for i = 1 , #friendmgr._data.avaliblelist do
	print( friendmgr._data.avaliblelist[i] , friendmgr._data.avaliblelist[i].id)
		friendmgr._data.avaliblelist[i] = friendmgr._data.avaliblelist[i].id
	end	
	friendmgr._data.appliedlist = friendmgr:_db_applied_idlist( user.id , msgtype.APPLY )
	--[[for i = 1 , #friendmgr._data.appliedlist do
		friendmgr._data.appliedlist[i] = friendmgr._data.appliedlist[i]
	end--]]
	friendmgr._data.applylist = friendmgr:_db_apply_idlist( user.id , msgtype.APPLY )
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
	local hightime = { year = year , month = month , day = day , hour = updatetime , min = 0 , sec = 0 }
	local hour = tonumber( os.date( "%H" , os.time() ) )
	local settime
	if 0 <= hour and hour < updatetime then
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
	local r = friendmgr:_db_get_recvheart( lowtime , hightime , user.id )

	local heart = 0
	if #r then
		for k , v in pairs( r ) do
			heart = heart + v.amount
		end
	end
	print( "heart is " .. heart )
	return heart
end		
		
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
		return nil
	else
		local settime = getsettime()
		local lowtime = settime - 60 * 60 * 24

		for k , v in pairs( friendmgr._data.friendlist ) do
			local tmp 
			print( k , v.friendid , v.recvtime , v.sendtime )

			local t = dc.get( v.friendid )
			if t then -- if online
				print( "online" )
				local msg = {}
				msg.type = msgtype.OTHER
				tmp = skynet.call( t.addr , "lua" , "friend" , "agent_request_handle" , msg )
				assert( tmp )
			else
				print( "not online" )
   				local r = friendmgr:_db_loadfriend( v.friendid )
   				assert( r )
   				tmp = r[1]
   			end
   			tmp.receive = receive
   			print( v.recvtime , v.sendtime , settime )
   			
   				if os.time() >= settime then
   					tmp.heartamount = ( v.recvtime > settime ) and v.heartamount or 0
   				else
   					tmp.heartamount = ( v.recvtime < lowtime ) and 0 or v.heartamount
   				end

   			if nil == v.sendtime or 0 == v.sendtime or ( v.sendtime < settime and os.time() > settime ) then
   				tmp.heart = true
   			else                                                                                                                                                                                                                                                            
   				tmp.heart = false
   			end
   			tmp.signtime = v.sendtime -- '0' represents that i never sent heart to others
   	 		local f = friendmgr:_createfriend( tmp )
   			assert( f )

			table.insert( fl , f )

   			print( "build a friend successfully" )
   			
   		end	
   		return fl
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

			skynet.call( r.addr , "lua" , "command" , "sendonlinenotice" , t )
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
			print( v.fromid )
			local r = friendmgr:_db_loadfriend( v.fromid )
			assert( r[1] )
    		local tmp = r[1]
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
   			print( v )
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
    		
    		if not f.index then
				f.index = uid
				counter = counter + 1
				if counter > MAXFRIENDNUM then
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
	
	for  k , v in pairs( a ) do
		print( k , v )
		local f = friendmgr:_db_loadfriend( v )
		assert( f )
		local n = friendmgr:_createfriend( f[1] )
		assert( n )
        	
		table.insert( avaliblefriends , n )
	end 	
			
	return avaliblefriends
end			
		 	
function friendmgr:applyfriend( friendlist )
	assert( friendlist )
    		
	for k , v in pairs( friendlist ) do
		local isfind = false
		if v.friendid == user.id then
			print( "can not apply youself" )

			local ret = {}
			ret.ok = false
			ret.error = 1
			ret.msg = "can not apply yourself"
        	
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
		end	
	end		
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
		local r = friendmgr:_db_loadfriend( v.friendid )
   		assert( r )
   	 	table.insert( friendmgr._data.friendlist , { friendid = v.friendid , recvtime = 0  , heartamount = 0 , sendtime = 0 } )
   		
   		friendmgr:_db_insert_newfriend( user.id , v.friendid )

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
			print( v.friendid , user.id )
			friendmgr:_db_insert_newfriend( v.friendid , user.id )
			friendmgr:_db_insertmsg( nm )
			local t = {}
			t.tname = "u_friendmsg"
			t.content = { isread = 1 }
			t.condition = { fromid = v.friendid , toid = user.id , type = msgtype.ACCEPT , signtime = v.signtime }
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
			t.condition = { fromid = v.friendid , toid = user.id , type = msgtype.REFUSE , signtime = v.signtime }
			friendmgr:_db_updatemsg( t )

			print( "insert a new msg to db and update a msg" )
		end 
	end				
end			
		
function friendmgr:deletefriend( friendid )
	assert( friendid )

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
	t.condition = { uid = user.id , friendid = friendid }

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
		t.condition = { uid = friendid , friendid = user.id }
		friendmgr:_db_updatefriend( t ) -- 

		print( "insert a new msg to db and update a msg" )
	end	

	return true
end			
	
function friendmgr:findfriend( id )
	assert( id )
	local ret = {}

	local r = friendmgr:_db_loadfriend( id )
	if nil == r[1] then
		ret.ok = false
		ret.error = 1
		ret.msg = "no such user"
		
		return ret 
	else
		if id == user.id then
			ret.ok = false
			ret.error = 2
			ret.msg = "can not add yourself"
			
			return ret 
		end	

		for k , v in pairs( friendmgr._data.friendlist ) do
			if v.friendid == id then
				ret.ok = false
				ret.error = 3
				ret.msg = "already friend"

				return ret
			end
		end

		for k , v in pairs( friendmgr._data.appliedlist ) do
			if v.fromid == id then
				ret.ok = false
				ret.error = 4
				ret.msg = "in the appliedlist "

				return ret
			end
		end
	end	

	local f = friendmgr:_createfriend( r[ 1 ] )
	assert( f )
	ret.ok = true
	ret.friend = {}
	table.insert( ret.friend , f )
	return ret
end			
		
function friendmgr:recvheart( heartlist , totalamount )
	assert( heartlist )
	if recvheartnum + totalamount > MAXHEARTNUM then
		local ret = {}
		ret.ok = false
		ret.msg = "too much heart"
		return ret
	end		

	local prop = user.u_propmgr:get_by_csv_id( 3 )
	
	--print( "total num is " .. total.num )
	for k , v in pairs( heartlist ) do
			recvheartnum = recvheartnum + v.amount
			prop.num = prop.num + v.amount

			local t = v
			t.toid = v.friendid
			t.type = msgtype.ACCEPTHEART
			t.signtime = v.signtime

			local nm = friendmgr:_createmsg( t ) 
			assert( nm )
        	
			local r = dc.get( v.friendid )
         	
			if r then -- if online notice the friend 
				skynet.send( r.addr , "lua" , "friend", "agent_request_handle" , nm )
				print( "notify an agent " , v.friendid ) 
			else 
				friendmgr:_db_insertmsg( nm ) -- insert a msg to friendmsg 
				--friendmgr:_db_updaterecv( user.id , v.friendid , )
				--friendmgr:_db_delete_friend( v.friendid , user.id ) -- 
				local t = {}
				t.tname = "u_friendmsg"
				t.content = { isread = 1 }
				t.condition = { fromid = v.friendid , toid = user.id , type = msgtype.SENDTHEART , srecvtime = v.signtime }
				friendmgr:_db_updatemsg( t )	
				print( "insert a new msg to db and update a msg" )
			end	
	end		

	prop:__update_db( {"num"} )

end			
		
function friendmgr:sendheart( heartlist , totalamount ) 
	assert( heartlist )
	print(	"heartamount = " .. totalamount )
	local prop = user.u_propmgr:get_by_csv_id( 3 )
	--assert( total )
	--print( "total num is " .. total.num )
	if nil == prop or prop.num - totalamount < 0 then -- not enough heart then return error
		local ret = {}
		ret.ok = false
		ret.msg = "not enough heart"

		return ret
	end  

	for k , v in pairs( heartlist ) do
		prop.num = prop.num - v.amount

		local t = v
		t.toid = v.friendid
		t.type = msgtype.SENDHEART
		t.signtime = v.signtime

		local nm = friendmgr:_createmsg( t ) 
		assert( nm )
        	
		for sk , sv in ipairs( friendmgr._data.friendlist ) do
			if sv.friendid == v.friendid then
				sv.sendtime = nm.srecvtime
				break
			end
		end

		local r = dc.get( v.friendid )
        
        local t = {}
		t.tname = "u_friend"
		t.content = { sendtime = nm.srecvtime }
		t.condition = { uid = user.id , friendid = v.friendid }
		friendmgr:_db_updatefriend( t ) 
		
		if r then -- if online notice the friend 
			skynet.send( r.addr , "lua" , "friend", "agent_request_handle" , nm )
			print( "notify an agent " , v.friendid ) 
		else 
			friendmgr:_db_insertmsg( nm ) -- insert a msg to friendmsg 	
			t = {}
			t.tname = "u_friend"
			t.content = { heartamount = v.amount , recvtime = nm.srecvtime }
			t.condition = { uid = v.friendid , friendid = user.id }
			friendmgr:_db_updatefriend( t )
			print( "insert a new msg to db and update a msg" )
		end	
	end	
	prop:__update_db( {"num"} )

end		
			
function friendmgr:agent_request_handle( msg )
	assert( msg )
			
	local ret = {}
	--local ret.friendmsg = {}
	if msg.type == msgtype.APPLY then
		friendmgr:_db_insertmsg( msg )
		table.insert( friendmgr._data.appliedlist , { fromid = msg.fromid , srecvtime = msg.signtime } )

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
		t.condition = { uid = user.id , friendid = msg.fromid }
		friendmgr:_db_updatefriend( t )
		--TODO
	elseif msg.type == msgtype.ACCEPT then
		friendmgr:_db_insertmsg( msg )
		friendmgr:_db_insert_newfriend( user.id , msg.fromid )
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
		t.condition = { fromid = user.id , toid = msg.fromid , type = msgtype.APPLY , srecvtime = msg.signtime }
		friendmgr:_db_updatemsg( t )
		
		--local ret = {}
		--ret.type = msgtype.ACCEPT
		--ret.ok = true

		--return ret	
	elseif msg.type == msgtype.REFUSE then 
		friendmgr:_db_insertmsg( msg )

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
		t.condition = { fromid = user.id , toid = msg.fromid , type = msgtype.APPLY , srecvtime = msg.signtime }
		friendmgr:_db_insertmsg( msg )
		friendmgr:_db_updatemsg( t )
		--TODO maybe should send some msg to client for redpoint
	elseif msg.type == msgtype.SENDHEART then
		
		friendmgr:_db_insertmsg( msg )

		for k , v in ipairs( friendmgr._data.friendlist ) do
			if v.friendid == msg.fromid then
				v.recvtime = msg.signtime
				v.heartamount = msg.amount
				break
			end
		end

		local t = {}
		t.tname = "u_friend"
		t.content = { heartamount = msg.amount , recvtime = msg.srecvtime }
		t.condition = { uid = user.id , friendid = msg.friendid }
		friendmgr:_db_updatefriend( t )

	elseif msg.type == msgtype.ACCEPTHEART then

		local t = {}
		t.tname = "u_friendmsg"
		t.content = { isread = 1 }
		t.condition = { fromid = user.id , toid = msg.friendid , type = msgtype.SENDHEART , srecvtime = msg.signtime }
		friendmgr:_db_insertmsg( msg )
		friendmgr:_db_updatemsg( t )
	else
		print( "get online user msg !!!!!!!!!!!!!!!!!!" )
		local r = {}
		
		r.id = user.id
		r.name = user.uname
		r.level = user.level
		r.viplevel = user.uviplevel
		r.iconid = user.iconid
		r.sign = user.sign
		r.combat = user.combat
		r.online_time = os.date( "%Y%m%d%H%M%S" , user.onlinetime) --user.onlinetime
		r.ifonline = true

		return r
		--r.heartamount = user.heartamount or 0
		--r.heart = user.heart or false
		--r.apply = true
		--r.receive = user.receive or false
		--TODO
	end	
end 		
		
return friendmgr
		
