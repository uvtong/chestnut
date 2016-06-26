local abc = {}
local a = abc["a"]
a = "a"
for k,v in pairs(abc) do
	print(k,v)
end