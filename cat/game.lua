package.path = "./../cat/?.lua;" .. package.path
local skynet = require "skynet"
require "skynet.manager"
local util = require "util"
local loader = require "loader"
local game

local CMD = {}
 
function CMD.start()
 	-- body
 	game = loader.load_game()
end 

function CMD.query(table_name, pk)
	-- body
	for k,v in pairs(game) do
		if v.__tname == table_name then
			return assert(v:get_by_csv_id(pk))
		end
	end
end

function CMD.query_g_goods(pk)
	-- body
	if type(pk) == "number" then
		return game.g_goodsmgr:get_by_csv_id(pk)
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
	if type(pk) == "number" then
		return game.g_goods_refresh_costmgr:get_by_csv_id(pk)
	elseif type(pk) == "nil" then
		return game.g_goods_refresh_costmgr.__data
	else
		assert(false)
	end
end

function CMD.query_g_prop(pk)
	-- body
	if type(pk) == "number" then
		return game.g_propmgr:get_by_csv_id(pk)
	elseif type(pk) == "nil" then
		return game.g_propmgr.__data
	else
		assert(false)
	end
end

function CMD.u_guid(user_id, csv_id)
	-- body
	print(user_id, csv_id)
	assert(game)
	return util.u_guid(user_id, game, csv_id)
end

function CMD.guid(csv_id)
	-- body
	return util.guid(game, csv_id)
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		print("*(8)game", command)
		local f = CMD[command]
		local result = assert(f(...))
		skynet.ret(skynet.pack(result))
	end)
	skynet.register ".game"
end)