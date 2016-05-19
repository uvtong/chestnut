local skynet = require "skynet"
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
			csv_id = 0,
			reward = 0,
		}
,
		__ecol_updated = {
			csv_id = 0,
			reward = 0,
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
	-- body
	return self.__count
end

local function get_cap(self)
	-- body
	return self.__cap
end

local function clear(self)
	-- body
	self.__data = {}
	self.__count = 0
end

function factory()
	-- body
	local _M     = setmetatable({}, modelmgr)
	_M.__data    = {}
	_M.__count   = 0
	_M.__cap     = 0
	_M.__tname   = "g_ara_pts"
	_M.__head    = {
	csv_id = {
		pk = true,
		uq = false,
		t = "number",
	},
	reward = {
		uq = false,
		t = "string",
	},
}

	_M.__pk      = "csv_id"
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

