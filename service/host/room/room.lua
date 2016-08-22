local skynet = require "skynet"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local context = require "context"
local ctx

local p1 = 0
local p2 = 1
local p3 = 1
local front_cards = {}
local back_cards = {}

local function function_name( ... )
	-- body
	front_cards[0 << 4 & 1] = 0 << 4 & 1
	front_cards[0 << 4 & 2] = 0 << 4 & 2
	front_cards[0 << 4 & 3] = 0 << 4 & 3
	front_cards[0 << 4 & 4] = 0 << 4 & 4
	front_cards[0 << 4 & 5] = 0 << 4 & 5
	front_cards[0 << 4 & 6] = 0 << 4 & 6
	front_cards[0 << 4 & 7] = 0 << 4 & 7
	front_cards[0 << 4 & 8] = 0 << 4 & 8
	front_cards[0 << 4 & 9] = 0 << 4 & 9
	front_cards[0 << 4 & 10] = 0 << 4 & 10
	front_cards[0 << 4 & 11] = 0 << 4 & 11
	front_cards[0 << 4 & 12] = 0 << 4 & 12
	front_cards[0 << 4 & 13] = 0 << 4 & 13

	front_cards[1 << 4 & 1] = 1 << 4 & 1
	front_cards[1 << 4 & 2] = 1 << 4 & 2
	front_cards[1 << 4 & 3] = 1 << 4 & 3
	front_cards[1 << 4 & 4] = 1 << 4 & 4
	front_cards[1 << 4 & 5] = 1 << 4 & 5
	front_cards[1 << 4 & 6] = 1 << 4 & 6
	front_cards[1 << 4 & 7] = 1 << 4 & 7
	front_cards[1 << 4 & 8] = 1 << 4 & 8
	front_cards[1 << 4 & 9] = 1 << 4 & 9
	front_cards[1 << 4 & 10] = 1 << 4 & 10
	front_cards[1 << 4 & 11] = 1 << 4 & 11
	front_cards[1 << 4 & 12] = 1 << 4 & 12
	front_cards[1 << 4 & 13] = 1 << 4 & 13

	front_cards[2 << 4 & 1] = 2 << 4 & 1
	front_cards[2 << 4 & 2] = 2 << 4 & 2
	front_cards[2 << 4 & 3] = 2 << 4 & 3
	front_cards[2 << 4 & 4] = 2 << 4 & 4
	front_cards[2 << 4 & 5] = 2 << 4 & 5
	front_cards[2 << 4 & 6] = 2 << 4 & 6
	front_cards[2 << 4 & 7] = 2 << 4 & 7
	front_cards[2 << 4 & 8] = 2 << 4 & 8
	front_cards[2 << 4 & 9] = 2 << 4 & 9
	front_cards[2 << 4 & 10] = 2 << 4 & 10
	front_cards[2 << 4 & 11] = 2 << 4 & 11
	front_cards[2 << 4 & 12] = 2 << 4 & 12
	front_cards[2 << 4 & 13] = 2 << 4 & 13

	front_cards[3 << 4 & 1] = 3 << 4 & 1
	front_cards[3 << 4 & 2] = 3 << 4 & 1
	front_cards[3 << 4 & 3] = 3 << 4 & 1
	front_cards[3 << 4 & 4] = 3 << 4 & 1
	front_cards[3 << 4 & 5] = 3 << 4 & 1
	front_cards[3 << 4 & 6] = 3 << 4 & 1
	front_cards[3 << 4 & 7] = 3 << 4 & 1
	front_cards[3 << 4 & 8] = 3 << 4 & 1
	front_cards[3 << 4 & 9] = 3 << 4 & 1
	front_cards[3 << 4 & 10] = 3 << 4 & 1
	front_cards[3 << 4 & 11] = 3 << 4 & 1
	front_cards[3 << 4 & 12] = 3 << 4 & 1
	front_cards[3 << 4 & 13] = 3 << 4 & 1

	front_cards[4 << 4 & 0] = 4 << 4 & 0
	front_cards[5 << 4 & 0] = 5 << 4 & 0
end

local REQUEST   = {}

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		if sz > 0 then
			local host = ctx:get_host()
			return host:dispatch(msg, sz)
		else 
			assert(false)
		end
	end,
	dispatch = function (session, source, type, ...)	
		if type == "REQUEST" then
			local ok, result = pcall(request, ...)
			if ok then
				if result then
					ctx:send_package(result)
				end
			else
				skynet.error(result)
			end
		elseif type == "RESPONSE" then
			pcall(response, ...)
		else
			assert(false, result)
		end
	end
}

local CMD = {}

function CMD:enter_room(uid, ... )
	-- body

	local cls = require "player"

end

function CMD:ready(uid, ... )
	-- body
end

function CMD:mp(uid, ... )
	-- body
end

function CMD:am(uid, ... )
	-- body
end

function CMD:rob(uid, ... )
	-- body
end

function CMD:lead(uid, ... )
	-- body
	if uid == p1:get_uid() then
		local addr = p1:get_addr()
		skynet.send(addr, "lua", "lead")
	elseif uid == p2:get_uid() then
	elseif uid == p3:get_uid() then

	end
end

function CMD:deal_cards(uid, ... )
	-- body
end

function CMD:start(source, conf, ... )
	-- body
	local client = conf.client
	local gate = conf.gate
	local version = conf.version
	local index = conf.index
	local last = source

end

function CMD.disconnect( ... )
	-- body
end

skynet.start(function ()
	-- body
	skynet.dispatch("lua", function(_, source, cmd, ...)
		local f = CMD[cmd]
		local r = f(ctx, ... )
		if r then
			skynet.retpack(r)
		end
	end)
	ctx = context.new()
	local host = sprotoloader.load(1):host "package"
	local send_request = host:attach(sprotoloader.load(2))
	ctx:set_host(host)
	ctx:set_send_request(send_request)
end)