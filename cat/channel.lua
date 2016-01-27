package.path = "./../cat/?.lua;" .. package.path
    
local skynet = require "skynet"
    
require "skynet.manager"
local mc = require "multicast"
local u_client_id = {}
			
local channel
local CMD = {}

local function randomaddr()
	local r = math.random( 1 , 5 )
	local addr = skynet.localname( string.format( ".db%d", math.floor( r ) ) )
	print("addr is " .. addr )
	assert( addr , "randomaddr failed\n" )

	return addr
end

		
function CMD:agent_start( user_id, addr )
	u_client_id.user_id = user_id
	assert(channel.channel)
	print( "channel.channel" , channel.channel )
	return channel.channel
end			
			
function CMD:hello( _ , tval )
	-- body	
	print("hello is callled\n")
	print( tval.type , tval.iconid )
	channel:publish( tval )
	local addr = randomaddr()
	skynet.send( addr, "lua", "command" , "insert_offlineemail", tval)
   	-- offline_email( tval )
end		   	
    
function offline_email( tvals )
	print( emaildb )
	-- local au = emaildb:select_allusers()
	
	-- if au == nil then
	-- 	print( "get no offline users in offline_email\n" )
	-- 	return
	-- else		    
	-- 	for k , v in pairs( au ) do
	-- 		tvals.uid = v.id
	-- 		emaildb:insert_email( tvals )
	-- 		--db.query( "select id from users where ifonline = 0")
	-- 		print("insert successfully\n")
	-- 	end	
	-- end		
end  		
			

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
end)
