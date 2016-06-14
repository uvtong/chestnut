local entitycpp = require "entitycpp"

local cls = class("u_new_drawentity", entitycpp)

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
			uid = 0,
			drawtype = 0,
			srecvtime = 0,
			propid = 0,
			amount = 0,
			iffree = 0,
			updatetime = 0,
			is_latest = 0,
		}

	self.__ecol_updated = {
			id = 0,
			uid = 0,
			drawtype = 0,
			srecvtime = 0,
			propid = 0,
			amount = 0,
			iffree = 0,
			updatetime = 0,
			is_latest = 0,
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

function cls:set_uid(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["uid"] = self.__ecol_updated["uid"] + 1
	if self.__ecol_updated["uid"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.uid = v
end

function cls:get_uid( ... )
	-- body
	return self.__fields.uid
end

function cls:set_drawtype(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["drawtype"] = self.__ecol_updated["drawtype"] + 1
	if self.__ecol_updated["drawtype"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.drawtype = v
end

function cls:get_drawtype( ... )
	-- body
	return self.__fields.drawtype
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

function cls:set_iffree(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["iffree"] = self.__ecol_updated["iffree"] + 1
	if self.__ecol_updated["iffree"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.iffree = v
end

function cls:get_iffree( ... )
	-- body
	return self.__fields.iffree
end

function cls:set_updatetime(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["updatetime"] = self.__ecol_updated["updatetime"] + 1
	if self.__ecol_updated["updatetime"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.updatetime = v
end

function cls:get_updatetime( ... )
	-- body
	return self.__fields.updatetime
end

function cls:set_is_latest(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["is_latest"] = self.__ecol_updated["is_latest"] + 1
	if self.__ecol_updated["is_latest"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.is_latest = v
end

function cls:get_is_latest( ... )
	-- body
	return self.__fields.is_latest
end


return cls
