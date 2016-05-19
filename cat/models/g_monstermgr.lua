local skynet = require "skynet"
<<<<<<< HEAD
local util = require "util"
local notification = require "notification"

local _M = {}
_M.__data = {}
_M.__count = 0
_M.__cap = 0
_M.__user_id = 0
_M.__tname = "g_monster"

local _Meta = {csv_id = 0, name = 0, combat = 0, defense = 0, critical_hit = 0, blessing = 0, quanfaid = 0 }

_Meta.__check = true

function _Meta.__new()
 	-- body
 	local t = {}
 	setmetatable( t, { __index = _Meta } )
 	return t
end 

function _Meta:__insert_db(priority)
	-- body
	assert(priority)
	local t = {}
	for k,v in pairs(_Meta) do
		if not string.match(k, "^__*") then
			t[k] = assert(self[k])
		end
	end
	local sql = util.insert(self.__tname, t)
	skynet.send(util.random_db(), "lua", "command", "insert_sql", _M.__tname, sql, priority)
end

function _Meta:__update_db(t, priority)
	-- body
	-- assert(type(t) == "table")
	-- local columns = {}
	-- for i,v in ipairs(t) do
	-- 	columns[tostring(v)] = self[tostring(v)]
	-- end
	-- local sql = util.insert(self.__tname, {{ user_id=self.user_id, csv_id=self.csv_id }}, columns)
	-- skynet.send(util.random_db(), "lua", "command", "update_sql", _M.__tname, sql, priority)
end

function _Meta:__get(key)
	-- body
	assert(type(key) == "string")
	assert(_Meta[key])
	return assert(self[key])
end

function _Meta:__set(key, value)
	-- body
	assert(type(key) == "string")
	if self.__check then
		if self[key] ~= nil then
			assert(type(value) == type(self[key]))
		end
	end
	self[key] = value
	if self[csv_id] == const.GOLD then
		notification.handler[self.EGOLD](self.EGOLD)
	elseif self[csv_id] == const.EXP then
		notification.handler[self.EEXP](self.EGOLD)
	else
	end
end

function _M.insert_db(values, priority)
	assert(priority)
	assert(type(values) == "table" )
	local total = {}
	for i,v in ipairs(values) do
		local t = {}
		for kk,vv in pairs(v) do
			if not string.match(kk, "^__*") then
				t[kk] = vv
			end
		end
		table.insert(total, t)
	end
	local sql = util.insert_all(_M.__tname, total)
	skynet.send(util.random_db(), "lua", "command", "insert_all_sql", _M.__tname, sql, priority)
end 

function _M.create_with_csv_id(csv_id)
 	-- body
 	assert(csv_id, "csv_id ~= nil")
 	return _M.create(r)
end

function _M.create( P )
	assert(P)
	local u = _Meta.__new()
	for k,v in pairs(_Meta) do
		if not string.match(k, "^__*") then
			u[k] = assert(P[k])
		end
	end
	return u
end	

function _M:add( u )
	assert(u)
	assert(self.__data[tostring(u.csv_id)] == nil)
	self.__data[tostring(u.csv_id)] = u
	self.__count = self.__count + 1
end
	
function _M:get_by_csv_id(csv_id)
	-- body
	return self.__data[tostring(csv_id)]
end

function _M:delete_by_csv_id(csv_id)
	-- body
	assert(self.__data[tostring(csv_id)])
	self.__data[tostring(csv_id)] = nil
	self.__count = self.__count - 1
end

function _M:get_count()
=======
local entity = require "entity"
local modelmgr = require "modelmgr"
local assert = assert
local type   = type
local setmetatable = setmetatable

local function genpk(self, user_id, csv_id)
	-- body
	local pk = user_id << 32
	pk = (pk | ((1 << 32 -1) & csv_id ))
	return pk
end

local function ctor(self, P)
	-- body
	local r = self.create(P)
	self:add(r)
	r("insert")
end

