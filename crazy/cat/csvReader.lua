--package.path = "../csvfiles/?.csv"

local csvreader = {} --store function 
csvcont = {}  --store csvcont
--local csvpath = "../csvfiles/" 

local 
function splitstr( s , delim )
	if type( delim ) ~= "string" or string.len( delim ) <= 0 then
		print( "wrong input" )
		return
	end

	local start = 1
	local t = {}

	while true do
		local pos = string.find( s , delim , start , true )

		if not pos then
			break
		end

		table.insert( t, string.sub( s , start , pos - 1 ) )
		start = pos + string.len( delim )
	end

	table.insert( t , string.sub( s, start ) )

	return t
end 

local 
function init_title( title )
		if nil == title then
			print("empty title")
			return nil 
		end
		print(title)
		local pos = 1
		local temp = {}
		temp = splitstr( title, "," )
		
		if temp ~= nil then
			for i , val in pairs( temp ) do
				--print( val )
				csvcont[val] = {}
			end
		end

		return temp	
end	
	
local	
function getindex( content , idval )
	print( content , idval )
	--assert( content == nil or idval == nil )
	if content == nil or idval == nil then
		print( content , idval )
	end

	local tab = content["ID"]
	local index = 0	
	
	for i = 1, #tab do
		if tab[i] == idval then
			print( i )
			return i
		end
	end
	
	print("can not find the idval : " .. idval)
	
	return nil
end	
								
function csvreader.getcont( filename )	
	local file = assert( io.open( filename , "r" ) )
	local title = file:read()
	local titlename = {}

	titlename = init_title( title )

	if titlename == nil then
		return nil
	else		
		local tmp = {}			

		for line in file:lines() do
			local index = 1

			if line ~= nil then
				tmp = splitstr( line, "," )
				if tmp ~= nil then
					for _, val in pairs( tmp ) do
						table.insert( csvcont[titlename[index]] , val )
						index = index + 1
					end
				end
			end
		end
	end		
	file.close()	

	return csvcont
end	

function csvreader.findval( content , idval , clomnname2 )
	print( content , idval , clomnname2 )
	assert( content == nil or clomnname1 == nil or clomnname2 == nil )

	local index = getindex( content , idval )

	if index then
		return csvcont[clomnname2][index]
	end
	
	return nil
end

function csvreader.getline( content , idval)
	print( content , idval )
	--assert( nil == content or nil == idval )
	if content == nil or idval == nil then
		print("error in getline")
	end
	local val = {}
	
	local index = getindex( content , idval )
	
	if index then
		for i , v in pairs( content ) do
			print( i, v[index])
			if i ~= "ID" then
				val[i] = v[index]
			end
		end

		return val
	end
	
	return nil
end
				
return csvreader	
			
	
	
	
