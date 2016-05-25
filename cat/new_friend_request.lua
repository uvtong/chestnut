package.path = "./../cat/?.lua;" .. package.path
	 				
local friendrequest = {}
local user 			
local dc 				
local friendmgr 	
local sendpackage 	
local sendrequest 	
local errorcode = require "errorcode"
	  
	 
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
			
		