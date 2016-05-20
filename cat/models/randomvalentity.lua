local entitycpp = require "entitycpp"

local cls = class("randomvalentity", entitycpp)

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
			val = 0,
			step = 0,
		}

	self.__ecol_updated = {
			id = 0,
			val = 0,
			step = 0,
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

function cls:set_val(v, ... )
	-- body
	assert(v)
	self.__fields.val = v
end

function cls:get_val( ... )
	-- body
	return self.__fields.val
end

function cls:set_step(v, ... )
	-- body
	assert(v)
	self.__fields.step = v
end

function cls:get_step( ... )
	-- body
	return self.__fields.step
end


return cls
