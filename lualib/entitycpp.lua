local query = require "query"
local json = require "cjson"
local sd = require "sharedata"

local cls = class("entitycpp")

function cls.set(t, ...)
	-- body
	local v = json.encode(t.__fields)
	local pk = t.__fields[t.__pk]
	local k = t.__tname..":"..string.format("%d", pk)
	-- print(string.format("set cache k: %s v: %s", k, v))
	query.set(k, v)
end

function cls.insert(t, ...)
	-- body
	-- assert(t.__fields ~= nil)
	-- local columns_str = "("
	-- local values_str = "("
	-- local value
	-- for k,v in pairs(t.__head) do
	-- 	columns_str = columns_str .. k .. ", "
	-- 	if v.t == "string" then
	-- 		value = "\'" .. t.__fields[k] .. "\'"
	-- 	elseif v.t == "number" then
	-- 		value = string.format("%d", t.__fields[k])
	-- 	else
	-- 		assert("others type", k)
	-- 	end
	-- 	values_str = values_str .. value .. ", "
	-- end
	-- columns_str = string.gsub(columns_str, "(.*)%,%s$", "%1)")
	-- values_str = string.gsub(values_str, "(.*)%,%s$", "%1)")
	-- local sql = string.format("insert into %s ", t.__tname) .. columns_str .. " values " .. values_str .. ";"
	-- print(t.__wdb)
	-- query.write(t.__wdb, t.__tname, sql, query.DB_PRIORITY_1)
end

function cls.gen_update_sql(t, ... )
	-- body
	local columns_str = ""
	local keys_str = "("
	local values_str = "("
	for k,v in pairs(t.__fields) do
		keys_str = keys_str.."`"..k.."`"..", "
		local head = t.__head[k]
		if head.pk then
			if head.t == "string" then
				values_str = values_str..string.format("\"%s\", ", v)
				columns_str = columns_str..string.format("`%s` = \"%s\", ", k, v)
			elseif head.t == "number" then
				values_str = values_str..string.format("%d, ", v)
				columns_str = columns_str..string.format("`%s` = %d, ", k, v)
			else
				assert(false)
			end
		else
			if true or t.__ecol_updated[k] > 0 then
				t.__ecol_updated[k] = 0
				if head.t == "string" then
					values_str = values_str..string.format("\"%s\", ", v)
					columns_str = columns_str..string.format("`%s` = \"%s\", ", k, v)
				elseif head.t == "number" then
					values_str = values_str..string.format("%d, ", v)
					columns_str = columns_str..string.format("`%s` = %d, ", k, v)
				else
					assert(false)
				end
			end
		end
	end
	keys_str = string.gsub(keys_str, "(.*)%,%s$", "%1")..")"
	values_str = string.gsub(values_str, "(.*)%,%s$", "%1")..")"
	columns_str = string.gsub(columns_str, "(.*)%,%s$", "%1")	
	local sql = string.format("insert into %s ", t.__tname)..keys_str.." values "..values_str.." on duplicate key update "..columns_str..";"
	return sql
end

function cls.update(t, ...)
	-- body
	assert(t.__fields ~= nil)
	if true or t.__col_updated > 1 then
		-- print("*************************1")
		t.__col_updated = 0
		-- t:set(t, ...)
		local sql = t:gen_update_sql()
		-- print(sql)
		query.write(t.__wdb, t.__tname, sql, query.DB_PRIORITY_3)
		
	else 	
		local tmp_sql = {}
		local sql_first_part = string.format("call " .. "qy_insert_" .. t.__tname .. " (" )
		table.insert(tmp_sql, sql_first_part)
		assert(t.__head_ord ~= nil)

		local counter = 0
		for k, v in ipairs(t.__head_ord) do
			assert(nil ~= t.__fields[v])
			if counter > 0 then
				table.insert(tmp_sql, ", ")
			else
				counter = counter + 1
			end
			
			if type(t.__fields[v]) == "string" then
				table.insert(tmp_sql, string.format("'%s'",t.__fields[v] ))
			else
				table.insert(tmp_sql, string.format("%s", t.__fields[v]))
			end
		end
		table.insert(tmp_sql, ")")
		local sql = table.concat(tmp_sql)
		print(sql)
		query.write(t.__wdb, t.__tname, sql, query.DB_PRIORITY_3)
	end
end

function cls.update_wait(t, ...)
	assert(t.__fields ~= nil)
	if true then
		t:update()
		-- t.__col_updated = 0
		-- local sql = t:gen_update_sql()
		-- query.read(t.__wdb, t.__tname, sql)
	end
end

function cls.update_field()
	-- body
end
		
function cls.load_data_to_stm(t, child)
	local r = {}
	for k,v in pairs(t) do
		if string.match("^%w+_%w+mgr$", k) then
			r.k = ctx.k("load_data_to_stm")
		end
	end 
	return r
end

function cls.load_data_to_sd(t, ... )
	-- body
	local pk = t.__fields[t.__pk]
	if t.__head[t.__pk].t == "number" then
		local key = string.format("%s:%d", t.__tname, pk)
		sd.new(key, t.__fields)
	end
end

return cls