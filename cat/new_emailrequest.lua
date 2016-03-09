local new_emailrequest = {}
local util = require "util"
local const = require "const"

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

function REQUEST:login(u)
	-- body
	assert( u )
	user = u
	for k,v in pairs(u.u_emailmgr.__data) do
		print(k,v)
	end
	emailmgr = user.u_emailmgr
end

function REQUEST:mails()
	local ret = {}
		
	ret.mail_list = {}

	local emailbox = emailmgr:get_all_emails()
	assert( emailbox )
	local counter = 0
	print( "emailbox num is *************************" , #emailbox )
	for i , v in pairs( emailbox ) do
		print( k , v )
		counter = counter + 1
		local tmp = {}
		tmp.attachs = {}

		tmp.emailid = v.csv_id
		tmp.type = v.type
		tmp.acctime = os.date( "%Y-%m-%d" , v.acctime )
		tmp.isread = ( v.isread == 0 ) and true or false 
		tmp.isreward = ( v.isreward == 0 ) and true or false 
		tmp.title = v.title
		tmp.content = v.content
		tmp.attachs = v:__getallitem()
		tmp.iconid = v.iconid

		table.insert( ret.mail_list , tmp )
	end 
 	
	print( "mails is called already" , counter )

	return ret
end      
		
function REQUEST:mail_read()
	print( "****************************email_read is called" )

	local emailbox = emailmgr:get_all_emails()
	assert( emailbox )

	for k , v in pairs( self.mail_id ) do
		print ( k , v , v.id )
		local e = emailmgr:get_by_csv_id( v.id )
		assert( e )

		e.isread = 1
		e:__update_db( { "isread" } )
	end 
end		
		
function REQUEST:mail_delete()
	print( "****************************email_delete is called" )

	local emailbox = emailmgr:get_all_emails()
	assert( emailbox )

	for k , v in pairs( self.mail_id ) do
		print ( k , v , v.id )
		local e = emailmgr:get_by_csv_id( v.id )
		assert( e )
		
		e.isdel = 1
		e:__update_db( { "isdel" } )
		emailmgr:delete_by_id( v.id )
	end 
end 
	
function REQUEST:mail_getreward()
	print( "****************************get_reward is called" )

	local emailbox = emailmgr:get_all_emails()
	assert( emailbox )

	for k , v in pairs( self.mail_id ) do		
		local e = emailmgr:get_by_csv_id( v.id )
		assert( e )
		if 0 == e.isreward then 	
			local items = e:__getallitem()
			assert( items )
			for k , v in ipairs( items ) do
				local prop = user.u_propmgr:get_by_csv_id( v.itemsn )
				if prop then
					prop.num = prop.num + v.itemnum
					prop:__update_db( { "num" } )
				else
					local p = game.g_propmgr:get_by_csv_id( v.itemsn )
					p.user_id = user.csv_id
					p.num = v.itemnum 
					local prop = user.u_propmgr.create( p )
					user.u_propmgr:add( prop )
					prop:__insert_db()
				end
			end

			if ( 1 == e.type ) then
				e.isdel = 1
				e:__update_db( { "isdel" } )
				emailmgr:delete_by_csv_id( e.csv_id )
			else
				e.isreward = 1
				e:__update_db( { "isreward" } )
			end
		end
	end 
end 
	
function new_emailrequest:newemail( tval , ... ) -- get a email to group
	assert( tval )
	print( "*********************************************REQUEST:newemail" )

	local v = emailmgr:recvemail( tval )
	assert( v )

	--[[local ret = {}
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
	send_package( send_request( "newemail" ,  ret ) )--]]
end 
		
function SUBSCRIBE:email( tvals , ... ) -- get email from channl , a email to all users 
	assert( tvals )
	print( " ***********************************SUBSCRIBE:email " )
	tvals.csv_id = util.u_guid( user.csv_id, game, const.UEMAILENTROPY )
	tvals.uid = user.csv_id
	print( "*********************************email csv_id is " , tvals.csv_id )
	local v = emailmgr:recvemail( tvals )
	assert( v )

	--[[local ret = {}
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
	tmp.attachs = v:__getallitem()
	tmp.iconid = v.iconid
	ret.mail = tmp
	send_package( send_request( "newemail" ,  ret ) )--]]
end

function RESPONSE:abd()
	-- body
end



function new_emailrequest.start(c, s, g, d, ...)
	-- body
	client_fd = c
	send_request = s
	game = g
	dc = d
end

function new_emailrequest.disconnect()
	-- body
end

new_emailrequest.REQUEST = REQUEST
new_emailrequest.RESPONSE = RESPONSE
new_emailrequest.SUBSCRIBE = SUBSCRIBE

return new_emailrequest
