local entitycpp = require "entitycpp"

local cls = class("g_rechargeentity", entitycpp)

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
			icon_id = 0,
			name = 0,
			diamond = 0,
			first = 0,
			gift = 0,
			rmb = 0,
			recharge_before = 0,
			recharge_after = 0,
		}

	self.__ecol_updated = {
			csv_id = 0,
			icon_id = 0,
			name = 0,
			diamond = 0,
			first = 0,
			gift = 0,
			rmb = 0,
			recharge_before = 0,
			recharge_after = 0,
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

function cls:set_icon_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["icon_id"] = self.__ecol_updated["icon_id"] + 1
	if self.__ecol_updated["icon_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.icon_id = v
end

function cls:get_icon_id( ... )
	-- body
	return self.__fields.icon_id
end

function cls:set_name(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["name"] = self.__ecol_updated["name"] + 1
	if self.__ecol_updated["name"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.name = v
end

function cls:get_name( ... )
	-- body
	return self.__fields.name
end

function cls:set_diamond(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["diamond"] = self.__ecol_updated["diamond"] + 1
	if self.__ecol_updated["diamond"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.diamond = v
end

function cls:get_diamond( ... )
	-- body
	return self.__fields.diamond
end

function cls:set_first(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["first"] = self.__ecol_updated["first"] + 1
	if self.__ecol_updated["first"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.first = v
end

function cls:get_first( ... )
	-- body
	return self.__fields.first
end

function cls:set_gift(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["gift"] = self.__ecol_updated["gift"] + 1
	if self.__ecol_updated["gift"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.gift = v
end

function cls:get_gift( ... )
	-- body
	return self.__fields.gift
end

function cls:set_rmb(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["rmb"] = self.__ecol_updated["rmb"] + 1
	if self.__ecol_updated["rmb"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.rmb = v
end

function cls:get_rmb( ... )
	-- body
	return self.__fields.rmb
end

function cls:set_recharge_before(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["recharge_before"] = self.__ecol_updated["recharge_before"] + 1
	if self.__ecol_updated["recharge_before"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.recharge_before = v
end

function cls:get_recharge_before( ... )
	-- body
	return self.__fields.recharge_before
end

function cls:set_recharge_after(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["recharge_after"] = self.__ecol_updated["recharge_after"] + 1
	if self.__ecol_updated["recharge_after"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.recharge_after = v
end

function cls:get_recharge_after( ... )
	-- body
	return self.__fields.recharge_after
end


return cls
