package.path = "./../../module/dezhou/room/?.lua;./../../module/dezhou/lualib/?.lua;../../lualib/?.lua;"..package.path
local skynet = require "skynet"
local context = require "rcontext"
local log = require "log"
local errorcode = require "errorcode"
local gs = require "gamestate"
local util = require "util"
local opcode = require "opcode"
local assert = assert

local ctx
local NORET = {}

local CMD = {}

function CMD:start(rule, mode, scene, ai_sz, ... )
	-- body
	self:start()
end

function CMD:close( ... )
	-- body
	self:clear()
end

function CMD:kill( ... )
	-- body
	skynet.exit()
end

function CMD:afk(sid, ... )
	-- body
	local player = self:get_player_by_sid(sid)
	player:set_onone(true)
	player:set_online(false)
	player:set_robot(false)
end

function CMD:on_join(agent, ... )
	-- body
	local res = {}
	if self:get_online() >= 6 then
		res.errorcode = errorcode.FAIL
		return res
	end

	local me = self:join(agent.uid, agent.sid, agent.agent, agent.name)
	
	local players = self:get_players()
	local ps = {}
	local p = {
		sid  = me:get_sid(),
		name = me:get_name(),
		orientation = 0,
	}
	table.insert(ps, p)
	local idx = 1
	local count = 0
	while true do
		local t = players[i]
		if count == 0 then -- find me
			if t == me then
				count = count + 1
			end
		elseif count == 1 then
			if t == me then
				break
			elseif not t._noone then
				local orientation = t:get_idx() - me:get_idx()
				if orientation > 0 then
				else
					orientation = orientation + 6
				end
				local p = {
					sid = t:get_sid(),
					name = t:get_name(),
					orientation = orientation
				}
				table.insert(ps, p)
			end
		end
	end

	local res = {}
	res.players = ps
	return res
end

function CMD:join(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
	return NORET
end

function CMD:on_leave(args, ... )
	-- body
	log.info("room leave_room: %d", uid)
	local controller = self._env:get_controller("game")
	-- if controller:get_state() == gs.CLOSE then
		
	local player = self:get_player_by_uid(uid)
	self:remove(player)
	skynet.call(".ROOM_MGR", "lua", "leave_room", uid)
	return NORET
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

function CMD:on_perflop(args, ... )
	-- body
	local player = self:get_player_by_sid(args.sid)
	if args.opcode == opcode.Bet then
		if player._chip >= player.filling then
			player._chip = player._chip - player.filling
		else
		end
	end
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
	if not player then
		log.info("sid: %d", sid)
	end
	local controller = self:get_controller("game")
	return controller:on_lead(player, args.lead, args.cards)
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

function CMD:on_identity(args, ... )
	-- body
	local p = self:get_player_by_sid(args.sid)
	local controller = self:get_controller("game")
	return controller:on_identity(p, args)
end

function CMD:identity(args, ... )
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