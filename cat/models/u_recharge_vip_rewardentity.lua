local entitycpp = require "entitycpp"

local cls = class("u_recharge_vip_rewardentity", entitycpp)

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
			vip = 0,
			collected = 0,
			purchased = 0,
		}

	self.__ecol_updated = {
			id = 0,
			user_id = 0,
			vip = 0,
			collected = 0,
			purchased = 0,
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

function cls:set_vip(v, ... )
	-- body
	assert(v)
	self.__fields.vip = v
end

function cls:get_vip( ... )
	-- body
	return self.__fields.vip
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

function cls:set_purchased(v, ... )
	-- body
	assert(v)
	self.__fields.purchased = v
end

function cls:get_purchased( ... )
	-- body
	return self.__fields.purchased
end


return cls
