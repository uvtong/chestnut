local entitycpp = require "entitycpp"

local cls = class("u_new_emailentity", entitycpp)

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
			uid = 0,
			type = 0,
			title = 0,
			content = 0,
			acctime = 0,
			deltime = 0,
			isread = 0,
			isdel = 0,
			itemsn1 = 0,
			itemnum1 = 0,
			itemsn2 = 0,
			itemnum2 = 0,
			itemsn3 = 0,
			itemnum3 = 0,
			itemsn4 = 0,
			itemnum4 = 0,
			itemsn5 = 0,
			itemnum5 = 0,
			isreward = 0,
		}

	self.__ecol_updated = {
			id = 0,
			csv_id = 0,
			uid = 0,
			type = 0,
			title = 0,
			content = 0,
			acctime = 0,
			deltime = 0,
			isread = 0,
			isdel = 0,
			itemsn1 = 0,
			itemnum1 = 0,
			itemsn2 = 0,
			itemnum2 = 0,
			itemsn3 = 0,
			itemnum3 = 0,
			itemsn4 = 0,
			itemnum4 = 0,
			itemsn5 = 0,
			itemnum5 = 0,
			isreward = 0,
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

function cls:set_title(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["title"] = self.__ecol_updated["title"] + 1
	if self.__ecol_updated["title"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.title = v
end

function cls:get_title( ... )
	-- body
	return self.__fields.title
end

function cls:set_content(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["content"] = self.__ecol_updated["content"] + 1
	if self.__ecol_updated["content"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.content = v
end

function cls:get_content( ... )
	-- body
	return self.__fields.content
end

function cls:set_acctime(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["acctime"] = self.__ecol_updated["acctime"] + 1
	if self.__ecol_updated["acctime"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.acctime = v
end

function cls:get_acctime( ... )
	-- body
	return self.__fields.acctime
end

function cls:set_deltime(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["deltime"] = self.__ecol_updated["deltime"] + 1
	if self.__ecol_updated["deltime"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.deltime = v
end

function cls:get_deltime( ... )
	-- body
	return self.__fields.deltime
end

function cls:set_isread(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["isread"] = self.__ecol_updated["isread"] + 1
	if self.__ecol_updated["isread"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.isread = v
end

function cls:get_isread( ... )
	-- body
	return self.__fields.isread
end

function cls:set_isdel(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["isdel"] = self.__ecol_updated["isdel"] + 1
	if self.__ecol_updated["isdel"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.isdel = v
end

function cls:get_isdel( ... )
	-- body
	return self.__fields.isdel
end

function cls:set_itemsn1(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["itemsn1"] = self.__ecol_updated["itemsn1"] + 1
	if self.__ecol_updated["itemsn1"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.itemsn1 = v
end

function cls:get_itemsn1( ... )
	-- body
	return self.__fields.itemsn1
end

function cls:set_itemnum1(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["itemnum1"] = self.__ecol_updated["itemnum1"] + 1
	if self.__ecol_updated["itemnum1"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.itemnum1 = v
end

function cls:get_itemnum1( ... )
	-- body
	return self.__fields.itemnum1
end

function cls:set_itemsn2(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["itemsn2"] = self.__ecol_updated["itemsn2"] + 1
	if self.__ecol_updated["itemsn2"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.itemsn2 = v
end

function cls:get_itemsn2( ... )
	-- body
	return self.__fields.itemsn2
end

function cls:set_itemnum2(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["itemnum2"] = self.__ecol_updated["itemnum2"] + 1
	if self.__ecol_updated["itemnum2"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.itemnum2 = v
end

function cls:get_itemnum2( ... )
	-- body
	return self.__fields.itemnum2
end

function cls:set_itemsn3(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["itemsn3"] = self.__ecol_updated["itemsn3"] + 1
	if self.__ecol_updated["itemsn3"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.itemsn3 = v
end

function cls:get_itemsn3( ... )
	-- body
	return self.__fields.itemsn3
end

function cls:set_itemnum3(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["itemnum3"] = self.__ecol_updated["itemnum3"] + 1
	if self.__ecol_updated["itemnum3"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.itemnum3 = v
end

function cls:get_itemnum3( ... )
	-- body
	return self.__fields.itemnum3
end

function cls:set_itemsn4(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["itemsn4"] = self.__ecol_updated["itemsn4"] + 1
	if self.__ecol_updated["itemsn4"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.itemsn4 = v
end

function cls:get_itemsn4( ... )
	-- body
	return self.__fields.itemsn4
end

function cls:set_itemnum4(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["itemnum4"] = self.__ecol_updated["itemnum4"] + 1
	if self.__ecol_updated["itemnum4"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.itemnum4 = v
end

function cls:get_itemnum4( ... )
	-- body
	return self.__fields.itemnum4
end

function cls:set_itemsn5(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["itemsn5"] = self.__ecol_updated["itemsn5"] + 1
	if self.__ecol_updated["itemsn5"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.itemsn5 = v
end

function cls:get_itemsn5( ... )
	-- body
	return self.__fields.itemsn5
end

function cls:set_itemnum5(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["itemnum5"] = self.__ecol_updated["itemnum5"] + 1
	if self.__ecol_updated["itemnum5"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.itemnum5 = v
end

function cls:get_itemnum5( ... )
	-- body
	return self.__fields.itemnum5
end

function cls:set_isreward(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["isreward"] = self.__ecol_updated["isreward"] + 1
	if self.__ecol_updated["isreward"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.isreward = v
end

function cls:get_isreward( ... )
	-- body
	return self.__fields.isreward
end


return cls
