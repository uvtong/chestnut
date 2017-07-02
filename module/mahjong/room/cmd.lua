local skynet = require "skynet"
local CMD = {}

function CMD:start(uid, args, ... )
	-- body
	return self:start(uid, args)
end

function CMD:close( ... )
	-- body
	-- will be kill
	return self:close()
end

function CMD:kill( ... )
	-- body
	skynet.exit()
end

function CMD:authed(uid, ... )
	-- body
	self:authed(uid)
	return true
end

function CMD:afk(uid, ... )
	-- body
	self:afk(uid)
	return true
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
	return self:leave(args.idx)
end

function CMD:leave(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
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

return CMD