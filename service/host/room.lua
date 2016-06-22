local skynet = require "skynet"
local p1 = 0
local p2 = 1
local p3 = 1


local CMD = {}

function CMD.enter_room(uid, ... )
	-- body
	local cls = require "player"

end

function CMD.ready(uid, ... )
	-- body
end

function CMD.mp(uid, ... )
	-- body
end

function CMD.am(uid, ... )
	-- body
end

function CMD.rob(uid, ... )
	-- body
end

function CMD.lead(uid, ... )
	-- body
	if uid == p1:get_uid() then
		local addr = p1:get_addr()
		skynet.send(addr, "lua", "lead")
	elseif uid == p2:get_uid() then
	elseif uid == p3:get_uid() then

	end
end

function CMD.deal_cards(uid, ... )
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