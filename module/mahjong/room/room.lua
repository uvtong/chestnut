package.path = "./../../module/mahjong/room/?.lua;./../../module/mahjong/lualib/?.lua;../../lualib/?.lua;"..package.path
local skynet = require "skynet"
local context = require "rcontext"
local log = require "log"
local errorcode = require "errorcode"
local gs = require "gamestate"
local util = require "util"
local opcode = require "opcode"
local assert = assert

local id = tonumber(...)
local ctx
local NORET = {}

local CMD = {}

function CMD:start(uid, args, ... )
	-- body
	self:start(uid, args)
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

function CMD:on_create(agent, ... )
	-- body
	local res = self:create(agent.uid, agent.sid, agent.agent, agent.name, agent.sex)
	return res
end

function CMD:on_join(agent, ... )
	-- body
	local res = self:join(agent.uid, agent.sid, agent.agent, agent.name, agent.sex)
	return res
end

function CMD:join(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
	return NORET
end

function CMD:on_leave(args, ... )
	-- body
	log.info("uid %d leave room", args.uid)
	local player = self:get_player_by_uid(args.uid)
	player:set_noone(true)

	local p = {
		name = player:get_name(),
		idx = player:get_idx(),
		sid = player:get_sid()
	}
	local args = {}
	args.p = p
	for k,v in pairs(self._players) do
		if not v._noone and v ~= player then
			skynet.send(v._agent, "lua", "leave", args)
		end
	end
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function CMD:leave(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end

function CMD:on_call(args, ... )
	-- body
	self:call(args.op)
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function CMD:on_shuffle(args, ... )
	-- body
	self:shuffle(args.idx)
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function CMD:on_dice(args, ... )
	-- body
	self:dice(args.idx)
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function CMD:on_lead(args, ... )
	-- body
	self:lead(args.idx, args.card)
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function CMD:on_step(args, ... )
	-- body
	self:step(args.idx)
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function CMD:on_restart(args, ... )
	-- body
	self:restart(args.idx)
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function CMD:on_rchat(args, ... )
	-- body
	self:chat(args)
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function CMD:on_xuanpao(args, ... )
	-- body
	self:xuanpao(args)
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function CMD:on_xuanque(args, ... )
	-- body
	self:xuanque(args)
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function CMD:ready(args, ... )
	-- body
	return NORET
end

function CMD:take_turn(args, ... )
	-- body
	return NORET
end

function CMD:peng(args, ... )
	-- body
	return NORET
end

function CMD:gang(args, ... )
	-- body
	return NORET
end

function CMD:hu(args, ... )
	-- body
	return NORET
end

function CMD:call(args, ... )
	-- body
	return NORET
end

function CMD:shuffle(args, ... )
	-- body
	return NORET
end

function CMD:dice(args, ... )
	-- body
	return NORET
end

function CMD:lead(args, ... )
	-- body
	return NORET
end

function CMD:deal(args, ... )
	-- body
	return NORET
end

function CMD:over(args, ... )
	-- body
	return NORET
end

function CMD:restart(args, ... )
	-- body
	return NORET
end

function CMD:take_restart(args, ... )
	-- body
	return NORET
end

function CMD:rchat(args, ... )
	-- body
	return NORET
end

function CMD:take_xuanpao(args, ... )
	-- body
	return NORET
end

function CMD:xuanpao( ... )
	-- body
	return NORET
end

function CMD:take_xuanque(args, ... )
	-- body
	return NORET
end

function CMD:xuanque(args, ... )
	-- body
	return NORET
end

function CMD:settle( ... )
	-- body
	return NORET
end

function CMD:final_settle( ... )
	-- body
	return NORET
end

function CMD:roomover( ... )
	-- body
	return NORET
end

skynet.start(function ()
	-- body
	skynet.dispatch("lua", function(_, source, cmd, ...)
		log.info("room [%s] is called", cmd)
		local f = CMD[cmd]
		local msgh = function ( ... )
			-- body
			log.info(tostring(...))
			log.info(debug.traceback())
		end
		local ok, err = xpcall(f, msgh, ctx, ...)
		if ok then
			if err ~= NORET then
				skynet.retpack(err)
			end
		end
	end)
	ctx = context.new()
	ctx:set_id(id)
end)