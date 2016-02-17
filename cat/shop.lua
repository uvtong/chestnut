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
	local ret = {}
	local l = {}
	local idx = 1
	for k,v in pairs(game.g_goodsmgr.__data) do
		local goods = {}
		goods.csv_id = v.csv_id
		goods.type = v.type
		goods.currency_type = v.currency_type
		goods.currency_num = v.currency_num
		goods.c_startingtime = v.c_startingtime
		
		if v.c_countdown and type(v.c_countdown) == "string" then
			--local year = tonumber(string.gsub(v.c_countdown, "(%d+)-(%d+)-(%d+)%s(%d+):(%d+):(%d+)", "%1"))
			--local month = tonumber(string.gsub(v.c_countdown, "(%d+)-(%d+)-(%d+)%s(%d+):(%d+):(%d+)", "%2"))
			--local day = tonumber(string.gsub(v.c_countdown, "(%d+)-(%d+)-(%d+)%s(%d+):(%d+):(%d+)", "%3"))
			local hour = string.gsub(v.c_countdown, "(%d+)-(%d+)-(%d+)%s(%d+):(%d+):(%d+)", "%4")
			local min = string.gsub(v.c_countdown, "(%d+)-(%d+)-(%d+)%s(%d+):(%d+):(%d+)", "%5")
			local sec = string.gsub(v.c_countdown, "(%d+)-(%d+)-(%d+)%s(%d+):(%d+):(%d+)", "%6")
			local total = tonumber(sec) + tonumber(min) * 60 + tonumber(hour) *3600
			goods.c_countdown = tostring(total)
		end
		goods.c_a_num = v.c_a_num
		goods.prop_csv_id = v.prop_csv_id
		goods.prop_num = v.prop_num
		goods.icon_id = v.icon_id
		l[idx] = goods
		idx = idx + 1
	end
	ret.errorcode = 0
	ret.msg	= "yes"
	ret.l = l
	return ret
end

function CMD.shop_refresh( goods_id )
	-- body
	local ret = {}
	local v = game.g_goodsmgr:get_by_csv_id(goods_id)
	local goods = {}
	goods.csv_id = v.csv_id
	goods.type = v.type
	goods.currency_type = v.currency_type
	goods.currency_num = v.currency_num
	goods.c_startingtime = v.c_startingtime
	goods.c_countdown = v.c_countdown
	goods.c_a_num = v.c_a_num
	goods.prop_csv_id = v.prop_csv_id
	goods.prop_num = v.prop_num
	goods.icon_id = v.icon_id
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
		local r = g_rechargemgr:get_by_csv_id(v.csv_id)
		print(r)
		local goods = {}
		goods.csv_id = r.csv_id
		goods.icon_id = r.icon
		goods.name = r.name
		goods.diamond = r.diamond
		goods.first = r.first
		goods.gift = r.gift
		goods.rmb = r.rmb
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