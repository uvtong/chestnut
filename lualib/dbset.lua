local query = require "query"
local json = require "cjson"
local sd = require "sharedata"
local stm = require "stm"
local sd_cache = {}

local cls = class("dbset")

function cls:ctor(env, dbctx, rdb, wdb, ... )
	-- body
	self._env = env
	self._dbctx = dbctx
	self._rdb = rdb
	self._wdb = wdb
	return self
end

function cls:get_row_db(pk_v)
	-- body
	assert(pk)
	assert(self._head[self._pk].pk == true)
	local sql
	if self._head[self._pk].t == "string" then
		sql = string.format("select * from %s where %s = '%s'", self._tname, self._pk, pk_v)
	elseif self._head[self._pk] == "number" then	
		sql = string.format("select * from %s where %s = %d", self.__tname, self.__pk, pk_v)
	else
		assert(false)
	end
	local r = query.read(t.__rdb, t.__tname, sql)
	if r and #r > 0 then
		return r[1]
	else
	end
end 
    
function cls:get_row_cache(pk)
	-- body
	local key
	if self._head[self._pk].t == "string" then
		assert(self._head[self._pk].t == type(pk))
		key = self.__tname..":"..pk
	elseif self._head[self._pk].t == "number" then
		assert(self._head[self._pk].t == type(pk))
		key = self.__tname..":"..string.format("%d", pk)
	end
	local rdb = self._rdb
	local v = query.get(rdb, key)
	if v == nil then
		return nil
	else
		v = json.decode(v)
		return v
	end
end

function cls:get_row(pk)
	-- body
	if self._data[pk] then
		return self._data[pk]
	end

	local r = self:get_row_cache(pk)
	if r then
		return r
	end
	local r = self:get_row_db(pk)
	if r then
		return r
	end
end

function cls:set_row_cache(key)
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

function cls:set_row(key, value, ... )
	-- body
end

