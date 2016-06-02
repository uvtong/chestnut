local skynet = require "skynet"
local dc = require "datacenter"
local sd = require "sharedata"
local errorcode = require "errorcode"
local const = require "const"
local util = require "util"
local super = require "module"
local cls = class("arenamodule", super)

function cls:ctor(env, ... )
	-- body
	self._env = env
end

function cls:shop_all(args, ... )
	-- body
	local user = self._env:get_user()
	local game = self._env:get_game()
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg	= errorcode[2].msg
		return ret
	end
	local now = os.time()
	local r = skynet.call(game, "lua", "query_g_goods")
	local ll = {}
	for k,v in pairs(r) do
		local item = {}
		item.csv_id = v.csv_id
		item.currency_type = v.currency_type
		item.currency_num = v.currency_num
		item.g_prop_csv_id = v.g_prop_csv_id
		item.g_prop_num = v.g_prop_num
		local tmp = user.u_goodsmgr:get_by_csv_id(v.csv_id)
		if tmp ~= nil then
			local inventory = tmp:get_field("inventory")
			if inventory == 0 then
				if tmp:get_field("st") == 0 then
					tmp:set_field("st", now)
				end
				local st = tmp:get_field("st")
				local walk = now - st
				if walk >= v.cd then
					tmp:set_field("inventory", v.inventory_init)
					tmp:set_field("st", 0)
					tmp:update_db()
					item.inventory = v.inventory_init
					item.countdown = 0
				else
					local countdown = v.cd - walk
					item.inventory = 0
					item.countdown = countdown
				end
			else
				item.inventory = inventory
				item.countdown = 0
			end
		else
			v.user_id = user.csv_id
			v.inventory = v.inventory_init
			v.countdown = 0
			v.st = 0
			v.id = genpk_2(v.user_id, v.csv_id)
			tmp = user.u_goodsmgr:create(v)
			user.u_goodsmgr:add(tmp)
			tmp:update_db()
			item.inventory = v.inventory
			item.countdown = 0
		end
		table.insert(ll, item)
	end
	local factory = self._env:get_myfactory()
	local j = factory:get_today()
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.l = ll
	ret.goods_refresh_count = j:get_field("goods_refresh_count")
	ret.store_refresh_count_max = user:get_field("store_refresh_count_max")
	return ret
end

function cls:shop_refresh(args, ... )
	-- body
	local user = self._env:get_user()
	local ret = {}
	assert(user)
	local j = assert(get_journal())
	local gg = assert(skynet.call(game, "lua", "query_g_goods", self.goods_id))
	local ug = user.u_goodsmgr:get_by_csv_id(self.goods_id)
	if ug.inventory == 0 then
		local now = os.time()
		local walk = now - ug.st
		if walk < gg.cd then
			-- judge refersh count
			print("****8ajfal", j.goods_refresh_count, user.store_refresh_count_max)
			if j.goods_refresh_count >= assert(user.store_refresh_count_max) then
				ug.countdown = gg.cd - walk
				ug:__update_db({ "countdown"})
				ret.errorcode = errorcode[5].code
				ret.msg = errorcode[5].msg
				ret.l = { goods}
				ret.goods_refresh_count  = assert(j.goods_refresh_count)
				ret.store_refresh_count_max = assert(user.store_refresh_count_max)
				return ret
			end
			local rc = assert(skynet.call(game, "lua", "query_g_goods_refresh_cost", j.goods_refresh_count + 1))
			local prop = get_prop(rc.currency_type)
			if prop.num > rc.currency_num then
				print("abc")
				prop.num = prop.num - rc.currency_num
				prop:__update_db({"num"})
				j.goods_refresh_count = j.goods_refresh_count + 1
				j:__update_db({"goods_refresh_count"})
				ug.inventory = gg.inventory_init
				ug.countdown = 0
				ug.st = 0
				ug:__update_db({"inventory", "countdown", "st"})
				ret.errorcode = errorcode[1].code
				ret.msg = errorcode[1].msg
				for k,v in pairs(ug) do
					gg[k] = ug[k]
				end
				ret.l = { gg }
				ret.goods_refresh_count = assert(j.goods_refresh_count)
				ret.store_refresh_count_max = assert(user.store_refresh_count_max)
				return ret
			else
				print("chjalkf")
				goods.countdown = gg.cd - walk
				goods:__update_db({"countdown"})
				for k,v in pairs(ug) do
					gg[k] = ug[k]
				end
				ret.errorcode = errorcode[6].code
				ret.msg = errorcode[6].msg
				ret.l = { gg}
				ret.goods_refresh_count = assert(j.goods_refresh_count)
				ret.store_refresh_count_max = assert(user.store_refresh_count_max)
				return ret	
			end
		else
			ug.inventory = gg.inventory_init
			ug.countdown = gg.cd - walk
			ug:__update_db({"inventory", "countdown"})
			for k,v in pairs(ug) do
				gg[k] = ug[k]
			end
			ret.errorcode = errorcode[7].code
			ret.msg = errorcode[7].msg
			ret.l = { goods}
			ret.goods_refresh_count = assert(j.goods_refresh_count)
			ret.store_refresh_count_max = assert(user.store_refresh_count_max)
			return ret
		end
	else
		assert(ug.inventory > 0)
		ret.errorcode = errorcode[8].code
		ret.msg = errorcode[8].msg
		for k,v in pairs(ug) do
			gg[k] = ug[k]
		end
		ret.l = { gg }
		ret.goods_refresh_count = assert(j.goods_refresh_count)
		ret.store_refresh_count_max = assert(user.store_refresh_count_max)
		return ret
	end
end



return cls