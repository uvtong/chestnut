local skynet = require "skynet"

local REQUEST = {}

function REQUEST.say()
	
end

local CMD = {}

function CMD.say()
	
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
	end,
	dispatch = function (_, _, t, ...)
	end
}

skynet.start(function () 
	
end)