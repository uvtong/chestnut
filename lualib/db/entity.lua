local query = require "query"
local json = require "cjson"
local sd = require "sharedata"
local log = require "log"

local cls = class("entity")

function cls:ctor(env, dbctx, set, ... )
	-- body
	self._env = env
	self._dbctx = dbctx
	self._set = set
	self.fields = {}
	self.pk = nil
 	return self
end

function cls:pk( ... )
	-- body
	return self.pk.value
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

function cls:gen_update_sql( ... )
	-- body
	local columns_str = ""
	local keys_str = "("
	local values_str = "("
	for k,v in pairs(t.__fields) do
		keys_str = keys_str.."`"..k.."`"..", "
		local head = t.__head[k]
		if head.pk then
			if head.t == "string" then
				values_str = values_str..string.format("\"%s\", ", v)
				columns_str = columns_str..string.format("`%s` = \"%s\", ", k, v)
			elseif head.t == "number" then
				values_str = values_str..string.format("%d, ", v)
				columns_str = columns_str..string.format("`%s` = %d, ", k, v)
			else
				assert(false)
			end
		else
			if true or t.__ecol_updated[k] > 0 then
				t.__ecol_updated[k] = 0
				if head.t == "string" then
					values_str = values_str..string.format("\"%s\", ", v)
					columns_str = columns_str..string.format("`%s` = \"%s\", ", k, v)
				elseif head.t == "number" then
					values_str = values_str..string.format("%d, ", v)
					columns_str = columns_str..string.format("`%s` = %d, ", k, v)
				else
					assert(false)
				end
			end
		end
	end
	keys_str = string.gsub(keys_str, "(.*)%,%s$", "%1")..")"
	values_str = string.gsub(values_str, "(.*)%,%s$", "%1")..")"
	columns_str = string.gsub(columns_str, "(.*)%,%s$", "%1")	
	local sql = string.format("insert into %s ", t.__tname)..keys_str.." values "..values_str.." on duplicate key update "..columns_str..";"
	return sql
end

function cls:update_db( ... )
	-- body
	if false or self.__col_updated > 1 then
		self.__col_updated = 0
		local sql = self:gen_update_sql()
		local wdb = self._wdb
		query.write(wdb, self._tname, sql, query.DB_PRIORITY_3)
	else 	
		local tmp_sql = {}
		local sql_first_part = string.format("call " .. "qy_insert_" .. t.__tname .. " (" )
		-- print("sql_first_part is :", sql_first_part)
		table.insert(tmp_sql, sql_first_part)
		assert(t.__head_ord ~= nil)
		local counter = 0
		for k, v in ipairs(t.__head_ord) do
			assert(nil ~= t.__fields[v.cn])
			if counter > 0 then
				table.insert(tmp_sql, ", ")
			else
				counter = counter + 1
			end
		
			if type(t.__fields[v.cn]) == "string" then
				table.insert(tmp_sql, string.format("'%s'",t.__fields[v.cn] ))
			else
				table.insert(tmp_sql, string.format("%s", t.__fields[v.cn]))
			end
		end
		table.insert(tmp_sql, ")")	
		local sql = table.concat(tmp_sql)
		--print(sql)
		query.write(t.__wdb, t.__tname, sql, query.DB_PRIORITY_3)
	end 
end

function cls:insert_db( ... )
	-- body
	self:update_db()
end

return cls
