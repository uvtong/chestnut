local skynet = require "skynet"
require "skynet.manager"
local mc = require "multicast"
local log = require "log"

local total = 0
local decrease = 0
local channel
local CMD = {}

function CMD.post(source)
	-- body
	tally = tally + 1
	return channel.channel
end

function CMD.exit(source)
	-- body
	decrease = decrease - 1
	if decrease == 0 then
		skynet.send(".FINISH", "lua", "exit")
	end
end

function CMD.finish(source)
	-- body
	log.info("start finish.")
	if decrease == 0 then
		skynet.send(".FINISH", "lua", "exit")
	else
		channel:publish("finish")
	end
end

function CMD.test(source, msg)
	-- body
	channel:publish("test", msg)
end


function CMD.abc( ... )
	-- body
end

skynet.start( function () 
	skynet.dispatch("lua" , function( _, source, command, ... )
		local f = assert(CMD[command])
		local r = f(source, ...)
		if r then
			skynet.ret(skynet.pack(r))
		end
	end)
	channel = mc.new()
	skynet.register ".CODWEB"
end)
