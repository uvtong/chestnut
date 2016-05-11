local assert = assert
local type   = type
local entity = require "entity"
local modelmgr = require "modelmgr"

local _M     = {}
setmetatable(_M, modelmgr)
_M.__data    = {}
_M.__count   = 0
_M.__cap     = 0
_M.__tname   = "users"
_M.__head    = {
	id = {
		pk = true,
		fk = false,
		uq = false,
		t = "number",
	},
	csv_id = {
		pk = false,
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
	group = {
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
}

_M.__pk      = "id"
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
			id = 0,
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
			group = 0,
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
		}
,
		__ecol_updated = {
			id = 0,
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
			group = 0,
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
