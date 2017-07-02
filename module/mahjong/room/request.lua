local _M = {}

function _M:lead(args, ... )
	-- body
	self:lead(args.idx, args.card)
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function _M:call(args, ... )
	-- body
	self:call(args.op)
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function _M:shuffle(args, ... )
	-- body\
	self:shuffle(args.idx)
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function _M:dice(args, ... )
	-- body
	self:dice(args.idx)
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function _M:step(args, ... )
	-- body
	self:step(args.idx)
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function _M:restart(args, ... )
	-- body
	self:restart(args.idx)
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function _M:rchat(args, ... )
	-- body
	self:chat(args)
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function _M:xuanpao(args, ... )
	-- body
	self:xuanpao(args)
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function _M:xuanque(args, ... )
	-- body
	self:xuanque(args)
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

return _M