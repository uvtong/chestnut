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

local function raise_achievement(type, user)
	-- body
	if type == "combat" then
	elseif type == const.A_T_GOLD then -- 2
		repeat
			local a = assert(user.u_achievementmgr:get_by_type(const.A_T_GOLD))
			if a.is_valid == 0 then
				break
			end
			local gold = user.u_propmgr:get_by_csv_id(const.GOLD) -- abain prop by type (type -- csv_id -- prop.id)		
			local progress = gold.num / a.c_num
			if progress >= 1 then -- success
				a.finished = 100
				a.reward_collected = 0			
				-- insert achievement rc	
				local rc = user.u_achievement_rcmgr.create(a)
				user.u_achievement_rcmgr:add(rc)
				rc:__insert_db()

				if string.match(a.unlock_next_csv_id, "%d*%*%d*") then
					local k1 = string.gsub(a.unlock_next_csv_id, "(%d*)%*(%d*)", "%1")
					local k2 = string.gsub(a.unlock_next_csv_id, "(%d*)%*(%d*)", "%2")
					
					local a1 = skynet.call(game, "lua", "query_g_achievement", k1)
					a1.user_id = user.csv_id
					a1.finished = 100
					a1.is_unlock = 1
					a1.reward_collected = 0
					a1 = user.u_achievement_rcmgr.create(a1)
					user.u_achievement_rcmgr:add(a1)
					a1:__insert_db()

					if tonumber(k2) == 0 then
						a.is_valid = 0
						a:__update_db({"is_valid"})	
						break
					else
						local ga = assert(game.g_achievementmgr:get_by_csv_id(k2))
						a.csv_id = ga.csv_id
						a.finished = 0
						a.c_num = ga.c_num
						a.unlock_next_csv_id = ga.unlock_next_csv_id
						-- a.is_unlock = 1
						a:__update_db({"csv_id", "finished", "c_num", "unlock_next_csv_id", "is_valid"})	
					end
				else
					local ga = assert(game.g_achievementmgr:get_by_csv_id(a.unlock_next_csv_id))
					a.csv_id = ga.csv_id
					a.finished = 0
					a.c_num = ga.c_num
					a.unlock_next_csv_id = ga.unlock_next_csv_id
					a.is_unlock = 1
					a:__update_db({"csv_id", "finished", "c_num", "unlock_next_csv_id", "is_unlock"})	
				end
			else
				a.finished = progress * 100
				a.finished = math.floor(a.finished)
				a:__update_db({"finished"})
				break
			end
		until false
	elseif type == const.A_T_EXP then
		repeat
			local a = assert(user.u_achievementmgr:get_by_type(type))
			if a.is_valid == 0 then
				break
			end
			local prop = user.u_propmgr:get_by_csv_id(const.EXP) -- abain prop by type (type -- csv_id -- prop.id)		
			local progress = prop.num / a.c_num
			if progress >= 1 then -- success
				a.finished = 100
				a.reward_collected = 0
				push_achievement(a)
				
				-- insert achievement rc	
				local rc = user.u_achievement_rcmgr.create(a)
				user.u_achievement_rcmgr:add(rc)
				rc:__insert_db()

				if string.match(a.unlock_next_csv_id, "%d*%*%d*") then
					local k1 = string.gsub(a.unlock_next_csv_id, "(%d*)%*(%d*)", "%1")
					local k2 = string.gsub(a.unlock_next_csv_id, "(%d*)%*(%d*)", "%2")
					
					local a1 = game.g_achievementmgr:get_by_csv_id(k1)
					a1.user_id = user.csv_id
					a1.finished = 100
					a1.is_unlock = 1
					a1.reward_collected = 0
					a1 = user.u_achievement_rcmgr.create(a1)
					user.u_achievement_rcmgr:add(a1)
					a1:__insert_db()

					if tonumber(k2) == 0 then
						a.is_valid = 0
						a:__update_db({"is_valid"})	
						break
					else
						local ga = assert(game.g_achievementmgr:get_by_csv_id(k2))
						a.csv_id = ga.csv_id
						a.finished = 0
						a.c_num = ga.c_num
						a.unlock_next_csv_id = ga.unlock_next_csv_id
						-- a.is_unlock = 1
						a:__update_db({"csv_id", "finished", "c_num", "unlock_next_csv_id", "is_valid"})	
					end

				else
					local ga = assert(game.g_achievementmgr:get_by_csv_id(a.unlock_next_csv_id))
					a.csv_id = ga.csv_id
					a.finished = 0
					a.c_num = ga.c_num
					a.unlock_next_csv_id = ga.unlock_next_csv_id
					a.is_unlock = 1
					a:__update_db({"csv_id", "finished", "c_num", "unlock_next_csv_id", "is_unlock"})	
				end
			else
				a.finished = progress * 100
				a.finished = math.floor(a.finished)
				a:__update_db({"finished"})
				break
			end
		until false
	elseif type == "level" then
	end
