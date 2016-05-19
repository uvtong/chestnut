local query = require "query"
local json = require "cjson"
local sharedata = require "sharedata"
local stm = require "stm"
local sd_cache = {}

local cls = class("modelmgrcpp")

function cls.get_row_db(t, pk)
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

function cls.set_row_cache(t, pk, value)
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

function cls.get_row_cache(t, pk)
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

function cls.get_row(t, pk)
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
function cls.load_db_to_cache(t, key, value)
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

function cls.load_db(t, key, value)
	-- body
	local sql
	if key ~= nil then
		if key == "pk" then
			if t.__head[t.__pk].t == "string" then
				assert(type(value) == "string")
				sql = string.format("select * from %s where %s = \"%s\"", t.__tname, t.__pk, value)
			elseif t.__head[t.__pk].t == "number" then
				assert(type(value) == "number")
				sql = string.format("select * from %s where %s = %d", t.__tname, t.__pk, value)
			else
				assert(false)
			end
		elseif key == "fk" then
			print(t.__fk)
			if t.__head[t.__fk].t == "string" then
				assert(type(value) == "string")
				sql = string.format("select * from %s where %s = \"%s\"", t.__tname, t.__fk, value)
			elseif t.__head[t.__pk].t == "number" then
				assert(type(value) == "number")
				sql = string.format("select * from %s where %s = %d", t.__tname, t.__fk, value)
			else
				assert(false)
			end
		else
			assert(false)
		end
	else
		sql = string.format("select * from %s", t.__tname)
	end
	local entity = require("models/"..t.__entity)
	local r = query.read(t.__rdb, t.__tname, sql)
	for i,v in ipairs(r) do
		local o = entity.new(t, v)
		t:add(o)
	end
end

function cls.load_cache(t, key, value)
	-- body
	local r = load_db_to_cache(t, key, value)
	for k,v in pairs(r) do
		local o = t.create(v)
		t:add(o)
	end
end

function cls.load_db_to_sd(t)
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

function cls.sd(t, k, sub)
	-- body
	assert(k and (type(k) == "string"))
	local r = sharedata.query(k)
	if sub then
		return r[sub]
	else
		return r
	end
end

function cls.load_db_to_stm(t)
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

function cls.load_cache_to_sd(t)
	-- body
end

function cls.load_cache_to_stm(t, ... )
	-- body
end

function cls.load_data_to_stm(t, child)
	-- body
	if t.__stm then
		-- ctx.__data
		local r = {}
		for k,v in pairs(t.__data) do
			r[k] = v("load_data_to_stm")
		end
	end
end

function cls.load_stm_to_data(t, child)
	-- body
	if t.__stm then
	end
end

function cls.update(t, ...)
	-- body
	for k,v in pairs(t.__data) do
		if v.__col_updated > 2 then
			v("update")
		end
	end
	if t.self_updata then
		t:self_updata()
	end
end

return cls