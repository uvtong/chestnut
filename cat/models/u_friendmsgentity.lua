local entitycpp = require "entitycpp"

local cls = class("u_friendmsgentity", entitycpp)

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
			fromid = 0,
			toid = 0,
			type = 0,
			amount = 0,
			propid = 0,
			isread = 0,
			csendtime = 0,
			srecvtime = 0,
			signtime = 0,
		}

	self.__ecol_updated = {
			id = 0,
			fromid = 0,
			toid = 0,
			type = 0,
			amount = 0,
			propid = 0,
			isread = 0,
			csendtime = 0,
			srecvtime = 0,
			signtime = 0,
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

function cls:set_fromid(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["fromid"] = self.__ecol_updated["fromid"] + 1
	if self.__ecol_updated["fromid"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.fromid = v
end

function cls:get_fromid( ... )
	-- body
	return self.__fields.fromid
end

function cls:set_toid(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["toid"] = self.__ecol_updated["toid"] + 1
	if self.__ecol_updated["toid"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.toid = v
end

function cls:get_toid( ... )
	-- body
	return self.__fields.toid
end

function cls:set_type(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["type"] = self.__ecol_updated["type"] + 1
	if self.__ecol_updated["type"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.type = v
end

function cls:get_type( ... )
	-- body
	return self.__fields.type
end

function cls:set_amount(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["amount"] = self.__ecol_updated["amount"] + 1
	if self.__ecol_updated["amount"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.amount = v
end

function cls:get_amount( ... )
	-- body
	return self.__fields.amount
end

function cls:set_propid(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["propid"] = self.__ecol_updated["propid"] + 1
	if self.__ecol_updated["propid"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.propid = v
end

function cls:get_propid( ... )
	-- body
	return self.__fields.propid
end

function cls:set_isread(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["isread"] = self.__ecol_updated["isread"] + 1
	if self.__ecol_updated["isread"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.isread = v
end

function cls:get_isread( ... )
	-- body
	return self.__fields.isread
end

function cls:set_csendtime(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["csendtime"] = self.__ecol_updated["csendtime"] + 1
	if self.__ecol_updated["csendtime"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.csendtime = v
end

function cls:get_csendtime( ... )
	-- body
	return self.__fields.csendtime
end

function cls:set_srecvtime(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["srecvtime"] = self.__ecol_updated["srecvtime"] + 1
	if self.__ecol_updated["srecvtime"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.srecvtime = v
end

function cls:get_srecvtime( ... )
	-- body
	return self.__fields.srecvtime
end

function cls:set_signtime(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["signtime"] = self.__ecol_updated["signtime"] + 1
	if self.__ecol_updated["signtime"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.signtime = v
end

function cls:get_signtime( ... )
	-- body
	return self.__fields.signtime
end


return cls
