local skynet = require "skynet"
local util = require "util"
local const = require "const"

local _M = {}
_M.__data = {}
_M.__count = 0

local _Meta = { user_id=0, csv_id=0, num=0, sub_type=0, level=0, pram1=0, pram2=0, use_type=0}
_Meta.__tname = "u_prop"

function _Meta.__new()
 	-- body
 	local t = {}
 	setmetatable( t, { __index = _Meta } )
 	return t
end 

function _Meta:__insert_db()
	-- body
	local t = {}
	for k,v in pairs(_Meta) do
		if not string.match(k, "^__*") then
			t[k] = assert(self[k])
		end
	end
	skynet.send(util.random_db(), "lua", "command", "insert", self.__tname, t)
end

function _Meta:__update_db(t)
	-- body
	assert(type(t) == "table")
	local columns = {}
	for i,v in ipairs(t) do
		columns[tostring(v)] = self[tostring(v)]
	end
	skynet.send(util.random_db(), "lua", "command", "update", self.__tname, {{ user_id = self.user_id,  csv_id = self.csv_id}}, columns)
end

function _Meta:__serialize()
	-- body
	local r = {}
	for k,v in pairs(_Meta) do
		if not string.match(k, "^__*") then
			r[k] = assert(self[k])
		end
	end
	return r
end

function _M.create(P)
	assert(P)
	local u = _Meta.__new()
	for k,v in pairs(_Meta) do
		if not string.match(k, "^__*") then
			u[k] = assert(P[k])
		end
	end
	return u
end	

function _M.create_gold(user, num)
	-- body
	assert(user)
	local u = _Meta.__new()
	u.user_id = user.csv_id
	u.csv_id = const.GOLD
	u.num = num
	u.name = "gold"
	return u
end

function _M.create_diamond(user, num)
	-- body
	assert(user)
	local u = _Meta.__new()
	u.user_id = user.csv_id
	u.csv_id = const.DIAMOND
	u.num = num
	u.name = "diamond"
	return u
end

function _M:add( u )
	assert(u)
	self.__data[tostring(u.csv_id)] = u
	self.__count = self.__count + 1
end

function _M:get_by_csv_id(csv_id)
	-- body
	return self.__data[tostring(csv_id)]
end

function _M:delete_by_csv_id(csv_id)
	-- body
	self.__data[tostring(csv_id)] = nil
end

function _M:get_count()
	-- body
	return self.__count
end

function _M:update_num(user, csv_id, num)
	-- body
	local prop = user.u_propmgr:get_by_csvid(csv_id)
	if prop then
		prop.num = prop.num + num
		prop:__update_db({"num"})
	else
		local p = game.g_propmgr:get_by_csv_id(csv_id)
		p.user_id = user.id
		p.num = num
		local prop = user.u_propmgr.create(p)
		user.u_propmgr:add(prop)
		prop:__insert_db()
	end
end

return _M
