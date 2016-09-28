local entitycpp = require "entity"

local cls = class("areaentity", entitycpp)

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
			server_id = 0,
			server = 0,
		}

	self.__ecol_updated = {
			id = 0,
			uid = 0,
			server_id = 0,
			server = 0,
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

function cls:set_server_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["server_id"] = self.__ecol_updated["server_id"] + 1
	if self.__ecol_updated["server_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.server_id = v
end

function cls:get_server_id( ... )
	-- body
	return self.__fields.server_id
end

function cls:set_server(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["server"] = self.__ecol_updated["server"] + 1
	if self.__ecol_updated["server"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.server = v
end

function cls:get_server( ... )
	-- body
	return self.__fields.server
end


return cls
