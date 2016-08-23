local entitycpp = require "entitycpp"

local cls = class("u_checkinentity", entitycpp)

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
			if_latest = 0,
			user_id = 0,
			u_checkin_time = 0,
			update_time = 0,
		}

	self.__ecol_updated = {
			id = 0,
			if_latest = 0,
			user_id = 0,
			u_checkin_time = 0,
			update_time = 0,
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

function cls:set_if_latest(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["if_latest"] = self.__ecol_updated["if_latest"] + 1
	if self.__ecol_updated["if_latest"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.if_latest = v
end

function cls:get_if_latest( ... )
	-- body
	return self.__fields.if_latest
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

function cls:set_u_checkin_time(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["u_checkin_time"] = self.__ecol_updated["u_checkin_time"] + 1
	if self.__ecol_updated["u_checkin_time"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.u_checkin_time = v
end

function cls:get_u_checkin_time( ... )
	-- body
	return self.__fields.u_checkin_time
end

function cls:set_update_time(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["update_time"] = self.__ecol_updated["update_time"] + 1
	if self.__ecol_updated["update_time"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.update_time = v
end

function cls:get_update_time( ... )
	-- body
	return self.__fields.update_time
end


return cls
