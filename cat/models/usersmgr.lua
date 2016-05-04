local skynet = require "skynet"
local util = require "util"
local db_common = require "db_common"
local query = require "query"

local _M = {}
_M.__data = {}
_M.__count = 0

local _Meta = { csv_id=0, 
				uname=0,
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
				cp_hanging_id=0,
				cp_battle_id=0,
				cp_battle_chapter=0 ,
				lilian_level = 0,
				lilian_exp = 0,
				lilian_phy_power = 0,
				purch_lilian_phy_power = 0
				}

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
	local sql = db_common.insert(self.__tname, t)
	query.insert_sql(self.__tname, sql, query.DB_PRIORITY_3)
end

function _Meta:__insert_db_wait(priority)
	-- body
	assert(priority)
	local t = {}
	for k,v in pairs(_Meta) do
		if not string.match(k, "^__*") then
			t[k] = self[k]
		end
	end
	return skynet.call(util.random_db(), "lua", "command", "insert_wait", self.__tname, t , priority)
end

function _Meta:__update_db(t, priority)
	-- body
	assert(priority)
	assert(type(t) == "table")
	local columns = {}
	for i,v in ipairs(t) do
		columns[tostring(v)] = self[tostring(v)]
	end
	local sql = util.update(self.__tname, {{ csv_id = self.csv_id }}, columns)
	skynet.send(util.random_db(), "lua", "command", "update_sql", self.__tname, sql, priority)
end

function _Meta:__update_db_all(priority)
	-- body
	assert(priority)
	local t = {}
	for k,v in pairs(_Meta) do
		if not string.match(k, "^__*") then
			if k ~= "csv_id" then
				table.insert(t, k)
			end
		end
	end
	self:__update_db(t, priority)
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

function _M.create_default(uid)
	-- body
	local level = skynet.call(".game", "lua", "query_g_user_level", 1)
	local vip = skynet.call(".game", "lua", "query_g_recharge_vip_reward", 0)
	local t = { csv_id= uid,
				uname="nihao",
				uviplevel=3,
				config_sound=1, 
				config_music=1, 
				avatar=0, 
				sign="peferct ", 
				c_role_id=1, 
				ifonline=0, 
				level=level.level, 
				combat=level.combat, 
				defense=level.defense, 
				critical_hit=level.critical_hit, 
				blessing=0, 
				modify_uname_count=0, 
				onlinetime=0, 
				iconid=0, 
				is_valid=1, 
				recharge_rmb=0, 
				goods_refresh_count=0, 
				recharge_diamond=0, 
				uvip_progress=0, 
				checkin_num=0, 
				checkin_reward_num=0, 
				exercise_level=0, 
				cgold_level=0,
				gold_max=level.gold_max + math.floor(level.gold_max * vip.gold_max_up_p/100),
				exp_max=level.exp_max + math.floor(level.exp_max * vip.exp_max_up_p/100),
				equipment_enhance_success_rate_up_p=assert(vip.equipment_enhance_success_rate_up_p),
				store_refresh_count_max=assert(vip.store_refresh_count_max),
				prop_refresh=0,
				arena_frozen_time=0,
				purchase_hp_count=0, 
				gain_gold_up_p=0,
				gain_exp_up_p=0,
				purchase_hp_count_max=4 ,--assert(vip.purchase_hp_count_max),
				SCHOOL_reset_count_max=assert(vip.SCHOOL_reset_count_max),
				SCHOOL_reset_count=0,
				signup_time=os.time() ,
				pemail_csv_id = 0,
				take_diamonds=0,
				draw_number=0 ,
				ifxilian = 0,              -- 
				cp_chapter=1,                 -- checkpoint progress 1
				cp_hanging_id=0,
				cp_battle_id=0,
				cp_battle_chapter=0,
				lilian_level = 1,
				lilian_exp = 0,
				lilian_phy_power = 120,
				purch_lilian_phy_power = 0,
				cp_hanging_drop_starttime=0,
				}
	local u = _M.create(t)
	return u
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
