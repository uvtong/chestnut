local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
local assert = assert
local type   = type

local cls = class("usersmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "users"
	self.__head    = {
	csv_id = {
		pk = true,
		fk = false,
		uq = false,
		t = "number",
	},
	uname = {
		pk = false,
		fk = false,
		uq = false,
		t = "string",
	},
	uviplevel = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	config_sound = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	config_music = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	avatar = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	sign = {
		pk = false,
		fk = false,
		uq = false,
		t = "string",
	},
	c_role_id = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	ifonline = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	level = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	combat = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	defense = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	critical_hit = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	blessing = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	permission = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	modify_uname_count = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	onlinetime = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	iconid = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	is_valid = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	recharge_rmb = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	recharge_diamond = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	uvip_progress = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	checkin_num = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	checkin_reward_num = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	exercise_level = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	cgold_level = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	gold_max = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	exp_max = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	equipment_enhance_success_rate_up_p = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	store_refresh_count_max = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	prop_refresh = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	arena_frozen_time = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	purchase_hp_count = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	gain_gold_up_p = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	gain_exp_up_p = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	purchase_hp_count_max = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	SCHOOL_reset_count_max = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	SCHOOL_reset_count = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	signup_time = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	pemail_csv_id = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	take_diamonds = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	draw_number = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	ifxilian = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	cp_chapter = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	cp_hanging_id = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	cp_battle_id = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	cp_battle_chapter = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	lilian_level = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	lilian_exp = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	lilian_phy_power = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	purch_lilian_phy_power = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	ara_role_id1 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	ara_role_id2 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	ara_role_id3 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	ara_rnk = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	ara_win_tms = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	ara_lose_tms = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	ara_tie_tms = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	ara_clg_tms = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	ara_clg_tms_pur_tms = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	ara_clg_tms_rst_tm = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
}

	self.__pk      = "csv_id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "usersentity"
	return self
end

function cls.genpk(self, csv_id)
	-- body
	if #self.__fk == 0 then
		return csv_id
	else
		local pk = user_id << 32
		pk = (pk | ((1 << 32 -1) & csv_id ))
		return pk
	end
end

function cls.add(self, u)
 	-- body
 	assert(u)
 	assert(self.__data[ u[self.__pk](u) ] == nil)
 	self.__data[ u[self.__pk](u) ] = u
 	self.__count = self.__count + 1
end

function cls.get(self, pk)
	-- body
	if self.__data[pk] then
		return self.__data[pk]
	else
		assert(false)
		-- local r = self("load", pk)
		-- if r then
		-- 	self.create(r)
		-- 	self:add(r)
		-- end
		-- return r
	end
end

function cls.delete(self, pk)
	-- body
	if nil ~= self.__data[pk] then
		self.__data[pk] = nil
		self.__count = self.__count - 1
	end
end

function cls.get_by_csv_id(self, csv_id)
	-- body
	local pk = self:genpk(csv_id)
	return self:get(pk)
end

function cls.delete_by_csv_id(self, csv_id)
	local pk = self:genpk(csv_id)
	self:delete(pk)
end

function cls.get_count(self)
	-- body
	return self.__count
end

function cls.get_cap(self)
	-- body
	return self.__cap
end

function cls.clear(self)
	-- body
	self.__data = {}
	self.__count = 0
end

return cls