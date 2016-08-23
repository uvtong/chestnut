local entitycpp = require "entitycpp"

local cls = class("u_ara_worship_rcentity", entitycpp)

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
			ouid = 0,
			date = 0,
			worship = 0,
		}

	self.__ecol_updated = {
			id = 0,
			user_id = 0,
			ouid = 0,
			date = 0,
			worship = 0,
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

function cls:set_ouid(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ouid"] = self.__ecol_updated["ouid"] + 1
	if self.__ecol_updated["ouid"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ouid = v
end

function cls:get_ouid( ... )
	-- body
	return self.__fields.ouid
end

function cls:set_date(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["date"] = self.__ecol_updated["date"] + 1
	if self.__ecol_updated["date"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.date = v
end

function cls:get_date( ... )
	-- body
	return self.__fields.date
end

function cls:set_worship(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["worship"] = self.__ecol_updated["worship"] + 1
	if self.__ecol_updated["worship"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.worship = v
end

function cls:get_worship( ... )
	-- body
	return self.__fields.worship
end


return cls
