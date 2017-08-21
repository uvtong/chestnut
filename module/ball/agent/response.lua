local skynet = require "skynet"

local assert = assert
local pcall = skynet.pcall
local error = skynet.error

local RESPONSE = {}

function RESPONSE:handshake(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end

function RESPONSE:join(args, ... )
	-- body
	local room = self:get_room()
	skynet.send(room, "lua", "join", args)
end

function RESPONSE:leave(args, ... )
	-- body
end

-----------------------forward room ----------------------------------
local function forward_room(name, ctx, args, msg, sz, ... )
	-- body
	local addr = assert(ctx:get_room())
	skynet.rawsend(addr, "client", msg, sz)
end
	
function RESPONSE:deal(args, ... )
	-- body
	forward_room("deal", self, args, ...)
end

function RESPONSE:ready(args, ... )
	-- body
	forward_room("ready", self, args, ...)
end

function RESPONSE:take_turn(args, ... )
	-- body
	forward_room("take_turn", self, args, ...)
end

function RESPONSE:peng(args, ... )
	-- body
	forward_room("peng", self, args, ...)
end

function RESPONSE:gang(args, ... )
	-- body
	forward_room("gang", self, args, ...)
end

function RESPONSE:hu(args, ... )
	-- body
	forward_room("hu", self, args, ...)
end

function RESPONSE:call(args, ... )
	-- body
	forward_room("call", self, args, ...)
end

function RESPONSE:shuffle(args, ... )
	-- body
	forward_room("shuffle", self, args, ...)
end

function RESPONSE:dice(args, ... )
	-- body
	forward_room("dice", self, args, ...)
end

function RESPONSE:lead(args, ... )
	-- body
	forward_room("lead", self, args, ...)
end


function RESPONSE:over(args, ... )
	-- body
	forward_room("over", args)
end

function RESPONSE:restart(args, ... )
	-- body
end

function RESPONSE:rchat(args, ... )
	-- body
end

function RESPONSE:take_restart(args, ... )
		-- body
end	

function RESPONSE:take_xuanpao(args, ... )
	-- body
end
	
function RESPONSE:take_xuanque(args, ... )
	-- body
end

function RESPONSE:xuanque(args, ... )
	-- body
end

function RESPONSE:xuanpao(args, ... )
	-- body
end

function RESPONSE:settle(args, ... )
	-- body
end

function RESPONSE:final_settle(args, ... )
	-- body
end

function RESPONSE:roomover(args, ... )
	-- body
end

return RESPONSE