local dbop = {}


function dbop.tinsert( tname , content ) 
	
	assert( tname , content )

	local ret = { key = "" , val = "" }

	ret["key"] = string.format( "insert into %s (" , tname ) 
	for k , v in ipairs( content ) do
		for subk , subv in pairs( v ) do
			ret["key"] = ret["key"] .. subk .. ','
			if type (subv ) == "string" then
				ret["val"] = ret["val"] .. ',' .. string.format( "'%s'" , subv )
			else
				ret["val"] = ret["val"] .. ',' .. subv
			end
		end
	end
				
	--去掉 ret["key"] 的最后一个 ','
	ret["key"] = string.sub( ret["key"] , 1 , -2)
	ret["val"] = string.sub( ret["val"] , 2 )
	ret["key"] = ret["key"] .. ") values ("
	ret["val"] = ret["val"] .. ")"

	return ret["key"] .. ret["val"]
end
	

function dbop.tselect( tname , condition )
	assert( tname )

	local ret = {}
	table.insert( ret , string.format( "select * from %s " , tname ) )
	
	if condition then
		table.insert( ret , "where " )
		local index = 1
		for k , v in pairs( condition ) do
			if index > 1 then
				table.insert( ret , " and " )
			end
			if type( v ) == "string" then
				table.insert( ret , string.format( "%s = '%s'" , k , v ) )
			else
				table.insert( ret , string.format( "%s = %s" , k , v ) )	
			end
			index = index + 1   
		end
	end

	return table.concat( ret )
end 
	

function dbop.tupdate( tname , content , condition )
	
	assert( tname , content , condition )
	local ret = {}
	
	table.insert( ret , string.format("update %s SET " , tname ) )
	local index = 1
	for k , v in pairs( content ) do
		if index > 1 then
			table.insert( ret , ',' )
		end

		if type( v ) == "string" then
			table.insert( ret , string.format( "%s = '%s' " , k , v ) )
		else
			table.insert( ret , string.format( "%s = %s " , k , v ) )
		end	
		index = index + 1
	end
	
	table.insert( ret , " where " )
	local index = 1
	for k , v in pairs( condition ) do
		if index > 1 then
			table.insert( ret , " and " )
		end
		if type( v ) == "string" then
			table.insert( ret , string.format( "%s = '%s'" , k , v ) )
		else
			table.insert( ret , string.format( "%s = %s" , k , v ) )	
		end   
		index = index + 1
	end
	
	return table.concat( ret )
end

function dbop.tdelete( tname , conditon  )
	assert( tname , conditon )

	local ret = {}
	table.insert( ret , string.format( "delete from %s " , tname ) )
	
	table.insert( ret , "where " )
	local index = 1
	for k , v in pairs( conditon ) do
		if index > 1 then
			table.insert( ret , " and " )
		end
		if type( v ) == "string" then
			table.insert( ret , string.format( "%s = '%s'" , k , v ) )
		else
			table.insert( ret , string.format( "%s = %s" , k , v ) )	
		end   
		index = index + 1
	end

	return table.concat( ret )
end	

local content = { { id = 1 } , { content = "sdfsd" } , { title = "sdf"} }

local sql = dbop.tinsert( "email" , content )
print( sql )
print( "..................................")
sql = dbop.tselect( "email" , { id = 4 , uid = 5 } )
print( sql )
print( "..................................")
sql = dbop.tupdate( "email" , { isread = 1 , isdel = 1 } , { uid = 2})
print( sql )
print( "..................................")
print( dbop.tdelete( "email" , { uid = 1 , id = 2 } ) )


return dbop