local function create(self, P)
	assert(P)
	local t = { 
		__head  = self.__head,
		__tname = self.__tname,
		__pk    = self.__pk,
		__fk    = self.__fk,
		__rdb   = self.__rdb,
		__wdb   = self.__wdb,
		__stm   = self.__stm,
		__col_updated=0,
		__fields = {
			id = 0,
			csv_id = 0,
			name = 0,
			combat = 0,
			defense = 0,
			critical_hit = 0,
			blessing = 0,
			quanfaid = 0,
		}
,
		__ecol_updated = {
			id = 0,
			csv_id = 0,
			name = 0,
			combat = 0,
			defense = 0,
			critical_hit = 0,
			blessing = 0,
			quanfaid = 0,
		}

	}
	setmetatable(t, entity)
	for k,v in pairs(t.__head) do
		t.__fields[k] = assert(P[k])
	end
	return t
end	

local function add(self, u)
 	-- body
 	assert(u)
 	assert(self.__data[u.id] == nil)
 	self.__data[ u[self.__pk] ] = u
 	self.__count = self.__count + 1
end

local function get(self, pk)
	-- body
	if self.__data[pk] then
		return self.__data[pk]
	else
		local r = self("load", pk)
		if r then
			self.create(r)
			self:add(r)
		end
		return r
	end
end

local function delete(self, pk)
	-- body
	local r = self.__data[pk]
	if r then
		r("update")
		self.__data[pk] = nil
	end
end

local function get_by_csv_id(self, csv_id)
	-- body
	return self.__data[csv_id]
end

local function delete_by_csv_id(self, csv_id)
	assert(self.__data[csv_id])
	self.__data[csv_id] = nil
	self.__count = self.__count - 1
end

local function get_count(self)
>>>>>>> 931696816634519aea42a229a9e7390203b5b471
	-- body
	return self.__count
end

<<<<<<< HEAD
function _M:get_cap()
=======
local function get_cap(self)
>>>>>>> 931696816634519aea42a229a9e7390203b5b471
	-- body
	return self.__cap
end

<<<<<<< HEAD
function _M:clear()
=======
local function clear(self)
	-- body
>>>>>>> 931696816634519aea42a229a9e7390203b5b471
	self.__data = {}
	self.__count = 0
end

<<<<<<< HEAD
function _M:get(pk, key)
	-- body
	local r = self:get_by_csv_id(pk)
	return r:__get(key)
end

function _M:set(pk, key, value)
	-- body
	local r = self:get_by_csv_id(pk)
	r:__set(key, value)
end

function _M:update_db(priority)
	-- body
	assert(priority)
	if self.__count > 0 then
		local columns = { "finished", "reward_collected", "is_unlock"}
		local condition = { {user_id = self.__user_id}, {csv_id = {}}}
		local sql = util.update_all(_M.__tname, condition, columns, self.__data)
		skynet.send(util.random_db(), "lua", "command", "update_all_sql", _M.__tname, sql, priority)
	end
end

return _M
=======
function factory()
	-- body
	local _M     = setmetatable({}, modelmgr)
	_M.__data    = {}
	_M.__count   = 0
	_M.__cap     = 0
	_M.__tname   = "g_monster"
	_M.__head    = {
	id = {
		pk = true,
		uq = false,
		t = "number",
	},
	csv_id = {
		uq = false,
		t = "number",
	},
	name = {
		uq = false,
		t = "string",
	},
	combat = {
		uq = false,
		t = "number",
	},
	defense = {
		uq = false,
		t = "number",
	},
	critical_hit = {
		uq = false,
		t = "number",
	},
	blessing = {
		uq = false,
		t = "number",
	},
	quanfaid = {
		uq = false,
		t = "string",
	},
}

	_M.__pk      = "id"
	_M.__fk      = "0"
	_M.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	_M.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	_M.__stm     = false
	_M.genpk     = genpk
	_M.ctor      = ctor
	_M.create    = create
	_M.add       = add
	_M.get       = get
	_M.delete    = delete
	_M.get_by_csv_id = get_by_csv_id
	_M.delete_by_csv_id = delete_by_csv_id
	_M.get_count = get_count
	_M.get_cap   = get_cap
	_M.clear     = clear
	return _M
end

return factory
>>>>>>> 931696816634519aea42a229a9e7390203b5b471

