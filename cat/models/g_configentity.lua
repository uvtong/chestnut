local entitycpp = require "entitycpp"

local cls = class("g_configentity", entitycpp)

function cls:ctor(mgr, P, ... )
	-- body
	self.__head  = mgr.__head
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
		}

	for k,v in pairs(self.__head) do
		self.__fields[k] = assert(P[k])
	end
	return self
end

function cls:set_csv_id(v, ... )
	-- body
	assert(v)
	self.__fields.csv_id = v
end

function cls:get_csv_id( ... )
	-- body
	return self.__fields.csv_id
end

function cls:set_user_level_max(v, ... )
	-- body
	assert(v)
	self.__fields.user_level_max = v
end

function cls:get_user_level_max( ... )
	-- body
	return self.__fields.user_level_max
end

function cls:set_user_vip_max(v, ... )
	-- body
	assert(v)
	self.__fields.user_vip_max = v
end

function cls:get_user_vip_max( ... )
	-- body
	return self.__fields.user_vip_max
end

function cls:set_xilian_begain_level(v, ... )
	-- body
	assert(v)
	self.__fields.xilian_begain_level = v
end

function cls:get_xilian_begain_level( ... )
	-- body
	return self.__fields.xilian_begain_level
end

function cls:set_cp_chapter_max(v, ... )
	-- body
	assert(v)
	self.__fields.cp_chapter_max = v
end

function cls:get_cp_chapter_max( ... )
	-- body
	return self.__fields.cp_chapter_max
end

function cls:set_purch_phy_power(v, ... )
	-- body
	assert(v)
	self.__fields.purch_phy_power = v
end

function cls:get_purch_phy_power( ... )
	-- body
	return self.__fields.purch_phy_power
end

function cls:set_diamond_per_sec(v, ... )
	-- body
	assert(v)
	self.__fields.diamond_per_sec = v
end

function cls:get_diamond_per_sec( ... )
	-- body
	return self.__fields.diamond_per_sec
end

function cls:set_ara_clg_tms_rst_tp(v, ... )
	-- body
	assert(v)
	self.__fields.ara_clg_tms_rst_tp = v
end

function cls:get_ara_clg_tms_rst_tp( ... )
	-- body
	return self.__fields.ara_clg_tms_rst_tp
end

function cls:set_worship_reward_id(v, ... )
	-- body
	assert(v)
	self.__fields.worship_reward_id = v
end

function cls:get_worship_reward_id( ... )
	-- body
	return self.__fields.worship_reward_id
end

function cls:set_worship_reward_num(v, ... )
	-- body
	assert(v)
	self.__fields.worship_reward_num = v
end

function cls:get_worship_reward_num( ... )
	-- body
	return self.__fields.worship_reward_num
end

function cls:set_ara_clg_tms_max(v, ... )
	-- body
	assert(v)
	self.__fields.ara_clg_tms_max = v
end

function cls:get_ara_clg_tms_max( ... )
	-- body
	return self.__fields.ara_clg_tms_max
end


return cls
