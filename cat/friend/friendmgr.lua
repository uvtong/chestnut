package.path = "package.path = "./../../cat/?.lua;" .. package.path"
	
local skynet = require "skynet"
require "skynetmanager"
	
local friendmgr = {}
friendmgr._data = { friendlist = {} , applylist = {} , appliedlist = {} , avaliblelist = {} }
	
local MAXHEARTNUM
local MAXFRIENDNUM
local recvheartnum	
local user
	
local friendmgr._data.friendlist = {}
local friendmgr._data.appliedlist = {}
local friendmgr._data.avaliblelist = {}
local friendmgr._data.applylist = {}
local dc 
	
local friend = { id, apply , name , level , viplevel , iconid , sign , fightpower , isonline , online_time , heart , apply , receive }
function friend:_new( ... )
	local t = {}

	setmetatable( t , { __index = friend } )

	return t
end	
	
local msgtype = { APPLY = 1 , DELETE = 2 , ACCEPT = 3 , REFUSE = 4 , SENDHEART = 5 , ACCEPTHEART = 6 }	
local msg = { fromid , toid , type , propid , amount , isreward , csendtime , srecvtime , signtime , isread }
function msg:_new()
	local t = {}
	setmetatable( t , { __index = msg } )

	return t
end	
	
function friendmgr:_createfriend( tfriend )
	assert( tfriendid )
			
	local r = friend:_new()
	assert( r )

	r.id = tfriend.id
	r.name = tfriend.uname
	r.level = tfriend.level
	r.viplevel = tfriend.viplevel
	r.iconid = tfriend.iconid
	r.sign = tfriend.sign
	r.combat = tfriend.combat
	r.online_time = 0 --tfriend.onlinetime
	--r.ifonline = tfriend.ifonline
	r.heart = true
	r.apply = true
	r.accept = true
	--TODO
	return r
end	
    
function friendmgr:_createmsg( tvals )
    assert( tvals )
    
    local nm = msg:_new()
    assert( nm )

    nm.fromid = user.id
    nm.toid = tvals.toid
    nm.type = tvals.type
    nm.propid = tvals.propid or 0
    nm.amount = tvals.amount or 0 
    nm.isreward = isreward or 0
    nm.srecvtime = os.time()
    nm.csendtime = tvals.csendtime or 0
    nm.signtime = tvals.signtime 
    nm.isread = tvals.isread or 0
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

	local addr = randomaddr()
	assert( addr )

	skynet.call( addr , "lua" , "command" , "insert_newmsg" , msg )

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
	
function friendmgr:_db_loadavaliblefriend_idlist( t )
	assert( uid )
	local addr = randomaddr()
	assert( addr )
    
	local result = skynet.call( addr , "lua" , "command" , "select_loadavaliblefriendmgr._data.friendlist" , t )
    	 
	return result
end		
	
function friendmgr:_db_applied_idlist( uid , msgtype )
	assert( t )

	local t = {}
	t.uid = uid
	t.type = msgtype

	local addr = randomaddr()
	assert( addr )

	local r = skynet.call( addr , "lua" , "command" , "select_applied_idlist" , t )
	if r then
		print( "has a result in applylist")
	end

	return r
end	
	
function friendmgr:_db_apply_idlist( uid , msgtype )
	assert( uid and msgtype )

	local t = {}
	t.uid = uid
	t.type = msgtype

	local addr = randomaddr()
	assert( addr )

	skynet.call( addr , "lua" , "command" , "select_apply_idlist" , t )

	print( "load apply_inlist successfully" )
end	
	
function friendmgr:loadfriend( u )
	user= u
    
	friendmgr._data.friendlist = friendmgr:_db_loadfriend_idlist( user.id )
	for i = 1 , #friendmgr._data.friendlist do
		friendmgr._data.friendlist.i = friendmgr._data.friendlist[i].id
	end
	friendmgr._data.avaliblelist = friendmgr:_db_loadavaliblefriend_idlist( user.level )
	for i = 1 , #friendmgr._data.avaliblelist do
		friendmgr._data.avaliblelist.i = friendmgr._data.avaliblelist[i].id
	end
	friendmgr._data.appliedlist = friendmgr:_db_applied_idlist( user.id , msgtype.APPLY )
	for i = 1 , #friendmgr._data.appliedlist do
		friendmgr._data.appliedlist[i] = friendmgr._data.appliedlist[i].toid
	end
	friendmgr._data.applylist = friendmgr:_db_apply_idlist( user.id , msgtype.APPLY )
	for i = 1 , #friendmgr._data.applylist do
		friendmgr._data.applylist[i] = friendmgr._data.applylist[i].fromid
	end
	--TODO get applied list
	print( "load all idlist over" )

	if nil == friendmgr._data.friendlist then
	   	print( "no friend in friendidlist , dbloadfriend\n" )
	end
    
	if #friendmgr._data.avaliblelist < MAXFRIENDNUM then
	   	print( "avalible friends num < 10" )
	end		
    		
   	return friendmgr
