local entitycpp = require "entitycpp"

local cls = class("g_goods_refresh_costentity", entitycpp)

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
			currency_type = 0,
			currency_num = 0,
		}

	self.__ecol_updated = {
			csv_id = 0,
			currency_type = 0,
			currency_num = 0,
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

function cls:set_currency_type(v, ... )
	-- body
	assert(v)
	self.__fields.currency_type = v
end

function cls:get_currency_type( ... )
	-- body
	return self.__fields.currency_type
end

function cls:set_currency_num(v, ... )
	-- body
	assert(v)
	self.__fields.currency_num = v
end

function cls:get_currency_num( ... )
	-- body
	return self.__fields.currency_num
end


return cls
