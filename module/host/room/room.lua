package.path = "./../../module/host/room/?.lua;./../../module/host/lualib/?.lua;../../lualib/?.lua;"..package.path
local skynet = require "skynet"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local context = require "context"
local log = require "log"
local errorcode = require "errorcode"
local assert = assert
local gs = require "gamestate"

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

local CMD = {}

function CMD:on_enter_room(agents, ... )
	-- body
	assert(#agents == 3)
	for i=1,3 do
		local agent = agents[i]
		local player = self:create_player(agent.uid, agent.agent)
		local res = skynet.call(agent.agent, "lua", "info")	
		player:set_name(res.name)
	end
	local players = self:get_players()
	for i=1,3 do
		local player = players[i]
		local ps = {}
		local p = {
			uid = player:get_uid(),
			name = player:get_name(),
			orientation = 0,
		}
		table.insert(ps, p)
		local last = player:get_last()
		if last then
			local p = {
				uid = last:get_uid(),
				name = last:get_name(),
				orientation = 1,
			}
			table.insert(ps, p)
		end
		local next = player:get_next()
		if next then
			local p = {
				uid = next:get_uid(),
				name = next:get_name(),
				orientation = -1
			}
			table.insert(ps, p)
		end
		
		local res = {}
		res.players = players
		skynet.send(player:get_agent(), "lua", "enter_room", res)
	end
	return true
end

function CMD:leave_room(uid, ... )
	-- body
	log.info("room leave_room: %d", uid)
	local controller = self._env:get_controller("game")
	if controller:get_state() == gs.CLOSE then
		
	local player = self:get_player_by_uid(uid)
	self:remove(player)
	skynet.call(".ROOM_MGR", "lua", "leave_room", uid)
	return NORET
end

function CMD:on_ready(args, ... )
	-- body
	local player = self:get_player_by_uid(args.uid)
	local controller = self:get_controller("game")
	return controller:ready(player, args.ready)
end

function CMD:on_mp(args, ... )
	-- body
end

function CMD:on_am(args, ... )
	-- body
end

function CMD:on_rob(args, ... )
	-- body
	local uid = args.uid
	local rob = args.rob
	local player = self:get_player_by_uid(uid)
	local controller = self._env:get_controller("game")
	return controller:rob(player, rob)
end

function CMD:on_lead(args, ... )
	-- body
	local uid = args.uid
	local player = self:get_player_by_uid(uid)
	local controller = self._env:get_controller("game")
	return controller:lead(player, flag, args.cards)
end

function CMD:enter_room(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
	return NORET
end

function CMD:ready(args, ... )
	-- body
	return NORET
end

function CMD:mp(args, ... )
	-- body
	return NORET
end

function CMD:rob(args, ... )
	-- body
	return NORET
end

function CMD:deal(args, ... )
	-- body
	local errorcode = args.errorcode
	assert(errorcode == errorcode.SUCCESS)
	return NORET
end



skynet.start(function ()
	-- body
	skynet.dispatch("lua", function(_, source, cmd, ...)
		log.info("room [%s] is called", cmd)
		local f = CMD[cmd]
		local ok, err = pcall(f, ctx, ...)
		if ok then
			if err ~= NORET then
				skynet.retpack(err)
			end
		else
			log.error(err)
		end
	end)
	init()
end)