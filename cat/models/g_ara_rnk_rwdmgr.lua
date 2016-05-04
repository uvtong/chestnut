local query  = require "query"
local db_common = require "db_common"
local assert = assert
local type   = type

local _M     = {}
_M.__data    = {}
_M.__count   = 0
_M.__cap     = 0
_M.__user_id = 0
_M.__tname   = "g_ara_rnk_rwd"
_M.__head    = {
seri = {
	pk = false,
	fk = false,
	uq = false,
	t = "number",
},csv_id = {
	pk = false,
	fk = false,
	uq = false,
	t = "number",
},reward = {
	pk = false,
	fk = false,
	uq = false,
	t = "string",
},}


local model = {
	__index = function (t, key)
		-- body
		assert(key)
		return t.fields[key].v
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
			local columns_str = "("
			local values_str = "("
			local value
			for k,v in pairs(t.fields) do
				columns_str = columns_str .. k .. ", "
				if v.t == "string" then
					value = "\'" .. v.v .. "\'"
				end
				values_str = values_str .. value .. ", "
			end
			columns_str = string.gsub(columns_str, "(.*)%,%s$", "%1)")
			values_str = string.gsub(values_str, "(.*)%,%s$", "%1)")
			local sql = string.format("insert into %s ", t.table_name) .. columns_str .. " values " .. values_str .. ";"
			query.insert_sql(t.table_name, sql, query.DB_PRIORITY_2)
		elseif func == "update" then
			local columns_str = "set "
			local condition_str = ""
			for k,v in pairs(t.fields) do
				if v.uq then
					if v.t == "string" then
						condition_str = condition_str..string.format("%s = \"%s\"", k, v.v).." and "
					elseif v.t == "number" then
						condition_str = condition_str..string.format("%s = %d", k, v.v).." and "
					else
						assert(false)
					end
				elseif v.pk then
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
			query.update(t.table_name, sql, query.DB_PRIORITY_2)
		end
	end
}

function _M.create(P)
	assert(P)
	local t = { table_name="g_ara_rnk_rwd", fields = {
	seri = { c = 0, v = nil },
	csv_id = { c = 0, v = nil },
	reward = { c = 0, v = nil },
}
}
	setmetatable(t, model)
	for k,v in pairs(t.fields) do
		t[k] = assert(P[k])
	end
	return t
end	

function _M:add(u)
 	-- body
 	assert(u)
 	assert(self.__data[u.csv_id] == nil)
 	self.__data[u.csv_id] = u
 	self.__count = self.__count + 1
end

function _M:get_by_csv_id(csv_id)
	-- body
	return self.__data[csv_id]
end

function _M:delete_by_csv_id(csv_id)
	assert(self.__data[csv_id])
	self.__data[csv_id] = nil
	self.__count = self.__count - 1
end

function _M:get_count()
	-- body
	return self.__count
end

function _M:get_cap()
	-- body
	return self.__cap
end

function _M:clear()
	-- body
	self.__data = {}
	self.__count = 0
end

function _M:update_db(priority)
	-- body
	assert(priority)
	if self.__count > 0 then
		for k,v in pairs(self.__data) do
			v("update")
		end
	end
end

return _M
