local skynet = require "skynet"
local userid1 = 0
local userid2 = 1
local userid2 = 1


local CMD = {}

function CMD.enter_room( ... )
	-- body
end

function CMD.ready(uid, ... )
	-- body
end

function CMD.mp( ... )
	-- body
end

function CMD.am( ... )
	-- body
end

function CMD.rob( ... )
	-- body
end

function CMD.lead( ... )
	-- body
end

function CMD.deal_cards( ... )
	-- body
end

skynet.start(function ()
	-- body
	skynet.dispatch("lua", function(_, source, command, ...)
		print("agent is called" , command)
		local f = CMD[command]
		local result = f(source, ... )
		if result then
			skynet.ret(skynet.pack(result))
		end
	end)
	id = skynet.call(".scene", "lua", "register", skynet.self())
end)