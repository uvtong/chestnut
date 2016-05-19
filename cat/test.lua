local _M = {}

function _M.new( ... )
	-- body
	local t = {}
	t["abc"] = "abc"
	return t
end

function _M:print( ... )
	-- body
	print(self.abc)
end

return _M