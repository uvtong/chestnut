package.path = "./../cat/?.lua;" .. package.path
	 	
local friendrequest = {}
local user 
local dc 
local friendmgr 	
local sendpackage
local sendrequest
local errorcode = require "errorcode"
	 		  	
function friendrequest:friend_list()
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
	
function friendrequest:applied_list()
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
		
function friendrequest:otherfriend_list()
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
		
function friendrequest:applyfriend()
	assert( self.friendlist )
	print( "applyfriend is called^^^^^^^^^^^^^^^^^^^")
		
	friendmgr:applyfriend( self.friendlist )	
end		
		
function friendrequest:recvfriend()
	print( "recvfriend is called^^^^^^^^^^^^^^^^^^^" )

	friendmgr:recvfriend( self.friendlist )
end		
		
function friendrequest:recvheart()
	print( "recvheart is called in request^^^^^^^^^^^^^^^^^^^" )

	local ret = friendmgr:recvheart( self.hl , self.totalamount )
	return ret
end		
		
function friendrequest:sendheart() 
	print( "sendheart is called in request ^^^^^^^^^^^^^^^^^^^" ) 
	--print( self.hl.totalamount ) 
	local ret = friendmgr:sendheart( self.hl , self.totalamount ) 
	return ret 
end	
	
function friendrequest:findfriend()
	print( "findfriend is called ^^^^^^^^^^^^^^^^^^^" )
	local ret = friendmgr:findfriend( self.id )
	return ret
end		
		
function friendrequest:deletefriend()
	print( "delete friend is called ^^^^^^^^^^^^^^^^^^^" )

	local ret = friendmgr:deletefriend( self.friendid )
	return ret
end		
		
function friendrequest:refusefriend()
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
	
	
function friendrequest.getvalue( u , sendpackage , sendrequest )
	user = u
	
	friendmgr = user.friendmgr
	sendpackage = sendpackage
	sendrequest = sendrequest
	
	assert( user and friendmgr )
end		
	
return friendrequest
			
		