end			
			
function friendmgr:apply_friendlist()
	--[[recvheartnum = friendmgr:_db_get_recvheart()
	local receive 
	if recvheartnum < MAXHEARTNUM  then
		receive = true
	else
		receive = false
	end
       --]]
    local fl = {}  
	if not friendmgr._data.friendlist then
		print( "no friendmgr._data.friendlist in friendmgr._data.friendlist" )
		return nil
	else		
		for k , v in pairs( friendmgr._data.friendlist ) do
   			local r = friendmgr:_db_loadfriend( v.friendid )
   			assert( r )

   	 		local f = friendmgr:_create( r[1] )
   			assert( f )

			table.insert( fl , f )

   			print( "build a friend successfully" )
   			return fl
   		end	
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
	if not friendmgr._data.appliedlist then
		return nil
	else
		for k , v in pairs( friendmgr._data.appliedlist ) do
			local r = friendmgr:_db_loadfriend( v.toid )
			assert( r )
    
			local n = friendmgr:_create( r )
			assert( n )
    
			table.insert( appliedlist , n ) 
		end
		return appliedlist
	end
end	
	
local function findexist( idlist , id )
	assert( idlist , id )
    
    for k , v in pairs( idlist )
		if v == id then
			return true
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
   		if not findexist( friendmgr._data.friendlist , v ) and not findexist( friendmgr._data.appliedlist , v ) then
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
		local f = friendmgr:_db_loadfriend( v )
		assert( f )
		local n = friendmgr:_create( f )
		assert( n )
        	
		table.insert( avaliblefriends , n )
	end 	
			
	return avaliblefriends
end			
		 	
function friendmgr:applyfriend( friendlist )
	assert( friendlist )
    
	for k , v in pairs( friendlist ) do
		local isfind = false
		if v.friendid == user.id
			print( "can not apply youself" )

			local ret = {}
			ret.ok = false
			ret.error = 1
			ret.msg = "can not apply yourself"
        	
			return ret
		end	
        	
		for k , v in pairs( friendmgr._data.applylist ) do
			if v == v.friendid
				isfind = true 
				break        
			end
		end			
        	
		if isfind ~= true then
			table.insert( friendmgr._data.applylist , v.id )

			local t = v
			t.toid = v.friendid
			t.type = msgtype.APPLY
			
			local nm = friendmgr:_createmsg( t )
			assert( nm )

			local r = dc.get( v.friendid )

			if r then
				skynet.call( r.addr , "lua" , "REQUEST" , "agent_request_handle" , nm )
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

   	skynet.call( addr , "lua" , "command" , "" , t )

   	print( "insert a new friend successfully" )
end		 	
	     
function friendmgr:_db_updatemsg( t )
	assert( t )
            
	local addr = randomaddr()
	assert( addr )

	skynet.call( addr , "lua" , "command" , "update_msg" , t )
	print( "update a msg successfully" )  
end		 	
		
function friendmgr:acceptfriend( friendlist )
	assert( friendlist )

	for k , v in pairs( friendlist ) do
		local r = friendmgr:_db_loadfriend( v.friendid )
   		assert( r )
   	 	table.insert( friendmgr._data.friendlist , v.friendid )
   		
   		friendmgr:_db_insert_newfriend( user.id , v.friendid )

		local t = v
		t.toid = v.friendid
		t.type = msgtype.ACCEPT
		t.signtime = v.signtime

		local nm = friendmgr:_createmsg( t )
		assert( nm )

		local r = dc.get( v.friendid )

		if r then
			skynet.call( r.addr , "lua" , "REQUEST" , "agent_request_handle" , nm )
			print( "notify an agent " , v.friendid ) 
		else
			friendmgr:_db_insert_newfriend( v.friendid , user.id )
			friendmgr:_db_insertmsg( nm )
			local t = {}
			t.tname = "friendmsg"
			t.content = { isread = 1 }
			t.condition = { fromid = v.friendid , toid = user.id , signtime = v.signtime }
			friendmgr:_db_updatemsg( t )

			print( "insert a new msg to db and update a msg" )
		end 
	end	
end	
 	
