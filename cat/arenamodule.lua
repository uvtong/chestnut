local skynet = require "skynet"
local dc = require "datacenter"
local super = require "module"
local cls = class("arena", super)

function cls:ctor(env, ... )
	-- body
	self._env = env
	self._me = false
	self._enemy = false
	self._me_modelmgr = false
	self._en_modelmgr = false
	return self
end

function cls:set_me(v, ... )
	-- body
	self._me = v
end

function cls:set_enemy(v, ... )
	-- body
	self._enemy = v
end

function cls:get_me( ... )
	-- body
	return self._me
end

function cls:get_enemy( ... )
	-- body
	return self._enemy
end

function cls:set_me_modelmgr(v, ... )
	-- body
	self._me_modelmgr = v
end

function cls:get_me_modelmgr( ... )
	-- body
	return self._me_modelmgr
end

function cls:set_en_modelmgr(v, ... )
	-- body
	self._en_modelmgr = v
end

function cls:get_en_modelmgr( ... )
	-- body
	return self._en_modelmgr
end

function cls:load_enemy(uid, ... )
	-- body
	if dc.get(uid, "online") then
		local modelmgr_cls = require "load_user"
		local modelmgr = modelmgr_cls.new()
		local addr = dc.get(uid, "addr")
		local r = skynet.call(addr, "lua", "ara_user")
		modelmgr:load_remote(uid, r)
		local user = modelmgr:get_user("user")
		self:set_enemy(user)
		self:set_en_modelmgr(modelmgr)
	else
		local modelmgr_cls = require "load_user"
		local modelmgr = modelmgr_cls.new()
		modelmgr:load1(uid)
		local user = modelmgr:get_user("user")
		self:set_enemy(user)
		self:set_en_modelmgr(modelmgr)
	end
end

