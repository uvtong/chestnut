local entitycpp = require "entitycpp"

local cls = class("g_equipment_effectentity", entitycpp)

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
			level = 0,
			effect = 0,
		}

	self.__ecol_updated = {
			level = 0,
			effect = 0,
		}

	for k,v in pairs(self.__head) do
		self.__fields[k] = assert(P[k], string.format("no exist %s", k))
	end
	return self
end

function cls:set_level(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["level"] = self.__ecol_updated["level"] + 1
	if self.__ecol_updated["level"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.level = v
end

function cls:get_level( ... )
	-- body
	return self.__fields.level
end

function cls:set_effect(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["effect"] = self.__ecol_updated["effect"] + 1
	if self.__ecol_updated["effect"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.effect = v
end

function cls:get_effect( ... )
	-- body
	return self.__fields.effect
end


return cls
