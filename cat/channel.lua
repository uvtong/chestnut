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
