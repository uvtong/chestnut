local skynet = require "skynet"
local _M = {}

local function __and( t )
	-- body
	assert(type(t) == "table")
	local seg = "("
	for k,v in pairs(t) do
		assert(type(v) ~= "table")
		local seg1 = ""
		if type(v) == "number" then
			seg1 = string.format("%s = %d", k, v)
		elseif type(v) == "string" then
			seg1 = string.format("%s = \"%s\"", k, v)
		else
			assert(false)
		end
		seg = seg .. seg1 .. " and "
	end
	return string.gsub(seg, "(.*)%sand%s$", "%1)")
end

local function __or( t )
	-- body
	assert(type(t) == "table")
	local seg = "("
	for i,v in ipairs(t) do
		assert(type(v) == "table")
		assert(#v == 1)
		local seg1 = ""
		for kk,vv in pairs(v) do
			if type(vvv) == "number" then
				seg1 = string.format("%s = %d", k, v)
			elseif type(v) == "string" then
				seg1 = string.format("%s = \"%s\"", k, v)
			else
				assert(false)
			end	
		end
		seg = seg .. seg1 .. " or "
	end
	return string.gsub(seg, "(.*)%sor%s$", "%1%)")
end

local function __condition( t )
	-- body
	-- { { k1 = {{},{} }, k2 = "" }, {}} ===> (((A or B) and C) or D)
	assert(type(t) == "table")
	local seg = ""
	for i,v in ipairs(t) do
		assert(type(v) == "table")
		local r1 = {}
		local r2 = {}
		for kk,vv in pairs(v) do
			if type(vv) == "table" then
				r1[kk] = __or(vv)
			else
				r2[kk] = vv
			end
		end
		if #r1 > 0 then
			r1["other"] = __and(r2)
			local seg1 = "("
			for k,v in pairs(r1) do
				r3 = r3 .. v .. " and "
			end
			t[i] = string.gsub(seg1, "(.*)%sand%s$", "%1)")
		else
			t[i] = __and(r2)
		end
		seg = seg .. t[i] .. " or "
	end
	return string.gsub(seg, "(.*)%sor%s$", "%1")
end

local function print_sql( sql )
	-- body
	assert(type("sql") == "string")
	-- skynet.error("\\**" .. sql .. "**\\")
end

function _M.select( table_name, condition, columns )
	-- body
	local columns_str = "("
	if not columns then
		columns_str = "*"
	else
		for k,v in pairs(columns) do
			columns_str = columns_str .. v .. ", "	
		end
		columns_str = string.gsub(columns_str, "(.*)%,%s$", "%1")
		columns_str = columns_str .. ")"
	end
	local condition_str 
	if type(condition) == "table" then
		condition_str = __condition(condition)
		if #condition_str > 0 then
			condition_str = " where " .. condition_str
		end
	elseif type(condition) == "string" then
		condition_str = condition
		if #condition_str > 0 then
			condition_str = " where " .. condition_str
		end
	elseif type(condition) == "nil" then
		condition_str = ""
	else
		assert(false)
	end
	local sql = string.format("select %s from %s", columns_str, table_name) .. condition_str .. ";"
	print_sql(sql)
	return sql
end

function _M.update( table_name, condition, columns )
	-- body
	assert(type(condition) == "table")
	assert(type(columns) == "table")
	local columns_str = "set "
	for k,v in pairs(columns) do
		local seg = ""
		if type(v) == "string" then
			seg = string.format("%s = \"%s\"", k, v)
		elseif type(v) == "number" then
			-- seg = string.format("%s = %d", k, math.tointeger(v))
			seg = string.format("%s = %d", k, v)
		else
			assert(false)
		end
		columns_str = columns_str .. seg .. ", "
	end
	columns_str = string.gsub(columns_str, "(.*)%,%s$", "%1")
	local condition_str = __condition(condition)
	if #condition_str > 0 then	
		condition_str = " where " .. condition_str
	end
	local sql = string.format("update %s ", table_name) .. columns_str .. condition_str .. ";"
	print_sql(sql)
	return sql
end

function _M.insert( table_name, columns )
	-- body
	assert(type(table_name) == "string")
	assert(type(columns) == "table")
	local columns_str = "("
	local values_str = "("
	for k,v in pairs(columns) do
		columns_str = columns_str .. k .. ", "	
		if type(v) == "string" then
			v = "\'" .. v .. "\'"
		end
		values_str = values_str .. v .. ", "
	end
	columns_str = string.gsub(columns_str, "(.*)%,%s$", "%1)")
	values_str = string.gsub(values_str, "(.*)%,%s$", "%1)")
	local sql = string.format("insert into %s ", table_name) .. columns_str .. " values " .. values_str .. ";"
	print_sql(sql)
	return sql
end
	
function _M.insert_all( table_name , tcolumns )
	assert( table_name and tcolumns )
	local f = assert( tcolumns[1] )
	assert( f )
	local columns_str = "("
	for k,v in pairs(f) do
		columns_str = columns_str .. k .. ", "	
	end	
	columns_str = string.gsub(columns_str, "(.*)%,%s$", "%1)")
	local tmp = {}
	local counter = 0
	
	for sk , sv in ipairs( tcolumns ) do
		local count = 0
		local values_str = {}
		table.insert( values_str , "(" )
		for k,v in pairs( sv ) do
			--print( v )
			--values_str = "("
			if type( v ) == "string" then
				v = "\'" .. v .. "\'"
			end
			if count >= 1 then
				table.insert( values_str , "," )
			end 
			table.insert( values_str , v )
			count = count + 1
			--values_str = values_str .. v .. ", "
			--print( values_str )
		end
		table.insert( values_str , ")" )
		local value = table.concat( values_str )
		--print( "values_str is " , value )
	
		value = string.gsub(value, "(.*)%,%s$", "%1)")
		if counter >= 1 then
			table.insert( tmp , " , " )
		end
		counter = counter + 1
		table.insert( tmp , value )
	end
	table.insert( tmp , ";" )
	local sql = string.format("insert into %s ", table_name) .. columns_str .. " values " .. table.concat( tmp ) 
	print_sql(sql)
	return sql
end 

function _M.update_all( table_name, condition, columns, data )
	-- body
	assert(type(table_name) == "string")
	local condition_str = "where"
	local columns_str = "set"
	assert(type(columns) == "table")
	for k,v in pairs(condition[2]) do
		for i,vv in ipairs(columns) do
			local t = string.format(" %s = case %s", vv, k)
			for kkk,vvv in pairs(data) do
				assert(type(vvv[k]) == "number", string.format("normal, this key is csv_id and number type, but table %s is %s, %s", table_name, type(vvv[k]), k))
				if type(vvv[vv]) == "number" then
					t = t .. string.format(" when %d then %d", vvv[k], vvv[vv])
				elseif type(vvv[vv]) == "string" then
					t = t .. string.format(" when %d then \"%s\"", vvv[k], vvv[vv])
				else
					error(string.format("don't support types %s fileds %s. in %s", type(vvv[vv]), vv, table_name))
				end
			end
			t = t .. " end,"
			columns_str = columns_str .. t
		end
		local t = string.format(" %s in (", k)
		for kk,vv in pairs(data) do
			assert(type(vv[k]) == "number")
			t = t .. string.format("%d, ", vv[k])
		end
		t = string.gsub(t, "(.*)%,%s$", "%1)")
		condition_str = condition_str .. t
	end
	columns_str = string.gsub(columns_str, "(.*)%,$", "%1 ")
	local t = ""
	if type(condition[1]) == "table" then
		for k,v in pairs(condition[1]) do
			t = t .. string.format("%s = %d", k, v)
		end
		t = " and " .. t
	end
	condition_str = condition_str .. t
	local sql = string.format("update %s ", table_name) .. columns_str .. condition_str .. ";"
	print_sql(sql)
	return sql
end

return _M