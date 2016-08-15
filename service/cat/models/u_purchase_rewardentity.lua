local entitycpp = require "entitycpp"

local cls = class("u_purchase_rewardentity", entitycpp)

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
			user_id = 0,
			csv_id = 0,
			g_goods_csv_id = 0,
			g_goods_num = 0,
			c_type = 0,
			c_recharge_vip = 0,
			c_vip = 0,
			collected = 0,
			prop_id = 0,
			u_purchase_rewardcol = 0,
			distribute_time = 0,
		}

	self.__ecol_updated = {
			id = 0,
			user_id = 0,
			csv_id = 0,
			g_goods_csv_id = 0,
			g_goods_num = 0,
			c_type = 0,
			c_recharge_vip = 0,
			c_vip = 0,
			collected = 0,
			prop_id = 0,
			u_purchase_rewardcol = 0,
			distribute_time = 0,
		}

	for k,v in pairs(self.__head) do
		self.__fields[k] = assert(P[k], string.format("no exist %s", k))
	end
	return self
end

function cls:set_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["id"] = self.__ecol_updated["id"] + 1
	if self.__ecol_updated["id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.id = v
end

function cls:get_id( ... )
	-- body
	return self.__fields.id
end

function cls:set_user_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["user_id"] = self.__ecol_updated["user_id"] + 1
	if self.__ecol_updated["user_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.user_id = v
end

function cls:get_user_id( ... )
	-- body
	return self.__fields.user_id
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

function cls:set_g_goods_csv_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["g_goods_csv_id"] = self.__ecol_updated["g_goods_csv_id"] + 1
	if self.__ecol_updated["g_goods_csv_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.g_goods_csv_id = v
end

function cls:get_g_goods_csv_id( ... )
	-- body
	return self.__fields.g_goods_csv_id
end

function cls:set_g_goods_num(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["g_goods_num"] = self.__ecol_updated["g_goods_num"] + 1
	if self.__ecol_updated["g_goods_num"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.g_goods_num = v
end

function cls:get_g_goods_num( ... )
	-- body
	return self.__fields.g_goods_num
end

function cls:set_c_type(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["c_type"] = self.__ecol_updated["c_type"] + 1
	if self.__ecol_updated["c_type"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.c_type = v
end

function cls:get_c_type( ... )
	-- body
	return self.__fields.c_type
end

function cls:set_c_recharge_vip(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["c_recharge_vip"] = self.__ecol_updated["c_recharge_vip"] + 1
	if self.__ecol_updated["c_recharge_vip"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.c_recharge_vip = v
end

function cls:get_c_recharge_vip( ... )
	-- body
	return self.__fields.c_recharge_vip
end

function cls:set_c_vip(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["c_vip"] = self.__ecol_updated["c_vip"] + 1
	if self.__ecol_updated["c_vip"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.c_vip = v
end

function cls:get_c_vip( ... )
	-- body
	return self.__fields.c_vip
end

function cls:set_collected(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["collected"] = self.__ecol_updated["collected"] + 1
	if self.__ecol_updated["collected"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.collected = v
end

function cls:get_collected( ... )
	-- body
	return self.__fields.collected
end

function cls:set_prop_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["prop_id"] = self.__ecol_updated["prop_id"] + 1
	if self.__ecol_updated["prop_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.prop_id = v
end

function cls:get_prop_id( ... )
	-- body
	return self.__fields.prop_id
end

function cls:set_u_purchase_rewardcol(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["u_purchase_rewardcol"] = self.__ecol_updated["u_purchase_rewardcol"] + 1
	if self.__ecol_updated["u_purchase_rewardcol"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.u_purchase_rewardcol = v
end

function cls:get_u_purchase_rewardcol( ... )
	-- body
	return self.__fields.u_purchase_rewardcol
end

function cls:set_distribute_time(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["distribute_time"] = self.__ecol_updated["distribute_time"] + 1
	if self.__ecol_updated["distribute_time"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.distribute_time = v
end

function cls:get_distribute_time( ... )
	-- body
	return self.__fields.distribute_time
end


return cls
