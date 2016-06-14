local skynet = require "skynet"
local dc = require "datacenter"
local sd = require "sharedata"
local errorcode = require "errorcode"
local const = require "const"
local util = require "util"
local super = require "module"
local cls = class("shopmodule", super)

function cls:ctor(env, ... )
	-- body
	self._env = env
end

function cls:refersh(csv_id, gg, ... )
	-- body
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
	local ret = {}
	local user = self._env:get_user()
	local game = self._env:get_game()
	local factory = self._env:get_myfactory()
	if not user then
		local ret = {}
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(user)
	local j = factory:get_today()
	local gg = assert(skynet.call(game, "lua", "query_g_goods", args.goods_id))
	local ug = user.u_goodsmgr:get_by_csv_id(args.goods_id)
	local item = {}
	item.csv_id        = gg.csv_id
	item.currency_type = gg.currency_type
	item.currency_num  = gg.currency_num
	item.g_prop_csv_id = gg.g_prop_csv_id
	item.g_prop_num    = gg.g_prop_num

	local inventory = ug:get_field("inventory")
	if inventory == 0 then

		local now = os.time()
		local walk = now - ug.st
		if walk < gg.cd then
			-- judge refersh count
			if j.goods_refresh_count > assert(user.store_refresh_count_max) then
				local countdown = gg.cd - walk
				item.inventory = inventory
				item.countdown = countdown
				ret.errorcode = errorcode[5].code
				ret.msg = errorcode[5].msg
				ret.l = { item}
				ret.goods_refresh_count  = assert(j.goods_refresh_count)
				ret.store_refresh_count_max = assert(user.store_refresh_count_max)
				return ret
			else
				local rc = assert(skynet.call(game, "lua", "query_g_goods_refresh_cost", j.goods_refresh_count + 1))
				local prop = factory:get_prop(rc.currency_type)
				if prop.num >= rc.currency_num then
					
					ug:set_field("inventory", gg.inventory_init)
					ug:set_field("countdown", 0)
					ug:set_field("st", 0)
					ug:update_db()

					item.inventory = ug.inventory
					item.countdown = 0

					prop:set_field("num", prop:get_field("num") - rc.currency_num)
					prop:update_db()

					j:set_field("goods_refresh_count", j:get_field("goods_refresh_count") + 1)
					j:update_db()

					ret.errorcode = errorcode[1].code
					ret.msg = errorcode[1].msg
					ret.l = { item }
					ret.goods_refresh_count = assert(j.goods_refresh_count)
					ret.store_refresh_count_max = assert(user.store_refresh_count_max)
					return ret
				else
					item.inventory = inventory
					item.countdown = gg.cd - walk

					ret.errorcode = errorcode[6].code
					ret.msg = errorcode[6].msg
					ret.l = { item}
					ret.goods_refresh_count = assert(j.goods_refresh_count)
					ret.store_refresh_count_max = assert(user.store_refresh_count_max)
					return ret	
				end
			end	
		else
			ug:set_field("inventory", gg.inventory_init)
			ug:set_field("st", 0)
			ug:update_db()

			local countdown = 0
			item.inventory = gg.inventory_init
			item.countdown = countdown

			ret.errorcode = errorcode[7].code
			ret.msg = errorcode[7].msg
			ret.l = { item}
			ret.goods_refresh_count = assert(j.goods_refresh_count)
			ret.store_refresh_count_max = assert(user.store_refresh_count_max)
			return ret
		end
	else
		item.inventory = inventory
		item.countdown = 0
		ret.errorcode = errorcode[8].code
		ret.msg = errorcode[8].msg
		ret.l = { item }
		ret.goods_refresh_count = assert(j.goods_refresh_count)
		ret.store_refresh_count_max = assert(user.store_refresh_count_max)
		return ret
	end
end

function cls:shop_purchase(args)
	-- body
	local ret = {}
	local user = self._env:get_user()
	local game = self._env:get_game()
	local factory = self._env:get_myfactory()
	local now = os.time()
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg	= errorcode[2].msg
		return ret
	end
	local goods_id = args.g[1].goods_id
	local goods_num = args.g[1].goods_num

	local gg = skynet.call(game, "lua", "query_g_goods", args.g[1].goods_id)
	local ug = user.u_goodsmgr:get_by_csv_id(gg.csv_id)

	local goods_item = {}
	goods_item.csv_id        = gg.csv_id
	goods_item.currency_type = gg.currency_type
	goods_item.currency_num  = gg.currency_num
	goods_item.g_prop_csv_id = gg.g_prop_csv_id
	goods_item.g_prop_num    = gg.g_prop_num

	local prop_item = {}

	local inventory = ug:get_field("inventory")
	if inventory > 0 then
		if inventory == 99 then

		elseif inventory >= goods_num then
			inventory = inventory - goods_num
			ug:set_field("inventory", inventory)
			if inventory == 0 then
				ug:set_field("st", now)
			end
			goods_item.inventory = inventory
			goods_item.countdown = gg.cd - (now - ug:get_field("st"))
		else
			ret.errorcode = errorcode[11].code
			ret.msg = errorcode[11].msg
			local j = assert(factory:get_today())
			ret.goods_refresh_count = assert(j.goods_refresh_count)
			ret.store_refresh_count_max = assert(user.store_refresh_count_max)
			return ret
		end

		local goods_currency_id = gg.currency_type
		local goods_currency_num = gg.currency_num * goods_num

		local currency = user.u_propmgr:get_by_csv_id(goods_currency_id)
		local currency_num = currency:get_field("num")
		if currency_num >= goods_currency_num then
			currency_num = currency_num - goods_currency_num
			currency:set_field("num", currency_num)

			local prop = factory:get_prop(gg.g_prop_csv_id)
			local num = prop.num + (gg.g_prop_num * args.g[1].goods_num)
			prop:set_field("num", num)
			prop:update_db({"num"})

			prop_item.csv_id = gg.g_prop_csv_id
			prop_item.num = num

			if goods_currency_id == const.GOLD then
				self._env:raise_achievement(const.ACHIEVEMENT_T_4)
			elseif goods_currency_id == const.DIAMOND then
				self._env:raise_achievement(const.ACHIEVEMENT_T_4)
			end

			ret.errorcode = errorcode[1].code
			ret.msg = errorcode[1].msg
			ret.ll = { goods_item}
			ret.l = { prop_item}
			local j = assert(factory:get_today())
			ret.goods_refresh_count = assert(j.goods_refresh_count)
			ret.store_refresh_count_max = assert(user.store_refresh_count_max)
			return ret
		else
			ret.errorcode = errorcode[9].code
			ret.msg = errorcode[9].msg
			local j = assert(factory:get_today())
			ret.goods_refresh_count = assert(j.goods_refresh_count)
			ret.store_refresh_count_max = assert(user.store_refresh_count_max)
			return ret
		end
	else
		ret.errorcode = errorcode[11].code
		ret.msg = errorcode[11].msg
		local j = assert(factory:get_today())
		ret.goods_refresh_count = assert(j.goods_refresh_count)
		ret.store_refresh_count_max = assert(user.store_refresh_count_max)
		return ret
	end
end

return cls