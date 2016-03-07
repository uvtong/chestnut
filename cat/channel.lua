package.path = "./../cat/?.lua;" .. package.path
local skynet = require "skynet"
require "skynet.manager"
local mc = require "multicast"
local util = require "util"
local loader = require "loader"
local const = require "const"
local dc = require "datacenter"
local u_emailmgr = require "models/u_emailmgr"	

local game
local channel
local u_client_id = {} -- if
local R = {}

local CMD = {}		
local SEND_TYPE = { TO_ALL = 1 , TO_GROUP = 2 } 

function CMD:agent_start( user_id, addr )
	--[[u_client_id.user_id = user_id
	u_client_id.addr = addr 

	assert(channel.channel)--]]
	return channel.channel
end			
			
function CMD:send_email_to_all( tvals )
	print( "channel send_email_to_all is called" )

	assert( tvals )

	tvals.acctime = os.time() -- an integer
	tvals.isread = 0
	tvals.isreward = 0
	tvals.isdel = 0
	tvals.deltime = 0
	for i = 1 , 5 do
		local id = "itemsn" .. i
		local num = "itemnum" .. i
		print( id , tvals[id] , num , tvals[num] )
		if nil == tvals[id] then
			assert( tvals[num] == nil )
			
			tvals[id] = 0
			tvals[num] = 0
		end
	end

	channel:publish( "email" , tvals )
	local sql = "select csv_id from users where ifonline = 0" -- in users , csv_id now is "uid".
	local r = skynet.call( util.random_db() , "lua" , "command" , "query" , sql )
	print( "sizeof r = " , #r )
		
	print( "begin to insert" )
	local tmp = {}
	for _ , v in ipairs( r ) do
		tvals.csv_id = util.u_guid( v.csv_id , game, const.UEMAILENTROPY ) 
		tvals.uid = v.csv_id
		local ne = u_emailmgr.create( tvals )
		--assert( ne )
		--ne:__insert_db()
		table.insert( tmp , ne )	
	end 

	u_emailmgr.insert_db( tmp )
end 	
		
function CMD:send_email_to_group( tval , tucsv_id )
	assert( tval and tucsv_id )
	print( "send to group is called" )
	tval.acctime = os.time() -- an integer
	tval.isread = 0
	tval.isreward = 0
	tval.isdel = 0
	tval.deltime = 0
	for i = 1 , 5 do
		local id = "itemsn" .. i
		local num = "itemnum" .. i
		print( id , tval[id] , num , tval[num] )
		if nil == tval[id] then
			assert( tval[num] == nil )
			
			tval[id] = 0
			tval[num] = 0
		end
	end

	for _ , v in ipairs( tucsv_id ) do
		print( v.csv_id )
		tval.csv_id = util.u_guid( v.csv_id , game, const.UEMAILENTROPY )
		tval.uid = v.csv_id
			
		local t = dc.get( v.csv_id )

		--[[ id user online then send directly , else insert into db --]]
		if t then 
			skynet.send( t.addr , "lua" , "newemail" , "newemail" , tval )
		else
			local ne = u_emailmgr.create( tval )
			assert( ne )
			ne:__insert_db()
		end	
	end 	
end 		
		
--[[function CMD:hello( tval , ... )
	-- body	
	print( "hello is called\n" )

	--channel:publish( "email" , { emailtype = , tval )
	local addr = util.random_db()


	-- local t = {csv_id=util.u_guid(user_id, game, const.UEMAILENTROPY), uid=user.csv_id, type=}
	-- tval.csv_id = 
	-- tval.user_id = user_id
	-- local u_emailmgr = require "u_emailmgr"
	-- local email = u_emailmgr.create(tvalh)
	-- email:__insert_db()
end    		   			
	
local ROUTINE = { TIME = -1 , ECONTENT = {} }
--[[ ROUTINE_TIME = -1 , donot send ROUTINE_EMAIL --]]
--[[function CMD:change_routin_values( time , tval )
	assert( time and tval )
	ROUTINE.TIME = time
	ROUTINE.ECONTENT = tval
end		

function CMD:start_routine( )
end	
		
--[[function CMD:get_emailcontent( delay_time , type , temailcontent , tuser_list )
	if type == SEND_TYPE.TO_ALL then
		skynet.timeout( delay_time , send_email_to_all( temailcontent ) )
	elseif type == SEND_TYPE.TO_GROUP then
		skynet.timeout( )	  	
	end 					  
	skynet.timeout(coutnfd. CMD:hello( type , {} , {} )
end --]]						  

-- local function send(coutdown, count, content, type, l)
-- 	-- body
-- 	if type == QF then
-- 		skynet.send()
-- 		channel.publish(content)
-- 		skynet.timeout(cd, function function_name(ftype, content, l)
-- 			-- body
-- 			send_email_to_all()
-- 			if R[ftype].count == 0 then
-- 				os.time(R[ftype].coutdown)

-- 				send()

-- 		end)
-- 	else
-- end

-- function CMD.send_email(ftype, coutdown, count, content, type, l)
-- 	-- body
-- 	if ttype == "xx" then
-- 		if R[ftype] then
-- 			R[ftype].coutdown
-- 			else
-- 		R[ftype] == { coutdown = coutdown, count = count}
-- 		local s = os.time(coutdown)
-- 		local now os.time()
-- 		local cd = s - now

-- 	else
	
-- end

skynet.start( function () 
	skynet.dispatch( "lua" , function( _, _, cmd, ... )
		print("channel is called")
		local f = assert( CMD[ cmd ] )
		print( "result is " , result )
		local result = f(CMD, ... )

		print( "result is " , result )
		if result then
			skynet.ret( skynet.pack( result ) )
		end
	end)
	channel = mc.new()
	skynet.register ".channel"
	
	game = loader.load_channel_game()
end)
