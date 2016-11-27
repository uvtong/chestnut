package.path = "./../../module/host/room/?.lua;./../../module/host/lualib/?.lua;../../lualib/?.lua;"..package.path
local skynet = require "skynet"
local context = require "rcontext"
local log = require "log"
local errorcode = require "errorcode"
local gs = require "gamestate"
local assert = assert

local ctx
local NORET = {}

local CMD = {}

function CMD:on_enter_room(agents, ... )
	-- body
	assert(#agents == 3)
	for i=1,3 do
		local agent = agents[i]
		local player = self:create_player(agent.uid, agent.sid, agent.agent)
		player:set_online(true)
		player:set_robot(false)
		local res = skynet.call(agent.agent, "lua", "info")	
		player:set_name(res.name)
	end
	local players = self:get_players()
	for i=1,3 do
		local player = players[i]
		local ps = {}
		local p = {
			sid = player:get_sid(),
			name = player:get_name(),
			orientation = 0,
		}
		table.insert(ps, p)
		local last = player:get_last()
		if last then
			local p = {
				sid = last:get_sid(),
				name = last:get_name(),
				orientation = 1,
			}
			table.insert(ps, p)
		end
		local next = player:get_next()
		if next then
			local p = {
				sid = next:get_sid(),
				name = next:get_name(),
				orientation = -1
			}
			table.insert(ps, p)
		end
		
		local res = {}
		res.players = ps
		skynet.send(player:get_agent(), "lua", "enter_room", res)
	end
	return true
end

function CMD:leave_room(uid, ... )
	-- body
	log.info("room leave_room: %d", uid)
	local controller = self._env:get_controller("game")
	-- if controller:get_state() == gs.CLOSE then
		
	local player = self:get_player_by_uid(uid)
	self:remove(player)
	skynet.call(".ROOM_MGR", "lua", "leave_room", uid)
	return NORET
end

function CMD:on_ready(args, ... )
	-- body
	local player = self:get_player_by_sid(args.sid)
	local controller = self:get_controller("game")
	return controller:on_ready(player, args.ready)
end

function CMD:on_mp(args, ... )
	-- body
end

function CMD:on_am(args, ... )
	-- body
end

function CMD:on_rob(args, ... )
	-- body
	local sid = args.sid
	local player = self:get_player_by_sid(sid)
	local controller = self:get_controller("game")
	return controller:on_rob(player, args)
end

function CMD:on_lead(args, ... )
	-- body
	local sid = args.sid
	local player = self:get_player_by_sid(sid)
	local controller = self:get_controller("game")
	return controller:lead(player, flag, args.cards)
end

function CMD:on_dealed(args, ... )
	-- body
	local sid = args.sid
	local player = self:get_player_by_sid(sid)
	local controller = self:get_controller("game")
	return controller:on_dealed(player, args)
end

function CMD:enter_room(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
	return NORET
end

function CMD:ready(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
	return NORET
end

function CMD:mp(args, ... )
	-- body
	return NORET
end

function CMD:rob(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
	return NORET
end

function CMD:lead(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
	return NORET
end

function CMD:dealed(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
	return NORET
end

function CMD:afk(sid, ... )
	-- body
	local player = self:get_player_by_sid(sid)
	player:set_online(false)
	player:set_robot(true)
end

function CMD:start(rule, mode, scene, ... )
	-- body
	local controller = self:get_controller("game")
	controller:set_rule(rule)
	controller:set_mode(mode)
	controller:set_scene(scene)
end

function CMD:close( ... )
	-- body
end

function CMD:kill( ... )
	-- body
	skynet.exit()
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
	ctx = context.new()
end)