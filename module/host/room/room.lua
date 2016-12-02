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

function CMD:start(rule, mode, scene, ai_sz, ... )
	-- body
	local controller = self:get_controller("game")
	controller:set_rule(rule)
	controller:set_mode(mode)
	controller:set_scene(scene)

	for i=1,ai_sz do
		local uid = skynet.call(".AI_MGR", "lua", "enter")
		local sid = skynet.call(".SID_MGR", "lua", "enter")
		log.info("uid: %d, sid: %d", uid, sid)
		local p = self:create_player(uid, sid)
		p:set_aiflag(true)
		p:set_online(false)
		P:set_robot(false)
	end
end

function CMD:close( ... )
	-- body
end

function CMD:kill( ... )
	-- body
	skynet.exit()
end

function CMD:afk(sid, ... )
	-- body
	local player = self:get_player_by_sid(sid)
	player:set_online(false)
	player:set_robot(true)
end

function CMD:on_enter_room(agent, ... )
	-- body
	local player = self:create_player(agent.uid, agent.sid, agent.agent)
	player:set_aiflag(false)
	player:set_online(true)
	player:set_robot(false)
	player:set_name(agent.name)
	
	for i=1,1 do
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
		assert(player:get_aiflag() == false)
		local res = {}
		res.players = ps
		skynet.send(player:get_agent(), "lua", "enter_room", res)
	end
	return true
end

function CMD:on_exit_room(args, ... )
	-- body
	log.info("room leave_room: %d", uid)
	local controller = self._env:get_controller("game")
	-- if controller:get_state() == gs.CLOSE then
		
	local player = self:get_player_by_uid(uid)
	self:remove(player)
	skynet.call(".ROOM_MGR", "lua", "leave_room", uid)
	return NORET
end

function CMD:exit_room(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end

function CMD:join(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
	return NORET
end

function CMD:on_leave(args, ... )
	-- body
end

function CMD:leave(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end

function CMD:on_ready(args, ... )
	-- body
	local player = self:get_player_by_sid(args.sid)
	local controller = self:get_controller("game")
	return controller:on_ready(player, args.ready)
end

function CMD:ready(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
	return NORET
end

function CMD:on_mp(args, ... )
	-- body
end

function CMD:mp(args, ... )
	-- body
	return NORET
end

function CMD:on_am(args, ... )
	-- body
end

function CMD:am(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end

function CMD:on_rob(args, ... )
	-- body
	local sid = args.sid
	local player = self:get_player_by_sid(sid)
	local controller = self:get_controller("game")
	return controller:on_rob(player, args)
end

function CMD:rob(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
	return NORET
end

function CMD:on_lead(args, ... )
	-- body
	local sid = args.sid
	local player = self:get_player_by_sid(sid)
	local controller = self:get_controller("game")
	return controller:lead(player, flag, args.cards)
end

function CMD:lead(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
	return NORET
end

function CMD:on_dealed(args, ... )
	-- body
	local sid = args.sid
	local player = self:get_player_by_sid(sid)
	local controller = self:get_controller("game")
	return controller:on_dealed(player, args)
end

function CMD:dealed(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
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
	ctx = context.new()
end)