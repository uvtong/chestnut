local entitycpp = require "entitycpp"

local cls = class("g_user_levelentity", entitycpp)

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
			level = 0,
			exp = 0,
			combat = 0,
			defense = 0,
			critical_hit = 0,
			skill = 0,
			gold_max = 0,
			exp_max = 0,
		}

	self.__ecol_updated = {
			id = 0,
			level = 0,
			exp = 0,
			combat = 0,
			defense = 0,
			critical_hit = 0,
			skill = 0,
			gold_max = 0,
			exp_max = 0,
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

function cls:set_level(v, ... )
	-- body
	assert(v)
	self.__fields.level = v
end

function cls:get_level( ... )
	-- body
	return self.__fields.level
end

function cls:set_exp(v, ... )
	-- body
	assert(v)
	self.__fields.exp = v
end

function cls:get_exp( ... )
	-- body
	return self.__fields.exp
end

function cls:set_combat(v, ... )
	-- body
	assert(v)
	self.__fields.combat = v
end

function cls:get_combat( ... )
	-- body
	return self.__fields.combat
end

function cls:set_defense(v, ... )
	-- body
	assert(v)
	self.__fields.defense = v
end

function cls:get_defense( ... )
	-- body
	return self.__fields.defense
end

function cls:set_critical_hit(v, ... )
	-- body
	assert(v)
	self.__fields.critical_hit = v
end

function cls:get_critical_hit( ... )
	-- body
	return self.__fields.critical_hit
end

function cls:set_skill(v, ... )
	-- body
	assert(v)
	self.__fields.skill = v
end

function cls:get_skill( ... )
	-- body
	return self.__fields.skill
end

function cls:set_gold_max(v, ... )
	-- body
	assert(v)
	self.__fields.gold_max = v
end

function cls:get_gold_max( ... )
	-- body
	return self.__fields.gold_max
end

function cls:set_exp_max(v, ... )
	-- body
	assert(v)
	self.__fields.exp_max = v
end

function cls:get_exp_max( ... )
	-- body
	return self.__fields.exp_max
end


return cls