function cls:ara_enter(args, ... )
	-- body
	local ctx = self._env
	local u = ctx:get_user()
	local modelmgr = ctx:get_modelmgr()
	local key = string.format("%s:%d", "g_config", 1)
 	local config = sd.query(key)
	local tm = os.date("*t", os.time())
	local t = { year=tm.year, month=tm.month, day=tm.day, hour=config.ara_clg_tms_rst}
	local sec = os.time(t)
	local now = os.time()
	if now > sec then
		u:set_ara_clg_tms(config.ara_clg_tms_max)
	end
	-- reset integral
	local t = { year=tm.year, month=tm.month, day=tm.day, hour=config.ara_integral_rst}
	local sec = os.time(t)
	if now > sec then
		u:set_field("ara_integral", 0)
		local u_ara_ptsmgr = modelmgr:get_u_ara_ptsmgr()
		for k,v in pairs(u_ara_ptsmgr:get_data()) do
			v:set_field("collected", 0)
		end
	end
	local t = { year=tm.year, month=tm.month, day=tm.day, hour=config.ara_clg_tms_pur_tms_rst}
	local sec = os.time(t)
	if now > sec then
		u:set_field("ara_clg_tms_pur_tms", 0)
	end

	local ara_interface = u:get_ara_interface()
	if ara_interface == 1 then
		local ara_fighting = u:get_ara_fighting()
		if ara_fighting == 1 then
			-- ctx:
			ctx:ara_bat_ovr(-1)
			u:set_ara_fighting(0)
			local ret = {}
			ret.errorcode        = errorcode[151].code
			ret.msg              = errorcode[151].msg
			ret.ara_win_tms      = u:get_field("ara_win_tms")
			ret.ara_lose_tms     = u:get_field("ara_lose_tms")
			ret.ara_tie_tms      = u:get_field("ara_tie_tms")
			ret.ara_clg_tms      = u:get_field("ara_clg_tms")
			ret.ara_integral     = u:get_field("ara_integral")
			ret.ara_rfh_tms      = ara_rfh_tms
			ret.ara_rfh_cost_tms = u:get_field("ara_rfh_cost_tms")
			ret.ara_clg_cost_tms = u:get_field("ara_clg_cost_tms")
			ret.ara_rfh_cd       = ara_rfh_cd
		end
	else
		ara_interface = 1
		u:set_ara_interface(ara_interface)
		local ara_fighting = u:get_ara_fighting()
		assert(ara_fighting == 0)
	end
	local factory = ctx:get_myfactory()
	local j = factory:get_today()
	local ara_rfh_tms = j:get_ara_rfh_tms()
	local l = ctx:ara_rfh()
	local key = string.format("%s:%d", "g_config", 1)
	local value = sd.query(key)
	local now = os.time()
	local st = u:get_field("ara_rfh_st")
	local walk = now - st
	local ara_rfh_dt = value["ara_rfh_dt"]
	if walk >= ara_rfh_dt then
		ara_rfh_cd = 0
	else
		ara_rfh_cd = ara_rfh_dt - walk
	end
	u:set_field("ara_rfh_cd", ara_rfh_cd)

	local u_ara_ptsmgr = modelmgr:get_u_ara_ptsmgr()
	local cl = {}
	for i,v in ipairs(const.ARA_PTS) do
		local rc = u_ara_ptsmgr:get_by_csv_id(v)
		if rc then
			local cl_li = {}
			cl_li["integral"] = v
			cl_li["collected"] = (rc:get_field("collected") == 1 and true or false)
			table.insert(cl, cl_li)
		else
			local cl_li = {}
			cl_li["integral"] = v
			cl_li["collected"] = false
			table.insert(cl, cl_li)
		end
	end
	local u_ara_rnk_rwdmgr = modelmgr:get_u_ara_rnk_rwdmgr()
	local rl = {}
	for i,v in ipairs(const.ARA_RNK_RWD) do
		local rc = u_ara_rnk_rwdmgr:get_by_csv_id(v)
		if rc then
			local rl_li = {}
			rl_li["ranking"] = v
			rl_li["collected"] = (rc:get_field("collected") == 1 and true or false)
			table.insert(rl, rl_li)
		else
			local rl_li = {}
			rl_li["ranking"] = v
			rl_li["collected"] = false
			table.insert(rl, rl_li)
		end
	end

	local ret = {}
	ret.errorcode        = errorcode[1].code
	ret.msg              = errorcode[1].msg
	ret.ara_rmd_list     = l
	ret.ara_win_tms      = u:get_field("ara_win_tms")
	ret.ara_lose_tms     = u:get_field("ara_lose_tms")
	ret.ara_tie_tms      = u:get_field("ara_tie_tms")
	ret.ara_clg_tms      = u:get_field("ara_clg_tms")
	ret.ara_integral     = u:get_field("ara_integral")
	ret.ara_rfh_tms      = ara_rfh_tms
	ret.ara_rfh_cost_tms = u:get_field("ara_rfh_cost_tms")
	ret.ara_clg_cost_tms = u:get_field("ara_clg_cost_tms")
	ret.ara_rfh_cd       = ara_rfh_cd
	ret.cl = cl
	ret.rl = rl
	return ret
end

function cls:ara_exit(args, ... )
	-- body
	local ctx = self._env
	local u = ctx:get_user()
	local ara_interface = u:get_ara_interface()
	if ara_interface == 1 then
		local ara_fighting = u:get_ara_fighting()
		if ara_fighting == 1 then
			ctx:ara_bat_ovr(-1)
			u:set_ara_fighting(0)
		end
	else
		u:set_ara_interface(0)
	end
	local ret = {}
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	return ret
end

