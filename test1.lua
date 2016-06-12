local abc = {"abc", "cedf", "ccd"}
local k, v = next(abc, 2)
print(k, v)


function abc( ... )
	-- body
	local r = select("#", ...)
	print(r)
end


abc("1", "aa", "cc")