end


function REQUEST:login(u)
	-- body
	assert( u )
	user = u
end

function REQUEST:mails()
	local ret = {}
		
	ret.mail_list = {}

	
	local counter = 0
	for i , v in pairs( user.u_emailmgr.__data ) do
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
	
 	ret.errorcode = errorcode[ 1 ].code
	ret.msg = errorcode[ 1 ].msg
	print( "mails is called already" , counter )

	return ret
end      
		
function REQUEST:mail_read()
	print( "****************************email_read is called" )
	local ret = {}
	for k , v in pairs( self.mail_id ) do
		print ( k , v , v.id )
		local e =user.u_emailmgr:get_by_csv_id( v.id )
		assert( e )

		e.isread = 1
		e:__update_db( { "isread" } )
	end 

	ret.errorcode = errorcode[ 1 ].code
	ret.msg = errorcode[ 1 ].msg

	return ret
end		
		
function REQUEST:mail_delete()
	print( "****************************email_delete is called" )
	local ret = {}
	for k , v in pairs( self.mail_id ) do
		print ( k , v , v.id )
		local e =user.u_emailmgr:get_by_csv_id( v.id )
		assert( e )
		
		e.isdel = 1
		e:__update_db( { "isdel" } )
		user.u_emailmgr:delete_by_id( v.id )
	end 

	ret.errorcode = errorcode[ 1 ].code
	ret.msg = errorcode[ 1 ].msg

	return ret
end 
	
function REQUEST:mail_getreward()
	print( "****************************get_reward is called" )
	local ret = {}

	for k , v in pairs( self.mail_id ) do                         		
		local e =user.u_emailmgr:get_by_csv_id( v.id )
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
				
				--[[if v.itemsn == const.A_T_GOLD or v.itemsn == const.A_T_EXP then
					raise_achievement( v.itemsn , user )
				end--]]
			end

			if ( 1 == e.type ) then
				e.isdel = 1
				e:__update_db( { "isdel" } )
				user.u_emailmgr:delete_by_csv_id( e.csv_id )
			else
				e.isreward = 1
				e:__update_db( { "isreward" } )
			end
		end
	end 

	ret.errorcode = errorcode[ 1 ].code
	ret.msg = errorcode[ 1 ].msg

	return ret
end 
	
function new_emailrequest:newemail( tval , ... ) -- get a email to group
	assert( tval )
	print( "*********************************************REQUEST:newemail" )

	local v =user.u_emailmgr:recvemail( tval )
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
		
function new_emailrequest:public_email( tvals , user )
	assert( tvals and user )

	tvals.uid = user.csv_id
	print( "*********************************email is " , tvals.csv_id )
	local v = user.u_emailmgr:recvemail( tvals )
	assert( v )
	
end 
	
function SUBSCRIBE:email( tvals , ... ) -- get email from channl , a email to all users 
	assert( tvals )
	print( " ***********************************SUBSCRIBE:email " )
	tvals.csv_id = skynet.call( ".game" , "lua" , "u_guid" , const.UEMAILENTROPY )

	tvals.uid = user.csv_id
	print( "*********************************email csv_id is " , tvals.csv_id )
	local v =user.u_emailmgr:recvemail( tvals )
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
