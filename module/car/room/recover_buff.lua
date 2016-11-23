local skynet = require "skynet"
local buff = require "room.buff"
local sd = require "sharedata"
local cls = class("recover_buff", buff)

function cls:ctor(ctx, id, type, limit, hpadd, ... )
	-- body
	assert(hpadd)
	cls.super.ctor(self, ctx, id, type, limit)
	self._hpadd = hpadd
	local callback = cc.handler(self, cls.recover)
	skynet.timeout(100, callback)
end

function cls:recover( ... )
	-- body
	if self._state == buff.state.DIE then
		return
	end
	local callback = cc.handler(self, cls.recover)
	skynet.timeout(100, callback)
	if self._type == buff.type.SINGLE then
		local player = self._parent:get_player()
		local players = self._ctx:get_players()
		for k,v in pairs(players) do
			local args = {}
			args.userid = player:get_uid()
			args.buff_id = self._id
			args.value = self._hpadd
			local agent = v:get_agent()
			agent.post.dealbuffvalue(args)
		end
	end
end

return cls