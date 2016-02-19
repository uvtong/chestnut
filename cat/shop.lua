package.path = "./../cat/?.lua;" .. package.path
local skynet = require "skynet"
require "skynet.manager"
local util = require "util"
local loader = require "loader"
local game

local CMD = {}
 
function CMD.load_goods()
 	-- body
 	game = loader.load_game()
 end 

function CMD.disconnect()
	-- todo: do something before exit
	skynet.exit()
end	

function CMD.shop_all()
	-- body
	local l = {}
	local idx = 1
	for k,v in pairs(game.g_goodsmgr.__data) do
		l[idx] = v:__serialize()
	end
	return l
end

function CMD.shop_refresh( goods_id )
	-- body
	local ret = {}
	local v = game.g_goodsmgr:get_by_csv_id(goods_id)
	local goods = {}
	local goods = v:__serialize()
	ret.errorcode = 0
	ret.msg = "yes"
	ret.l = { goods }
	return ret
end

function CMD.shop_purchase( g )
	-- body
	local l = {}
	local idx = 1
	for i,v in ipairs(g) do
		print(v.goods_id)
		local r = game.g_goodsmgr:get_by_csv_id(v.goods_id)
		local goods = r:__serialize()
		goods.p_num = v.goods_num
		for k,v in pairs(goods) do
			print(k,v)
		end
		l[idx] = goods
		idx = idx + 1
	end
	return l
end

function CMD.recharge_all()
	local ret = {}
	ret.errorcode = 0
	ret.msg = "yes"
	local l = {}
	local idx = 1
	for k,v in pairs(game.g_rechargemgr.__data) do
		local goods = {}
		goods.csv_id = v.csv_id
		goods.icon_id = v.icon
		goods.name = v.name
		goods.diamond = v.diamond
		goods.first = v.first
		goods.gift = v.gift
		goods.rmb = v.rmb
		goods.p_num = v.num
		l[idx] = goods
		idx = idx + 1
	end
	ret.l = l
	return ret
end

function CMD.recharge_purchase( g )
	-- body
	local l = {}
	local idx = 1
	for i,v in ipairs(g) do
		print(v.csv_id)
		local r = game.g_rechargemgr:get_by_csv_id(v.csv_id)
		local goods = r:__serialize()
		goods.p_num = v.num
		l[idx] = goods
		idx = idx + 1
	end
	return l
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
	skynet.register ".shop"
end)