local entitycpp = require "entitycpp"

local cls = class("u_purchase_rewardentity", entitycpp)

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
			id = 0,
			user_id = 0,
			distribute_time = 0,
			g_goods_csv_id = 0,
			g_goods_num = 0,
			c_type = 0,
			c_recharge_vip = 0,
			c_vip = 0,
			collected = 0,
			prop_id = 0,
			csv_id = 0,
		}

	self.__ecol_updated = {
			id = 0,
			user_id = 0,
			distribute_time = 0,
			g_goods_csv_id = 0,
			g_goods_num = 0,
			c_type = 0,
			c_recharge_vip = 0,
			c_vip = 0,
			collected = 0,
			prop_id = 0,
			csv_id = 0,
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

function cls:set_user_id(v, ... )
	-- body
	assert(v)
	self.__fields.user_id = v
end

function cls:get_user_id( ... )
	-- body
	return self.__fields.user_id
end

function cls:set_distribute_time(v, ... )
	-- body
	assert(v)
	self.__fields.distribute_time = v
end

function cls:get_distribute_time( ... )
	-- body
	return self.__fields.distribute_time
end

function cls:set_g_goods_csv_id(v, ... )
	-- body
	assert(v)
	self.__fields.g_goods_csv_id = v
end

function cls:get_g_goods_csv_id( ... )
	-- body
	return self.__fields.g_goods_csv_id
end

function cls:set_g_goods_num(v, ... )
	-- body
	assert(v)
	self.__fields.g_goods_num = v
end

function cls:get_g_goods_num( ... )
	-- body
	return self.__fields.g_goods_num
end

function cls:set_c_type(v, ... )
	-- body
	assert(v)
	self.__fields.c_type = v
end

function cls:get_c_type( ... )
	-- body
	return self.__fields.c_type
end

function cls:set_c_recharge_vip(v, ... )
	-- body
	assert(v)
	self.__fields.c_recharge_vip = v
end

function cls:get_c_recharge_vip( ... )
	-- body
	return self.__fields.c_recharge_vip
end

function cls:set_c_vip(v, ... )
	-- body
	assert(v)
	self.__fields.c_vip = v
end

function cls:get_c_vip( ... )
	-- body
	return self.__fields.c_vip
end

function cls:set_collected(v, ... )
	-- body
	assert(v)
	self.__fields.collected = v
end

function cls:get_collected( ... )
	-- body
	return self.__fields.collected
end

function cls:set_prop_id(v, ... )
	-- body
	assert(v)
	self.__fields.prop_id = v
end

function cls:get_prop_id( ... )
	-- body
	return self.__fields.prop_id
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


return cls
