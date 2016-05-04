local function abc(edf)
	-- body

end
local function cc( ... )
	-- body
	m = 3
end
abc()
print(m)
cc()
print(m)

abc(function ( ... )
	-- body
end)