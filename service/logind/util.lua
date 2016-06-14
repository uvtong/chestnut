local skynet = require "skynet"
require "skynet.manager"
local const = require "const"
local util = {}

function util.random_db()
	-- body
	local addr = ".db"
	return addr
end

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

function util.select( table_name, condition, columns )
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

function util.update( table_name, condition, columns )
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

function util.insert( table_name, columns )
	-- body
	print( "tablename and columns is " , table_name , columns )
	for k , v in pairs( columns ) do
		print( k , v )
	end
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
	
function util.insert_all( table_name , tcolumns )
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

function util.update_all( table_name, condition, columns, data )
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

function util.send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end

function util.RSHash()
	-- body
end     
		
function util.parse_text(src, parten, D)
	-- body
	-- src = "1000*10*10*10*10*10"
	-- D = 2
	-- parten = "(%d+%*%d+%*%d+%*?)"
	-- print( "src , parten , D is " , src , parten , D )
	assert( src and parten and D )
	local xparten = ""
	string.gsub(parten, "(%%%w%+)%%%*", function (s)
		-- body
		xparten = xparten .. "(" .. s .. ")" .. "%*"
	end)
	xparten = xparten .. "?"
	local r = {}
	string.gsub(src, parten, function (s)
		-- body
		local t = {}
		for i=1,D do
			local x = string.gsub(s, xparten, string.format("%%%d", i))
			table.insert(t, assert(tonumber(x)))
		end
		table.insert(r, t)
	end)
	return r
end 		
			
local function collect_info_from_g_role_effect( bufferid , ttotal )
	assert( bufferid and ttotal )

	gre = skynet.call( ".game" , "lua" , "query_g_role_effect" , bufferid )
	assert( gre )

	local i = 1
	while i <= 8 do
		local property_id = "property_id" .. i
		local value = "value" .. i

		local index = gre[ property_id ] 
		assert( index )
		print( index , gre[ value ] )
		if 0 ~= index then
			ttotal[ index ] = ttotal[ index ] + gre[ value ]
		end
		i = i + 1
	end		
end			
	--[[ if online ( user , nil , propertyname ) , if not online ( nil , uid , propertyname )                  ]]
function util.get_total_property( user , uid )   -- zhijie ti sheng zhan dou li gu ding zhi hai mei you ,  
	local uequip
	local role 
	local roles
	local u
 		
 	local tmpname = propertyname

	if user then
		uequip = assert( user.u_equipmentmgr.__data )
		role = user.u_rolemgr:get_by_csv_id( user.c_role_id )	
		roles = user.u_rolemgr.__data
		u = user
	else    
		local sql = string.format( "select * from u_equipment where user_id = %s " , uid )
		uequip = skynet.call( util.random_db() , "lua" , "command" , "query" , sql )
		assert( uequip )
 		sql = string.format( "select * from u_role where user_id = %s " , uid )
 		print( sql )
 		roles = skynet.call( util.random_db() , "lua" , "command" , "query" , sql )
 		assert( roles )
		
 		if "king" == propertyname then
 			tmpname = "blessing"
 		end

 		sql = string.format( "select c_role_id , combat , defense , critical_hit , blessing , ifxilian from users where csv_id = %s " , uid )
		print( sql )
		local tmp = skynet.call( util.random_db() , "lua" , "command" , "query" , sql )

		u = tmp[ 1 ]
		assert( u )

 		for k , v in pairs( roles ) do
 			print( k , v , v.csv_id , u.c_role_id )
 			if v.csv_id == u.c_role_id then
 				role = v
 				print( "find the role ********************************" )
 				break
 			end	
 		end
 		assert( role )
	end 

	----all equipment property
	local ttotal = { 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 }
	local tproperty = { "combat" , "defense" , "critical_hit" , "king" }

	for k , v in ipairs( tproperty ) do
		local probability = v .. "_probability"
		print( "property is ***************************************" , probability )
		for kk , vv in pairs( uequip ) do
			if 0 ~= vv[ v ] then 
				ttotal[ k ] = ttotal[ k ] + vv[ v ]
				ttotal[ k  + 4 ] = ttotal[ k + 4 ] + vv[ probability ]
			end
		end		
	end     

	-- role battle property
	collect_info_from_g_role_effect( role.battle_buffer_id , ttotal )

	-- xilian property
	if 1 == u.ifxilian then
		local i = 1 
		while i <= 5 do
			local property_id = "property_id" .. i
			local value = "value" .. i
			local index = role[ property_id ]
			if 0 ~= index then
				ttotal[ index ] = ttotal[ index ] + role[ value ]
			end

			i = i + 1
		end 
	end     

	--kungfu property
	local i = 1
	while i <= 7 do 
		local sk_csv_id = "k_csv_id" .. i
		local ik_csv_id = role[ sk_csv_id ]

		if 0 ~= ik_csv_id then
			local gk = skynet.call( ".game" , "lua" , "query_g_kungfu" , ik_csv_id )
			assert( gk )

			collect_info_from_g_role_effect( gk.buff_id , ttotal )
		end 

		i = i + 1 
	end     

	--rolecollect property
	for k , v in pairs( roles ) do
		collect_info_from_g_role_effect( v.gather_buffer_id , ttotal )
	end
	--basic property
	ttotal[ 1 ] = ttotal[ 1 ] + u.combat
	ttotal[ 2 ] = ttotal[ 2 ] + u.defense
	ttotal[ 3 ] = ttotal[ 3 ] + u.critical_hit
	ttotal[ 4 ] = ttotal[ 4 ] + u.blessing

	local result = { }
	local i = 1
	while i <= 4 do
		table.insert( result , math.floor( ( ttotal[ i ] * ( 1 + ttotal[ i + 4 ] / 100 ) ) ) )
		i = i + 1
	end	  

	print( "final combat and percent is ************" , result[ 1 ] , result[ 2 ] , result[ 3 ] , result[ 4 ] )

	return result
end  			
			
return util 
	