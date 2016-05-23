local entitycpp = require "entitycpp"

local cls = class("g_checkpointentity", entitycpp)

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
			csv_id = 0,
			chapter = 0,
			combat = 0,
			level = 0,
			name = 0,
			checkpoint = 0,
			type = 0,
			cd = 0,
			gain_gold = 0,
			gain_exp = 0,
			drop = 0,
			reward = 0,
			monster_csv_id1 = 0,
			monster_csv_id2 = 0,
			monster_csv_id3 = 0,
			drop_cd = 0,
		}

	self.__ecol_updated = {
			csv_id = 0,
			chapter = 0,
			combat = 0,
			level = 0,
			name = 0,
			checkpoint = 0,
			type = 0,
			cd = 0,
			gain_gold = 0,
			gain_exp = 0,
			drop = 0,
			reward = 0,
			monster_csv_id1 = 0,
			monster_csv_id2 = 0,
			monster_csv_id3 = 0,
			drop_cd = 0,
		}

	for k,v in pairs(self.__head) do
		self.__fields[k] = assert(P[k], string.format("no exist %s", k))
	end
	return self
end

function cls:set_csv_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["csv_id"] = self.__ecol_updated["csv_id"] + 1
	if self.__ecol_updated["csv_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.csv_id = v
end

function cls:get_csv_id( ... )
	-- body
	return self.__fields.csv_id
end

function cls:set_chapter(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["chapter"] = self.__ecol_updated["chapter"] + 1
	if self.__ecol_updated["chapter"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.chapter = v
end

function cls:get_chapter( ... )
	-- body
	return self.__fields.chapter
end

function cls:set_combat(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["combat"] = self.__ecol_updated["combat"] + 1
	if self.__ecol_updated["combat"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.combat = v
end

function cls:get_combat( ... )
	-- body
	return self.__fields.combat
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

function cls:set_name(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["name"] = self.__ecol_updated["name"] + 1
	if self.__ecol_updated["name"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.name = v
end

function cls:get_name( ... )
	-- body
	return self.__fields.name
end

function cls:set_checkpoint(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["checkpoint"] = self.__ecol_updated["checkpoint"] + 1
	if self.__ecol_updated["checkpoint"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.checkpoint = v
end

function cls:get_checkpoint( ... )
	-- body
	return self.__fields.checkpoint
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

function cls:set_cd(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["cd"] = self.__ecol_updated["cd"] + 1
	if self.__ecol_updated["cd"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.cd = v
end

function cls:get_cd( ... )
	-- body
	return self.__fields.cd
end

function cls:set_gain_gold(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["gain_gold"] = self.__ecol_updated["gain_gold"] + 1
	if self.__ecol_updated["gain_gold"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.gain_gold = v
end

function cls:get_gain_gold( ... )
	-- body
	return self.__fields.gain_gold
end

function cls:set_gain_exp(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["gain_exp"] = self.__ecol_updated["gain_exp"] + 1
	if self.__ecol_updated["gain_exp"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.gain_exp = v
end

function cls:get_gain_exp( ... )
	-- body
	return self.__fields.gain_exp
end

function cls:set_drop(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["drop"] = self.__ecol_updated["drop"] + 1
	if self.__ecol_updated["drop"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.drop = v
end

function cls:get_drop( ... )
	-- body
	return self.__fields.drop
end

function cls:set_reward(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["reward"] = self.__ecol_updated["reward"] + 1
	if self.__ecol_updated["reward"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.reward = v
end

function cls:get_reward( ... )
	-- body
	return self.__fields.reward
end

function cls:set_monster_csv_id1(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["monster_csv_id1"] = self.__ecol_updated["monster_csv_id1"] + 1
	if self.__ecol_updated["monster_csv_id1"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.monster_csv_id1 = v
end

function cls:get_monster_csv_id1( ... )
	-- body
	return self.__fields.monster_csv_id1
end

function cls:set_monster_csv_id2(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["monster_csv_id2"] = self.__ecol_updated["monster_csv_id2"] + 1
	if self.__ecol_updated["monster_csv_id2"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.monster_csv_id2 = v
end

function cls:get_monster_csv_id2( ... )
	-- body
	return self.__fields.monster_csv_id2
end

function cls:set_monster_csv_id3(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["monster_csv_id3"] = self.__ecol_updated["monster_csv_id3"] + 1
	if self.__ecol_updated["monster_csv_id3"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.monster_csv_id3 = v
end

function cls:get_monster_csv_id3( ... )
	-- body
	return self.__fields.monster_csv_id3
end

function cls:set_drop_cd(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["drop_cd"] = self.__ecol_updated["drop_cd"] + 1
	if self.__ecol_updated["drop_cd"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.drop_cd = v
end

function cls:get_drop_cd( ... )
	-- body
	return self.__fields.drop_cd
end


return cls
