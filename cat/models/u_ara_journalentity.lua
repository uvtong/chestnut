local entitycpp = require "entitycpp"

local cls = class("u_ara_journalentity", entitycpp)

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
			csv_id = 0,
			date = 0,
			ara_clg_tms = 0,
			ara_clg_tms_pur_tms = 0,
			ara_rfh_tms = 0,
			ara_bat_ser = 0,
		}

	self.__ecol_updated = {
			id = 0,
			user_id = 0,
			csv_id = 0,
			date = 0,
			ara_clg_tms = 0,
			ara_clg_tms_pur_tms = 0,
			ara_rfh_tms = 0,
			ara_bat_ser = 0,
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

function cls:set_ara_clg_tms(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_clg_tms"] = self.__ecol_updated["ara_clg_tms"] + 1
	if self.__ecol_updated["ara_clg_tms"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_clg_tms = v
end

function cls:get_ara_clg_tms( ... )
	-- body
	return self.__fields.ara_clg_tms
end

function cls:set_ara_clg_tms_pur_tms(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_clg_tms_pur_tms"] = self.__ecol_updated["ara_clg_tms_pur_tms"] + 1
	if self.__ecol_updated["ara_clg_tms_pur_tms"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_clg_tms_pur_tms = v
end

function cls:get_ara_clg_tms_pur_tms( ... )
	-- body
	return self.__fields.ara_clg_tms_pur_tms
end

function cls:set_ara_rfh_tms(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_rfh_tms"] = self.__ecol_updated["ara_rfh_tms"] + 1
	if self.__ecol_updated["ara_rfh_tms"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_rfh_tms = v
end

function cls:get_ara_rfh_tms( ... )
	-- body
	return self.__fields.ara_rfh_tms
end

function cls:set_ara_bat_ser(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_bat_ser"] = self.__ecol_updated["ara_bat_ser"] + 1
	if self.__ecol_updated["ara_bat_ser"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_bat_ser = v
end

function cls:get_ara_bat_ser( ... )
	-- body
	return self.__fields.ara_bat_ser
end


return cls
