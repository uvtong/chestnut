package.path = "./../cat/?.lua;" .. package.path
local skynet = require "skynet"
require "skynet.manager"
local util = require "util"
local g_goodsmgr = require "g_goodsmgr"
local g_rechargemgr = require "g_rechargemgr"
local g_refresh_costmgr = require "g_refresh_costmgr"
local g_propmgr = require "g_propmgr"
local g_recharge_vipmgr = require "g_recharge_vipmgr"

local function load_goods()
	-- body
	if g_goodsmgr:get_count() <= 0 then
		local r = skynet.call(util.random_db(), "lua", "command", "select", "g_goods")	
		for i,v in ipairs(r) do
			local goods = g_goodsmgr.create(r[i])
			g_goodsmgr:add(goods)                      
		end
	end
	for i,v in ipairs(g_goodsmgr.__data) do
		print(i,v)
	end
end

local function load_recharge()
	-- body
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_recharge")
	for i,v in ipairs(r) do
		local recharge = g_rechargemgr.create(r[i])
		g_rechargemgr:add(recharge)
	end
end

local function load_refresh_cost()
	-- body
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_refresh_cost")
	for i,v in ipairs(r) do
		local refresh_cost = g_refresh_costmgr.create(r[i])
		g_refresh_costmgr:add(refresh_cost)
	end
end

local function load_prop()
	-- body
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_prop")
	for i,v in ipairs(r) do
		local prop = g_propmgr.create(r[i])
		g_propmgr:add(prop)
	end
end

local function load_g_recharge_vip()
	-- body
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_prop")
	for i,v in ipairs(r) do
		local t = g_rechargemgr.create(v)
		g_rechargemgr:add(t)
	end
end

local CMD = {}
 
function CMD.load_goods()
 	-- body
 	load_goods()
 	load_recharge()
 	load_refresh_cost()
 	load_prop()
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
	for k,v in pairs(g_goodsmgr.__data) do
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
	local v = g_goodsmgr:get_by_csv_id(goods_id)
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
		local r = g_goodsmgr:get_by_csv_id(v.goods_id)
		print(r)
		local goods = {}
		goods.csv_id = r.csv_id
		goods.type = r.type
		goods.currency_type = r.currency_type
		goods.currency_num = r.currency_num
		goods.prop_csv_id = r.prop_csv_id
		goods.prop_num = r.prop_num
		goods.c_startingtime = r.c_startingtime
		goods.c_countdown = r.c_countdown
		goods.c_a_num = r.c_a_num
		goods.cd = r.cd
		goods.icon_id = r.icon_id
		goods.p_num = v.goods_num
		print(v.goods_num)
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
	for k,v in pairs(g_rechargemgr.__data) do
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
	for k,v in pairs(g_rechargemgr.__data) do
		print(k,v)
	end
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