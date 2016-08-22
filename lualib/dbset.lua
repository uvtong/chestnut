local skynet = require "skynet"
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
	self._cache_flag = false
	return self
end

function cls:set_cache_flag(flag, ... )
	-- body
	self._cache_flag = flag
end

-- this function pull
function cls:load_cache_to_data(condition, ... )
	-- body
	local rdb = self._rdb
	local r = query.get(rdb, self._tname)
	for k,v in pairs(r) do
		if type(v) == "number" then
			local key = string.format("%s:%d", self._tname, v)
			local row = query.get(rdb, key)
			local entity = self:create_entity(row)
			self:add(entity)
		end
	end
end

function cls:load_db_to_data(condition, ... )
	-- body
	local sql
	if false then
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
		sql = string.format("select * from %s", self._tname)
	end
	skynet.error(sql)
	local rdb = self._rdb
	local table_name = self._tname
	local r = query.read(rdb, table_name, sql)
	for i,v in ipairs(r) do
		local entity = self:create_entity(v)
		self:add(entity)
	end
end

function cls:load_data_to_sd()
	-- body
	local l = {}
	for k,v in pairs(self._data) do
		v:load_data_to_sd()
		local pk = v:get_field(v._pk)
		table.insert(l, pk)
	end
	sd.new(self._tname, l)
end

function cls:load_data_to_remote(p, ... )
	-- body
	for i,v in ipairs(p) do
		local o = self:create_entity(v)
		self:add(o)
	end
end

function cls:update_cache( ... )
	-- body
	for k,v in pairs(self._data) do
		v:set()
	end
end

function cls:update_cache_wait( ... )
	-- body
end

function cls:update_db( ... )
	-- body
	for k,v in pairs(self._data) do
		v:update()
	end
end

function cls:update_db_wait( ... )
	-- body
end

function cls:update( ...)
	-- body
	if self._cache_flag then
		self:update_cache()
		self:update_db()
	else
		self:update_db()
	end
end

function cls:update_wait( ... )
	-- body
	if self._cache_flag then
		self:update_cache()
		self:update_db()
	else
		self:update_db()
	end
end

function cls:insert_cache( ... )
	-- body
end

function cls:insert_db( ... )
	-- body
end

function cls:insert( ... )
	-- body
	if self._cache_flag then
		self:insert_cache()
		self:insert_db()
	else
		self:insert_db()
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
	
function cls.genpk(self, csv_id)
	-- body
	if #self.__fk == 0 then
		return genpk_1(csv_id)
	else
		local user_id = self:get_user():get_csv_id()
		return genpk_2(user_id, csv_id)
	end
end 

-- manipulat data
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
