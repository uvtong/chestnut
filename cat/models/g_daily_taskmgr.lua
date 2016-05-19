local skynet = require "skynet"
<<<<<<< HEAD
local util = require "util"
			
local _M = {}
_M.__data = {}
_M.__count = 0
			
-- type = daily_type * 10 + exercise_type
local _Meta = { update_time = 0 , type = 0 , task_name = 0 , cost_amount = 0 , iconid = 0 , basic_reward = 0 , levelup_reward = 0 , level_up = 0 , cost_id = 0 }
			
_M.__tname = "g_daily_task"
			    
function _Meta.__new()
 	-- body     
 	local t = {}
 	setmetatable( t, { __index = _Meta } )
 	return t    
end 		    
			    
function _Meta:__insert_db()
	-- body	    
	local t = {}
	for k,v in pairs(self) do
		if not string.match(k, "^__*") then
			t[k] = self[k]
		end     
	end 	    
	skynet.send(util.random_db(), "lua", "command", "insert", self.__tname, t)
end 		
			
function _Meta:__update_db(t)
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
			update_time = 0,
			type = 0,
			task_name = 0,
			cost_amount = 0,
			iconid = 0,
			basic_reward = 0,
			levelup_reward = 0,
			level_up = 0,
			cost_id = 0,
		}
,
		__ecol_updated = {
			id = 0,
			update_time = 0,
			type = 0,
			task_name = 0,
			cost_amount = 0,
			iconid = 0,
			basic_reward = 0,
			levelup_reward = 0,
			level_up = 0,
			cost_id = 0,
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
>>>>>>> 931696816634519aea42a229a9e7390203b5b471
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

local function get_one(self)
	for k , v in pairs( self.__data ) do
		return v
	end
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
	_M.__tname   = "g_daily_task"
	_M.__head    = {
	id = {
		pk = true,
		uq = false,
		t = "number",
	},
	update_time = {
		uq = false,
		t = "string",
	},
	type = {
		uq = false,
		t = "number",
	},
	task_name = {
		uq = false,
		t = "string",
	},
	cost_amount = {
		uq = false,
		t = "number",
	},
	iconid = {
		uq = false,
		t = "number",
	},
	basic_reward = {
		uq = false,
		t = "string",
	},
	levelup_reward = {
		uq = false,
		t = "string",
	},
	level_up = {
		uq = false,
		t = "number",
	},
	cost_id = {
		uq = false,
		t = "number",
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
	_M.get_one   = get_one
	return _M
end

return factory

