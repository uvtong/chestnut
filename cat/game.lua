package.path = "./../cat/?.lua;./../cat/lualib/?.lua;" .. package.path
package.cpath = "./../cat/luaclib/?.so;" .. package.cpath
local skynet = require "skynet"
require "skynet.manager"
local util = require "util"
local loader = require "loader"
local tptr = require "tablepointer"
local game

local CMD = {}
 
function CMD.start()
 	-- body
 	game = loader.load_game()
end 

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

function CMD.u_guid(user_id, csv_id)
	-- body
	print(user_id, csv_id)
	return util.u_guid(user_id, game, csv_id)
end

function CMD.guid(csv_id)
	-- body
	return util.guid(game, csv_id)
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
end)