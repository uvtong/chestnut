local query = require "query"
local json = require "cjson"
local sd = require "sharedata"
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
function cls.load_db_to_cache(t, pk)
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
					assert(type(value) == "number")
					sql = string.format("select * from %s where `%s` = %d", t.__tname, t.__pk, value)
				else
					assert(false)
				end
			elseif key == "fk" then
				print(t.__fk)
				if t.__head[t.__fk].t == "string" then
					assert(type(value) == "string")
					sql = string.format("select * from %s where `%s` = \"%s\"", t.__tname, t.__fk, value)
				elseif t.__head[t.__pk].t == "number" then
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
	local entity = require("models/"..t.__entity)
	local r = query.read(t.__rdb, t.__tname, sql)
	for i,v in ipairs(r) do
		local o = entity.new(t, v)
		t:add(o)
	end
end

function cls.load_db(t, key, value)
	-- body
	if type(key) == nil then
		if not t:load_cache() then
			t:load_db_to_data()
			t:load_data_to_cache()
		end
	else
		t:load_db_to_data(key, value)
		t:load_data_to_cache()
	end
end

function cls.load_data_to_cache(t, ... )
	-- body
	for k,v in pairs(t.__data) do
		v:set()
	end
end

function cls.load_cache(t, pk)
	-- body
	if pk == nil then
		local h = query.hget(t.__rdb, t.__tname)
		for k,v in pairs(h) do
			local k = string.format("%s:%d", t.__tname, v)
			if k == nil then
				return false
			end
			local v = query.get(k)
			if v then
				v = json.decode(v)
				local r = t:create_entity(v)
				t:add(r)
			else
				return false
			end
		end
		return true
	else
		if t.__head[t.__pk].t == "number" then
			local k = string.format("%s:%d", t.__tname, pk)
			local v = query.get(k)
			if v then
				v = json.decode(v)
				local r = t:create_entity(v)
				t:add(r)
			else
				t:load_db("pk", pk)
			end
		end
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
		sd.new(key, v)
	end
end

function cls.load_data_to_sd(t)
	-- body
	local v = {}
	for k,v in pairs(t.__data) do
		v:load_data_to_sd()
		local pk = v:get_field(v.__pk)
		table.insert(v, pk)
	end
	sd.new(t.__tname, v)
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

function cls.update(t, ...)
	-- body
	for k,v in pairs(t.__data) do
		v:update()
		-- if v.__col_updated > 2 then
		-- 	v("update")
		-- end
	end
	-- if t.self_updata then
	-- 	t:self_updata()
	-- end
end

function cls.update_wait(t, ... )
	-- body
	for k,v in pairs(t.__data) do
		v:update_wait()
	end
end

function cls.create(t, p, ...)
	-- body
	return t:create_entity(p)
end 
	
function cls.create_entity(t, p)
	-- body
	local entity = require("models/"..t.__entity)
	local r = entity.new(t, p)
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
	print("******************###########", self.__tname)
	if #self.__fk == 0 then
		return genpk_1(csv_id)
	else
		local user_id = self:get_user():get_csv_id()
		return genpk_2(user_id, csv_id)
	end
end 
	
function cls.add(self, u)
 	-- body
 	assert((u and self.__pk), self.__pk)
 	assert(self.__data[ u[self.__pk] ] == nil, u[self.__pk], self.__data[ u[self.__pk] ])
 	self.__data[ u[self.__pk] ] = u
 	self.__count = self.__count + 1
end 
	
function cls.get(self, pk)
	-- body
	return self.__data[pk]
	-- if self.__data[pk] then
	-- 	return self.__data[pk]
	-- else
	-- 	assert(false, self.__tname, pk)
	-- 	-- local r = self("load", pk)
	-- 	-- if r then
	-- 	-- 	self.create(r)
	-- 	-- 	self:add(r)
	-- 	-- end
	-- 	-- return r
	-- end
end 
	
function cls.delete(self, pk)
	-- body
	if nil ~= self.__data[pk] then
		self.__data[pk] = nil
		self.__count = self.__count - 1
	end
end 

function cls.get_by_chapter(self, csv_id, ... )
	-- body
	return self:get_by_csv_id(csv_id)
end

function cls.get_by_csv_id(self, csv_id)
	-- body
	print(self.__tname)
	local pk = self:genpk(csv_id)
	return self:get(pk)
end 
	
function cls.delete_by_csv_id(self, csv_id)
	local pk = self:genpk(csv_id)
	self:delete(pk)
end 
	
function cls.get_count(self)
	-- body
	return self.__count
end 
	
function cls.get_cap(self)
	-- body
	return self.__cap
end

function cls:get_data( ... )
	-- body
	return self.__data
end

function cls.clear(self)
	-- body
	self.__data = {}
	self.__count = 0
end

return cls
