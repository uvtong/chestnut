package.path = "./../cat/?.lua;./../cat/lualib/?.lua;./../lualib/?.lua;" .. package.path
package.cpath = "./../cat/luaclib/?.so;" .. package.cpath
local skynet = require "skynet"
require "skynet.manager"
local sharedata = require "sharedata"
rdb = skynet.localname(".rdb")
wdb = skynet.localname(".db")
local query = require "query"
local util = require "util"
local loader = require "loader"
local tptr = require "tablepointer"
local const = require "const"
local game

local CMD = {}

function CMD.ptr()
	-- body
	return tptr.topointer(game)
end

function CMD.query(table_name, pk)
	-- body
	for k,v in pairs(game) do
		if v.__tname == table_name then
			return assert(v:get_by_csv_id(pk))
		end
	end
end

function CMD.query_g_achievement(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_achievementmgr:get_by_csv_id(pk)
		if r then
			return r
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
			return r
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
			return r
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
			return r
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
			return r
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		return game.g_checkpoint_chaptermgr.__data
	else
		assert(false)
	end
end

function CMD.query_g_daily_task(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_daily_taskmgr:get_by_csv_id(pk)
		if r then
			return r
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
			return r
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
			return r
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
			return r
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
			return r
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
			return r
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
			return r
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
			return r
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		return game.g_equipmentmgr.__data
	else
		assert(false)
	end
end

function CMD.query_g_equipment_enhance(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_equipment_enhancemgr:get_by_csv_id(pk)
		if r then
			return r
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
			return r
		else
			error "there are insufficient data"
		end
	elseif type(pk) == "nil" then
		return game.g_goodsmgr.__data
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
	local r = game.g_daily_taskmgr:get_one()
	if r then
		return r
	else
		assert(false)
	end
end

function CMD.query_g_goods_refresh_cost(pk)
	-- body
	print("abcedfe")
	if type(pk) == "number" then
		local r = game.g_goods_refresh_costmgr:get_by_csv_id(pk)
		if r then
			return r
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
			return r
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

function CMD.query_g_monster(pk)
	-- body
	if type(pk) == "number" then
		local r = game.g_monstermgr:get_by_csv_id(pk)
		if r then
			print("*****************************************************g_monster1", r.combat, r.defense, r.critical_hit)
			return r
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
		local r = game.g_equipment_effectmgr:get_by_level(pk)
		if r then
			return r
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
			return r
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
	local x = 1
	while true do
		if game then
			x = x + 1
			local sql = string.format("update g_uid set entropy= %d where csv_id = 2;", x)
			query.write(wdb, "g_uid", sql, const.DB_PRIORITY_1)
			-- game.g_uidmgr:update_db(const.DB_PRIORITY_1)
			-- game.g_randomvalmgr:update_db(const.DB_PRIORITY_1)
		end
		skynet.sleep(100 * 60) -- 1ti == 0.01s
	end
end

local function load_g_achievement()
	-- body
	assert(game.g_achievementmgr == nil)
	local g_achievementmgr = require "models/g_achievementmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_achievement")
	for i,v in ipairs(r) do
		local t = g_achievementmgr.create(v)
		g_achievementmgr:add(t)
	end
	game.g_achievementmgr = g_achievementmgr
end

local function load_g_ara_pts()
	-- body
	assert(game.g_ara_ptsmgr == nil)
	local g_ara_ptsmgr = require "models/g_ara_ptsmgr"
	g_ara_ptsmgr("load_db")
	game.g_ara_ptsmgr = g_ara_ptsmgr
end

local function load_g_ara_rnk_rwd()
	-- body
	assert(game.g_ara_rnk_rwdmgr == nil)
	local g_ara_rnk_rwdmgr = require "models/g_ara_rnk_rwdmgr"
	g_ara_rnk_rwdmgr("load_db")
	game.g_ara_rnk_rwdmgr = g_ara_rnk_rwdmgr
end

local function load_g_ara_tms()
	-- body
	assert(game.g_ara_tmsmgr == nil)
	local g_ara_tmsmgr = require "models/g_ara_tmsmgr"
	g_ara_tmsmgr("load_db")
	game.g_ara_tmsmgr = g_ara_tmsmgr
end

local function load_g_checkpoint()
	-- body
	assert(game.g_checkpointmgr == nil)
	local g_checkpointmgr = require "models/g_checkpointmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_checkpoint")
	for i,v in ipairs(r) do
		local t = g_checkpointmgr.create(v)
		g_checkpointmgr:add(t)
	end
	game.g_checkpointmgr = g_checkpointmgr
end

local function load_g_checkpoint_chapter()
	-- body
	assert(game.g_checkpoint_chaptermgr == nil)
	local g_checkpoint_chaptermgr = require "models/g_checkpoint_chaptermgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_checkpoint_chapter")
	for i,v in ipairs(r) do
		local t = g_checkpoint_chaptermgr.create(v)
		g_checkpoint_chaptermgr:add(t)
	end
	game.g_checkpoint_chaptermgr = g_checkpoint_chaptermgr
