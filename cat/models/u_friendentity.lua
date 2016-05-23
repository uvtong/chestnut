local entitycpp = require "entitycpp"

local cls = class("u_friendentity", entitycpp)

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
			friendid = 0,
			isdel = 0,
			recvtime = 0,
			heartamount = 0,
			sendtime = 0,
		}

	self.__ecol_updated = {
			id = 0,
			uid = 0,
			friendid = 0,
			isdel = 0,
			recvtime = 0,
			heartamount = 0,
			sendtime = 0,
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

function cls:set_friendid(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["friendid"] = self.__ecol_updated["friendid"] + 1
	if self.__ecol_updated["friendid"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.friendid = v
end

function cls:get_friendid( ... )
	-- body
	return self.__fields.friendid
end

function cls:set_isdel(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["isdel"] = self.__ecol_updated["isdel"] + 1
	if self.__ecol_updated["isdel"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.isdel = v
end

function cls:get_isdel( ... )
	-- body
	return self.__fields.isdel
end

function cls:set_recvtime(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["recvtime"] = self.__ecol_updated["recvtime"] + 1
	if self.__ecol_updated["recvtime"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.recvtime = v
end

function cls:get_recvtime( ... )
	-- body
	return self.__fields.recvtime
end

function cls:set_heartamount(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["heartamount"] = self.__ecol_updated["heartamount"] + 1
	if self.__ecol_updated["heartamount"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.heartamount = v
end

function cls:get_heartamount( ... )
	-- body
	return self.__fields.heartamount
end

function cls:set_sendtime(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["sendtime"] = self.__ecol_updated["sendtime"] + 1
	if self.__ecol_updated["sendtime"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.sendtime = v
end

function cls:get_sendtime( ... )
	-- body
	return self.__fields.sendtime
end


return cls
