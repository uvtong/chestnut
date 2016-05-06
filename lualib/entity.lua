local query = require "query"
local json = require "json"

local function set(t, ...)
	-- body
	assert(t.__fields ~= nil)
	local tmp = {}
	local pk
	for k,v in pairs(t.__fields) do
		tmp[k] = v.v
		if t.__head[k].pk then
			pk = v.v
		end
	end
	local v = json.encode(tmp)
	local k = t.__tname..":"..string.format("%d", pk)
	query.set(k, v)
end

local function update(t, ...)
	-- body
	assert(t.__fields ~= nil)
	set(t, ...)
	local columns_str = "set "
	local condition_str = ""
	for k,v in pairs(t.__fields) do
		if t.__head[k].pk then
			if v.t == "string" then
				condition_str = condition_str..string.format("%s = \"%s\"", k, v.v).." and "
			elseif v.t == "number" then
				condition_str = condition_str..string.format("%s = %d", k, v.v).." and "
			else
				assert(false)
			end
		else
			if v.c > 1 then
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
	query.update(t.table_name, sql, query.DB_PRIORITY_3)
end

local _M = {
	__index = function (t, key)
		-- body
		assert(key)
		if key == "update" then
			return update
		elseif key == "insert" then
			return insert
		elseif key == "set" then
			return set
		else
			return t.fields[key].v
		end
	end,
	__newindex = function (t, key, value)
		-- body
		assert(key and value)
		assert(_M.__head[key])
		assert(type(value) == _M.__head[key].t)
		rawset(t.fields[key], "v", value)
		t.fields[key].c = t.fields[key].c + 1
	end,
	__call = function (t, func, ...)
		-- body
		if func == "insert" then
			
		elseif func == "update" then
			
		end
	end
}

return _M