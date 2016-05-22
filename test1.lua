local mm = { __call = function (t, ...)
	-- body
	print("abc")
end}

local m = setmetatable({}, mm)

local _M = setmetatable({}, m)

_M()