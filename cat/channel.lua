package.path = "./../cat/?.lua;" .. package.path
local skynet = require "skynet"
require "skynet.manager"
local mc = require "multicast"
local util = require "util"
local loader = require "loader"
local const = require "const"
local dc = require "datacenter"
local emailmgr = require "models/u_emailmgr"	

local game
local channel
local u_client_id = {} -- if
	
local CMD = {}		
local SEND_TYPE = { TO_ALL = 1 , TO_GROUP = 2 } 

function CMD:agent_start( user_id, addr )
	--[[u_client_id.user_id = user_id
	u_client_id.addr = addr 

	assert(channel.channel)--]]
	return channel.channel
end			
			
function CMD:send_email_to_all( tval )
	assert( tval )
	channel:publish( "email" , tval )
	local sql = "select csv_id from users where ifonline = 0" -- in users , csv_id now is "uid".
	local r = skynet.call( util.random_db() , "lua" , "command" , "query" , sql )

	for _ , v in ipairs( r ) do
		tval.csv_id = util.u_guid( v.csv_id , game, const.UEMAILENTROPY ) 
		tval.uid = v.csv_id

		local ne = u_emailmgr.create( tval )
		assert( ne )
		ne:__insert_db()		
	end 
end 	
		
function CMD:send_email_to_group( tval , tucsv_id )
	assert( tval and tucsv_id )

	for _ , ucsv_id in pairs( tucsv_id ) do
		tval.csv_id = util.u_guid( ucsv_id , game, const.UEMAILENTROPY )
		tval.uid = ucsv_id
			
		local t = dc.get( ucsv_id )

		--[[ id user online then send directly , else insert into db --]]
		if t then 
			skynet.send( t.addr , "lua" , "command" , "newemail" , tval )
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
	skynet.send( addr, "lua", "command" , "insert_offlineemail", tval)

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

function start	
		
function CMD:get_emailcontent( delay_time , type , temailcontent , tuser_list )
	if type == SEND_TYPE.TO_ALL then
		skynet.timeout( delay_time , send_email_to_all( temailcontent ) )
	elseif type == SEND_TYPE.TO_GROUP then
		skynet.timeout( )	  	
	end 					  
	skynet.timeout(coutnfd. CMD:hello( type , {} , {} )
end 						  
							  
function CMD.ds()             
{		
	now	os.time()
	t= {
	lsf 
	local s = os.time(t)
	s - now
 	skynet.timeout(ssf, funcito)
}		
--]]
skynet.start( function () 
	skynet.dispatch( "lua" , function( _, _, cmd, ... )
		print("channel is called")
		local f = assert( CMD[ cmd ] )
		local result = f(CMD, ... )
		if result then
			skynet.ret( skynet.pack( result ) )
		end
	end)
	channel = mc.new()
	skynet.register ".channel"
	
	game = loader.load_channel_game()
end)
