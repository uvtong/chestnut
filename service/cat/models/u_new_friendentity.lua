local entitycpp = require "entitycpp"

local cls = class("u_new_friendentity", entitycpp)

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
			self_csv_id = 0,
			friend_csv_id = 0,
			isdelete = 0,
			recvtime = 0,
			heartamount = 0,
			update_time = 0,
			ifrecved = 0,
			ifsent = 0,
		}

	self.__ecol_updated = {
			id = 0,
			self_csv_id = 0,
			friend_csv_id = 0,
			isdelete = 0,
			recvtime = 0,
			heartamount = 0,
			update_time = 0,
			ifrecved = 0,
			ifsent = 0,
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

function cls:set_self_csv_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["self_csv_id"] = self.__ecol_updated["self_csv_id"] + 1
	if self.__ecol_updated["self_csv_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.self_csv_id = v
end

function cls:get_self_csv_id( ... )
	-- body
	return self.__fields.self_csv_id
end

function cls:set_friend_csv_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["friend_csv_id"] = self.__ecol_updated["friend_csv_id"] + 1
	if self.__ecol_updated["friend_csv_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.friend_csv_id = v
end

function cls:get_friend_csv_id( ... )
	-- body
	return self.__fields.friend_csv_id
end

function cls:set_isdelete(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["isdelete"] = self.__ecol_updated["isdelete"] + 1
	if self.__ecol_updated["isdelete"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.isdelete = v
end

function cls:get_isdelete( ... )
	-- body
	return self.__fields.isdelete
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

function cls:set_ifrecved(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ifrecved"] = self.__ecol_updated["ifrecved"] + 1
	if self.__ecol_updated["ifrecved"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ifrecved = v
end

function cls:get_ifrecved( ... )
	-- body
	return self.__fields.ifrecved
end

function cls:set_ifsent(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ifsent"] = self.__ecol_updated["ifsent"] + 1
	if self.__ecol_updated["ifsent"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ifsent = v
end

function cls:get_ifsent( ... )
	-- body
	return self.__fields.ifsent
end


return cls
