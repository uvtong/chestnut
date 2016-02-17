local skynet = require "skynet"
require "skynet.manager"
local mc = require "multicast"
local u_client_id = {}

local channel

local CMD = {}
	
function CMD:agent_start( user_id, addr )
	u_client_id.user_id = addr
	assert(channel.channel)
	print("channel.channel", channel.channel)
	return channel.channel
end	

function CMD:hello( ... )
	-- body
	channel:publish("hello")
end

skynet.start( function () 
	skynet.dispatch( "lua" , function( _, _, cmd, ... )
		local f = assert( CMD[ cmd ] )
		local result = f(CMD, ... )
		if result then
			skynet.ret( skynet.pack( result ) )
		end
	end)
	channel = mc.new()
	skynet.register ".channel"
	end)