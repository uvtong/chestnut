local skynet = require "skynet"
local util = require "util"
local loader = require "loader"
local const = require "const"

function CMD.query_g_mainreward(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_mainrewardmgr:get_by_csv_id(pk)
		if r then
			return r
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		return game.g_mainrewardmgr.__data
	else
		assert(false)
	end
end

function CMD.query_g_monster()
	-- body
	if type(pk) == "number" then
		local r = game.g_monstermgr:get_by_csv_id(pk)
		if r then
			return r
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		return game.g_monstermgr.__data
	else
		assert(false)
	end
end

function CMD.query_g_prop(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_propmgr:get_by_csv_id(pk)
		if r then
			return r
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		return game.g_propmgr.__data
	else
		assert(false)
	end
end

function CMD.query_g_recharge(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_rechargemgr:get_by_csv_id(pk)
		if r then
			return r
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		return game.g_rechargemgr.__data
	else
		assert(false)
	end
end

function CMD.query_g_recharge_vip_reward(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_recharge_vip_rewardmgr:get_by_vip(pk)
		if r then
			return r
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		return game.g_recharge_vip_rewardmgr.__data
	else
		assert(false)
	end
end

function CMD.query_g_role(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_rolemgr:get_by_csv_id(pk)
		if r then
			return r
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		return game.g_rolemgr.__data
	else
		assert(false)
	end
end

function CMD.query_g_role_effect(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_role_effectmgr:get_by_csv_id(pk)
		if r then
			return r
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		return game.g_role_effectmgr.__data
	else
		assert(false)
	end
end

function CMD.query_g_role_star(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_role_starmgr:get_by_csv_id(pk)
		if r then
			return r
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		return game.g_role_starmgr.__data
	else
		assert(false)
	end
end

function CMD.query_g_subreward(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_subrewardmgr:get_by_csv_id(pk)
		if r then
			return r
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		return game.g_subrewardmgr.__data
	else
		assert(false)
	end
end

function CMD.query_g_user_level(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_user_levelmgr:get_by_level(pk)
		if r then
			return r
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		return game.g_user_levelmgr.__data
	else
		assert(false)
	end
end

function CMD.query_g_lilian_phy_power(pk)
	assert(pk)
	if type(pk) == "number" then
		local r = game.g_lilian_phy_powermgr:get_by_csv_id(pk)
		if r then
			return r
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		return game.g_lilian_phy_powermgr.__data
	else
		assert(false)
	end
end

function CMD.query_g_config(pk)
	-- body
	if type(pk) == "string" then
		return game.g_configmgr:get_by_csv_id(1)[pk]
	else
		local r = game.g_configmgr:get_by_csv_id(1)
		local ptr = tptr.topointer(r)
		return ptr
	end
end

function CMD.query_g_xilian_cost(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_xilian_costmgr:get_by_csv_id(pk)
		if r then
			return r
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		return game.g_xilian_costmgr.__data
	else
		assert(false)
	end
end

function CMD.query_g_property_pool(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_property_poolmgr:get_by_csv_id(pk)
		if r then
			return r
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		assert(game.g_property_poolmgr:get_count() > 0)
		for k,v in pairs(game.g_property_poolmgr.__data) do
			print(k,v)
		end
		return game.g_property_poolmgr.__data
	else
		assert(false)
	end
end

function CMD.query_g_property_pool_second(pk, T)
	-- body
	if type(pk) == "number" then
		if pk > 0 then
			local r = game.g_property_pool_secondmgr:get_by_csv_id(pk)
			if r then
				return r
			else
				error "there are insufficient data"
			end
		else
			assert(type(T) == "number")
			local second = {}
			for k,v in pairs(game.g_property_pool_secondmgr.__data) do
				if v.property_pool_id == T then
					table.insert(second, v)
				end
			end
			return second
		end
	elseif type(pk) == "nil" then
		return game.g_property_pool_secondmgr.__data
	else
		assert(false)
	end
end

function CMD.query_g_randomval()
	-- body
	return assert(game.g_randomvalmgr.__data)
end

function CMD.query_g_equipment_effect(pk)
	-- body
	if type(pk) == "number" then
		local r = game.query_g_equipment_effectmgr:get_by_level(pk)
		if r then
			return r
		else
			error "there are insufficient data"
		end
	else
		assert(false)
	end
end

local function guid(csv_id)
	-- body
	local r = game.g_uidmgr:get_by_csv_id(csv_id)
	if not r then
		local t = { csv_id=csv_id, entropy=1}
		t = game.g_uidmgr.create(t)
		game.g_uidmgr:add(t)
		t:__insert_db(const.DB_PRIORITY_2)
		return t.entropy
	else
		r.entropy = tonumber(r.entropy) + 1
		return r.entropy
	end
end

local function u_guid(user_id, csv_id)
	-- body
	csv_id = user_id * 10000 + csv_id
	return guid(csv_id)
end

function CMD.u_guid(user_id, csv_id)
	-- body
	assert(type(user_id) == "number" and user_id > 0)
	assert(type(csv_id) == "number" and csv_id > 0)
	return u_guid(user_id, csv_id)
end

function CMD.guid(csv_id)
	-- body
	assert(type(csv_id) == "number" and csv_id > 0)
	return guid(csv_id)
end

local function update_db()
	-- body
	while true do
		if game then
			game.g_uidmgr:update_db(const.DB_PRIORITY_3)
			game.g_randomvalmgr:update_db(const.DB_PRIORITY_3)
		end
		skynet.sleep(100 * 60) -- 1ti == 0.01s
	end
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		print("called", command)
		local f = CMD[command]
		local result = f(...)
		if result then
			skynet.ret(skynet.pack(result))
		end
	end)
	-- skynet.fork(update_db)
	skynet.register ".game"
end)