function cls:ara_choose_role_enter(args, ... )
	-- body
	local u = ctx:get_user()
	local modelmgr = ctx:get_modelmgr()
	local u_rolemgr = modelmgr:get_u_rolemgr()
	if u_rolemgr:get_count() <= 3 then
		local ret = {}
		ret.errorcode = errorcode[150].code
		ret.msg = errorcode[150].msg
		return ret
	else
		local key = string.format("%s:%d", "g_config", 1)
 		local value = sd.query(key)
 		local ara_clg_tms_rst = value["ara_clg_tms_rst"]
		local t = os.date("*t", os.time())
		local t = { year=t.year, month=t.month, day=t.day, hour=ara_clg_tms_rst}
		local sec = os.time(t)
		local now = os.time()
		if now > sec then
			local ara_clg_tms_max = value["ara_clg_tms_max"]
			u:set_ara_clg_tms(ara_clg_tms_max)
		end
		local ara_clg_tms = u:get_field("ara_clg_tms")
		if ara_clg_tms <= 0 then
			local ara_clg_cost_tms = u:get_field("ara_clg_cost_tms")
			ara_clg_cost_tms = ara_clg_cost_tms + 1
			local key = string.format("%s:%d", "g_ara_tms", ara_clg_cost_tms)
			local value = sd.query(key)
			local purchase_cost = value["purchase_cost"]
			local r = util.parse_text(purchase_cost, "(%d+%*%d+%*?)", 2)
			local u_propmgr = modelmgr:get_u_propmgr()
			local prop = u_propmgr:get_by_csv_id(r[1])
			if prop:get_field("num") > r[2] then
				local num = prop:get_field("num") - r[2]
				prop:set_field("num", num)
			else
				local ret = {}
				ret.errorcode = errorcode[31].code
				ret.msg = errorcode[31].msg
				return ret
			end
		end
	end
	local arena = ctx:get_arena()
	arena:set_me(u)
	arena:set_me_modelmgr(modelmgr)
	arena:load_enemy(self.enemy_id)
	local en_modelmgr = arena:get_en_modelmgr()
	local enemy = en_modelmgr:gen_remote()
	local ret = {}
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.bat_roleid[1] = u:get_field("ara_role_id1")
	ret.bat_roleid[2] = u:get_field("ara_role_id2")
	ret.bat_roleid[3] = u:get_field("ara_role_id3")
	ret.e = enemy
	return ret
end

function cls:ara_choose_role(args, ... )
	-- body
	assert(#self.bat_roleid == 3)
	local u = ctx:get_user()
	u:set_field("ara_role_id1", self.bat_roleid[1])
	u:set_field("ara_role_id1", self.bat_roleid[1])
	u:set_field("ara_role_id1", self.bat_roleid[1])
	local ret = {}
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	return ret
end

function cls:ara_bat_enter(args, ... )
 	-- body
end 

function cls:ara_bat_exit(args)
	-- body
end

function cls:ara_rfh(args)
	-- body
	-- first test when to reset
	local u = ctx:get_user()
	local ara_rfh_cd = u:get_field("ara_rfh_cd")
	if ara_rfh_cd > 0 then
		local ara_rfh_cd_cost_tms = u:get_field("ara_rfh_cd_cost_tms")
		ara_rfh_cd_cost_tms = ara_rfh_cd_cost_tms + 1
		local tms = ara_rfh_cd_cost_tms
		if tms < 10 then
		elseif tms < 100 then
			tms = tms // 10 * 10
		elseif tms < 1000 then
			tms = tms // 100 * 100
		end
		local key = string.format("%s:%d", "g_ara_tms", tms)
		local value = sd.query(key)
		local list_cd_refresh_cost = value["list_cd_refresh_cost"]
		local r = util.parse_text(list_cd_refresh_cost, "(%d+%*%d+%*?)", 2)
		local id = tonumber(r[1][1])
		local num = tonumber(r[1][2])
		local prop = u_propmgr:get_by_csv_id(id)
		local onum = prop:get_num()
		if onum > num then
			local nnum = onum - num
			prop:set_num(nnum)
			u:set_field("ara_rfh_cd_cost_tms", ara_rfh_cd_cost_tms)
			u:set_field("ara_rfh_cd", 0)
			local ret = {}
			ret.errorcode = errorcode[1].code
			ret.msg = errorcode[1].msg
			ret.ara_rfh_cd = 0
			return ret
		else
			local ret = {}
			ret.errorcode = errorcode[31].code
			ret.msg = errorcode[31].msg
			return ret
		end
	else	
		local factory = ctx:get_myfactory()
		local j = factory:get_today()
		local ara_rfh_tms = j:get_ara_rfh_tms()
		if ara_rfh_tms > 0 then
			ara_rfh_tms = ara_rfh_tms - 1
			j:set_ara_rfh_tms(ara_rfh_tms)
		else
			
			local modelmgr = ctx:get_modelmgr()
			local u_propmgr = modelmgr:get_u_propmgr()
			local ara_rfh_cost_tms = u:get_ara_rfh_cost_tms()
			ara_rfh_cost_tms = ara_rfh_cost_tms + 1
			local key = string.format("%s:%d", "g_ara_tms", ara_rfh_cost_tms)
			local value = sd.query(key)
			local list_refresh_cost = value["list_refresh_cost"]
			print(list_refresh_cost)
			local r = util.parse_text(list_refresh_cost, "(%d+%*%d+%*?)", 2)
			local id = tonumber(r[1][1])
			local num = tonumber(r[1][2])
			local prop = u_propmgr:get_by_csv_id(id)
			local onum = prop:get_num()
			if onum > num then
				local nnum = onum - num
				prop:set_num(nnum)
			else
				local ret = {}
				ret.errorcode = errorcode[31].code
				ret.msg = errorcode[31].msg
				return ret
			end
		end
		local l = ctx:ara_rfh()
		local ret = {}
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].msg
		ret.ara_rmd_list = l
		return ret
	end
