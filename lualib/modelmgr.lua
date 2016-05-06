local query = require "query"
local json = require "json"

local function load(t, pk)
	-- body
	query.select_sql_wait(t.__tname, "")
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_achievement")
	for i,v in ipairs(r) do
		local t = g_achievementmgr.create(v)
		g_achievementmgr:add(t)
	end
	game.g_achievementmgr = g_achievementmgr
end

local function m_update(t)
	-- body
	assert(t.__data)
	for k,v in pairs(t.__data) do
		if v.col_num_ued > 0 then
			v.update()
		end
	end
end

local function m_insert(t)
	-- body
end

local function insert(t, ...)
	-- body
	assert(t.__fields ~= nil)
	set(t, ...)
	local columns_str = "("
	local values_str = "("
	local value
	for k,v in pairs(t.__fields) do
		columns_str = columns_str .. k .. ", "
		if v.t == "string" then
			value = "\'" .. v.v .. "\'"
		end
		values_str = values_str .. value .. ", "
	end
	columns_str = string.gsub(columns_str, "(.*)%,%s$", "%1)")
	values_str = string.gsub(values_str, "(.*)%,%s$", "%1)")
	local sql = string.format("insert into %s ", t.__tname) .. columns_str .. " values " .. values_str .. ";"
	query.insert_sql(t.__tname, sql, query.DB_PRIORITY_3)
end

local function get_row(t, pk)
	-- body
	local sql = string.format("select * from %s where t.__pk")
end

local function get_rows(t, key, value)
	-- body
	local sql
	if type(value) == "string" then
		sql = string.format("select * from %s where %s = \"%s\"", t.__tname, key, value)
	elseif type(value) == "number" then
		sql = string.format("select * from %s where %s = %d", t.__tname, key, value)
	end
	query.select_sql_wait(t.__tname, sql, query.DB_PRIORITY_1)
end

local function get_table(t)
	-- body
	local sql = string.format("select * from %s", t.__tname)
	query.select_sql_wait()
end

local function set_cache(t, pk)
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

local function get_cache(t, pk)
	-- body
	assert(type(pk) == t.__pk.t)
	local k
	if t.__pk.t == "string" then
		k = t.__tname..":"..pk
	elseif type(pk) then
		k = t.__tname..":"..string.format("%d", pk)
	end
	local v = query.get(k)
	if v == nil then
		v = get_db(t, pk)
		if v == nil then
			return nil
		else
			v = t.create(t[1])
			t:add(v)
			set_cache(t, pk)
			return v
		end
	else
		v = json.decode(v)
		v = t.create(v)
		t:add(v)
		return v
	end
end

local function init(t, key, value)
	-- body
	if key ~= nil then
		get_rows(t, key, value)
	else
		get_table()
	end
end

_M = {
	__index = function (t, key) 
		if key == "update" then
			return update
		end
	end,

	__call = function (t, func, ...)
		-- body
	end
}

return _M