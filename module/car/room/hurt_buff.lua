local buff = require "room.buff"
local cls = class("hurt_buff")

function cls:ctor(ctx, id, type, limit, ... )
	-- body
	cls.super.ctor(self, ctx, id, type, limit)
	local callback = cc.handler(self, cls.minus)
	skynet.timeout(100, callback)
	return self
end

function cls:minus( ... )
	-- body
	if self._state == buff.state.DIE then
		return
	end
	local callback = cc.handler(self, cls.minus)
	skynet.timeout(100, callback)
	if self._type == buff.type.SINGLE then
		local key = string.format("%s:%d", "s_buff", id)
		raw = sd.query(key)
		local player = self._parent:get_player()
		local players = self._ctx:get_players()
		for k,v in pairs(players) do
			local args = {}
			args.userid = player:get_uid()
			args.buff_id = self._id
			args.value = raw.hpminus
			local agent = v:get_agent()
			agent.post.dealbuffvalue(args)
		end
	end
end

return cls