end


function cls:ara_worship(args)
	-- body
	local ctx = self._env
	local modelmgr = ctx:get_modelmgr()
	local u_ara_worshipmgr = modelmgr:get_u_ara_worshipmgr()
	local t = os.date("*t", os.time())
	local t = { year=t.year, month=t.month, day=t.day}
	local today = os.time(t)
	local leaderboards_name = skynet.getenv("leaderboards_name")
	local ranking2 = skynet.call(leaderboards_name, "lua", "ranking", ctx:get_userid())
	local l = {}
	for i,v in ipairs(self.uids) do
		local li = {}
		li.uid = v
		local r = u_ara_worshipmgr:get_by_csv_id(v)
		if r:get_field("date") == today and r:get_field("worship") == 1 then
			li.worship = true
		else
			local ranking1 = skynet.call(leaderboards_name, "lua", "ranking", v)
			if ranking1 >= 100 and ranking1 > ranking2 then
				local key = string.format("%s:%d", "g_config", 1)
				local value = sd.query(key)
				local id = value["worship_reward_id"]
				local num = value["worship_reward_num"]
				local u_propmgr = modelmgr:get_u_propmgr()
				local prop = user.u_propmgr:get_by_csv_id(id)
				prop.num = prop.num + num
				if r:get_field("date") ~= today then
					local u_ara_worship_rc = modelmgr:get_u_ara_worship_rcmgr()
					local rc = u_ara_worship_rc:create_entity(r.__fields)
					rc:update_db()
					r:set_field("date", today)
					r:set_field("worship", 1)
				else
					r:set_field("worship", 1)
				end
				li.worship = true
				ret.errorcode = errorcode[1].code
				ret.msg = errorcode[1].msg
				return ret
			else
				li.worship = false
				ret.errorcode = errorcode[33].code
				ret.msg = errorcode[33].msg
				return ret
			end
		end
	end
	local ret = {}
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	return ret
end

