local assert = assert
local type   = type
local entity = require "entity"
local modelmgr = require "modelmgr"

local _M     = {}
setmetatable(_M, modelmgr)
_M.__data    = {}
_M.__count   = 0
_M.__cap     = 0
_M.__tname   = "g_config"
_M.__head    = {
	csv_id = {
		pk = true,
		fk = false,
		uq = false,
		t = "number",
	},
	user_level_max = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	user_vip_max = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	xilian_begain_level = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	cp_chapter_max = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	purch_phy_power = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	diamond_per_sec = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	ara_clg_tms_rst_tp = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	worship_reward_id = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	worship_reward_num = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
}

_M.__pk      = "csv_id"
_M.__rdb     = ".rdb"
_M.__wdb     = ".wdb"

function _M:genpk(user_id, csv_id)
	-- body
	local pk = user_id << 32
	pk = (pk | ((1 << 32 -1) & csv_id ))
	return pk
end

function _M:ctor(P)
	-- body
	local r = self.create(P)
	self:add(r)
	r("insert")
end

function _M.create(P)
	assert(P)
	local t = { 
		__head  = _M.__head,
		__tname = _M.__tname,
		__pk    = _M.__pk,
		__col_updated=0,
		__fields = {
			csv_id = 0,
			user_level_max = 0,
			user_vip_max = 0,
			xilian_begain_level = 0,
			cp_chapter_max = 0,
			purch_phy_power = 0,
			diamond_per_sec = 0,
			ara_clg_tms_rst_tp = 0,
			worship_reward_id = 0,
			worship_reward_num = 0,
		}
,
		__ecol_updated = {
			csv_id = 0,
			user_level_max = 0,
			user_vip_max = 0,
			xilian_begain_level = 0,
			cp_chapter_max = 0,
			purch_phy_power = 0,
			diamond_per_sec = 0,
			ara_clg_tms_rst_tp = 0,
			worship_reward_id = 0,
			worship_reward_num = 0,
		}

	}
	setmetatable(t, entity)
	for k,v in pairs(t.__head) do
		t.__fields[k] = assert(P[k])
	end
	return t
end	

function _M:add(u)
 	-- body
 	assert(u)
 	assert(self.__data[u.id] == nil)
 	self.__data[ u[self.__pk] ] = u
 	self.__count = self.__count + 1
end

function _M:get(pk)
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

function _M:delete(pk)
	-- body
	local r = self.__data[pk]
	if r then
		r("update")
		self.__data[pk] = nil
	end
end

function _M:get_by_csv_id(csv_id)
	-- body
	return self.__data[csv_id]
end

function _M:delete_by_csv_id(csv_id)
	assert(self.__data[csv_id])
	self.__data[csv_id] = nil
	self.__count = self.__count - 1
end

function _M:get_count()
	-- body
	return self.__count
end

function _M:get_cap()
	-- body
	return self.__cap
end

function _M:clear()
	-- body
	self.__data = {}
	self.__count = 0
end

return _M
