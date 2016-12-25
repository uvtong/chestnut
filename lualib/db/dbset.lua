local skynet = require "skynet"
local query = require "query"
local json = require "cjson"
local sd = require "sharedata"
local stm = require "stm"
local sd_cache = {}

local cls = class("dbset")

function cls:ctor(env, dbctx, ... )
	-- body
	self._env = env
	self._dbctx = dbctx
	self._data = {}
	self._count = 0
	self._pk = {}
	self._searchs = {}
	return self
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

-- find
function cls:find(pk, ... )
	-- body
	return self._pk[pk]
end

function cls:find_and(k1, k2, ... )
	-- body
end

function cls:update_db_all( ... )
	-- body
	for k,v in pairs(self._data) do
		v:update_db()
	end
end

function cls:update_db(entity, ... )
	-- body
	entity:update_db()
end

function cls:insert_db(entity, ... )
	-- body
	table.insert(self._data, entity)
	self._pk[entity:pk()] = entity
	entity:insert_db()
end

return cls
