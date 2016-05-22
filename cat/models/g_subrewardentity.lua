local entitycpp = require "entitycpp"

local cls = class("g_subrewardentity", entitycpp)

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
			csv_id = 0,
			propid = 0,
			propnum = 0,
			proptype = 0,
		}

	self.__ecol_updated = {
			id = 0,
			csv_id = 0,
			propid = 0,
			propnum = 0,
			proptype = 0,
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

function cls:set_csv_id(v, ... )
	-- body
	assert(v)
	self.__fields.csv_id = v
end

function cls:get_csv_id( ... )
	-- body
	return self.__fields.csv_id
end

function cls:set_propid(v, ... )
	-- body
	assert(v)
	self.__fields.propid = v
end

function cls:get_propid( ... )
	-- body
	return self.__fields.propid
end

function cls:set_propnum(v, ... )
	-- body
	assert(v)
	self.__fields.propnum = v
end

function cls:get_propnum( ... )
	-- body
	return self.__fields.propnum
end

function cls:set_proptype(v, ... )
	-- body
	assert(v)
	self.__fields.proptype = v
end

function cls:get_proptype( ... )
	-- body
	return self.__fields.proptype
end


return cls
