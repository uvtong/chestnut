local mysql = require "mysql"
local redis = require "redis"

local dbop = {}

local
function dbop.tinsert( tvals ) --{ tname = "" , content = { {colname = val} ,  ... } , condition = "tiao jian" }
	if nil == tvals then 
		print( "empty argtable\n" )
		return nil
	end

	local tname = tvals["tname"]
	if nil == tname then
		print( "No tname\n" )
		return nil
	end

	local cont = tvals["content"]
	if nil == cont then
		print( "No Cont\n" )
		return nil
	end

	local ret = { key = "" , val = "" }

	ret["key"] = string.format( "insert into %s (" , tname ) 
	for k , v in ipairs( cont ) do
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
	
local 
function dbop.tselect( tvals )
	if nil == tvals then
		print( "tvals is empty" )
		return
	end
	
	local tname = tvals["tname"]
	if nil == tname then
		print("tname is empty\n")
		return nil
	end
	
	local content = tvals["content"]
	
	local condition = tvals["condition"]
	
	local ret = {}
	if nil == content then
		table.insert( ret , string.format( "select * from %s " , tname ) )
	else
		table.insert( ret , string.format( "select " ))
		for k , v in ipairs( content ) do
			if k > 1 then
				table.insert( ret , "," )
			end
			
			table.insert( ret , string.format( "%s" , v ) )
		end
		table.insert( ret , string.format( " from %s " , tname ) )
	end

	return condition and table.concat( ret ) or table.concat( ret ) .. "where" .. condition
end 
	
local
function dbop.tupdate( tvals )
	if nil == tvals then
		print( "No vals in tvals \n" )
		return nil
	end

	local tname = tvals["tname"]
	if nil == tname then
		print("No tname\n")
		return nil
	end
	
	local content = tvals["content"]
	if nil == content then
		print("No content\n")
		return nil
	end

	local condition = tvals["condition"]

	local ret = {}
	
	table.insert( ret , string.format("update %s SET " , tname ) )
	for k , v in ipairs( content ) do
		if k > 1 then
			table.insert( ret , ',' )
		end

		for subk , subv in pairs( v ) do
			if type( subv ) == "string" then
				table.insert( ret , string.format( "%s = '%s'" , subk , subv ) )
			else
				table.insert( ret , string.format( "%s = %s" , subk , subv ) )
			end	
		end
	end
	
	return ( condition and table.concat( ret ) or table.concat( ret ) .. " where " .. condition )
end

local 
function dbop.tdelete( tvals )
	if nil == tvals then 
		print( "tvals is empty\n" )
		return nil
	end 
	
	local tname = tvals["tname"]
	if nil == tname then
		print( "No tname\n" )
		return nil
	end
	
	local condition = tvals["condition"]
	if nil == condition then
		print( "No condition\n" )
		return nil
	end
	
	return string.format( "delete from %s where " , tname ) .. conditon 
end	

return dbop