function friendmgr:refusefriend( friendlist )
	assert( friendlist )

	for k , v in pairs( friendlist ) do
		local tmp = {}
		for k , v in pairs( friendmgr._data.appliedlist ) do
			if v ~= v.friendid
				table.insert( tmp , v.friendid )
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
			skynet.call( r.addr , "lua" , "REQUEST" , "agent_request_handle" , nm )
			print( "notify an agent " , v.friendid ) 
		else
			friendmgr:_db_insertmsg( nm )
			
			local t = {}
			t.tname = "friendmsg"
			t.content = { isread = 1 }
			t.condition = { fromid = v.friendid , toid = user.id , signtime = v.signtime }
			friendmgr:_db_updatemsg( t )

			print( "insert a new msg to db and update a msg" )
		end 
	end				
end			
		
function friendmgr:_db_delete_friend( uid , friendid )
	assert( uid and friend )

	local addr = randomaddr()
	assert( addr )

	local t = {}
	t.uid = uid
	t.friendid = friendid

	skynet.call( addr , "lua" , "command" , "delete_friend" , t ) 
	print( "delete a friend successfully" )
end		
		
function friendmgr:deletefriend( friendlist )
	assert( friendlist )

	for k , v in pairs( friendlist ) do
		local tmp = {}
		for sk , sv in pairs( friendmgr._data.friendlist ) do
			if sv ~= v.friendid
				table.insert( tmp , v.friendid )
			end
		end

		friendmgr._data.friendlist = tmp -- delete friend data in memory first 
		friendmgr:_db_delete_friend( user.id , v.friendid ) -- delete friend data in db

		local t = v
		t.toid = v.friendid
		t.type = msgtype.DELETE
		t.signtime = v.signtime
       	
		local nm = friendmgr:_createmsg( t ) 
		assert( nm )
        
		local r = dc.get( v.friendid )
         
		if r then -- if online notice the friend 
			skynet.call( r.addr , "lua" , "REQUEST" , "agent_request_handle" , nm )
			print( "notify an agent " , v.friendid ) 
		else 
			friendmgr:_db_insertmsg( nm ) -- insert a msg to friendmsg 
			friendmgr:_db_delete_friend( v.friendid , user.id ) -- 

			print( "insert a new msg to db and update a msg" )
		end
	end				
end			
											   				
function friendmgr:agent_request_handle( msg )
	assert( msg )
		
	local ret = {}
	local ret.friendmsg = {}
	friendmgr:_db_insertmsg( msg )

	if msg.type == msgtype.APPLY then
		friendmgr:_db_insertmsg( msg )
		table.insert( friendmgr._data.appliedlist , msg.fromid )

		--[[local r = friendmgr:_db_loadfriend( msg.fromid )
	
		ret.type = msg.type
		friendmsg.id = msg.fromid
		friendmsg.name = r.uname
		friendmsg.level = r.level
		friendmsg.viplevel = r.uviplevel
		friendmsg.iconid = r.iconid
		friendmsg.sign = r.sign
		friendmsg.ifonline = r.ifonline
		friendmsg.online_time = os.date( "%c" , os.time( r.onlinetime ) )
		friendmsg.signtime = msg.srecvtime
		friendmsg.heart = true
		friendmsg.apply = true
		friendmsg.receive = true
    	
    	return ret--]]

	elseif msg.type == msgtype.DELETE then
		local tmp = {}
		for k , v in pairs( friendmgr._data.friendlist ) do
			if v ~= v.friendid
				table.insert( tmp , v.friendid )
			end
		end

		friendmgr._data.friendlist = tmp
		friendmgr:_db_insertmsg( nm ) -- insert a msg to friendmsg 
		friendmgr:_db_delete_friend( user.id , msg.fromid )

		--TODO 
	elseif msg.type == msgtype.ACCEPT then
		friendmgr:_db_insertmsg( msg )
		friendmgr:_db_insert_newfriend( user.id , msg.fromid )
		table.insert( friendmgr._data.friendlist , msg.fromid )

		local t = {}
		t.tname = "friendmsg"
		t.content = { isread = 1 }
		t.condition = { fromid = user.id , toid = fromid , signtime = v.signtime }
		friendmgr:_db_updatemsg( t )
		
		local ret = {}
		ret.type = msgtype.ACCEPT
		ret.ok = true

		return ret	

	elseif msg.type == msgtype.REFUSE then      
		local tmp = {}
		for k , v in pairs( friendmgr._data.applylist ) do
			if v ~= v.friendid
				table.insert( tmp , v.friendid )
			end
		end
		
		friendmgr._data.applylist = tmp
		
		local t = {}
		t.tname = "friendmsg"
		t.content = { isread = 1 }
		t.condition = { fromid = v.friendid , toid = user.id , signtime = v.signtime }
		friendmgr:_db_insertmsg( msg )
		friendmgr:_db_updatemsg( t )

		--TODO maybe should send some msg to client for redpoint
	elseif msg.type == msgtype.SENDHEART then


	elseif msg.type == msgtype.ACCEPTHEART then

	end		
end 	
    			
return friendmgr