function abc(  )
	-- body
	return "hell"
end

local ok, result = pcall(abc)
print(result)