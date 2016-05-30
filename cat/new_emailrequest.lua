local new_emailrequest = {}
local util = require "util"
local const = require "const"
local socket = require "socket"
local skynet = require "skynet"
local errorcode = require "errorcode"
local send_package
local send_request

local REQUEST = {}
local RESPONSE = {}
local SUBSCRIBE = {}

local client_fd

local dc

local game
local user

local MAXEMAILNUM = 50

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end

local function push_achievement(achievement)
	-- body
	ret = {}
	ret.which = {
		csv_id = achievement.csv_id,
		finished = achievement.finished
	}
	send_package(send_request("finish_achi", ret))
end

function REQUEST:login(u)
	-- body
	assert( u )
	user = u
end

function REQUEST:mails(ctx)
	assert(ctx)
	user = ctx:get_user()
	assert(user)

	local ret = {}

	ret.mail_list = {}

	local counter = 0
	for i , v in pairs( user.u_new_emailmgr.__data ) do
		print( k , v )
		counter = counter + 1
		local tmp = {}
		tmp.attachs = {}

		tmp.emailid = v.id
		tmp.type = v.type
		tmp.acctime = os.date( "%Y-%m-%d" , v.acctime )
		tmp.isread = ( v.isread == 0 ) and true or false 
		tmp.isreward = ( v.isreward == 0 ) and true or false 
		tmp.title = v.title
		tmp.content = v.content

		for i = 1 , 5 do
			local id = "itemsn" .. i
			local num = "itemnum" .. i
		
			if nil ~= v[id] and 0 ~= v[num] then
				local ni = {}
			
				ni.itemsn = v[id]
				ni.itemnum = v[num]
				table.insert( tmp.attachs , ni )
			end
		end

		tmp.iconid = v.iconid

		table.insert( ret.mail_list , tmp )
	end 	
				
 	ret.errorcode = errorcode[ 1 ].code
	ret.msg = errorcode[ 1 ].msg
	print( "mails is called already" , counter )

	return ret
end 
	
function REQUEST:mail_read(ctx)
	assert(ctx)

	print( "****************************email_read is called" )
	local ret = {}
	if self.mail_id then
		for k , v in pairs( self.mail_id ) do
			print ( k , v , v.id )
			local e = user.u_new_emailmgr:get_by_csv_id( v.id )
			assert( e )

			e.isread = 1
			e:update_db()
		end 

		ret.errorcode = errorcode[ 1 ].code
		ret.msg = errorcode[ 1 ].msg
	else
		ret.errorcode = errorcode[41].code
		ret.msg = errorcode[41].msg
	end

	return ret
end	
		
-- function REQUEST:mail_delete(ctx)
-- 	assert(ctx)

-- 	print( "****************************email_delete is called" )
-- 	local ret = {}
-- 	for k , v in pairs( self.mail_id ) do
-- 		print ( k , v , v.id )
-- 		local e =user.u_new_emailmgr:get_by_csv_id( v.id )
-- 		assert( e )
		
-- 		e.isdel = 1
-- 		e:update_db()
-- 		user.u_new_emailmgr:delete_by_id( v.id )
-- 	end 

-- 	ret.errorcode = errorcode[ 1 ].code
-- 	ret.msg = errorcode[ 1 ].msg

-- 	return ret
-- end 
	
function REQUEST:mail_getreward(ctx)
	assert(ctx)

	print( "****************************get_reward is called" )
	local ret = {}
	if self.mail_id then
		for k , v in pairs( self.mail_id ) do                         		
			local e =user.u_new_emailmgr:get( v.id )
			assert( e )
			if 0 == e.isreward then 	

				for i = 1 , 5 do
					local id = "itemsn" .. i
					local num = "itemnum" .. i
		
					if nil ~= v[id] and 0 ~= v[num] then
						local prop = user.u_propmgr:get_by_csv_id( v[id] )
						if prop then
							prop.num = prop.num + v[num]
						else
							local p = game.g_propmgr:get_by_csv_id( v[id] )
							p.user_id = user.csv_id
							p.num = v[num]
							local prop = user.u_propmgr.create( p )
							user.u_propmgr:add( prop )
							prop:update_db()
						end			
					end
				end
					
					--[[if v[id] == const.A_T_GOLD or v[id] == const.A_T_EXP then
						raise_achievement( v[id] , user )
					end--]] 

				if 1 == e.type then
					e.isdel = 1
					e:update_db()
					user.u_new_emailmgr:delete( e:get_id() )
				else 		   
					e.isreward = 1
					e:update_db()
				end 		   
			end 			   
		end

		ret.errorcode = errorcode[ 1 ].code
		ret.msg = errorcode[ 1 ].msg
	else
		ret.errorcode = errorcode[ 41 ].code
		ret.msg = errorcode[ 41 ].msg
	end 
		
	return ret
end 	
		
function new_emailrequest:newemail(ctx,  tval , ... ) -- get a email to group
	assert(ctx and tval)
	print( "*********************************************REQUEST:newemail" )
		
	local v = user.u_new_emailmgr:recvemail( tval )
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
		
function new_emailrequest:public_email(ctx, tvals , user )
	assert(ctx and tvals and user )

	tvals.uid = user.csv_id
	print( "*********************************email is " , tvals.csv_id )
	assert(false)
	local v = user.u_new_emailmgr:recvemail( tvals )
	assert( v )
	
end 
	
function SUBSCRIBE:email(ctx, tvals , ... ) -- get email from channl , a email to all users 
	assert( tvals )
	print( " ***********************************SUBSCRIBE:email " )
	user.public_email = tvals.csv_id
	tvals.csv_id = skynet.call( ".game" , "lua" , "u_guid" , user.csv_id , const.UEMAILENTROPY )

	tvals.uid = user.csv_id
	print( "*********************************email csv_id is " , tvals.csv_id )
	local v = user.u_new_emailmgr:recvemail( tvals )
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
