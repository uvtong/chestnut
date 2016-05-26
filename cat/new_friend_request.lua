package.path = "./../cat/?.lua;" .. package.path

local friendrequest = {}
local user 			
local dc 				
local friendmgr 	
local sendpackage 	
local sendrequest 	
local errorcode = require "errorcode"
local query = require "query"
local dc = require "datacenter"
	 
local recommand_idlist = {}
local apply_idlist = {}	 

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
	
local msgtype = {APPLY = 1 , SENDHEART = 2}	
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
	r.ifonline = tfriend.ifonline --( tfriend.ifonline == 0 ) and false or true
	r.heartamount = tfriend.heartamount or 0 -- the heart num that sended by another user
	r.heart = tfriend.heart
	r.apply = true
	r.receive = tfriend.receive
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
		


function REQUEST:friendlist(ctx)
	assert(ctx)

	local ret = {}
	local date = os.time()

	local if_can_recv_heart = 0
	if (ctx:get_user().get_daily_recv_heart()) - MAXHEARTNUM > 0 then
		if_can_recv_heart = 1
	else
		if_can_recv_heart = 0
	end 

	for k, v in pairs(ctx:get_modelmgr():get_u_new_friendmgr()._data) do
		local tmp 
		local t = dc.get(v.friendid )
				
		--if online
		if t then
			print("friend is online****************************")
			tmp = skynet.call(t.addr, "lua", "friend", "agent_friendmsg")
			assert(tmp)
		else 	
			print("not online***********************************")
			local sql = local sql = string.format( "select csv_id , uname , uviplevel , level , sign , ifonline, onlinetime , iconid from users where csv_id = %d" , v.friendid)
			local r = query.read(sql)
			assert(nil == r.errno and r[1])
			tmp = r[1]
			tmp[1].combat = util.get_total_property(nil , v.friendid) --zong zhan li
		end 				
							
		if date > v.updatetime then
			v:set_heartamount(0)
			v:set_updatetime(getsettime())
			v:update_db()
			--v:set()
			ctx:get_user():set_daily_recv_heart(0)
			ctx:get_user():set_if_send_heart(0)
			--ctx:get_user():set_field("if_send_heart", 0)
			tmp.heartamount = 0
		else  	
			if 1 == ifrecved then
				tmp.heartamount = 0
			else
				tmp.heartamount = v:get_heartamount()
				tmp.heart = 1
			end   
		end 	
		
		local f = friendmgr:_createfriend(tmp)
   		assert(f)

		table.insert(ret, f)
	end 

	ret.today_left_heart = MAXHEARTNUM - ctx:get_user():get_daily_recv_heart()
	ret.errorcode = errorcode[1].code
	ret.heart = ctx:get_user():get_if_send_heart()
	ret.receive = if_can_recv_heart

	return ret
end 		
		 	
-- function friendmgr:apply_friendlist()
-- 	recvheartnum = gettodayheart()
-- 	print( "recvheartnum is " .. recvheartnum )
-- 	local receive 
-- 	if recvheartnum < MAXHEARTNUM  then
-- 		receive = true
-- 	else 	
-- 		receive = false
-- 	end	 	
		    
