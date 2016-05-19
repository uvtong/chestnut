local _M = {}

function _M.new(mgr, P)
	assert(P)
	local t = { 
		__head  = mgr.__head,
		__tname = mgr.__tname,
		__pk    = mgr.__pk,
		__fk    = mgr.__fk,
		__rdb   = mgr.__rdb,
		__wdb   = mgr.__wdb,
		__stm   = mgr.__stm,
		__col_updated=0,
		__fields = %s,
		__ecol_updated = %s
	}
	setmetatable(t, entity)
	for k,v in pairs(t.__head) do
		t.__fields[k] = assert(P[k])
	end
	return t
end	

return _M