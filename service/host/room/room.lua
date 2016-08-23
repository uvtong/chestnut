local skynet = require "skynet"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local context = require "context"
local ctx

local NORET = {}

local REQUEST   = {}

function REQUEST:ready(args, ... )
	-- body
	local uid = args.uid
	local ready = args.ready
	local player = self:get_player(uid)
	if player:get_ready() then
		assert(false, "client send error message.")
	else
		player:set_ready(ready)
	end
	local players = self:get_players()
	for i=1,3 do
		local player = players[i]
		local ready = player:get_ready()
		if ready then
		else
			local res = {}
			res.errorcode = errorcode.SUCCESS
			return res
		end
	end
	local cards = self:get_cards()
	local first = uid
	local res = {}
	res.errorcode = errorcode.ALL_READY
	res.first = first
	res.cards = cards
	return res
end

function REQUEST:mp(args, ... )
	-- body
	local uid = args.uid
	local player = self:get_player(uid)
end

function REQUEST:am(uid, ... )
	-- body
end

function REQUEST:rob(args, ... )
	-- body
	local uid = args.uid
	local rob = args.rob
	local player = self:get_player(uid)
	player:set_rob(rob)
	local first_player = self:get_first_player()
	local rob = first_player:get_rob()
	if #rob == 2 then
		-- decide to who is master

	else
		local next = player:get_next()
		local next_uid = next:get_uid()
		local res = {}
		res.errorcode = errorcode.SUCCESS
		res.your_turn = next_uid
		return res
	end
end

function REQUEST:lead(args, ... )
	-- body
	local uid = args.uid
	local cards = args.cards
	local player = self:get_player(uid)
	player:lead(cards)
	if player:is_over() then
	else
		local next = player:get_next()
		local next_uid = next:get_uid()
		local res = {}
		res.errorcode = errorcode.SUCCESS
		res.your_turn = next_uid
		local send_request = self._env:get_send_request()
		local v = send_request("lead", res)
		self._env:send_package(v)
		return res
	end
end

local function request(name, args, response)
	skynet.error(string.format("line request: %s", name))
    local f = REQUEST[name]
    local ok, result = pcall(f, ctx, args)
    if ok then
    	return response(result)
    else
    	skynet.error(result)
    	local ret = {}
    	ret.errorcode = errorcode.FAIL
    	return response(ret)
    end
end

local RESPONSE = {}

function RESPONSE:mp( ... )
	-- body
end

local function response(session, args)
	-- body
	error(string.format("response: %s", name))
    local f = RESPONSE[name]
    local ok, result = pcall(f, env, args)
    if ok then
    else
    	skynet.error(result)
    end
end

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

-- forward agent
function CMD:join(source, conf, ... )
	-- body
	local client = conf.client
	local gate = conf.gate
	local version = conf.version
	local index = conf.index
	local uid = conf.uid
	local p = player.new(self, uid)
	self:add(p)
	skynet.call(gate, "lua", "forward", uid, skynet.self())
	return true
end

function CMD:leave( ... )
	-- body

end

function CMD.disconnect( ... )
	-- body
end

skynet.start(function ()
	-- body
	skynet.dispatch("lua", function(_, source, cmd, ...)
		local f = CMD[cmd]
		local r = f(ctx, ... )
		if r ~= NORET then
			skynet.retpack(r)
		end
	end)
	ctx = context.new()
	local host = sprotoloader.load(1):host "package"
	local send_request = host:attach(sprotoloader.load(2))
	ctx:set_host(host)
	ctx:set_send_request(send_request)
end)