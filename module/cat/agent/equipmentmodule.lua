local skynet = require "skynet"
local dc = require "datacenter"
local sd = require "sharedata"
local errorcode = require "errorcode"
local const = require "const"
local util = require "util"
local super = require "module"
local cls = class("equipmentmodule", super)

function cls:ctor(env, ... )
	-- body
	self._env = env
end

function cls:equipment_all(args)
	-- body
	-- 1 offline 
	local user = self._env:get_user()
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	local l = {}
	for k,v in pairs(user.u_equipmentmgr.__data) do
		local e = {}
		e.csv_id  = v:get_field("csv_id")
		e.level   = v:get_field("level")
		e.combat  = v:get_field("combat")
		e.defense = v:get_field("defense")
		e.critical_hit = v:get_field("critical_hit")
		e.king = v:get_field("king")
		e.combat_probability = v:get_field("combat_probability")
		e.critical_hit_probability = v:get_field("critical_hit_probability")
		e.defense_probability = v:get_field("defense_probability")
		e.king_probability = v:get_field("king_probability")
		e.enhance_success_rate = v:get_field("enhance_success_rate")
		table.insert(l, e)
	end
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.l = l
	return ret
end

function cls:equipment_enhance(args)
	-- body
	assert(args.csv_id, string.format("from client the value is: %s", type(args.csv_id)))
	local user = self._env:get_user()
	local modelmgr = self._env:get_modelmgr()
	local u_equipmentmgr = modelmgr:get_u_equipmentmgr()
	local u_propmgr = modelmgr:get_u_propmgr()
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end

	local e = u_equipmentmgr:get_by_csv_id(args.csv_id)
	if e:get_field("csv_id") == 1 then
		local last = u_equipmentmgr:get_by_csv_id(4)
		assert(e:get_field("level") == last:get_field("level"))
	else
		local last = u_equipmentmgr:get_by_csv_id(args.csv_id - 1)
		assert(e:get_field("level") < last:get_field("level"))
	end

	local key = string.format("%s:%d", "g_equipment_enhance", (e:get_field("csv_id") * 1000) + (e:get_field("level") + 1))
	local ee = sd.query(key)
	if ee.level > user:get_field("level") then
		ret.errorcode = errorcode[23].code	
		ret.msg = errorcode[23].msg
		return ret
	else
		local currency = u_propmgr:get_by_csv_id(ee.currency_type)
		if currency:get_field("num") < ee.currency_num then
			ret.errorcode = errorcode[6].code
			ret.msg = errorcode[6].msg
			return ret
		else
			local r = math.random(0, 100)
			local rate = ee.enhance_success_rate  + (ee.enhance_success_rate * user:get_field("equipment_enhance_success_rate_up_p")/100 )
			if r < rate then
				e:set_field("level", ee.level)
				e:set_field("combat", ee.combat)
				e:set_field("defense", ee.defense)
				e:set_field("critical_hit", ee.critical_hit)
				e:set_field("king", ee.king)
				e:set_field("critical_hit_probability", ee.critical_hit_probability)
				e:set_field("combat_probability", ee.combat_probability)
				e:set_field("defense_probability", ee.defense_probability)
				e:set_field("king_probability", ee.king_probability)
				
				currency:set_field("num", currency:get_field("num") - ee.currency_num )
				currency:update_db()

				ret.errorcode = errorcode[1].code
				ret.msg = errorcode[1].msg
				ret.e = {}
				ret.e.csv_id  = e:get_field("csv_id")
				ret.e.level   = e:get_field("level")
				ret.e.combat  = e:get_field("combat")
				ret.e.defense = e:get_field("defense")
				ret.e.critical_hit = e:get_field("critical_hit")
				ret.e.king    = e:get_field("king")
				ret.e.combat_probability   = e:get_field("combat_probability")
				ret.e.defense_probability  = e:get_field("defense_probability")
				ret.e.critical_hit_probability = e:get_field("critical_hit_probability")
				ret.e.defense_probability  = e:get_field("defense_probability")
				if e:get_field("csv_id") == 4 and e:get_field("level") % 10 == 0 then
					local key = string.format("%s:%d", "g_equipment_effect", e:get_field("level"))
					local equip_effect = sd.query(key)
					ret.is_valid = true
					ret.effect = equip_effect.effect
					return ret
				else
					ret.is_valid = false
					ret.effect = 0
					return ret
				end
			else
				ret.errorcode = errorcode[24].code
				ret.msg = errorcode[24].msg
				return ret
			end
		end
	end
end

return cls