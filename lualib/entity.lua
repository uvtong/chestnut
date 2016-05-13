local query = require "query"
local json = require "cjson"

local function set(t, ...)
	-- body
	local v = json.encode(t.__fields)
	local pk = t.__fields[t.__pk]
	local k = t.__tname..":"..string.format("%d", pk)
	-- print(string.format("set cache k: %s v: %s", k, v))
	query.set(k, v)
end

local function insert(t, ...)
	-- body
	assert(t.__fields ~= nil)
	local columns_str = "("
	local values_str = "("
	local value
	for k,v in pairs(t.__head) do
		columns_str = columns_str .. k .. ", "
		if v.t == "string" then
			value = "\'" .. t.__fields[k] .. "\'"
		elseif v.t == "number" then
			value = string.format("%d", t.__fields[k])
		else
			assert("others type", k)
		end
		values_str = values_str .. value .. ", "
	end
	columns_str = string.gsub(columns_str, "(.*)%,%s$", "%1)")
	values_str = string.gsub(values_str, "(.*)%,%s$", "%1)")
	local sql = string.format("insert into %s ", t.__tname) .. columns_str .. " values " .. values_str .. ";"
	query.write(t.__wdb, t.__tname, sql, query.DB_PRIORITY_1)
end

local function update(t, ...)
	-- body
	assert(t.__fields ~= nil)
	if t.__col_updated > 1 then
		t.__col_updated = 0
		set(t, ...)
		local columns_str = "set "
		local condition_str = ""
		for k,v in pairs(t.__fields) do
			local head = t.__head[k]
			if head.pk then
				if head.t == "string" then
					condition_str = condition_str..string.format("%s = \"%s\"", k, v.v).." and "
				elseif head.t == "number" then
					condition_str = condition_str..string.format("%s = %d", k, v.v).." and "
				else
					assert(false)
				end
			else
				if t.__ecol_updated[k] > 0 then
					t.__ecol_updated[k] = 0
					if v.t == "string" then
						columns_str = columns_str..string.format("%s = \"%s\"", k, v.v)..", "
					elseif v.t == "number" then
						columns_str = columns_str..string.format("%s = %d", k, v.v)..", "
					else
						assert(false)
					end
				end
			end
		end
		columns_str = string.gsub(columns_str, "(.*)%,%s$", "%1")
		condition_str = string.gsub(condition_str, "(.*)%sand%s$", "%1)")
		if #condition_str > 0 then	
			condition_str = " where " .. condition_str
		end
		local sql = string.format("update %s ", t.table_name) .. columns_str .. condition_str .. ";"
		query.write(t.__wdb, t.table_name, sql, query.DB_PRIORITY_3)
	end
end

local function load_data_to_stm(ctx, child)
	local r = {}
	for k,v in pairs(ctx) do
		if string.match("^%w+_%w+mgr$", k) then
			r.k = ctx.k("load_data_to_stm")
		end
	end
	return r
end

local _M = {
	__index = function (t, key)
		-- body
		-- return fields
		local r = t.__fields[key]
		if r then
			return r
		else
			return nil
		end
	end,
	__newindex = function (t, key, value)
		-- body
		assert(key and value)
		local head = t.__head[key]
		if head then
			assert(head.t == type(value), "type of the value is not correct.")
			rawset(t.__fields, key, value)
			if t.__ecol_updated[key] == 1 then -- except create
				t.__col_updated = t.__col_updated + 1
			end
			t.__ecol_updated[key] = t.__ecol_updated[key] + 1
		else
			rawset(t, key, value)
		end
	end,
	__call = function (t, func, ...)
		-- body
		if func == "insert" then
			set(t)
			insert(t)
		elseif func == "update" then
			if t.__col_updated < 1 then
				return 
			end
			set(t)
			update(t)
		else
			assert(false)
		end
	end
}

return _M