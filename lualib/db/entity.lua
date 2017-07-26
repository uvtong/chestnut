local skynet = require "skynet"
local sd = require "skynet.sharedata"
local log = require "skynet.log"
local query = require "query"
local json = require "cjson"
local field = require "db.field"

local cls = class("entity")

function cls:ctor(env, dbctx, set, ... )
	-- body
	self._env = env
	self._dbctx = dbctx
	self._set = set
	self._fields = {}
	self._pk = nil
	self._changed = {}
 	return self
end

function cls:pk( ... )
	-- body
	return self._pk.value
end

function cls:update_cache(tname, ... )
	-- body
	if tname == nil then
		tname = self._set._tname
	end
	local suid = assert(self._env._suid)
	if #self._changed > 0 then
		local pk = self._fields[self._pk]
		local key
		for k,v in pairs(self._changed) do
			if type(pk) == "number" then
				key = string.format("%s:%d", tname, pk)	
			elseif type(pk) == "string" then
				key = string.format("%s:%s", tname, pk)
			end
			skynet.send("WATCHER", "lua", "hset", suid, key, v)
		end
		self._changed = {}
	end
end
																																								
function cls:insert_cache(tname, ...)
	if tname == nil then
		tname = self._set._tname
	end
	local suid = assert(self._env._suid)
	if #self._changed > 0 then
		local pk = self._fields[self._pk]
		local key
		for k,v in pairs(self._changed) do
			if type(pk) == "number" then
				key = string.format("%s:%d", tname, pk)	
			elseif type(pk) == "string" then
				key = string.format("%s:%s", tname, pk)
			end
			skynet.send("WATCHER", "lua", "hset", suid, key, v)
		end
		self._changed = {}
	end
end

function cls:update_db(tname, col, ... )
	-- body
	if tname == nil then
		tname = self._set._tname
	end
	local set = ""
	if col then
		local v = assert(self._fields[col])
		if v:dt() == field.data_type.integer then
			set = set .. v.name .. string.format("=%d,", v.value)
		elseif v:dt() == field.data_type.biginteger then
			set = set .. v.name .. string.format("=%d,", v.value)
		end
	else
		for i,v in ipairs(self._fields) do
			if v:changed() then
				if v:dt() == field.data_type.integer then
					set = set .. v.name .. string.format("=%d,", v.value)
				elseif v:dt() == field.data_type.biginteger then
					set = set .. v.name .. string.format("=%d,", v.value)
				end
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
		query.update(tname, sql)
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
		noexists = string.format("%s=%d", self._pk.name, self._pk.value)
	elseif self._pk:dt() == field.data_type.biginteger then
		noexists = string.format("%s=%d", self._pk.name, self._pk.value)
	end
	local sql = string.format("insert into %s (%s) values (%s) ON DUPLICATE KEY UPDATE %s;", tname, keys, values, noexists)
	log.info(sql)
	query.insert(tname, sql)
end

function cls:load_cache_to_data( ... )
	-- body
end

function cls:load_db_to_data( ... )
	-- body
end

function cls:print_info( ... )
	-- body
	log.info("print_info begin")
	for k,v in pairs(self._fields) do
		log.info("key = " .. k .. " , val = " .. v.value)
	end
	log.info("print_info end")

end

return cls
