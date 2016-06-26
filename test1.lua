local testt = require "test"
local x = 1
local abc = {"abc", "cedf", "ccd"}
local k, v = next(abc, 2)
print(k, v)


function abc( ... )
	-- body
	local r = select("#", ...)
	print(r)
end


abc("1", "aa", "cc")

function genpk_3(_1, _2, ... )
	-- body
	local pk = (~(1 << 9 -1) & _1)
    pk = pk << 24
    pk = (pk | (~(1 << 25 -1) & _2 ))
    return pk
end

local a = genpk_3(1, 1)
print(a)