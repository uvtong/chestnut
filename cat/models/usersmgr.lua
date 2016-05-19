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
			uname = 0,
			uviplevel = 0,
			config_sound = 0,
			config_music = 0,
			avatar = 0,
			sign = 0,
			c_role_id = 0,
			ifonline = 0,
			level = 0,
			combat = 0,
			defense = 0,
			critical_hit = 0,
			blessing = 0,
			permission = 0,
			modify_uname_count = 0,
			onlinetime = 0,
			iconid = 0,
			is_valid = 0,
			recharge_rmb = 0,
			recharge_diamond = 0,
			uvip_progress = 0,
			checkin_num = 0,
			checkin_reward_num = 0,
			exercise_level = 0,
			cgold_level = 0,
			gold_max = 0,
			exp_max = 0,
			equipment_enhance_success_rate_up_p = 0,
			store_refresh_count_max = 0,
			prop_refresh = 0,
			arena_frozen_time = 0,
			purchase_hp_count = 0,
			gain_gold_up_p = 0,
			gain_exp_up_p = 0,
			purchase_hp_count_max = 0,
			SCHOOL_reset_count_max = 0,
			SCHOOL_reset_count = 0,
			signup_time = 0,
			pemail_csv_id = 0,
			take_diamonds = 0,
			draw_number = 0,
			ifxilian = 0,
			cp_chapter = 0,
			cp_hanging_id = 0,
			cp_battle_id = 0,
			cp_battle_chapter = 0,
			lilian_level = 0,
			lilian_exp = 0,
			lilian_phy_power = 0,
			purch_lilian_phy_power = 0,
			ara_role_id1 = 0,
			ara_role_id2 = 0,
			ara_role_id3 = 0,
			ara_rnk = 0,
			ara_win_tms = 0,
			ara_lose_tms = 0,
			ara_tie_tms = 0,
			ara_clg_tms = 0,
			ara_clg_tms_pur_tms = 0,
			ara_clg_tms_rst_tm = 0,
		}
