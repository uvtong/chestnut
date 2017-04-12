local skynet = require "skynet"
local mc = require "multicast"
local query = require "query"
local util = require "util"
local loader = require "load_game"
local const = require "const"
local game

local CMD = {}

function CMD.ptr()
	-- body
	return tptr.topointer(game)
end

function CMD.query(table_name, pk)
	-- body
	local mgr = string.format("%smgr", table_name)
	local row = game[mgr]:get(pk)
	return row.__fields
end

function CMD.query_key(table_name, pk, key)
	-- body
	local mgr = string.format("%smgr", table_name)
	local row = game[mgr]:get(pk)
	return row[key]
end

function CMD.query_g_achievement(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_achievementmgr:get_by_csv_id(pk)
		if r then
			return r.__fields
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		return game.g_achievementmgr.__data
	else
		print(pk)
		if type(pk) == "table" then
			for k,v in pairs(pk) do
				print(k,v)
			end
		end
		assert(false)
	end
end

function CMD.query_g_checkin(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_checkinmgr:get_by_csv_id(pk)
		if r then
			return r.__fields
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		return game.g_checkinmgr.__data
	else
		assert(false)
	end
end

function CMD.query_g_checkin_total(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_checkin_totalmgr:get_by_csv_id(pk)
		if r then
			return r.__fields
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		return game.g_checkin_totalmgr.__data
	else
		assert(false)
	end
end

function CMD.query_g_checkpoint(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_checkpointmgr:get_by_csv_id(pk)
		if r then
			return r.__fields
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		return game.g_checkpointmgr.__data
	else
		assert(false)
	end
end

function CMD.query_g_checkpoint_chapter(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_checkpoint_chaptermgr:get_by_chapter(pk)
		if r then
			return r.__fields
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		return game.g_checkpoint_chaptermgr.__data
	else
		assert(false)
	end
end

function CMD.query_g_daily_task_by_id(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_daily_taskmgr:get_by_csv_id(pk)
		if r then
			return r.__fields
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		return game.g_daily_taskmgr.__data
	else
		assert(false)
	end
end

function CMD.query_g_drawcost(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_drawcostmgr:get_by_csv_id(pk)
		if r then
			return r.__fields
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		return game.g_drawcostmgr.__data 
	else
		assert(false)
	end
end

function CMD.query_g_draw_role(pk)
	if type(pk) == "number" then
		local r = game.g_draw_rolemgr:get_by_csv_id(pk)
		if r then
			return r.__fields
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		return game.g_draw_rolemgr.__data
	else
		assert(false)
	end
end

function CMD.query_g_lilian_event(pk)
	if type(pk) == "number" then
		local r = game.g_lilian_eventmgr:get_by_csv_id(pk)
		if r then
			return r.__fields
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		return game.g_lilian_eventmgr.__data
	else
		assert(false)
	end
end

function CMD.query_g_lilian_invitation(pk)
	if type(pk) == "number" then
		local r = game.g_lilian_invitationmgr:get_by_csv_id(pk)
		if r then
			return r.__fields
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		return game.g_lilian_invitationmgr.__data
	else
		assert(false)
	end
end

function CMD.query_g_lilian_level(pk)
	if type(pk) == "number" then
		local r = game.g_lilian_levelmgr:get_by_csv_id(pk)
		if r then
			return r.__fields
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		return game.g_lilian_levelmgr.__data
	else
		assert(false)
	end
end

function CMD.query_g_lilian_quanguan(pk)
	if type(pk) == "number" then
		local r = game.g_lilian_quanguanmgr:get_by_csv_id(pk)
		if r then
			return r.__fields
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		return game.g_lilian_quanguanmgr.__data
	else
		assert(false)
	end
end

function CMD.query_g_equipment(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_equipmentmgr:get_by_csv_id(pk)
		if r then
			for k,v in pairs(r.__fields) do
				print(k,v)
			end
			return r.__fields
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		local r = {}
		for k,v in pairs(game.g_equipmentmgr.__data) do
			r[k] = v.__fields
		end
		return r
	else
		assert(false)
	end
end

function CMD.query_g_equipment_enhance(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_equipment_enhancemgr:get_by_csv_id(pk)
		if r then
			return r.__fields
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		return game.g_equipment_enhancemgr.__data
	else
		assert(false)
	end
end

function CMD.query_g_goods(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_goodsmgr:get_by_csv_id(pk)
		if r then
			return r.__fields
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		local r = {}
		for k,v in pairs(game.g_goodsmgr.__data) do
			r[k] = v.__fields
		end
		return r
	elseif type(pk) == "table" then
		local r = {}
		for i,v in ipairs(pk) do
			local t = assert(game.g_goodsmgr:get_by_csv_id(v))
			table.insert(r, t)
		end
		return r
	else
		assert(false)
	end
end

function CMD:query_g_daily_task()
	for k, v in pairs(game.g_daily_taskmgr.__data) do
		return v.__fields
	end
	assert(false)
end

function CMD.query_g_goods_refresh_cost(pk)
	-- body
	print("abcedfe")
	if type(pk) == "number" then
		local r = game.g_goods_refresh_costmgr:get_by_csv_id(pk)
		if r then
			return r.__fields
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		return game.g_goods_refresh_costmgr.__data
	else
		assert(false)
	end
end

function CMD.query_g_kungfu(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_kungfumgr:get_by_csv_id(pk)
		if r then
			return r.__fields
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		return game.g_kungfumgr.__data
	else
		assert(false)
	end
end

function CMD.query_g_mainreward(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_mainrewardmgr:get_by_csv_id(pk)
		if r then
			return r.__fields
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		return game.g_mainrewardmgr.__data
	else
		assert(false)
	end
end

function CMD.query_g_monster(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_monstermgr:get_by_csv_id(pk)
		if r then
			print("*****************************************************g_monster1", r.combat, r.defense, r.critical_hit)
			return r.__fields
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		print("*****************************************************g_monster1")
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
			return r.__fields
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
			return r.__fields
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		local l = {}
		for k,v in pairs(game.g_rechargemgr.__data) do
			l[k] = v.__fields
		end
		return l
	else
		assert(false)
	end
end

function CMD.query_g_recharge_vip_reward(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_recharge_vip_rewardmgr:get(pk)
		if r then
			return r.__fields
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		local l = {}
		for k,v in pairs(game.g_recharge_vip_rewardmgr.__data) do
			l[k] = v.__fields
		end
		return l
	else
		assert(false)
	end
end

function CMD.query_g_role(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_rolemgr:get_by_csv_id(pk)
		if r then
			return r.__fields
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		local l = {}
		for k,v in pairs(game.g_rolemgr.__data) do
			l[k] = v.__fields
		end
		return l
	else
		assert(false)
	end
end

function CMD.query_g_role_effect(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_role_effectmgr:get_by_csv_id(pk)
		if r then
			return r.__fields
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
			return r.__fields
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
			return r.__fields
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
		local r = game.g_user_levelmgr:get(pk)
		if r then
			return r.__fields
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
			return r.__fields
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
			return r.__fields
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
			return r.__fields
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		assert(game.g_property_poolmgr:get_count() > 0)
		local l = {}
		for k,v in pairs(game.g_property_poolmgr.__data) do
			l[k] = v.__fields
		end
		return l
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
				return r.__fields
			else
				error "there are insufficient data"
			end
		else
			assert(type(T) == "number")
			local r = {}
			for k,v in pairs(game.g_property_pool_secondmgr.__data) do
				if v:get_property_pool_id() == T then
					r[k] = v.__fields
				end
			end
			return r
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
		local r = game.g_equipment_effectmgr:get(pk)
		if r then
			return r.__fields
		else
			error "there are insufficient data"
		end
	else
		assert(false)
	end
end

function CMD.query_g_ara_pts(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_ara_ptsmgr:get_by_csv_id(pk)
		if r then
			return r.__fields
		else
			error "there are insufficient data"
		end
	else
		assert(false)
	end
end

function CMD.query_g_ara_rnk_rwd(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_ara_rnk_rwdmgr:get_by_csv_id(pk)
		for i,v in ipairs(game.g_ara_rnk_rwdmgr.__data) do
			if v.csv_id >= pk then
				return v.reward
			end
		end
	else
		assert(false)
	end
end

function CMD.query_g_ara_tms(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_ara_tmsmgr:get_by_csv_id(pk)
		if r then
			return r.__fields
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
		t = game.g_uidmgr:create(t)
		game.g_uidmgr:add(t)
		return t:get_field("entropy")
	else
		local entropy = r:get_field("entropy")
		entropy = entropy + 1
		r:set_field("entropy", entropy)
		return entropy
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
	print("########################################3", csv_id)
	assert(type(csv_id) == "number" and csv_id > 0)
	return guid(csv_id)
end

local function update_db()
	-- body
	while true do
		if game then
			-- x = x + 1
			-- local sql = string.format("update g_uid set entropy= %d where csv_id = 2;", x)
			-- query.write(wdb, "g_uid", sql, const.DB_PRIORITY_1)
			game.g_uidmgr:update()
			-- 
			-- game.g_randomvalmgr:update_db()
		end
		skynet.sleep(100 * 60) -- 1ti == 0.01s
	end
end

local START_SUBSCRIBE = {}

function START_SUBSCRIBE.finish(source, ...)
	-- body
	-- flush_db(const.DB_PRIORITY_1)
	game.g_uidmgr:update()
	print(string.format("the node agent %d will be finished. you should clean something.", skynet.self()))
	skynet.send(source, "lua", "exit")
end

local function start_subscribe()
	-- body
	local c = skynet.call(".start_service", "lua", "register")
	local c2 = mc.new {
		channel = c,
		dispatch = function (channel, source, cmd, ...)
			-- body
			local f = START_SUBSCRIBE[cmd]
			if f then
				f(source, ...)
			end
		end
	}
	c2:subscribe()
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
	game = loader.load_game()
	skynet.fork(update_db)
	start_subscribe()
end)
