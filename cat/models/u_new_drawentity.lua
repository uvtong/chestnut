local entitycpp = require "entitycpp"

local cls = class("u_new_drawentity", entitycpp)

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
			uid = 0,
			drawtype = 0,
			srecvtime = 0,
			propid = 0,
			amount = 0,
			iffree = 0,
		}

	self.__ecol_updated = {
			id = 0,
			uid = 0,
			drawtype = 0,
			srecvtime = 0,
			propid = 0,
			amount = 0,
			iffree = 0,
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

function cls:set_uid(v, ... )
	-- body
	assert(v)
	self.__fields.uid = v
end

function cls:get_uid( ... )
	-- body
	return self.__fields.uid
end

function cls:set_drawtype(v, ... )
	-- body
	assert(v)
	self.__fields.drawtype = v
end

function cls:get_drawtype( ... )
	-- body
	return self.__fields.drawtype
end

function cls:set_srecvtime(v, ... )
	-- body
	assert(v)
	self.__fields.srecvtime = v
end

function cls:get_srecvtime( ... )
	-- body
	return self.__fields.srecvtime
end

function cls:set_propid(v, ... )
	-- body
	assert(v)
	self.__fields.propid = v
end

function cls:get_propid( ... )
	-- body
	return self.__fields.propid
end

function cls:set_amount(v, ... )
	-- body
	assert(v)
	self.__fields.amount = v
end

function cls:get_amount( ... )
	-- body
	return self.__fields.amount
end

function cls:set_iffree(v, ... )
	-- body
	assert(v)
	self.__fields.iffree = v
end

function cls:get_iffree( ... )
	-- body
	return self.__fields.iffree
end


return cls
