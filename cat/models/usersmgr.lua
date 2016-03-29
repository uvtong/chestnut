local skynet = require "skynet"
local util = require "util"

local _M = {}
_M.__data = {}
_M.__count = 0

local _Meta = { csv_id=0, 
				uname=0, 
				uaccount=0, 
				upassword=0, 
				uviplevel=0, 
				config_sound=0, 
				config_music=0, 
				avatar=0, 
				sign=0, 
				c_role_id=0, 
				ifonline=0, 
				level=0, 
				combat=0, 
				defense=0, 
				critical_hit=0, 
				blessing=0, 
				modify_uname_count=0, 
				onlinetime=0, 
				iconid=0, 
				is_valid=0, 
				recharge_rmb=0, 
				recharge_diamond=0, 
				uvip_progress=0, 
				checkin_num=0, 
				checkin_reward_num=0, 
				exercise_level=0, 
				cgold_level=0,
				gold_max=0,
				exp_max=0,
				equipment_enhance_success_rate_up_p=0,
				store_refresh_count_max=0,
				prop_refresh=0,
				arena_frozen_time=0,
				purchase_hp_count=0,
				gain_gold_up_p=0,
				gain_exp_up_p=0,
				purchase_hp_count_max=0,
				SCHOOL_reset_count_max=0,
				SCHOOL_reset_count=0,
				signup_time=0,
				pemail_csv_id=0,
				take_diamonds=0,
				draw_number=0 ,
				ifxilian=0,
				cp_chapter=0,                 -- checkpoint progress
				hanging_starttime=0,
				hanging_checkpoint=0,
				cp_battle_id=0,
				cp_battle_enter_starttime=0 }

_Meta.__tname = "users"

function _Meta:__insert_db( priority )
	-- body
	assert(priority)
	local t = {}
	for k,v in pairs(_Meta) do
		if not string.match(k, "^__*") then
			t[k] = self[k]
		end
	end
	skynet.send(util.random_db(), "lua", "command", "insert", self.__tname, t , priority)
end

function _Meta:__update_db(t, priority)
	-- body
	assert(priority)
	assert(type(t) == "table")
	local columns = {}
	for i,v in ipairs(t) do
		columns[tostring(v)] = self[tostring(v)]
	end
	skynet.send(util.random_db(), "lua", "command", "update", self.__tname, {{ csv_id = self.csv_id }}, columns, priority)
end

function _Meta:__get(key)
	-- body
	assert(type(key) == "string")
	return assert(self[key])
end

function _Meta:__set(key, value)
	-- body
	assert(type(key) == "string")
	self[key] = value
	if key == "level" then
		notification.handler[self.EUSER_LEVEL](self.EUSER_LEVEL)
	end
end

function _Meta.__new()
 	-- body
 	local t = {}
 	setmetatable( t, { __index = _Meta } )
 	return t
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
	self.__data[tostring(u.csv_id)] = u
	self.__count = self.__count + 1
end

function _M:get_by_csv_id(csv_id)
	-- body
	return self.__data[tostring(csv_id)]
end

function _M:delete_by_csv_id(csv_id)
	-- body
	-- local u = assert(self.__data[tostring(csv_id)])
	-- u.is_valid = 0
	-- u:__update_db({"is_valid"})
	-- assert(false)
end

function _M:get_count()
	-- body
	return self.__count
end

function _M:clear()
	self.__data = {}
	self.__count = 0
end

function _M:update_db(priority)
	-- body
	-- assert(priority)
	-- local columns = { "finished", "reward_collected", "is_unlock"}
	-- local condition = { {user_id = self.__user_id}, {csv_id = {}}}
	-- skynet.send(util.random_db(), "lua", "command", "update_all", _Meta.__tname, condition, columns, self.__data)
end

return _M
