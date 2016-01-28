package.path = "./../cat/?.lua;" .. package.path
local skynet = require "skynet"
require "skynet.manager"
local mc = require "multicast"
local util = require "util"

local channel
local u_client_id = {} -- if

local CMD = {}
		
function CMD:agent_start( user_id, addr )
	u_client_id.user_id = addr
	assert(channel.channel)
	return channel.channel
end			
			
function CMD:hello( _ , tval )
	-- body	
	print("hello is callled\n")
	print( tval.type , tval.iconid )
	channel:publish("email", tval )
	local addr = util.random_db()
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