function cls:ara_rnk_reward_collected(args)
	-- body
	local ret = {}
	local leaderboards_name = skynet.getenv("leaderboards_name")
	local ranking = skynet.call(leaderboards_name, "lua", "ranking", ctx:get_userid())
	local u = ctx:get_user()
	local modelmgr = ctx:get_modelmgr()
	local u_ara_rnk_rwdmgr = modelmgr:get_u_ara_rnk_rwdmgr()
	local seg = 0
	if ranking < 10 then
		seg = ranking
	elseif ranking < 100 then
		seg = (seg // 10 * 10)
	elseif ranking < 1000 then
		seg = seg // 100 * 100
	else
		assert(false)
	end
	local u_propmgr = modelmgr:get_u_propmgr()
	local props = {}
	local rl = {}
	local rnk_rwd = u_ara_rnk_rwdmgr:get_by_csv_id(seg)
	if rnk_rwd == nil then
		local tmp = {}
		tmp["user_id"] = u:get_field("csv_id")
		tmp["csv_id"] = seg
		tmp["id"] = genpk_2(u:get_field("csv_id"), seg)
		tmp["collected"] = 1

		local key = string.format("%s:%d", "g_ara_rnk_rwd", seg)
		local value = sd.query(key)
		local reward = util.parse_text(value["reward"], "(%d+%*%d+%*?)", 2)
		for i,v in ipairs(reward) do
			local prop = u_propmgr:get_by_csv_id(v[1])
			if prop then
				prop:set_field("num", prop:get_field("num") + v[2])
			else
				local key = string.format("%s:%d", "g_prop", v[1])
				local prop = sd.query(key)
				prop["user_id"] = u:get_field("csv_id")
				prop["num"] = v[2]
				prop["id"] = genpk_2(v:get_field("csv_id"), v[2])
				prop = u_propmgr:create_entity(prop)
				u_propmgr:add(prop)
				prop:update_db()
			end
			local prop_li = {}
			prop_li["csv_id"] = prop:get_field("csv_id")
			prop_li["num"] = prop:get_field("num")
			table.insert(props, prop_li)
		end
	else
		if rnk_rwd:get_field("collected") == 1 then
			local ret = {}
			ret.errorcode = errorcode[152].code
			ret.msg = errorcode[152].msg
			return ret
		else
			rnk_rwd:set_field("collected", 1)

			local key = string.format("%s:%d", "g_ara_rnk_rwd", seg)
			local value = sd.query(key)
			local reward = util.parse_text(value["reward"], "(%d+%*%d+%*?)", 2)
			for i,v in ipairs(reward) do
				local prop = u_propmgr:get_by_csv_id(v[1])
				if prop then
					prop:set_field("num", prop:get_field("num") + v[2])
				else
					local key = string.format("%s:%d", "g_prop", v[1])
					local prop = sd.query(key)
					prop["user_id"] = u:get_field("csv_id")
					prop["num"] = v[2]
					prop["id"] = genpk_2(v:get_field("csv_id"), v[2])
					prop = u_propmgr:create_entity(prop)
					u_propmgr:add(prop)
					prop:update_db()
				end
				local prop_li = {}
				prop_li["csv_id"] = prop:get_field("csv_id")
				prop_li["num"] = prop:get_field("num")
				table.insert(props, prop_li)
			end
		end
	end
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.props = props
	ret.rl = rl
	return ret
end

function cls:ara_convert_pts(args, ... )
	-- body
	local u = ctx:get_user()
	local modelmgr = ctx:get_modelmgr()
	local key = string.format("%s:%d", "g_config", 1)
 	local config = sd.query(key)
	local tm = os.date("*t", os.time())
	local t = { year=tm.year, month=tm.month, day=tm.day, hour=config.ara_integral_rst}
	local sec = os.time(t)
	local now = os.time()
	if now > sec then
		u:set_field("ara_integral", 0)
		local u_ara_ptsmgr = modelmgr:get_u_ara_ptsmgr()
		for k,v in pairs(u_ara_ptsmgr:get_data()) do
			v:set_field("collected", 0)
		end
	end
	local u_propmgr = modelmgr:get_u_propmgr()
	local props = {}
	local cl = {}
	local u_ara_ptsmgr = modelmgr:get_u_ara_ptsmgr()
	local ara_integral = u:get_ara_integral()
	if ara_integral > 0 then
		for i=ara_integral,1 do
			if i // 2 == 0 then
				local r = u_ara_ptsmgr:get_by_csv_id(i)
				if r == nil then
					local tmp = {}
					tmp["user_id"] = u:get_field("csv_id")
					tmp["csv_id"] = i
					tmp["id"] = genpk_2(u:get_field("csv_id"), i)
					tmp["collected"] = 1
					local entity = u_ara_ptsmgr:create_entity(tmp)
					u_ara_ptsmgr:add(entity)
					entity:update_db()
					local key = string.format("%s:%d", "g_ara_pts", i)
					local ara_pts = sd.query(key)
					local reward = util.parse_text(ara_pts.reward, "(%d+%*%d+%*?)", 2)
					for i,v in ipairs(reward) do
						local prop = u_propmgr:get_by_csv_id(v[1])
						if prop then
							prop:set_field("csv_id", prop:get_field("csv_id") + v[2])
						else
							local key = string.format("%s:%d", "g_prop", v[1])
							local prop = sd.query(key)
							prop["user_id"] = u:get_field("csv_id")
							prop["num"] = v[2]
							prop["id"] = genpk_2(v:get_field("csv_id"), v[2])
							prop = u_propmgr:create_entity(prop)
							u_propmgr:add(prop)
							prop:update_db()
						end
						local prop_li = {}
						prop_li["csv_id"] = prop:get_field("csv_id")
						prop_li["num"] = prop:get_field("num")
						table.insert(props, prop_li)
					end
					local cl_li = {}
					cl_li["internal"] = i
					cl_li["collected"] = true
					table.insert(cl, cl_li)
				else
					local collected = r:get_field("collected")
					if collected then
						break
					else
						r:set_field("collected", 1)
						local key = string.format("%s:%d", "g_ara_pts", i)
						local value = sd.query(key)
						local reward = value["reward"]
						local reward = util.parse_text(reward, "(%d+%*%d+%*?)", 2)
						for i,v in ipairs(reward) do
							local prop = u_propmgr:get_by_csv_id(v[1])
							if prop then
								prop:set_field("csv_id", prop:get_field("csv_id") + v[2])
							else
								local key = string.format("%s:%d", "g_prop", v[1])
								local prop = sd.query(key)
								prop["user_id"] = u:get_field("csv_id")
								prop["num"] = v[2]
								prop["id"] = genpk_2(v:get_field("csv_id"), v[2])
								prop = u_propmgr:create_entity(prop)
								u_propmgr:add(prop)
								prop:update_db()
							end
							local prop_li = {}
							prop_li["csv_id"] = prop:get_field("csv_id")
							prop_li["num"] = prop:get_field("num")
							table.insert(props, prop_li)
						end
						local cl_li = {}
						cl_li["internal"] = i
						cl_li["collected"] = true
						table.insert(cl, cl_li)
					end
				end
			end
		end
	end
	local ret = {}
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.props = props
	ret.cl = cl
	return ret
end

function cls:ara_lp(args, ... )
	-- body
	local ctx = self._env
	local leaderboards_name = skynet.getenv("leaderboards_name")
	local r1 = skynet.call(leaderboards_name, "lua", "ranking_range", 1, 10)
	local l = {}
	for i,v in ipairs(r1) do
		local li = {}
		local ranking = i
		local uid = v
		li.ranking = ranking
		li.uid = uid
		li.top = true
		print("#########################ara_lp", li.uid)
		local usersmgr = ctx:get_usersmgr()
		if usersmgr:get(uid) then
			local u = usersmgr:get(uid)
			li["total_combat"] = u:get_field("sum_combat")
			li["uname"] = u:get_field("uname")
			table.insert(l, li)
		elseif dc.get(uid, "online") then
			local addr = dc.get(uid, "addr")
			local u = skynet.call(addr, "lua", "user")
			li["total_combat"] = u["user"].sum_combat
			li["uname"] = u["user"].uname
			table.insert(l, li)
		else
			local usersmgr = ctx:get_usersmgr()
			usersmgr:load_cache(uid)
			local u = usersmgr:get(uid)
			li["total_combat"] = u:get_field("sum_combat")
			li["uname"] = u:get_field("uname")
			table.insert(l, li)
		end
	end
	local ret = {}
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.lp = l
	return ret
end

return cls