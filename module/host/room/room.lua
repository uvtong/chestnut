package.path = "./../../module/host/room/?.lua;./../../module/host/lualib/?.lua;../../lualib/?.lua;"..package.path
local skynet = require "skynet"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local context = require "context"
local log = require "log"
local player = require "player"
local errorcode = require "errorcode"
local assert = assert
local ctx
local NORET = {}

local function init( ... )
	-- body
	ctx = context.new()
	local host = sprotoloader.load(1):host "package"
	local send_request = host:attach(sprotoloader.load(2))
	ctx:set_host(host)
	ctx:set_send_request(send_request)
end

local REQUEST   = {}

function REQUEST:enter_room(args, ... )
	-- body
	assert(false)
end

function REQUEST:leave_room(args, ... )
	-- body
end

function REQUEST:ready(args, ... )
	-- body
	local controller = self:get_controller("game")
	return controller:ready(args)
end

function REQUEST:mp(args, ... )
	-- body
	local uid = args.uid
	local player = self:get_player_by_uid(uid)
end

function REQUEST:am(uid, ... )
	-- body
end

function REQUEST:rob(args, ... )
	-- body
	local uid = args.uid
	local rob = args.rob
	local player = self:get_player_by_uid(uid)
	local controller = self._env:get_controller("game")
	controller:rob(player, rob)
	
	-- player:set_rob(rob)
	-- local first_player = self:get_first_player()
	-- local rob = first_player:get_rob()
	-- if #rob == 2 then
	-- 	-- decide to who is master

	-- else
	-- 	local next = player:get_next()
	-- 	local next_uid = next:get_uid()
	-- 	local res = {}
	-- 	res.errorcode = errorcode.SUCCESS
	-- 	res.your_turn = next_uid
	-- 	return res
	-- end
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
	log.print_info("room request: %s", name)
    local f = REQUEST[name]
    local ok, result = pcall(f, ctx, args)
    if ok then
    	return result
    else
    	log.print_error(result)
    	local ret = {}
    	ret.errorcode = errorcode.FAIL
    	return ret
    end
end

local RESPONSE = {}

function RESPONSE:mp( ... )
	-- body
end

function RESPONSE:deal(args, ... )
	-- body
	local errorcode = args.errorcode
	assert(errorcode == errorcode.SUCCESS)
end

local function response(name, args)
	-- body
	log.print_info("room response: %s", name)
    local f = RESPONSE[name]
    local ok, result = pcall(f, ctx, args)
    if ok then
    else
    	log.print_error(result)
    end
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = skynet.unpack,
	dispatch = function (session, source, type, ...)	
		if type == "REQUEST" then
			local ok, result = pcall(request, ...)
			if ok then
				if result then
					skynet.retpack(result)
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
-- start
function CMD:enter_room(source, conf, ... )
	-- body
	assert(self:get_players_count() <= 3)
	local uid = conf.uid
	local p = player.new(self, uid, source)
	self:add(p)
	local players = {}
	local last = p:get_last()
	if last then
		local player = {}
		player.uid = uid
		local agent = assert(last:get_agent())
		local info = skynet.call(agent, "lua", "enter_room", player)
		local player = {
			name = info.name,
			orientation = -1,
		}
		table.insert(players, player)
	end
	local next = p:get_next()
	if next then
		local player = {}
		player.uid = uid
		local agent = assert(last:get_agent())
		local info = skynet.call(agent, "lua", "enter_room", player)
		local player = {
			name = info.name,
			orientation = 1
		}
		table.insert(players, player)
	end
	local res = {}
	res.errorcode = errorcode.SUCCESS
	res.players = players
	return res
end

function CMD:leave_room(source, ... )
	-- body
end

function CMD:afk(source, fd)
	-- body
	local player = self:get_player_by_fd(fd)
	local uid = player:get_uid()
	log.print_info("agent uid = %d) disconnect", uid)
end

skynet.start(function ()
	-- body
	skynet.dispatch("lua", function(_, source, cmd, ...)
		local f = CMD[cmd]
		local r = f(ctx, source, ... )
		if r ~= NORET then
			skynet.retpack(r)
		end
	end)
	init()
end)