-- this function 
function cls:load_db_to_cache(pk)
	-- body

	if t.__head[t.__pk].t == "number" then
		local sql = string.format("select * from %s where %s = %d", t.__tname, t.__pk, pk)
		local r = query.read(r.__rdb, t.__tname, sql)
		assert(#r == 1)
		local k = string.format("%s:%d", t.__tname, pk)
		local v = json.encode(r[1])
		query.set(k, v)
	end
end     

function cls.load_db_to_data(t, key, value, ... )
	-- body
	local sql
	if key ~= nil then
		if type(key) == "string" then
			if key == "pk" then
				if t.__head[t.__pk].t == "string" then
					assert(type(value) == "string")
					sql = string.format("select * from %s where `%s` = \"%s\"", t.__tname, t.__pk, value)
				elseif t.__head[t.__pk].t == "number" then
					print(key, value, t.__tname)
					assert(type(value) == "number")
					sql = string.format("select * from %s where `%s` = %d", t.__tname, t.__pk, value)
				else
					assert(false)
				end
			elseif key == "fk" then
				if t.__head[t.__fk].t == "string" then
					assert(type(value) == "string")
					sql = string.format("select * from %s where `%s` = \"%s\"", t.__tname, t.__fk, value)
				elseif t.__head[t.__fk].t == "number" then
					assert(type(value) == "number")
					sql = string.format("select * from %s where `%s` = %d", t.__tname, t.__fk, value)
				else
					assert(false)
				end
			end
		elseif type(key) == "table" then
			local seg = ""
			for k,v in pairs(key) do
				if t.__head[k].t == "string" then
					seg = seg..string.format("`%s` = %s and ", k, v)
				elseif t.__head[k].t == "number" then
					seg = seg..string.format("`%s` = %d and ", k, v)
				end
			end
			seg = string.gsub(seg, "(.*)%sand%s$", "%1)")
			sql = string.format("select * from %s where %s", t.__tname, seg)
		else
			assert(false)
		end
	else
		sql = string.format("select * from %s", t.__tname)
	end
	print("hubing123", sql)
	local entity = require("models/"..t.__entity)
	local r = query.read(t.__rdb, t.__tname, sql)

	for i,v in ipairs(r) do
		local o = entity.new(t, v)
		t:add(o)
	end
end

function cls.load_db(t, key, value)
	-- body
	t:load_db_to_data(key, value)
	-- t:load_data_to_cache()
end

function cls.load_data_to_cache(t, pk, ... )
	-- body
	if pk then
		local v = t:get(pk)
		v:set()
	else
		for k,v in pairs(t.__data) do
			v:set()
		end
	end
	t.__cache_flag = true
end

function cls.load_cache(t, pk)
	-- body
	assert(pk)
	if t.__head[t.__pk].t == "number" then
		local k = string.format("%s:%d", t.__tname, pk)
		local v = query.get(t.__rdb, k)
		if v then
			v = json.decode(v)
			local r = t:create_entity(v)
			t:add(r)
		else
			t:load_db("pk", pk)
			t:load_data_to_cache(pk)
		end
	end
end

function cls.load_data_to_sd(t)
	-- body
	local l = {}
	for k,v in pairs(t.__data) do
		v:load_data_to_sd()
		local pk = v:get_field(v.__pk)
		table.insert(l, pk)
	end
	sd.new(t.__tname, l)
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

function cls.load_remote(t, p, ... )
	-- body
	local entity = require("models/"..t.__entity)
	for i,v in ipairs(p) do
		local o = entity.new(t, v)
		t:add(o)
	end
end

function cls:update_cache(t, ... )
	-- body
	for k,v in pairs(t.__data) do
		v:set()
	end
end

function cls:update_db(t, ... )
	-- body
	self:update()
end

function cls:update( ...)
	-- body
	if t.__cache_flag then
		for k,v in pairs(t.__data) do
			v:update()
			v:set()
		end
	else
		for k,v in pairs(t.__data) do
			v:update()
		end	
	end
	-- if t.self_updata then
	-- 	t:self_updata()
	-- end
end

function cls:update_wait( ... )
	-- body
	for k,v in pairs(self._data) do
		v:update_wait()
	end
end

function cls:create(p, ...)
	-- body
	return self:create_entity(p)

end 
	
function cls:create_entity(p)
	-- body
	local entity = require("models/" .. self._entity_cls)
	local r = entity.new(self._env, self._dbctx, self, self._rdb, self._wdb, p)
	return r
end 
	
function cls.set_user(self, user, ... )
	-- body
	self._user = user
end 

function cls.get_user(self, ... )
	-- body
	return self._user
end
	
function cls.genpk(self, csv_id)
	-- body
	if #self.__fk == 0 then
		return genpk_1(csv_id)
	else
		local user_id = self:get_user():get_csv_id()
		return genpk_2(user_id, csv_id)
	end
end 
	
function cls:add(value)
 	-- body
 	assert(value.__cname == self._entity_cls)
 	local pk = value.fields[self._pk]
 	self._data[pk] = value
 	self._count = self._count + 1
end 
	
function cls:get(pk)
	-- body
	if self._data then
		return self._data[pk]
	else
		error "_data is empty"
	end
end 
	
function cls:delete(pk)
	-- body
	if self._data then
		self._data[pk] = nil
		self._count = self._count - 1
	else
		error "_data is empty"
	end
end 

function cls:get_by_vip(csv_id, ... )
	-- body
	return self:get_by_csv_id(csv_id)
end

function cls:get_by_chapter(csv_id, ... )
	-- body
	return self:get_by_csv_id(csv_id)
end

function cls:get_by_csv_id(csv_id)
	-- body
	local pk = self:genpk(csv_id)
	return self:get(pk)
end 
	
function cls:delete_by_csv_id(self, csv_id)
	local pk = self:genpk(csv_id)
	self:delete(pk)
end 
	
function cls:get_count()
	-- body
	return self._count
end 
	
function cls:get_cap()
	-- body
	return self._cap
end

function cls:get_data( ... )
	-- body
	return self._data
end

function cls:clear()
	-- body
	self.__data = {}
	self.__count = 0
end

return cls