end

local function load_g_effct()
	-- body
	assert(game.g_effctmgr == nil)
	local g_effctmgr = require "models/g_effctmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_effct")
	for i,v in ipairs(r) do
		local t = g_effctmgr.create(v)
		g_effctmgr:add(t)
	end
	game.g_effctmgr = g_effctmgr
end

local function load_g_role_effect()
	assert( nil == game.g_role_effectmgr )
	local g_role_effectmgr = require "models/g_role_effectmgr"
	local r = skynet.call( util.random_db() , "lua" , "command" , "select" , "g_role_effect" )
	for i,v in ipairs(r) do
		local t = g_role_effectmgr.create(v)
		g_role_effectmgr:add(t)
	end
	game.g_role_effectmgr = g_role_effectmgr
end	

local function load_g_equipment()
	-- body
	assert(game.g_equipmentmgr == nil)
	local g_equipmentmgr = require "models/g_equipmentmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_equipment")
	for i,v in ipairs(r) do
		local t = g_equipmentmgr.create(v)
		g_equipmentmgr:add(t)
	end
	game.g_equipmentmgr = g_equipmentmgr
end

local function load_g_equipment_enhance()
	-- body
	assert(game.g_equipment_enhancemgr == nil)
	local g_equipment_enhancemgr = require "models/g_equipment_enhancemgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_equipment_enhance")
	for i,v in ipairs(r) do
		local t = g_equipment_enhancemgr.create(v)
		g_equipment_enhancemgr:add(t)
	end
	game.g_equipment_enhancemgr = g_equipment_enhancemgr
end

local function load_g_goods()
	-- body
	assert(game.g_goodsmgr == nil)
	local g_goodsmgr = require "models/g_goodsmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_goods")
	for i,v in ipairs(r) do
		local t = g_goodsmgr.create(v)
		g_goodsmgr:add(t)
	end
	game.g_goodsmgr = g_goodsmgr
end

local function load_g_goods_refresh_cost()
	-- body
	assert(game.g_goods_refresh_costmgr == nil)
	local g_goods_refresh_costmgr = require "models/g_goods_refresh_costmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_goods_refresh_cost")
	for i,v in ipairs(r) do
		local t = g_goods_refresh_costmgr.create(v)
		g_goods_refresh_costmgr:add(t)
	end
	game.g_goods_refresh_costmgr = g_goods_refresh_costmgr
end

local function load_g_kungfu()
	-- body
	assert(game.g_kungfumgr == nil)
	local g_kungfumgr = require "models/g_kungfumgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_kungfu")
	for i,v in ipairs(r) do
		local t = g_kungfumgr.create(v)
		g_kungfumgr:add(t)
	end
	game.g_kungfumgr = g_kungfumgr
end

local function load_g_lilian_level()
	-- body
	assert(game.g_lilian_levelmgr == nil)
	local g_lilian_levelmgr = require "models/g_lilian_levelmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_lilian_level")
	for i,v in ipairs(r) do
		local t = g_lilian_levelmgr.create(v)
		g_lilian_levelmgr:add(t)
	end
	game.g_lilian_levelmgr = g_lilian_levelmgr
end

local function load_g_lilian_event()
	-- body
	assert(game.g_lilian_eventmgr == nil)
	local g_lilian_eventmgr = require "models/g_lilian_eventmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_lilian_event")
	for i,v in ipairs(r) do
		local t = g_lilian_eventmgr.create(v)
		g_lilian_eventmgr:add(t)
	end
	game.g_lilian_eventmgr = g_lilian_eventmgr
end

local function load_g_lilian_quanguan()
	-- body
	assert(game.g_lilian_quanguanmgr == nil)
	local g_lilian_quanguanmgr = require "models/g_lilian_quanguanmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_lilian_quanguan")
	for i,v in ipairs(r) do
		local t = g_lilian_quanguanmgr.create(v)
		g_lilian_quanguanmgr:add(t)
	end
	game.g_lilian_quanguanmgr = g_lilian_quanguanmgr
end

local function load_g_lilian_invitation()
	-- body
	assert(game.g_lilian_invitationmgr == nil)
	local g_lilian_invitationmgr = require "models/g_lilian_invitationmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_lilian_invitation")
	for i,v in ipairs(r) do
		local t = g_lilian_invitationmgr.create(v)
		g_lilian_invitationmgr:add(t)
	end
	game.g_lilian_invitationmgr = g_lilian_invitationmgr
