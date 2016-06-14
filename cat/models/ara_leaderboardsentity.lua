local entitycpp = require "entitycpp"

local cls = class("ara_leaderboardsentity", entitycpp)

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
			uid = 0,
			ranking = 0,
			k = 0,
		}

	self.__ecol_updated = {
			uid = 0,
			ranking = 0,
			k = 0,
		}

	for k,v in pairs(self.__head) do
		self.__fields[k] = assert(P[k], string.format("no exist %s", k))
	end
	return self
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

function cls:set_ranking(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ranking"] = self.__ecol_updated["ranking"] + 1
	if self.__ecol_updated["ranking"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ranking = v
end

function cls:get_ranking( ... )
	-- body
	return self.__fields.ranking
end

function cls:set_k(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["k"] = self.__ecol_updated["k"] + 1
	if self.__ecol_updated["k"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.k = v
end

function cls:get_k( ... )
	-- body
	return self.__fields.k
end


return cls