,
		__ecol_updated = {
			csv_id = 0,
			uname = 0,
			uviplevel = 0,
			config_sound = 0,
			config_music = 0,
			avatar = 0,
			sign = 0,
			c_role_id = 0,
			ifonline = 0,
			level = 0,
			combat = 0,
			defense = 0,
			critical_hit = 0,
			blessing = 0,
			permission = 0,
			modify_uname_count = 0,
			onlinetime = 0,
			iconid = 0,
			is_valid = 0,
			recharge_rmb = 0,
			recharge_diamond = 0,
			uvip_progress = 0,
			checkin_num = 0,
			checkin_reward_num = 0,
			exercise_level = 0,
			cgold_level = 0,
			gold_max = 0,
			exp_max = 0,
			equipment_enhance_success_rate_up_p = 0,
			store_refresh_count_max = 0,
			prop_refresh = 0,
			arena_frozen_time = 0,
			purchase_hp_count = 0,
			gain_gold_up_p = 0,
			gain_exp_up_p = 0,
			purchase_hp_count_max = 0,
			SCHOOL_reset_count_max = 0,
			SCHOOL_reset_count = 0,
			signup_time = 0,
			pemail_csv_id = 0,
			take_diamonds = 0,
			draw_number = 0,
			ifxilian = 0,
			cp_chapter = 0,
			cp_hanging_id = 0,
			cp_battle_id = 0,
			cp_battle_chapter = 0,
			lilian_level = 0,
			lilian_exp = 0,
			lilian_phy_power = 0,
			purch_lilian_phy_power = 0,
			ara_role_id1 = 0,
			ara_role_id2 = 0,
			ara_role_id3 = 0,
			ara_rnk = 0,
			ara_win_tms = 0,
			ara_lose_tms = 0,
			ara_tie_tms = 0,
			ara_clg_tms = 0,
			ara_clg_tms_pur_tms = 0,
			ara_clg_tms_rst_tm = 0,
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
	_M.__tname   = "users"
	_M.__head    = {
	csv_id = {
		pk = true,
		uq = false,
		t = "number",
	},
	uname = {
		uq = false,
		t = "string",
	},
	uviplevel = {
		uq = false,
		t = "number",
	},
	config_sound = {
		uq = false,
		t = "number",
	},
	config_music = {
		uq = false,
		t = "number",
	},
	avatar = {
		uq = false,
		t = "number",
	},
	sign = {
		uq = false,
		t = "string",
	},
	c_role_id = {
		uq = false,
		t = "number",
	},
	ifonline = {
		uq = false,
		t = "number",
	},
	level = {
		uq = false,
		t = "number",
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
	permission = {
		uq = false,
		t = "number",
	},
	modify_uname_count = {
		uq = false,
		t = "number",
	},
	onlinetime = {
		uq = false,
		t = "number",
	},
	iconid = {
		uq = false,
		t = "number",
	},
	is_valid = {
		uq = false,
		t = "number",
	},
	recharge_rmb = {
		uq = false,
		t = "number",
	},
	recharge_diamond = {
		uq = false,
		t = "number",
	},
	uvip_progress = {
		uq = false,
		t = "number",
	},
	checkin_num = {
		uq = false,
		t = "number",
	},
	checkin_reward_num = {
		uq = false,
		t = "number",
	},
	exercise_level = {
		uq = false,
		t = "number",
	},
	cgold_level = {
		uq = false,
		t = "number",
	},
	gold_max = {
		uq = false,
		t = "number",
	},
	exp_max = {
		uq = false,
		t = "number",
	},
	equipment_enhance_success_rate_up_p = {
		uq = false,
		t = "number",
	},
	store_refresh_count_max = {
		uq = false,
		t = "number",
	},
	prop_refresh = {
		uq = false,
		t = "number",
	},
	arena_frozen_time = {
		uq = false,
		t = "number",
	},
	purchase_hp_count = {
		uq = false,
		t = "number",
	},
	gain_gold_up_p = {
		uq = false,
		t = "number",
	},
	gain_exp_up_p = {
		uq = false,
		t = "number",
	},
	purchase_hp_count_max = {
		uq = false,
		t = "number",
	},
	SCHOOL_reset_count_max = {
		uq = false,
		t = "number",
	},
	SCHOOL_reset_count = {
		uq = false,
		t = "number",
	},
	signup_time = {
		uq = false,
		t = "number",
	},
	pemail_csv_id = {
		uq = false,
		t = "number",
	},
	take_diamonds = {
		uq = false,
		t = "number",
	},
	draw_number = {
		uq = false,
		t = "number",
	},
	ifxilian = {
		uq = false,
		t = "number",
	},
	cp_chapter = {
		uq = false,
		t = "number",
	},
	cp_hanging_id = {
		uq = false,
		t = "number",
	},
	cp_battle_id = {
		uq = false,
		t = "number",
	},
	cp_battle_chapter = {
		uq = false,
		t = "number",
	},
	lilian_level = {
		uq = false,
		t = "number",
	},
	lilian_exp = {
		uq = false,
		t = "number",
	},
	lilian_phy_power = {
		uq = false,
		t = "number",
	},
	purch_lilian_phy_power = {
		uq = false,
		t = "number",
	},
	ara_role_id1 = {
		uq = false,
		t = "number",
	},
	ara_role_id2 = {
		uq = false,
		t = "number",
	},
	ara_role_id3 = {
		uq = false,
		t = "number",
	},
	ara_rnk = {
		uq = false,
		t = "number",
	},
	ara_win_tms = {
		uq = false,
		t = "number",
	},
	ara_lose_tms = {
		uq = false,
		t = "number",
	},
	ara_tie_tms = {
		uq = false,
		t = "number",
	},
	ara_clg_tms = {
		uq = false,
		t = "number",
	},
	ara_clg_tms_pur_tms = {
		uq = false,
		t = "number",
	},
	ara_clg_tms_rst_tm = {
		uq = false,
		t = "number",
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

