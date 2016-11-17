local skynet = require "skynet"
local cls = class("region")

function cls:ctor(ctx, mgr, id, begin, cd, ... )
	-- body
	self._ctx = ctx
	self._mgr = mgr
	self._id = id
	self._begin = begin
	self._cd = cd

	local callback = cc.handler(self, cls.begin)
	skynet.timeout(self._begin, callback)

end

function cls:begin( ... )
	-- body
	local args = {}
	args.buff_id = self._id
	local players = self._ctx:get_players()
	for k,v in pairs(players) do
		local agent = v:get_agent()
		agent.post.buffgenerate(args)
	end

	local callback = cc.handler(self, cls.die)
	skynet.timeout(self._cd, callback)
end

function cls:die( ... )
	-- body
	local args = {}
	args.buff_id = self._id
	local players = self._ctx:get_players()
	for k,v in pairs(players) do
		local agent = v:get_agent()
		agent.post.deletebuffgenerate(args)
	end
	self._mgr:remove(self)
end

return cls