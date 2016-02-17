package.path = "./../cat/?.lua;" .. package.path
local friendrequest = {}
local user 
local dc 
local friendmgr 	
local sendpackage
local sendrequest
		 		  	
function friendrequest:friend_list()
	local list = friendmgr:friend_list()
	local ret = {}

	if not list then
		ret.msg = "no friend list"
	end

	return ret
end	  
	
function friendrequest:applied_list()
end

function friendrequest:otherfriend_list()
end
		  
--[[function friendrequest:apply_friendlist()

end	
	
function friendrequest:send_heart()
	
end	
	
function friendrequest:otherfriendlist()
	 
end 
function friendrequest:recv_heart()
	
end	
	
function friendrequest:applyfriend()
	assert( self.apply_idlist )
	print( "applyfriend is called")

	friendmgr:applyfriend( self.apply_idlist )	
end	
	
	
--[[function friendrequest:sendonlinenotice( t )
	local ret = {}
	
	ret.onlinetime = t.onlinetime
	ret.ifonline = t.ifonline
	ret.uid = t.uid
	
	return ret
end	
--]] -- maybe used in the future

function friendrequest.agent_request_handle( msg )
	assert( msg )
	
	local ret = friendmgr:agent_request_handle( msg )
	assert( ret )

    sendpackage( sendrequest( "response_apply" , ret ) )
   	print( "response apply successfully" )
end	
	--]]
local friendrequest.getvalue( u , sendpackage , sendrequest )
	user = u

	friendmgr = user.friendmgr
	sendpackage = sendpackage
	sendrequest = sendrequest

	assert( user , friendmgr )
end	
	
return friendrequest
		