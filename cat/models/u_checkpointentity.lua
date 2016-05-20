local entitycpp = require "entitycpp"

local cls = class("u_checkpointentity", entitycpp)

function cls:ctor(mgr, P, ... )
	-- body
	self.__head  = mgr.__head
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
			chapter = 0,
			chapter_type0 = 0,
			chapter_type1 = 0,
			chapter_type2 = 0,
		}

	self.__ecol_updated = {
			id = 0,
			user_id = 0,
			chapter = 0,
			chapter_type0 = 0,
			chapter_type1 = 0,
			chapter_type2 = 0,
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

function cls:set_user_id(v, ... )
	-- body
	assert(v)
	self.__fields.user_id = v
end

function cls:get_user_id( ... )
	-- body
	return self.__fields.user_id
end

function cls:set_chapter(v, ... )
	-- body
	assert(v)
	self.__fields.chapter = v
end

function cls:get_chapter( ... )
	-- body
	return self.__fields.chapter
end

function cls:set_chapter_type0(v, ... )
	-- body
	assert(v)
	self.__fields.chapter_type0 = v
end

function cls:get_chapter_type0( ... )
	-- body
	return self.__fields.chapter_type0
end

function cls:set_chapter_type1(v, ... )
	-- body
	assert(v)
	self.__fields.chapter_type1 = v
end

function cls:get_chapter_type1( ... )
	-- body
	return self.__fields.chapter_type1
end

function cls:set_chapter_type2(v, ... )
	-- body
	assert(v)
	self.__fields.chapter_type2 = v
end

function cls:get_chapter_type2( ... )
	-- body
	return self.__fields.chapter_type2
end


return cls