--     local fl = {}  
--     print( "friend mgr date is " .. #friendmgr._data.friendlist )
-- 	if 0 == #friendmgr._data.friendlist then
-- 		print( "no friendmgr._data.friendlist in friendmgr._data.friendlist" )
-- 		return nil , MAXHEARTNUM - recvheartnum
-- 	else 	
-- 		local settime = getsettime()
-- 		local lowtime = settime - 60 * 60 * 24
         	
-- 		for k , v in pairs( friendmgr._data.friendlist ) do
-- 			local tmp 
-- 			--print( k , v.friendid , v.recvtime , v.sendtime )

-- 			local t = dc.get( v.friendid )
-- 			if t then -- if online
-- 				print( "online" )
-- 				tmp = skynet.call( t.addr , "lua" , "friend" , "agent_friendmsg")
-- 				assert( tmp )
-- 			else
-- 				print( "not online" )
--    				local r = friendmgr:_db_loadfriend( v.friendid )
--    				assert( r )
--    				tmp = r[1]
--    				local t = util.get_total_property( nil , tmp.csv_id )
--    				assert( t )
--    				tmp.combat = t[ 1 ]
--    			end

--    			tmp.receive = receive
--    			--print( v.recvtime , v.sendtime , settime , v.heartamount)
   			
--    				if os.time() >= settime then
--    					tmp.heartamount = ( v.recvtime > settime ) and v.heartamount or 0
--    					print("bigger than heart amolunt is " .. tmp.heartamount)
--    				else
--    					tmp.heartamount = ( v.recvtime < lowtime ) and 0 or v.heartamount
--    					print("smaller then heart amolunt is " .. tmp.heartamount)
--    				end

--    			if nil == v.sendtime or 0 == v.sendtime or ( v.sendtime < settime and os.time() > settime ) then
--    				tmp.heart = true
--    			else                                                                                                                                                                                                                                                            
--    				tmp.heart = false
--    			end
--    			tmp.signtime = v.recvtime -- '0' represents that i never sent heart to others , and used for sendheart and recvheart
--    			print( "tmp.signtime is **************************" , tmp.signtime )
--    	 		local f = friendmgr:_createfriend( tmp )
--    			assert( f )

-- 			table.insert( fl , f )

--    			print( "build a friend successfully" )

--    		end	
--    		print( MAXHEARTNUM ,  MAXHEARTNUM - recvheartnum , recvheartnum )
--    		return fl , ( MAXHEARTNUM - recvheartnum ) -- today_heart is the heart amount user gets today
--    	end		
-- end 	
local function get_friend_basic_info(uid)
	assert(uid)

	local tmp 

	local t = dc.get( uid )
	if t then -- if online
		print( "online" )
		tmp = skynet.call( t.addr , "lua" , "friend" , "agent_friendmsg")
		assert( tmp )
	else
		print( "not online" )
		local sql = local sql = string.format( "select csv_id , uname , uviplevel , level , sign , ifonline, onlinetime , iconid from users where csv_id = %d" , uid)
		local r = query.read(sql)
		assert(nil == r.errno and r[1])
		
		tmp = r[1]
		local t = util.get_total_property( nil , uid )
		assert( t )
		tmp.combat = t[ 1 ]
	end
	assert(tmp)
	
	return tmp
end		

function REQUEST:applied_list(ctx)
	assert(ctx)

	local ret = {}
	local uid = ctx:get_user():get_csv_id()
	for k, v in pairs(ctx:get_modelmgr():get_u_new_friendmsgmgr()._data) do
		if v:get_toid() == uid and v:get_type() == msgtype.APPLY then
			local tmp = get_friend_basic_info(v:get_fromid())
			tabel.insert(ret, friendmgr:_createfriend(tmp))
		end
	end	

	ret.errorcode = errorcode[1].code
	return ret
end 		
		

-- function friendmgr:apply_appliedlist()
-- 	local appliedlist = {}
-- 	if 0 == #friendmgr._data.appliedlist then
-- 		print( "applied is null" )
-- 		return nil
-- 	else
-- 		print( "not nil" , #friendmgr._data.appliedlist )
-- 		for k , v in pairs( friendmgr._data.appliedlist ) do
-- 			--print( v.fromid )
-- 			local tmp
-- 			local t = dc.get( v.fromid )
-- 			if t then -- if online
-- 				print( "online" )
-- 				tmp = skynet.call( t.addr , "lua" , "friend" , "agent_friendmsg")
-- 				assert( tmp )
-- 			else
-- 				print( "not online" )
--    				local r = friendmgr:_db_loadfriend( v.fromid )
--    				assert( r )
--    				tmp = r[1]
--    				local t = util.get_total_property( nil , tmp.csv_id )
--    				assert( t )
--    				tmp.combat = t[ 1 ]
--    			end
	
--     		tmp.signtime = v.srecvtime
--     		print( "v.srecvtime is " .. v.srecvtime )
-- 			local n = friendmgr:_createfriend( tmp )
-- 			assert( n )
    
-- 			table.insert( appliedlist , n ) 
-- 		end
-- 		return appliedlist
-- 	end 
-- end	 	
			
function REQUEST:otherfriend_list(ctx)
	assert(ctx)

	local ret = {}
end 	
				
local function init_apply_idlist(ctx)
	assert(ctx)
	print("in init_apply_idlist*****************************************")

	for k, v in pairs(ctx:get_modelmgr():get_u_new_friendmsgmgr()._data) do
		if v.fromid == ctx:get_user():get_csv_id() then
			apply_idlist[tostring(v.toid)] = v.toid
		end	
	end
end 
	
function new_friend_request:loadfriend(uid, lowlevel, uplevel)
	assert(uid and lowlevel and uplevel)

	local i = 1     
	local step = 20 
	local lastday = os.time() - 24 * 60 * 60
	local ok = false
	local tmp_recommand_idlist
	-- select friend on different condition
	while i <= 3 do
		local sql = string.format("call qy_select_friend_msg(%d, %d, %d, %d)", uid, lowlevel, uplevel, lastday)
		print( sql )

		tmp_recommand_idlist = query.read(sql)        --two tables return, first holds value, second hold return info
		assert(recommand_idlist.errno == nil) 

		if #tmp_recommand_idlist[1] < 10 then    
			tmp_recommand_idlist = {}
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
		lastday = 0

		while i <= 3 do
			local sql = string.format("call qy_select_friend_msg(%d, %d, %d, %d)", uid, lowlevel, uplevel, lastday)
			print( sql )

			tmp_recommand_idlist = query.read(sql)        --two tables return, first holds value, second hold return info
			assert(tmp_recommand_idlist.errno == nil)

			if #tmp_recommand_idlist[1] < 10 then
				tmp_recommand_idlist = {}
				step = step + 10
			else 
				break
			end
			
			i = i + 1
		end 
	end     

	assert(tmp_recommand_idlist[1])

	if #tmp_recommand_idlist[1] < MAXFRIENDNUM then
	   	print( "avalible friends num < 10" )
	end		
    print("________________________load friend over")

    recommand_idlist = tmp_recommand_idlist[1]
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
   	--filter id in friendlist and appliedlist
   	for k , v in pairs( friendmgr._data.avaliblelist ) do
   		if false == findexist(friendmgr._data.friendlist,  v) and false == findexist(friendmgr._data.appliedlist, v) then
   		--	print( v )
   			table.insert(tmp, v.csv_id)
		end 
   	end		
   			
   	if not tmp then
   		--TODO lower the fileter condition
   		return nil	
   	end		

   	recommand_idlist = tmp

   	local f = {}
   	if #recommand_idlist < MAXFRIENDNUM then
   		print("avalible friends is less than 10")
   		return recommand_idlist
   	else	
   		while true do
	    	index = math.floor(math.random(1 , #friendmgr._data.avaliblelist))
	    	local uid = friendmgr._data.avaliblelist[index]
    		if not f[index] then
				table.insert(f, uid)
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

function REQUEST:applyfriend(ctx)
	assert(ctx)
end

function REQUEST:recvfriend(ctx)
	assert(ctx)
end

function REQUEST:recvheart(ctx)
	assert(ctx)
end

function REQUEST:sendheart(ctx)
	print( "sendheart is called in request ^^^^^^^^^^^^^^^^^^^" )
	--print( self.hl.totalamount )
	local ret = friendmgr:sendheart( self.hl , self.totalamount )
	return ret
end	
	
function REQUEST:findfriend(ctx)
	print( "findfriend is called ^^^^^^^^^^^^^^^^^^^" )
	local ret = friendmgr:findfriend( self.id )
	return ret
end		
		
function REQUEST:deletefriend(ctx)
	print( "delete friend is called ^^^^^^^^^^^^^^^^^^^" )

	local ret = friendmgr:deletefriend( self.friendid )
	return ret
end		
		
function REQUEST:refusefriend(ctx)
	print( "refuse friend is called ^^^^^^^^^^^^^^^^^^^" )

	friendmgr:refusefriend( self.friendlist )
end		
		
--[[function friendrequest:sendonlinenotice( t )
	local ret = {}
		
	ret.onlinetime = t.onlinetime
	ret.ifonline = t.ifonline
	ret.uid = t.uid
		
	return ret
end		
--]] -- maybe used in the future
		
function REQUEST:agent_request_handle( msg )
	assert( msg )
	print( "agemt_request is called ^^^^^^^^^^^^^^^^^^^" )
	friendmgr:agent_request_handle( msg )
	--assert( ret )
	--[[if ret then
		print( "ret is called" )
		if msg.type <= 6 then
    		sendpackage( sendrequest( "response_apply" , ret ) )
    	else
    		print( "ret is returned" )
    		for k , v in pairs( ret ) do
    			print( k , v )
    		end
    		-- return ret
    	end
    else
   		print( "response apply successfully" )
    	return nil
    end	--]]
    print( "response apply successfully" )
end	
	


function REQUEST:agent_friendmsg()
	print( "agent_friendmsg is called" )
	
	return friendmgr:agent_friendmsg()	
end 


function friendrequest:friend_list(ctx)
	print( "friedlist is called ^^^^^^^^^^^^^^^^^^^")
	local list, heartamount = friendmgr:apply_friendlist()
	local ret = {} 	
	ret.friendlist = list
	--[[if list then
		for k , v in pairs( list ) do
			table.insert( ret.friendlist , v )
		end 		
	end--]] 		
	ret.errorcode = errorcode[ 1 ].code
	ret.msg = errorcode[ 1 ].msg
	print("send friendlist " , heartamount )
	ret.today_left_heart = heartamount
	return ret 		
end					
					
function friendrequest:applied_list(ctx)
	print( "applied_list is called ^^^^^^^^^^^^^^^^^^^" )
					
	local list = friendmgr:apply_appliedlist()
	local ret = {}	
	ret.friendlist = list
	--[[if list then
		for k , v in pairs( list ) do
			table.insert( ret.friendlist , v )
		end 		
	end--]] 		
	ret.errorcode = errorcode[ 1 ].code
	ret.msg = errorcode[ 1 ].msg

	return ret
end		
		
function friendrequest:otherfriend_list(ctx)
	print("other is called^^^^^^^^^^^^^^^^^^^")
		
	local list = friendmgr:apply_otherfriendlist()
	local ret = {}
	ret.friendlist = list
	--[[if list then
		for k , v in pairs( list ) do
			table.insert( ret.friendlist , v )
		end
	end--]]
	ret.errorcode = errorcode[ 1 ].code
	ret.msg = errorcode[ 1 ].msg
	return ret
end 	
		
function friendrequest:applyfriend(ctx)
	assert( self.friendlist )
	print( "applyfriend is called^^^^^^^^^^^^^^^^^^^")
		
	friendmgr:applyfriend( self.friendlist )	
end		
		
function friendrequest:recvfriend(ctx)
	print( "recvfriend is called^^^^^^^^^^^^^^^^^^^" )

	friendmgr:recvfriend( self.friendlist )
end		
		
function friendrequest:recvheart(ctx)
	print( "recvheart is called in request^^^^^^^^^^^^^^^^^^^" )

	local ret = friendmgr:recvheart( self.hl , self.totalamount )
	return ret
end		
		
function friendrequest:sendheart(ctx)
	print( "sendheart is called in request ^^^^^^^^^^^^^^^^^^^" )
	--print( self.hl.totalamount )
	local ret = friendmgr:sendheart( self.hl , self.totalamount )
	return ret
end	
	
function friendrequest:findfriend(ctx)
	print( "findfriend is called ^^^^^^^^^^^^^^^^^^^" )
	local ret = friendmgr:findfriend( self.id )
	return ret
end		
		
function friendrequest:deletefriend(ctx)
	print( "delete friend is called ^^^^^^^^^^^^^^^^^^^" )

	local ret = friendmgr:deletefriend( self.friendid )
	return ret
end		
		
function friendrequest:refusefriend(ctx)
	print( "refuse friend is called ^^^^^^^^^^^^^^^^^^^" )

	friendmgr:refusefriend( self.friendlist )
end		
		
--[[function friendrequest:sendonlinenotice( t )
	local ret = {}
		
	ret.onlinetime = t.onlinetime
	ret.ifonline = t.ifonline
	ret.uid = t.uid
		
	return ret
end		
--]] -- maybe used in the future
		
function friendrequest:agent_request_handle( msg )
	assert( msg )
	print( "agemt_request is called ^^^^^^^^^^^^^^^^^^^" )
	friendmgr:agent_request_handle( msg )
	--assert( ret )
	--[[if ret then
		print( "ret is called" )
		if msg.type <= 6 then
    		sendpackage( sendrequest( "response_apply" , ret ) )
    	else
    		print( "ret is returned" )
    		for k , v in pairs( ret ) do
    			print( k , v )
    		end
    		-- return ret
    	end
    else
   		print( "response apply successfully" )
    	return nil
    end	--]]
    print( "response apply successfully" )
end	
	
function friendrequest:agent_friendmsg()
	print( "agent_friendmsg is called" )
	
	return friendmgr:agent_friendmsg()	
end 
	

	
return friendrequest
			
		