local entitycpp = require "entitycpp"

local cls = class("g_recharge_vip_rewardentity", entitycpp)

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
			id = 0,
			vip = 0,
			diamond = 0,
			gain_gold_up_p = 0,
			gain_exp_up_p = 0,
			gold_max_up_p = 0,
			exp_max_up_p = 0,
			equipment_enhance_success_rate_up_p = 0,
			prop_refresh_reduction_p = 0,
			arena_frozen_time_reduction_p = 0,
			purchase_hp_count_max = 0,
			SCHOOL_reset_count_max = 0,
			rewared = 0,
			store_refresh_count_max = 0,
			purchasable_gift = 0,
			marked_diamond = 0,
			purchasable_diamond = 0,
		}

	self.__ecol_updated = {
			id = 0,
			vip = 0,
			diamond = 0,
			gain_gold_up_p = 0,
			gain_exp_up_p = 0,
			gold_max_up_p = 0,
			exp_max_up_p = 0,
			equipment_enhance_success_rate_up_p = 0,
			prop_refresh_reduction_p = 0,
			arena_frozen_time_reduction_p = 0,
			purchase_hp_count_max = 0,
			SCHOOL_reset_count_max = 0,
			rewared = 0,
			store_refresh_count_max = 0,
			purchasable_gift = 0,
			marked_diamond = 0,
			purchasable_diamond = 0,
		}

	for k,v in pairs(self.__head) do
		self.__fields[k] = assert(P[k])
	end
	return self
end

function cls:set_id(v, ... )
	-- body
	assert(v)
	self.__fields.id = v
end

function cls:get_id( ... )
	-- body
	return self.__fields.id
end

function cls:set_vip(v, ... )
	-- body
	assert(v)
	self.__fields.vip = v
end

function cls:get_vip( ... )
	-- body
	return self.__fields.vip
end

function cls:set_diamond(v, ... )
	-- body
	assert(v)
	self.__fields.diamond = v
end

function cls:get_diamond( ... )
	-- body
	return self.__fields.diamond
end

function cls:set_gain_gold_up_p(v, ... )
	-- body
	assert(v)
	self.__fields.gain_gold_up_p = v
end

function cls:get_gain_gold_up_p( ... )
	-- body
	return self.__fields.gain_gold_up_p
end

function cls:set_gain_exp_up_p(v, ... )
	-- body
	assert(v)
	self.__fields.gain_exp_up_p = v
end

function cls:get_gain_exp_up_p( ... )
	-- body
	return self.__fields.gain_exp_up_p
end

function cls:set_gold_max_up_p(v, ... )
	-- body
	assert(v)
	self.__fields.gold_max_up_p = v
end

function cls:get_gold_max_up_p( ... )
	-- body
	return self.__fields.gold_max_up_p
end

function cls:set_exp_max_up_p(v, ... )
	-- body
	assert(v)
	self.__fields.exp_max_up_p = v
end

function cls:get_exp_max_up_p( ... )
	-- body
	return self.__fields.exp_max_up_p
end

function cls:set_equipment_enhance_success_rate_up_p(v, ... )
	-- body
	assert(v)
	self.__fields.equipment_enhance_success_rate_up_p = v
end

function cls:get_equipment_enhance_success_rate_up_p( ... )
	-- body
	return self.__fields.equipment_enhance_success_rate_up_p
end

function cls:set_prop_refresh_reduction_p(v, ... )
	-- body
	assert(v)
	self.__fields.prop_refresh_reduction_p = v
end

function cls:get_prop_refresh_reduction_p( ... )
	-- body
	return self.__fields.prop_refresh_reduction_p
end

function cls:set_arena_frozen_time_reduction_p(v, ... )
	-- body
	assert(v)
	self.__fields.arena_frozen_time_reduction_p = v
end

function cls:get_arena_frozen_time_reduction_p( ... )
	-- body
	return self.__fields.arena_frozen_time_reduction_p
end

function cls:set_purchase_hp_count_max(v, ... )
	-- body
	assert(v)
	self.__fields.purchase_hp_count_max = v
end

function cls:get_purchase_hp_count_max( ... )
	-- body
	return self.__fields.purchase_hp_count_max
end

function cls:set_SCHOOL_reset_count_max(v, ... )
	-- body
	assert(v)
	self.__fields.SCHOOL_reset_count_max = v
end

function cls:get_SCHOOL_reset_count_max( ... )
	-- body
	return self.__fields.SCHOOL_reset_count_max
end

function cls:set_rewared(v, ... )
	-- body
	assert(v)
	self.__fields.rewared = v
end

function cls:get_rewared( ... )
	-- body
	return self.__fields.rewared
end

function cls:set_store_refresh_count_max(v, ... )
	-- body
	assert(v)
	self.__fields.store_refresh_count_max = v
end

function cls:get_store_refresh_count_max( ... )
	-- body
	return self.__fields.store_refresh_count_max
end

function cls:set_purchasable_gift(v, ... )
	-- body
	assert(v)
	self.__fields.purchasable_gift = v
end

function cls:get_purchasable_gift( ... )
	-- body
	return self.__fields.purchasable_gift
end

function cls:set_marked_diamond(v, ... )
	-- body
	assert(v)
	self.__fields.marked_diamond = v
end

function cls:get_marked_diamond( ... )
	-- body
	return self.__fields.marked_diamond
end

function cls:set_purchasable_diamond(v, ... )
	-- body
	assert(v)
	self.__fields.purchasable_diamond = v
end

function cls:get_purchasable_diamond( ... )
	-- body
	return self.__fields.purchasable_diamond
end


return cls
