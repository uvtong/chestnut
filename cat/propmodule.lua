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

function cls:props(args)
	-- body
	local user = self._env:get_user()
	local modelmgr = self._env:get_modelmgr()
	local u_propmgr = modelmgr:get_u_propmgr()
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(user)
	local l = {}
	for k,v in pairs(u_propmgr.__data) do
		local num = v:get_field("num")
		if num > 0 then
			local item = {}
			item.csv_id = v:get_field("csv_id")
			item.num = num
			table.insert(l, item)
		end
	end
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.l = l
	return ret
end

function cls:use_prop(args)
	-- body
	local ret = {}
	local user = self._env:get_user()
	local modelmgr = self._env:get_modelmgr()
	local u_propmgr = modelmgr:get_u_propmgr()
	local factory = self._env:get_myfactory()
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(#args.props == 1)
	local prop = factory:get_prop(args.props[1].csv_id)
	local l = {}
	if args.props[1].num > 0 then
		prop:set_field("num", prop:get_field("num") + args.props[1].num)
		prop:update_db()
		local item = {}
		item.csv_id = prop:get_field("csv_id")
		item.num    = prop:get_field("num")
		table.insert(l, item)
	elseif args.props[1].num < 0 then
		local use_prop_num = math.abs(args.props[1].num)
		if prop:get_field("num") < use_prop_num then
			ret.errorcode = errorcode[16].code
			ret.msg = errorcode[16].msg
			return ret
		end

		if assert(prop.use_type) == 0 then
			ret.errorcode = errorcode[28].code
			ret.msg = errorcode[28].msg
			return ret
		elseif assert(prop.use_type) == 1 then -- exp 
			local e = user.u_propmgr:get_by_csv_id(const.EXP)
			e:set_field("num", e:get_field("num") + (tonumber(prop:get_field("pram1")) * use_prop_num))
			e:update_db({"num"})
			local item = {}
			item.csv_id = const.EXP
			item.num = e:get_field("num")
			table.insert(l, item)
			ctx:raise_achievement(const.ACHIEVEMENT_T_3)
		elseif assert(prop.use_type) == 2 then -- gold
			local g = user.u_propmgr:get_by_csv_id(const.GOLD)
			g:set_field("num", (tonumber(prop:get_field("pram1")) * use_prop_num))
			g:update_db({"num"})
			local item = {}
			item.csv_id = const.GOLD
			item.num = g:get_field("num")
			table.insert(l, item)
			ctx:raise_achievement(const.ACHIEVEMENT_T_2)
		elseif assert(prop.use_type) == 3 then
			local r = util.parse_text(prop.pram1)
			print("length of r", #r)
			for k,v in pairs(r) do
				local p = u_propmgr:get_by_csv_id(v[1])
				p:set_field("num", prop:get_field("num") + (v[2] * use_prop_num))
				p:update_db()

				local item = {}
				item.csv_id = v[1]
				item.num = p:get_field("num")
				table.insert(l, item)

				if v[1] == const.GOLD then
					self._env:raise_achievement(const.ACHIEVEMENT_T_2)
				elseif v[1] == const.EXP then
					self._env:raise_achievement(const.ACHIEVEMENT_T_3)
				end
			end
		elseif assert(prop.use_type) == 4 then
			local f = false
			local r = util.parse_text(prop:get_field("pram1"), "(%d+%*%d+%*%d+%*?)", 3)

			local total = 0
			for i,v in ipairs(r) do
				v.min = total
				total = total + assert(v[3])
				v.max = total
			end
			local rand = math.random(1, total-1)
			for i,v in ipairs(r) do
				if rand >= v.min and rand < v.max then
					f = true
					local p = assert(factory:get_prop(v[1]))
					p:set_field("num", p:get_field("num") + (v[2] * use_prop_num))
					p:update_db()
					
					local item = {}
					item.csv_id = v[1]
					item.num = p:get_field("num")
					table.insert(l, item)
					break
				end
			end
			assert(f)
		else
			ret.errorcode = errorcode[28].code
			ret.msg = errorcode[28].msg
			return ret
		end

		prop:set_field("num", prop:get_field("num") - use_prop_num)
		prop:update_db()
		local item = {}
		item.csv_id = prop:get_field("csv_id")
		item.num = prop:get_field("num")
		table.insert(l, item)

		ret.errorcode = errorcode[1].code
		ret.msg	= errorcode[1].msg
		ret.props = l
		return ret
	else
		ret.errorcode = errorcode[27].code
		ret.msg = errorcode[27].msg
		return ret
	end
end

return cls