end

local function load_g_prop()
	-- body
	assert(game.g_propmgr == nil)
	local g_propmgr = require "models/g_propmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_prop")
	for i,v in ipairs(r) do
		local t = g_propmgr.create(v)
		g_propmgr:add(t)
	end
	game.g_propmgr = g_propmgr
end

local function load_g_recharge()
	-- body
	assert(game.g_rechargemgr == nil)
	local g_rechargemgr = require "models/g_rechargemgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_recharge")
	for i,v in ipairs(r) do
		local t = g_rechargemgr.create(v)
		g_rechargemgr:add(t)
	end
	game.g_rechargemgr = g_rechargemgr
end

local function load_g_recharge_vip_reward()
	-- body
	assert(game.g_recharge_vip_rewardmgr == nil)
	local g_recharge_vip_rewardmgr = require "models/g_recharge_vip_rewardmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_recharge_vip_reward")
	for i,v in ipairs(r) do
		local t = g_recharge_vip_rewardmgr.create(v)
		g_recharge_vip_rewardmgr:add(t)
	end
	game.g_recharge_vip_rewardmgr = g_recharge_vip_rewardmgr
end

local function load_g_role()
	-- body
	assert(game.g_rolemgr == nil)
	local g_rolemgr = require "models/g_rolemgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_role")
	for i,v in ipairs(r) do
		local t = g_rolemgr.create(v)
		g_rolemgr:add(t)
	end
	game.g_rolemgr = g_rolemgr
end

local function load_g_role_star()
	-- body
	assert(game.g_role_starmgr == nil)
	local g_role_starmgr = require "models/g_role_starmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_role_star")
	for i,v in ipairs(r) do
		local t = g_role_starmgr.create(v)
		g_role_starmgr:add(t)
	end
	game.g_role_starmgr = g_role_starmgr
end

local function load_g_shop()
	-- body
	assert(game.g_shopmgr == nil)
	local g_shopmgr = require "models/g_shopmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_shop")
	for i,v in ipairs(r) do
		local t = g_shopmgr.create(v)
		g_shopmgr:add(t)
	end
	game.g_shopmgr = g_shopmgr
end

local function load_g_user_level()
	-- body
	assert(game.g_user_levelmgr == nil)
	local g_user_levelmgr = require "models/g_user_levelmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_user_level")
	for i,v in ipairs(r) do
		local t = g_user_levelmgr.create(v)
		g_user_levelmgr:add(t)
	end
	game.g_user_levelmgr = g_user_levelmgr
end

local function load_g_checkin()
	assert( nil == game.g_checkinmgr )

	local g_checkinmgr = require "models/g_checkinmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_checkin")
	for i,v in ipairs(r) do
		local t = g_checkinmgr.create(v)
		g_checkinmgr:add(t)
	end
	game.g_checkinmgr = g_checkinmgr
end

local function load_g_checkin_total()
	assert( nil == game.g_checkin_totalmgr )

	local g_checkin_totalmgr = require "models/g_checkin_totalmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_checkin_total")
	for i,v in ipairs(r) do
		local t = g_checkin_totalmgr.create(v)
		g_checkin_totalmgr:add(t)
	end
	game.g_checkin_totalmgr = g_checkin_totalmgr
end

local function load_g_daily_task()
	assert( nil == game.g_daily_taskmgr )
	local g_daily_taskmgr = require "models/g_daily_taskmgr"
	local r = skynet.call( util.random_db() , "lua" , "command" , "select" , "g_daily_task" )
	for i , v in ipairs( r ) do
		local t = g_daily_taskmgr.create( v )
		g_daily_taskmgr:add( t )
	end
	game.g_daily_taskmgr = g_daily_taskmgr
end

local function load_g_drawcost()
	assert( nil == game.g_drawcostmgr )

	local g_drawcostmgr = require "models/g_drawcostmgr"
	local r = skynet.call(util.random_db() , "lua" , "command" , "select" , "g_drawcost")
	for i , v in ipairs( r ) do
		local t = g_drawcostmgr.create( v )
		g_drawcostmgr:add( t )
	end
	game.g_drawcostmgr = g_drawcostmgr
end

local function load_g_draw_role()
	assert( nil == game.g_draw_rolemgr )

	local g_draw_rolemgr = require "models/g_draw_rolemgr"
	local r = skynet.call(util.random_db() , "lua" , "command" , "select" , "g_draw_role")
	for i , v in ipairs( r ) do
		local t = g_draw_rolemgr.create( v )
		g_draw_rolemgr:add( t )
	end
	game.g_draw_rolemgr = g_draw_rolemgr
end

