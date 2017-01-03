local query = require "query"
local json = require "cjson"
local sd = require "sharedata"
local log = require "log"
local field = require "db.field"

local cls = class("entity")

function cls:ctor(env, dbctx, set, ... )
	-- body
	self._env = env
	self._dbctx = dbctx
	self._set = set
	self._fields = {}
	self._pk = nil
 	return self
end

function cls:pk( ... )
	-- body
	return self._pk.value
end
																																								
function cls:insert_cache( ...)
	local k
	local v = json.encode(self._fields)
	local pk = self._fields[self._pk]
	if type(pk) == "number" then
		k = string.format("%s:%d", self._tname, pk)	
	elseif type(pk) == "string" then
		k = string.format("%s:%s", self._tname, pk)	
	end
	local wdb = self._wdb
	query.set(wdb, k, v)
	query.hset(wdb, self._tname, pk, pk)
	log.info("insert cache %s, %s", self._tname, pk)
end

function cls:update_cache( ... )
	-- body
	local k
	local v = json.encode(self._fields)
	local pk = self._fields[self._pk]
	if type(pk) == "number" then
		k = string.format("%s:%d", self._tname, pk)	
	elseif type(pk) == "string" then
		k = string.format("%s:%s", self._tname, pk)	
	end
	local wdb = self._wdb
	query.set(wdb, k, v)
	query.hset(wdb, self._tname, pk, pk)
	log.info("update cache %s, %s", self._tname, pk)
end

function cls:update_db(tname, ... )
	-- body
	if tname == nil then
		tname = self._set._tname
	end
	local set = ""
	for i,v in ipairs(self._fields) do
		if v:changed() then
			if v:dt() == field.data_type.integer then
				set = set .. v.name .. string.format("=%d,", v.value)
			elseif v:dt() == field.data_type.biginteger then
				set = set .. v.name .. string.format("=%d,", v.value)
			end
		end
	end
	if set == "" then
		return
	else
		set = string.sub(set, 1, #set-1)
		local where = ""
		if self._pk:dt() == field.data_type.integer then
			where = string.format("%s=%d", self._pk.value)
		elseif self._pk:dt() == field.data_type.biginteger then
			where = string.format("%s=%d", self._pk.value)
		end
		local sql = string.format("update %s set %s where %s;", tname, set, where)
		log.info(sql)
		query.insert(tname, sql)
	end
end

function cls:insert_db(tname, ... )
	-- body
	if tname == nil then
		tname = self._set._tname
	end
	local keys = ""
	local values = ""
	for i,v in ipairs(self._fields) do
		keys = keys .. v.name .. ","
		if v:dt() == field.data_type.integer then
			values = values .. string.format("%d,", v.value)
		elseif v:dt() == field.data_type.biginteger then
			values = values .. string.format("%d,", v.value)
		elseif v:dt() == field.data_type.char then
			values = values .. string.format("'%s',", v.value)
		end
	end
	keys = string.sub(keys, 1, #keys-1)
	values = string.sub(values, 1, #values-1)
	local noexists = ""
	if self._pk:dt() == field.data_type.integer then
		noexists = string.format("select * from %s where %s=%d", self._pk.name, tname, self._pk.name, self._pk.value)
	elseif self._pk:dt() == field.data_type.biginteger then
		noexists = string.format("select * from %s where %s=%d", self._pk.name, tname, self._pk.name, self._pk.value)
	end
	local sql = string.format("insert into %s (%s) values (%s) where no exists(%s);", tname, keys, values, noexists)
	log.info(sql)
	query.insert(tname, sql)
end

return cls
