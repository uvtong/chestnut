local entitycpp = require "entitycpp"

local cls = class("g_configentity", entitycpp)

function cls:ctor(mgr, P, ... )
	-- body
	self.__head  = mgr.__head
	self.__head_ord = mgr.__head_ord
	self.__tname = mgr.__tname
	self.__pk    = mgr.__pk
	self.__fk    = mgr.__fk
	self.__rdb   = mgr.__rdb
	self.__wdb   = mgr.__wdb
	self.__stm   = mgr.__stm
	self.__col_updated=0
	self.__fields = {
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
			ara_clg_tms_max = 0,
			ara_clg_tms_rst = 0,
			ara_integral_rst = 0,
			ara_clg_tms_pur_tms_rst = 0,
			ara_rfh_dt = 0,
		}

	self.__ecol_updated = {
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
			ara_clg_tms_max = 0,
			ara_clg_tms_rst = 0,
			ara_integral_rst = 0,
			ara_clg_tms_pur_tms_rst = 0,
			ara_rfh_dt = 0,
		}

	for k,v in pairs(self.__head) do
		self.__fields[k] = assert(P[k], string.format("no exist %s", k))
	end
	return self
end

function cls:set_csv_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["csv_id"] = self.__ecol_updated["csv_id"] + 1
	if self.__ecol_updated["csv_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.csv_id = v
end

function cls:get_csv_id( ... )
	-- body
	return self.__fields.csv_id
end

function cls:set_user_level_max(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["user_level_max"] = self.__ecol_updated["user_level_max"] + 1
	if self.__ecol_updated["user_level_max"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.user_level_max = v
end

function cls:get_user_level_max( ... )
	-- body
	return self.__fields.user_level_max
end

function cls:set_user_vip_max(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["user_vip_max"] = self.__ecol_updated["user_vip_max"] + 1
	if self.__ecol_updated["user_vip_max"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.user_vip_max = v
end

function cls:get_user_vip_max( ... )
	-- body
	return self.__fields.user_vip_max
end

function cls:set_xilian_begain_level(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["xilian_begain_level"] = self.__ecol_updated["xilian_begain_level"] + 1
	if self.__ecol_updated["xilian_begain_level"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.xilian_begain_level = v
end

function cls:get_xilian_begain_level( ... )
	-- body
	return self.__fields.xilian_begain_level
end

function cls:set_cp_chapter_max(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["cp_chapter_max"] = self.__ecol_updated["cp_chapter_max"] + 1
	if self.__ecol_updated["cp_chapter_max"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.cp_chapter_max = v
end

function cls:get_cp_chapter_max( ... )
	-- body
	return self.__fields.cp_chapter_max
end

function cls:set_purch_phy_power(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["purch_phy_power"] = self.__ecol_updated["purch_phy_power"] + 1
	if self.__ecol_updated["purch_phy_power"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.purch_phy_power = v
end

function cls:get_purch_phy_power( ... )
	-- body
	return self.__fields.purch_phy_power
end

function cls:set_diamond_per_sec(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["diamond_per_sec"] = self.__ecol_updated["diamond_per_sec"] + 1
	if self.__ecol_updated["diamond_per_sec"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.diamond_per_sec = v
end

function cls:get_diamond_per_sec( ... )
	-- body
	return self.__fields.diamond_per_sec
end

function cls:set_ara_clg_tms_rst_tp(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_clg_tms_rst_tp"] = self.__ecol_updated["ara_clg_tms_rst_tp"] + 1
	if self.__ecol_updated["ara_clg_tms_rst_tp"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_clg_tms_rst_tp = v
end

function cls:get_ara_clg_tms_rst_tp( ... )
	-- body
	return self.__fields.ara_clg_tms_rst_tp
end

function cls:set_worship_reward_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["worship_reward_id"] = self.__ecol_updated["worship_reward_id"] + 1
	if self.__ecol_updated["worship_reward_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.worship_reward_id = v
end

function cls:get_worship_reward_id( ... )
	-- body
	return self.__fields.worship_reward_id
end

function cls:set_worship_reward_num(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["worship_reward_num"] = self.__ecol_updated["worship_reward_num"] + 1
	if self.__ecol_updated["worship_reward_num"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.worship_reward_num = v
end

function cls:get_worship_reward_num( ... )
	-- body
	return self.__fields.worship_reward_num
end

function cls:set_ara_clg_tms_max(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_clg_tms_max"] = self.__ecol_updated["ara_clg_tms_max"] + 1
	if self.__ecol_updated["ara_clg_tms_max"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_clg_tms_max = v
end

function cls:get_ara_clg_tms_max( ... )
	-- body
	return self.__fields.ara_clg_tms_max
end

function cls:set_ara_clg_tms_rst(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_clg_tms_rst"] = self.__ecol_updated["ara_clg_tms_rst"] + 1
	if self.__ecol_updated["ara_clg_tms_rst"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_clg_tms_rst = v
end

function cls:get_ara_clg_tms_rst( ... )
	-- body
	return self.__fields.ara_clg_tms_rst
end

function cls:set_ara_integral_rst(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_integral_rst"] = self.__ecol_updated["ara_integral_rst"] + 1
	if self.__ecol_updated["ara_integral_rst"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_integral_rst = v
end

function cls:get_ara_integral_rst( ... )
	-- body
	return self.__fields.ara_integral_rst
end

function cls:set_ara_clg_tms_pur_tms_rst(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_clg_tms_pur_tms_rst"] = self.__ecol_updated["ara_clg_tms_pur_tms_rst"] + 1
	if self.__ecol_updated["ara_clg_tms_pur_tms_rst"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_clg_tms_pur_tms_rst = v
end

function cls:get_ara_clg_tms_pur_tms_rst( ... )
	-- body
	return self.__fields.ara_clg_tms_pur_tms_rst
end

function cls:set_ara_rfh_dt(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_rfh_dt"] = self.__ecol_updated["ara_rfh_dt"] + 1
	if self.__ecol_updated["ara_rfh_dt"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_rfh_dt = v
end

function cls:get_ara_rfh_dt( ... )
	-- body
	return self.__fields.ara_rfh_dt
end


return cls