local function load_g_mainreward()
	assert( nil == game.g_mainrewardmgr )

	local g_mainrewardmgr = require "models/g_mainrewardmgr"
	local r = skynet.call(util.random_db() , "lua" , "command" , "select" , "g_mainreward")
	for i , v in ipairs( r ) do
		local t = g_mainrewardmgr.create( v )
		g_mainrewardmgr:add( t )
	end
	game.g_mainrewardmgr = g_mainrewardmgr
end

local function load_g_subreward()
	assert( nil == game.g_subrewardmgr )

	local g_subrewardmgr = require "models/g_subrewardmgr"
	local r = skynet.call(util.random_db() , "lua" , "command" , "select" , "g_subreward")
	for i , v in ipairs( r ) do
		local t = g_subrewardmgr.create( v )
		g_subrewardmgr:add( t )
	end
	game.g_subrewardmgr = g_subrewardmgr
end

local function load_g_randomval()
	assert( nil == game.g_randomvalmgr )

	local g_randomvalmgr = require "models/g_randomvalmgr"
	local r = skynet.call( util.random_db() , "lua" , "command" , "select" , "randomval" )
	for k , v in ipairs( r ) do
		local t = g_randomvalmgr.create( v )
		g_randomvalmgr:add( t )
	end
	print( "load randomval successfully" )
	game.g_randomvalmgr = g_randomvalmgr
end

local function  load_g_lilian_phy_power()
	-- body
	assert( nil == game.g_lilian_phy_powermgr )
	local g_lilian_phy_powermgr = require "models/g_lilian_phy_powermgr"
	local r = skynet.call(util.random_db() , "lua" , "command" , "select" , "g_lilian_phy_power")
	for i , v in ipairs( r ) do
		local t = g_lilian_phy_powermgr.create( v )
		g_lilian_phy_powermgr:add( t )
	end
	game.g_lilian_phy_powermgr = g_lilian_phy_powermgr
end

local function load_g_uid()
	-- body
	assert(nil == game.g_uidmgr)
	local g_uidmgr = require "models/g_uidmgr"
	local r = skynet.call(util.random_db() , "lua" , "command" , "select" , "g_uid")
	for i , v in ipairs( r ) do
		local t = g_uidmgr.create( v )
		g_uidmgr:add( t )
	end
	game.g_uidmgr = g_uidmgr
end

local function load_g_config()
	-- body
	assert(game.g_configmgr == nil)
	local g_configmgr = require "models/g_configmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_config")
	for i,v in ipairs(r) do
		local t = g_configmgr.create(v)
		g_configmgr:add(t)
	end
	game.g_configmgr = g_configmgr
end

local function load_g_xilian_cost()
	-- body
	assert(game.g_xilian_costmgr == nil)
	local g_xilian_costmgr = require "models/g_xilian_costmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_xilian_cost")
	for i,v in ipairs(r) do
		local t = g_xilian_costmgr.create(v)
		g_xilian_costmgr:add(t)
	end
	game.g_xilian_costmgr = g_xilian_costmgr
end

local function load_g_property_pool()
	-- body
	assert(game.g_property_poolmgr == nil)
	local g_property_poolmgr = require "models/g_property_poolmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_property_pool")
	for i,v in ipairs(r) do
		local t = g_property_poolmgr.create(v)
		g_property_poolmgr:add(t)
	end
	game.g_property_poolmgr = g_property_poolmgr
end
	
local function load_g_property_pool_second()
	-- body
	assert(game.g_property_pool_secondmgr == nil)
	local g_property_pool_secondmgr = require "models/g_property_pool_secondmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_property_pool_second")
	for i,v in ipairs(r) do
		local t = g_property_pool_secondmgr.create(v)
		g_property_pool_secondmgr:add(t)
	end
	game.g_property_pool_secondmgr = g_property_pool_secondmgr
end 
	 
local function load_g_equipment_effect()
	-- body
	assert(game.g_equipment_effectmgr == nil)
	local g_equipment_effectmgr = require "models/g_equipment_effectmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_equipment_effect")
	for i,v in ipairs(r) do
		local t = g_equipment_effectmgr.create(v)
		g_equipment_effectmgr:add(t)
	end
	game.g_equipment_effectmgr = g_equipment_effectmgr
end 
	
local function load_g_monster()
	assert(nil == game.g_monstermgr)
	local g_monstermgr = require "models/g_monstermgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_monster")
	for i, v in ipairs(r) do
		local t = g_monstermgr.create(v)
		g_monstermgr:add(t)
	end

	game.g_monstermgr = g_monstermgr
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
	-- local r = skynet.call(".db", "lua", "select", "g_uid")
	-- local r = skynet.call(".db", "lua", "test")
	-- print(r)
end)
