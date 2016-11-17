-- local type = {}
-- type.NONE    = 0
-- type.RECOVER = 1
-- type.SHIELD  = 2
-- type.ACCEL   = 3
-- type.HARM    = 4
-- type.DECEL   = 5
-- type.HURT    = 6
-- type.WEAK    = 7

local sd = require "sharedata"

local type = {}
type.REGIN = 1
type.SINGLE = 2

local state = {}
state.NONE  = 0
state.LIVE  = 1
state.DIE   = 2

local skynet = require "skynet"
local cls = class("buff")
cls.type = type
cls.state = state

function cls:ctor(ctx, id, type, limit, ... )
	-- body
	assert(ctx and id and type and limit)
	self._ctx = ctx
	self._id = id
	self._type = type
	self._limit = limit
	self._state = state.LIVE
	self._parent = nil
	local callback = cc.handler(self, cls.die)
	skynet.timeout(limit, callback)
end

function cls:get_id( ... )
	-- body
	return self._id
end

function cls:set_state(value, ... )
	-- body
	self._state = value
end

function cls:get_state( ... )
	-- body
	return self._state
end

function cls:die( ... )
	-- body
	if self._state == state.LIVE then
		self._state = state.DIE
		local player = self._parent:get_player()
		local players = self._ctx:get_players()
		for k,v in pairs(players) do
			local agent = v:get_agent()
			local args = {}
			args.userid = player:get_uid()
			args.buff_id = self._id
			local id = self._id
			local key = string.format("%s:%d", "s_buff", id)
			raw = sd.query(key)	
			if id == 1 then	
				args.value = raw.accelerateadd
			elseif id == 2 then
				args.value = 0
			elseif id == 3 then
				args.value = raw.damageadd
			elseif id == 4 then
				args.value = raw.invinciblecount
			elseif id == 5 then
				args.value = -raw.accelerateminus
			elseif id == 6 then
				args.value = 0
			elseif id == 7 then
				args.value = -raw.damageminus
			end
			agent.post.dealbuffvalue(args)
			agent.post.deletebuff(args)
		end
	else
	end
end

function cls:set_parent(value, ... )
	-- body
	self._parent = value
end

function cls:get_parent( ... )
	-- body
	return self._parent
end

return cls
