local query = require "query"
local json = require "cjson"
local sharedata = require "sharedata"
local stm = require "stm"
local sd_cache = {}

local function get_row_db(t, pk)
	-- body
	-- assert(t.__head[t.__pk].pk == true)
	local sql
	if t.__head[t.__pk].t == "string" then
		sql = string.format("select * from %s where %s = \"%s\"", t.__tname, t.__pk, pk)
	elseif t.__head[t.__pk].t == "number" then
		sql = string.format("select * from %s where %s = %d", t.__tname, t.__pk, pk)
	else
		assert(false)
	end
	local r = query.read(t.__rdb, t.__tname, sql)
	return r[1]
end

local function set_row_cache(t, pk, value)
	-- body
	assert(type(pk) == t.__head[t.__pk].t)
	local k
	if t.__head[t.__pk].t == "string" then
		k = t.__tname..":"..pk
	elseif t.__head[t.__pk].t == "number" then
		k = t.__tname..":"..string.format("%d", pk)
	end
	local v = json.encode(value)
	query.set(t.__wdb, k, v)
end

local function get_row_cache(t, pk)
	-- body
	assert(type(pk) == t.__head[t.__pk].t)
	local k
	if t.__head[t.__pk].t == "string" then
		k = t.__tname..":"..pk
	elseif t.__head[t.__pk].t == "number" then
		k = t.__tname..":"..string.format("%d", pk)
	end
	local v = query.get(t.__rdb, k)
	if v == nil then
		return nil
	else
		v = json.decode(v)
		return v
	end
end

local function get_row(t, pk)
	-- body
	local r = get_row_cache(t, pk)
	if r then
		return r
	else
		r = get_row_db(t, pk)
		return r
	end
end

-- this function 
local function load_db_to_cache(t, key, value)
	-- body
	local sql
	if type(key) ~= "nil" then
		if type(value) == "string" then
			sql = string.format("select * from %s where %s = \"%s\"", t.__tname, key, value)
		elseif type(value) == "number" then
			sql = string.format("select * from %s where %s = %d", t.__tname, key, value)
		else
			assert(false)
		end
	else
		sql = string.format("select * from %s", t.__tname)
	end
	local r = query.read(t.__rdb, t.__tname, sql)
	for i,v in ipairs(r) do
		local pk = v[t.__pk]
		set_row_cache(t, pk, v)
	end
	return r
end

local function load_db(t, key, value)
	-- body
	local sql
	if type(key) ~= "nil" then
		if type(value) == "string" then
			sql = string.format("select * from %s where %s = \"%s\"", t.__tname, key, value)
		elseif type(value) == "number" then
			sql = string.format("select * from %s where %s = %d", t.__tname, key, value)
		else
			assert(false)
		end
	else
		sql = string.format("select * from %s", t.__tname)
	end
	local r = query.read(t.__rdb, t.__tname, sql)
	for i,v in ipairs(r) do
		local o = t.create(v)
		t:add(o)
	end
end

local function load_cache(t, key, value)
	-- body
	local r = load_db_to_cache(t, key, value)
	for k,v in pairs(r) do
		local o = t.create(v)
		t:add(o)
	end
end

local function load_db_to_sd()
	-- body
	local sql
	if type(key) ~= "nil" then
		if type(value) == "string" then
			sql = string.format("select * from %s where %s = \"%s\"", t.__tname, key, value)
		elseif type(value) == "number" then
			sql = string.format("select * from %s where %s = %d", t.__tname, key, value)
		else
			assert(false)
		end
	else
		sql = string.format("select * from %s", t.__tname)
	end
	local r = query.read(t.__rdb, t.__tname, sql)
	for i,v in ipairs(r) do
		local key
		local pk = v[t.__pk]
		local head = t.__head[t.__pk]
		if head.t == "string" then
			key = t.__tname..":"..pk
		elseif head.t == "number" then
			key = t.__tname..":"..string.format("%d")
		else
			assert(false)
		end
		sharedata.new(key, v)
	end
end

local function sd(k, sub)
	-- body
	assert(k and (type(k) == "string"))
	local r = sharedata.query(k)
	if sub then
		return r[sub]
	else
		return r
	end
end

local function load_db_to_stm()
	-- body
	local sql
	if type(key) ~= "nil" then
		if type(value) == "string" then
			sql = string.format("select * from %s where %s = \"%s\"", t.__tname, key, value)
		elseif type(value) == "number" then
			sql = string.format("select * from %s where %s = %d", t.__tname, key, value)
		else
			assert(false)
		end
	else
		sql = string.format("select * from %s", t.__tname)
	end
	local r = query.read(t.__rdb, t.__tname, sql)
	for i,v in ipairs(r) do
		local key
		local pk = v[t.__pk]
		local head = t.__head[t.__pk]
		if head.t == "string" then
			key = t.__tname..":"..pk
		elseif head.t == "number" then
			key = t.__tname..":"..string.format("%d", pk)
		else
			assert(false)
		end
	end
end

local function load_cache_to_sd()
	-- body
end

local function load_cache_to_stm( ... )
	-- body
end

local function load_data_to_stm(ctx, child)
	-- body
	if t.__stm then
		-- ctx.__data
		local r = {}
		for k,v in pairs(t.__data) do
			r[k] = v("load_data_to_stm")
		end
	end
end

local function load_stm_to_data(ctx, child)
	-- body
	if t.__stm then
	end
end

local function update(t, ...)
	-- body
	for k,v in pairs(t.__data) do
		if v.__col_updated > 2 then
			v("update")
		end
	end
end

_M = {
	__index = function (t, key) 
	end,
	__call = function (t, func, ...)
		-- body
		if func == "get_row" then
			get_row(t, ...)
		elseif func == "load_db_to_cache" then
			load_db_to_cache(t, ...)
		elseif func == "load_db" then
			load_db(t, ...)
		elseif func == "load_cache" then
			load_cache(t, ...)
		elseif func == "update" then
			update(t, ...)
		end
	end
}

return _M