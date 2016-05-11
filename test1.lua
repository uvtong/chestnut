_ENV['abc'] = 3
for k,v in pairs(_ENV) do
	print(k,v)
end
print("**********************")

for k,v in pairs(_G) do
	print(k,v)
end