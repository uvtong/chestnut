local emailrequest = {}
local util = require "util"

local send_package
local send_request

local REQUEST = {}
local RESPONSE = {}
local SUBSCRIBE = {}

local client_fd

local dc

local game
local user
local emailmgr

local MAXEMAILNUM = 50

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end

function REQUEST:login(user)
	-- body
	assert( user )
	user = user
	emailmgr = user.u_emailmgr
end

function REQUEST:mails()
	local ret = {}
	ret.mail_list = {}

	local emailbox = emailmgr:get_all_emails()
	assert( emailbox )

	for i , v in ipairs( emailbox ) do
		local tmp = {}
		tmp.attachs = {}

		tmp.emailid = v.csv_id
		tmp.type = v.type
		tmp.acctime = os.date( "%Y-%m-%d" , v.acctime )
		tmp.isread = ( v.isread == 1 ) and true or false 
		tmp.isreward = ( v.isreward == 1 ) and true or false 
		tmp.title = v.title
		tmp.content = v.content
		tmp.attachs = v:getallitem()
		tmp.iconid = v.iconid

		table.insert( ret.email_list , tmp )
	end

	print( "mails is called already" )

	return ret
end

function REQUEST:mail_read()
	print( "****************************email_read is called" )

	local emailbox = emailmgr:get_all_emails()
	assert( emailbox )

	for k , v in pairs( self.id_list ) do
		print ( k , v , v.id )
		local e = emailmgr:get_by_id( v.id )
		assert( e )

		e.isread = 1
		e:__update( { "isread" } )
	end
end

function REQUEST:mail_delete()
	print( "****************************email_delete is called" )

	local emailbox = emailmgr:get_all_emails()
	assert( emailbox )

	for k , v in pairs( self.id_list ) do
		print ( k , v , v.id )
		local e = emailmgr:get_by_id( v.id )
		assert( e )

		e.isdel = 1
		e:__update( { "isdel" } )
		emailmgr:delete_by_id( v.id )
	end 
end

function REQUESST:email_getreward()
	print( "****************************get_reward is called" )

	local emailbox = emailmgr:get_all_emails()
	assert( emailbox )

	for k , v in pairs( self.id_list ) do
		print ( k , v , v.id )
		local e = emailmgr:get_by_id( v.id )
		assert( e )

		e.isreward = 1
		e:__update( { "isreward" } )
	end 
end

function REQUEST:mail_newemail()

end

function SUBSCRIBE:email( tvals , ... )
	assert( tvals )
	print( " ***********************************SUBSCRIBE:email " )
	tvals.csv_id = util.u_guid( user.id, game, const.UEMAILENTROPY )
	tvals.uid = user.id
	print( "*********************************email csv_id is " , tvals.csv_id )
	local v = emailmgr:recvemail( tvals )
	assert( v )

	local ret = {}
	ret.mail = {}
	local tmp = {}
   	tmp.attachs = {}

    tmp.emailid = v.csv_id
    tmp.type = v.type
    tmp.acctime = os.date("%Y-%m-%d" , v.acctime)
    tmp.isread = v.isread
    tmp.isreward = v.isreward
    tmp.title = v.title
    tmp.content = v.content
	tmp.attachs = v:getallitem()
	tmp.iconid = v.iconid
	ret.mail = tmp
	send_package( send_request( "newemail" ,  ret ) )
end

function RESPONSE:()
	-- body
end



function emailrequest.start(conf, send_request, game, dc, ...)
	-- body
	client_fd = conf.client
	send_request = send_request
	game = game
	dc = dc
end

function emailrequest.disconnect()
	-- body
end

emailrequest.REQUEST = REQUEST
emailrequest.RESPONSE = RESPONSE
emailrequest.SUBSCRIBE = SUBSCRIBE

return emailrequest
