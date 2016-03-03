local skynet = require "skynet"
local util = require "util"

local _M = {}
_M.__data = {}
_M.__count = 0

local _Meta = { vip=0, 
				diamond=0, 
				gain_gold_up_p=0, 
				gain_exp_up_p=0, 
				gold_max_up_p=0, 
				exp_max_up_p=0, 
				equipment_enhance_success_rate_up_p=0, 
				prop_refresh_reduction_p=0,
				arena_frozen_time_reduction_p=0,
				purchase_hp_count_max=0,
				SCHOOL_reset_count_max=0,
				rewared=0,
				store_refresh_count_max=0,
				purchasable_gift=0,
				marked_diamond=0,
				purchasable_diamond=0}

_Meta.__tname = "g_recharge_vip_reward"

function _Meta.__new()
 	-- body
 	local t = {}
 	setmetatable( t, { __index = _Meta } )
 	return t
end 

function _Meta:__insert_db()
	-- body
	local t = {}
	for k,v in pairs(self) do
		if not string.match(k, "^__*") then
			t[k] = self[k]
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
	skynet.send(util.random_db(), "lua", "command", "update", self.__tname, {{ id = self.id }}, columns)
end

function _Meta:__serialize()
	-- body
	local r = {}
	for k,v in pairs(_Meta) do
		if not string.match(k, "^__*") then
			r[k] = self[k]
		end
	end
	return r
end

function _M.create( P )
	assert(P)
	local u = _Meta.__new()
	for k,v in pairs(_Meta) do
		if not string.match(k, "^__*") then
			u[k] = assert(P[k])
		end
	end
	return u
end	

function _M:add( u )
	assert(u)
	self.__data[tostring(u.vip)] = u
	self.__count = self.__count + 1
end
	
function _M:get_by_vip(vip)
	-- body
	return self.__data[tostring(vip)]
end

function _M:get_count()
	-- body
	return self.__count
end

return _M

