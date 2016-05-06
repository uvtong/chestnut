package.path = "./../cat/?.lua;../lualib/?.lua;" .. package.path
package.cpath = "./../cat/luaclib/?.so;" .. package.cpath
local skynet = require "skynet"
require "skynet.manager"
local netpack = require "netpack"
local socket = require "socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local mc = require "multicast"
local dc = require "datacenter"
local util = require "util"
local loader = require "loader" 
local errorcode = require "errorcode"
local const = require "const"
local tptr = require "tablepointer"
local context = require "agent_context"
local notification = require "notification"

local friendrequest = require "friendrequest"
local friendmgr = require "friendmgr"
local M = {}
local new_emailrequest = require "new_emailrequest"
local checkinrequest = require "checkinrequest"
local exercise_request = require "exercise_request"
local cgold_request = require "cgold_request"
local kungfurequest = require "kungfurequest"
local new_drawrequest = require "new_drawrequest"
local lilian_request = require "lilian_request"
local core_fightrequest = require "core_fightrequest"

table.insert(M, checkinrequest )
table.insert(M, exercise_request )
table.insert(M, cgold_request )
table.insert(M, new_emailrequest )
table.insert(M, kungfurequest )
table.insert(M, new_drawrequest )
table.insert(M, lilian_request )
table.insert(M, core_fightrequest)

local host
local send_request
local gate
local userid, subid
local secret

local CMD       = {}
local REQUEST   = {}
local RESPONSE  = {}
local SUBSCRIBE = {}

local func_gs 
local table_gs = {}

local db
local game
local user

local leaderboards_name = skynet.getenv("leaderboards_name")
local lb = skynet.localname(leaderboards_name)

notification.handler = function (event)
	-- body
	if event == notification.EGOLD then
		context:raise_achievement(const.ACHIEVEMENT_T_2)
	elseif event == notification.EEXP then
		context:raise_achievement(const.ACHIEVEMENT_T_3)
	else
		context:raise_achievement(const.ACHIEVEMENT_T_7)
	end
end

local global_response_session = 1

local function send_package(pack)
	-- body

	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end

local function flush_db(priority)
	-- body
	assert(priority)
	if user then
		for k,v in pairs(user) do
			if string.match(k, "^u_[%w_]+mgr$") then
				v:update_db(priority)
			end
		end
		user:__update_db_all(priority)
		local cm = user.u_checkin_monthmgr:get_checkin_month()
		if cm then
			cm:__update_db({"checkin_month"}, priority)
		end
		local ls = user.u_lilian_submgr:get_lilian_sub()
		if ls then
			ls:__update_db( {"first_lilian_time" , "start_time" , "update_time" , "used_queue_num" , "end_lilian_time" } , priority )
		end
	end
end

local function get_journal()
	-- body
	local t = os.date("*t", os.time())
	t = { year=t.year, month=t.month, day=t.day}
	local sec = os.time(t)
	local j = user.u_journalmgr:get_by_date(sec)
	if j then
		return j
	else
		t = { user_id=user.csv_id, date=sec, goods_refresh_count=0, goods_refresh_reset_count=0}
		j = user.u_journalmgr.create(t)
		user.u_journalmgr:add(j)
		j:__insert_db(const.DB_PRIORITY_1)
		return j
	end
end

local function get_prop(csv_id)
	-- body
	print("get_prop", csv_id)
	local p = user.u_propmgr:get_by_csv_id(csv_id)
	if p then
		return p
	else
		p = skynet.call(game, "lua", "query_g_prop", csv_id)
		p.user_id = user.csv_id
		p.num = 0
		p = user.u_propmgr.create(p)
		user.u_propmgr:add(p)
		p:__insert_db(const.DB_PRIORITY_2)
		return p
	end
end

local function get_goods(csv_id)
	-- body
	local p = user.u_goodsmgr:get_by_csv_id(csv_id)
	if p then
		return p
	else
		p = skynet.call(game, "lua", "query_g_goods", csv_id)
		p.user_id = user.csv_id
		p.inventory = p.inventory_init
		p.countdown = 0
		p.st = 0
		p = user.u_goodsmgr.create(p)
		user.u_goodsmgr:add(p)
		p:__insert_db(const.DB_PRIORITY_2)
	end
end

local function store_refresh_reset_count()
	-- body
	-- could refresh the cd of the goods.
	local j = get_journal()
	if j.goods_refresh_reset_count ~= 1 then
		local hour = os.date("%H")
		local min = os.date("%M")
		local sec = os.date("%S")
		local goods_refresh_reset_h = skynet.call("SIMPLEDB", "lua", "GET", "goods_refresh_reset_h")
		if tonumber(hour) > goods_refresh_reset_h then
			j.goods_refresh_count = 0
			j.goods_refresh_reset_count = 1
			j:__update_db({"goods_refresh_count", "goods_refresh_reset_count"})
		end
	end
end

local function xilian(role, t)
	-- body
	assert(type(t) == "table")
	local ret = {}
	local property_pool = skynet.call(game, "lua", "query_g_property_pool")
	local last = 0
	local sum = 0
	for k,v in pairs(property_pool) do
		v.min = last
		sum = sum + v.probability
		v.max = sum
	end
	local n = 0
	if t.is_locked1 then
		n = n + 1
		ret.property_id1 = role.property_id1
		ret.value1 = role.value1
	else
		local property_pool_id
		local rand = math.random(0, sum-1)
		for k,v in pairs(property_pool) do
			if rand >= v.min and rand < v.max then
				property_pool_id = v.property_pool_id
				break
			end
		end
		assert(property_pool_id)
		property_pool_id = 1
		local last1 = 0
		local sum1 = 0
		local second = skynet.call(game, "lua", "query_g_property_pool_second", 0, property_pool_id)
		for i,v in ipairs(second) do
			v.min = last1
			sum1 = sum1 + v.probability
			v.max = sum1
		end
		rand = math.random(0, sum1-1)
		for i,v in ipairs(second) do
			if rand >= v.min and rand < v.max then
				ret.property_id1 = v.property_id
				ret.value1 = v.value
				break
			end
		end
	end

	if t.is_locked2 then
		n = n + 1
		ret.property_id2 = role.property_id2
		ret.value2 = role.value2
	else
		local property_pool_id
		local rand = math.random(0, sum-1)
		for k,v in pairs(property_pool) do
			if rand >= v.min and rand < v.max then
				property_pool_id = v.property_pool_id
				break
			end
		end
		assert(property_pool_id)
		property_pool_id = 1
		local last1 = 0
		local sum1 = 0
		local second = skynet.call(game, "lua", "query_g_property_pool_second", 0, property_pool_id)
		for i,v in ipairs(second) do
			v.min = last1
			sum1 = sum1 + v.probability
			v.max = sum1
		end
		rand = math.random(0, sum1-1)
		for i,v in ipairs(second) do
			if rand >= v.min and rand < v.max then
				ret.property_id2 = v.property_id
				ret.value2 = v.value
				break
			end
		end
	end

	if t.is_locked3 then
		n = n + 1
		ret.property_id3 = role.property_id3
		ret.value3 = role.value3
	else
		local property_pool_id
		local rand = math.random(0, sum-1)
		for k,v in pairs(property_pool) do
			if rand >= v.min and rand < v.max then
				property_pool_id = v.property_pool_id
				break
			end
		end
		assert(property_pool_id)
		property_pool_id = 1
		local last1 = 0
		local sum1 = 0
		local second = skynet.call(game, "lua", "query_g_property_pool_second", 0, property_pool_id)
		for i,v in ipairs(second) do
			v.min = last1
			sum1 = sum1 + v.probability
			v.max = sum1
		end
		rand = math.random(0, sum1-1)
		for i,v in ipairs(second) do
			if rand >= v.min and rand < v.max then
				ret.property_id3 = v.property_id
				ret.value3 = v.value
				break
			end
		end
	end

	if t.is_locked4 then
		n = n + 1
		ret.property_id4 = role.property_id4
		ret.value4 = role.value4
	else
		local property_pool_id
		local rand = math.random(0, sum-1)
		for k,v in pairs(property_pool) do
			if rand >= v.min and rand < v.max then
				property_pool_id = v.property_pool_id
				break
			end
		end
		assert(property_pool_id)
		property_pool_id = 1
		local last1 = 0
		local sum1 = 0
		local second = skynet.call(game, "lua", "query_g_property_pool_second", 0, property_pool_id)
		for i,v in ipairs(second) do
			v.min = last1
			sum1 = sum1 + v.probability
			v.max = sum1
		end
		rand = math.random(0, sum1-1)
		for i,v in ipairs(second) do
			if rand >= v.min and rand < v.max then
				ret.property_id4 = v.property_id
				ret.value4 = v.value
				break
			end
		end
	end

	if t.is_locked5 then
		n = n + 1
		ret.property_id5 = role.property_id5
		ret.value5 = role.value5
	else
		local property_pool_id
		local rand = math.random(0, sum-1)
		for k,v in pairs(property_pool) do
			if rand >= v.min and rand < v.max then
				property_pool_id = v.property_pool_id
				break
			end
		end
		assert(property_pool_id)
		property_pool_id = 1
		local last1 = 0
		local sum1 = 0
		local second = skynet.call(game, "lua", "query_g_property_pool_second", 0, property_pool_id)
		for i,v in ipairs(second) do
			v.min = last1
			sum1 = sum1 + v.probability
			v.max = sum1
		end
		rand = math.random(0, sum1-1)
		for i,v in ipairs(second) do
			if rand >= v.min and rand < v.max then
				ret.property_id5 = v.property_id
				ret.value5 = v.value
				break
			end
		end
	end
	return n, ret
end

local function cp_exit()
	-- body
	print("cp_exit*********************************%d", user.cp_battle_id)
	if user.cp_battle_id > 0 then
 		local cp_rc = user.u_checkpoint_rcmgr:get_by_csv_id(user.cp_battle_id)
 		if cp_rc.cd_finished == 0 then
 			local now = os.time()
			cp_rc.cd_walk = cp_rc.cd_walk + (now - cp_rc.cd_starttime)
			cp_rc.cd_starttime = 0
		end
		user.cp_battle_id = 0
		user.cp_battle_chapter = 0
	end
end

local function subscribe( )
	-- body
	local c = skynet.call(".channel", "lua", "agent_start", user.csv_id, skynet.self())
	local c2 = mc.new {
		channel = c,
		dispatch = function ( channel, source, cmd, tvals , ... )
			-- body
			if SUBSCRIBE[cmd] then
				local f = assert(SUBSCRIBE[cmd])
				f(SUBSCRIBE, tvals, ...)
			else
				for k,v in pairs(M) do
					if v.SUBSCRIBE[cmd] then
						local f = assert(v.SUBSCRIBE[cmd])
						f(SUBSCRIBE, tvals, ...)
						break		
					end
				end
			end
		end
	}
	c2:subscribe()
end

function REQUEST:achievement()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(user)
	local l = {}
	for i=1,const.ACHIEVEMENT_T_SUM do
		local flag = false
		for j=1,11 do
			local T = i + 1
			local idx = i * 1000 + j
			local a = user.u_achievement_rcmgr:get_by_csv_id(idx)
			if a then
				if a.reward_collected ~= 1 then
					flag = true
				end
			else
				a = assert(user.u_achievementmgr:get_by_type(T))
				assert(a.csv_id == idx, string.format("T: %d, idx: %d", T, idx))
				flag = true
			end
			if flag then
				local tmp = {}
				for k,v in pairs(a) do
					tmp[k] =v
				end
				tmp.reward_collected = false
				tmp.is_unlock = true
				table.insert(l, tmp)
				break
			end
		end
		assert(flag)
	end
	ret.errorcode = errorcode[1].code
    ret.msg = errorcode[1].msg
    ret.achis = l
    return ret
end

function REQUEST:achievement_reward_collect()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(user)
	assert(self.csv_id)
	local a = user.u_achievement_rcmgr:get_by_csv_id(self.csv_id)
	if a and a.finished == 100 and a.reward_collected == 0 then
		a.reward_collected = 1
		local a_src = skynet.call(game, "lua", "query_g_achievement", a.csv_id)
		if a_src.type == 2 then
			local csv_id1 = string.gsub(a_src.reward, "(%d*)%*(%d*)", "%1")
			local num1 = string.gsub(a_src.reward, "(%d*)%*(%d*)", "%2")
			local prop = get_prop(csv_id1)

			local prop = user.u_propmgr:get_by_csv_id(csv_id1)
			if prop then
				prop.num = prop.num + num1
				prop:__update_db({"num"})
			else
				prop = game.g_propmgr:get_by_csv_id(csv_id1)
				prop.user_id = user.csv_id
				prop.num = num1
				prop = user.u_propmgr.create(prop)

				prop:__insert_db(const.DB_PRIORITY_2)
			end
		end
		local next = user.u_achievement_rcmgr:get_by_csv_id(a_src.unlock_next_csv_id)
		if next then
			ret.next = {}
			for k,v in pairs(next) do
				ret.next[k] = v
			end
			ret.next.reward_collected = (next.reward_collected == 1) and true or false
			ret.next.is_unlock = (next.is_unlock == 1) and true or false
		else
			next = user.u_achievementmgr:get_by_type(a_src.type)
			if a_src.unlock_next_csv_id ~= 0 then
				assert(next.csv_id == a_src.unlock_next_csv_id, string.format("%d, %d", next.csv_id, a_src.unlock_next_csv_id))
			end
			ret.next = {}
			for k,v in pairs(next) do
				ret.next[k] = v
			end
			ret.next.reward_collected = false
			ret.next.is_unlock = true
		end
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].msg
		return ret
	end
	ret.errorcode = errorcode[26].code
	ret.msg = errorcode[26].msg
	return ret
end
        	
local function get_public_email()
	local r = skynet.call( ".channel" , "lua" , "agent_get_public_email" , user.csv_id , user.pemail_csv_id , user.signup_time )
	assert( r )

	for k , v in ipairs( r ) do
		assert( v and v.pemail_csv_id )
		
		user.pemail_csv_id = v.pemail_csv_id
		user:__update_db( { "pemail_csv_id" }, const.DB_PRIORITY_2)

		v.pemail_csv_id = nil
		new_emailrequest:public_email( v , user )
	end 
end    	
	 	
function REQUEST:login()
	assert((#self.account > 1 and #self.password > 1), string.format("from client account:%s, password:%s incorrect.", self.account, self.password))
	local ret = {}
	if user then
		if user.uaccount == self.account and user.upassword == self.password then
			ret.errorcode  = errorcode[14].code
			ret.msg = errorcode[14].msg
			return ret
		else
			user.ifonline = 0
			flush_db(const.DB_PRIORITY_1)
			dc.set(user.csv_id, nil)
			loader.clear(user)
			user = nil
		end
	end
	local condition = {{ uaccount = self.account, upassword = self.password }}
	local addr = util.random_db()
	local r = skynet.call(addr, "lua", "command", "select", "users", condition)
	if #r == 0  then
		ret.errorcode = errorcode[15].code
		ret.msg = errorcode[15].msg
		return ret
	elseif #r == 1 then
		local usersmgr = require "models/usersmgr"
		user = usersmgr.create(r[1])
		if dc.get(user.csv_id) then
			skynet.error("user %d is logged in the agent %d", user.csv_id, dc.get(user.csv_id).addr)
			user = nil
			ret.errorcode = errorcode[14].code
			ret.msg = errorcode[14].msg
			return ret
		end

		
	else
		assert(false)
	end 
end	
	
local function print_user(user)
	assert(user)
	print( "print_user is called" )
	for k ,v in pairs(user) do
		if string.match(k, "^u_[%w_]+mgr$") then
			local t = {}
			for sk , sv in pairs(v.__data) do
				table.insert(t, sk .. "--" .. tostring(sv) )
			end
			print(string.format( "%s:%s", k, table.concat(t, ",") ))
		end
		print( k , v )		
	end
end
	
local function __logout()
	-- body
	assert(user)
	cp_exit()
	flush_db(const.DB_PRIORITY_1)
	loader.clear( user )
	print_user(user)
	user.ifonline = 0
	user:__update_db({"ifonline"}, const.DB_PRIORITY_1)
	dc.set(user.csv_id , nil)
	user = nil
end

function REQUEST:logout()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	__logout()
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	return ret
end

function REQUEST:role_info()
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(user)
	assert(self.role_id)
	local role = assert(user.u_rolemgr:get_by_csv_id(self.role_id))
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.r = role
	ret.r.is_possessed = true
	local prop = user.u_propmgr:get_by_csv_id(role.us_prop_csv_id)
	if prop then
		ret.r.u_us_prop_num = prop.num
	else
		ret.r.u_us_prop_num = 0
	end
	return ret
end	

function REQUEST:choose_role()
	assert(false)
end	
	
function REQUEST:role_upgrade_star()
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(self.role_csv_id)
	local role = assert(user.u_rolemgr:get_by_csv_id(self.role_csv_id))
	local prop = user.u_propmgr:get_by_csv_id(role.us_prop_csv_id)
	local role_star = skynet.call(game, "lua", "query_g_role_star", role.csv_id*1000+role.star+1)
	if prop and prop.num >= role_star.us_prop_num then
		prop.num = prop.num - role_star.us_prop_num
		prop:__update_db({"num"})
		role.star = role_star.star
		-- role.us_prop_csv_id = assert(role_star.us_prop_csv_id)
		role.us_prop_num = assert(role_star.us_prop_num)
		role.sharp = assert(role_star.sharp)
		role.skill_csv_id = assert(role_star.skill_csv_id)
		role.gather_buffer_id = assert(role_star.gather_buffer_id)
		role.battle_buffer_id = assert(role_star.battle_buffer_id)
		role:__update_db({"star", "us_prop_num", "sharp", "skill_csv_id", "gather_buffer_id", "battle_buffer_id"})
		-- return
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].msg
		ret.r = {
			csv_id = role.csv_id,
			is_possessed = true,
			star = role.star,
    		u_us_prop_num = prop.num
		}
		return ret
	else
		ret.errorcode = errorcode[3].code
		ret.msg = errorcode[3].msg
		return ret
	end
end
		
function REQUEST:wake()
	assert(false)
end		

function REQUEST:props()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(user)
	local l = {}
	for k,v in pairs(user.u_propmgr.__data) do
		table.insert(l, v)
	end
	ret.l = l
	return ret
end

function REQUEST:use_prop()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(user)
	assert(#self.props == 1)
	local l = {}
	local prop = assert(get_prop(self.props[1].csv_id))
	if self.props[1].num > 0 then
		-- get
		prop.num = prop.num + v.num
		prop.__update_db({"num"})
		table.insert(l, prop)
	elseif self.props[1].num < 0 then
		-- consume
		local num = math.abs(self.props[1].num)
		if prop.num < num then
			ret.errorcode = errorcode[16].code
			ret.msg = errorcode[16].msg
			return ret
		end
		prop.num = prop.num + self.props[1].num
		prop:__update_db({"num"})
		table.insert(l, prop)
		if assert(prop.use_type) == 0 then
			ret.errorcode = errorcode[28].code
			ret.msg = errorcode[28].msg
			return ret
		elseif assert(prop.use_type) == 1 then -- exp 
			local e = user.u_propmgr:get_by_csv_id(const.EXP)
			e.num = e.num + (tonumber(prop.pram1) * num)
			e:__update_db({"num"})
			table.insert(l, e)
			context:raise_achievement(const.ACHIEVEMENT_T_3)
		elseif assert(prop.use_type) == 2 then -- gold
			local g = user.u_propmgr:get_by_csv_id(const.GOLD)
			g.num = g.num + (tonumber(prop.pram1) * num)
			g:__update_db({"num"})
			table.insert(l, g)
			context:raise_achievement(const.ACHIEVEMENT_T_2)
		elseif assert(prop.use_type) == 3 then
			local r = util.parse_text(prop.pram1, "(%d+%*%d+%*?)", 2)
			print("length of r", #r)
			for k,v in pairs(r) do
				if v[1] == const.GOLD then
					local prop = user.u_propmgr:get_by_csv_id(const.GOLD)
					prop.num = prop.num + (v[2] * num)
					prop:__update_db({"num"})
					table.insert(l, prop)
					context:raise_achievement(const.ACHIEVEMENT_T_2)
				elseif v[1] == const.EXP then
					local prop = user.u_propmgr:get_by_csv_id(v[1])
					prop.num = prop.num + (v[2] * num)
					prop:__update_db({"num"})
					table.insert(l, prop)
					context:raise_achievement(const.ACHIEVEMENT_T_3)
				else
					local prop = get_prop(v[1])
					prop.num = prop.num + (v[2] * num)
					prop:__update_db({"num"})
					table.insert(l, prop)
				end
			end
		elseif assert(prop.use_type) == 4 then
			local f = false
			local r = util.parse_text(prop.pram1, "(%d+%*%d+%*%d+%*?)", 3)
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
					local prop = assert(get_prop(v[1]))
					prop.num = prop.num + (v[2] * num)
					prop:__update_db({"num"})
					table.insert(l, prop)
					break
				end
			end
			assert(f)
		end	
	else
		ret.errorcode = errorcode[27].code
		ret.msg = errorcode[27].msg
		return ret
	end
	ret.errorcode = errorcode[1].code
	ret.msg	= errorcode[1].msg
	ret.props = l
	return ret
end

function REQUEST:user()
	-- body
	local ret = {}
	print("called****************************111")
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg	= errorcode[2].msg
		return ret
	end
	assert(user)
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.user = {
		uname = user.uname,
    	uviplevel = user.uviplevel,
    	config_sound = (user.config_sound == 1) and true or false,
    	config_music = (user.config_music == 1) and true or false,
    	avatar = user.avatar,
    	sign = user.sign,
    	c_role_id = user.c_role_id,
    	level = user.level,
    	recharge_rmb = user.recharge_rmb,
    	recharge_diamond = user.recharge_diamond,
    	uvip_progress = user.uvip_progress,
    	cp_hanging_id = user.cp_hanging_id,
    	uexp = assert(user.u_propmgr:get_by_csv_id(const.EXP)).num,
    	gold = assert(user.u_propmgr:get_by_csv_id(const.GOLD)).num,
    	diamond = assert(user.u_propmgr:get_by_csv_id(const.DIAMOND)).num,
    	love = assert(user.u_propmgr:get_by_csv_id(const.LOVE)).num,
	}
	print("called****************************222")
	ret.user.equipment_list = {}
	for k,v in pairs(user.u_equipmentmgr.__data) do
		table.insert(ret.user.equipment_list, v)
	end
	print("called****************************333")
	ret.user.kungfu_list = {}
	for k,v in pairs(user.u_kungfumgr.__data) do
		table.insert(ret.user.kungfu_list, v)
	end
	print("called****************************444")
	ret.user.rolelist = {}
	for k,v in pairs(user.u_rolemgr.__data) do
		table.insert(ret.user.rolelist, v)
	end
	print("called****************************555")
	return ret
end

function REQUEST:user_can_modify_name()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	if user.modify_uname_count >= 1 then
		ret.errorcode = errorcode[17].code
		ret.msg = errorcode[17].msg
	else
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].msg
	end
	return ret
end

function REQUEST:user_modify_name()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg	= errorcode[2].msg
		return ret
	end
	if user.modify_uname_count >= 1 then
		local prop = user.u_propmgr:get_by_csv_id(const.DIAMOND)
		if prop.num >= 100 then
			prop.num = prop.num - 100
			prop:__update_db({"num"})
			user.uname = self.name
			user.modify_uname_count = user.modify_uname_count + 1
			user:__update_db({"modify_uname_count", "uname"}, const.DB_PRIORITY_2)
			ret.errorcode = errorcode[1].code
			ret.msg = errorcode[1].msg
			return ret
		else
			ret.errorcode = errorcode[6].code
			ret.msg = errorcode[6].msg
			return ret
		end
	else
		user.uname = self.name
		user.modify_uname_count = user.modify_uname_count + 1
		user:__update_db({"modify_uname_count", "uname"}, const.DB_PRIORITY_2)
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].msg
		return ret
	end
end

function REQUEST:user_upgrade()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(user)
	local user_level_max
	local xilian_begain_level
	local ptr = skynet.call(game, "lua", "query_g_config")
	tptr.createtable(ptr)
	for _,k,v in tptr.pairs(ptr) do
		if k == "user_level_max" then
			user_level_max = v
		elseif k == "xilian_begain_level" then
			xilian_begain_level = v
		end
	end
	if user.level + 1 >= user_level_max then
		ret.errorcode = errorcode[30].code
		ret.msg = errorcode[30].msg
		return ret
	else
		local L = skynet.call(game, "lua", "query_g_user_level", user.level + 1)
		local prop = user.u_propmgr:get_by_csv_id(const.EXP)
		if prop.num >= tonumber(L.exp) then
			prop.num = prop.num - L.exp
			user.level = L.level
			user.combat = L.combat
			user.defense = L.defense
			user.critical_hit = L.critical_hit
			user.blessing = L.skill              -- blessing.
			user.gold_max = assert(L.gold_max)
			user.exp_max = assert(L.exp_max)
			if user.level >= xilian_begain_level then
				user.ifxilian = 1
			end
			context:raise_achievement(const.ACHIEVEMENT_T_7)
			ret.errorcode = errorcode[1].code
			ret.msg = errorcode[1].msg
			return ret
		else
			ret.errorcode = errorcode[19].code
			ret.msg	= errorcode[19].msg
			return ret
		end
	end
end

function REQUEST:shop_all()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg	= errorcode[2].msg
		return ret
	end
	assert(user)
	local r = skynet.call(game, "lua", "query_g_goods")
	local ll = {}
	for k,v in pairs(r) do
		local tmp = user.u_goodsmgr:get_by_csv_id(v.csv_id)
		if tmp then
			if tmp.inventory == 0 then
				local now = os.time()
				local walk = os.difftime(now, tmp.st)
				if walk > v.cd then
					tmp.inventory = v.inventory_init
					tmp.countdown = 0
					tmp.st = 0
					tmp:__update_db({"inventory", "countdown", "st"})
				else
					tmp.countdown = v.cd - walk
					tmp:__update_db({"countdown"})
				end
			end
		else
			v.user_id = user.csv_id
			v.inventory = v.inventory_init
			v.countdown = 0
			v.st = 0
			tmp = user.u_goodsmgr.create(v)
			user.u_goodsmgr:add(tmp)
			tmp:__insert_db(const.DB_PRIORITY_2)
		end
		for kk,vv in pairs(tmp) do
			v[kk] = vv
		end
		table.insert(ll, v)
	end
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.l = ll
	ret.goods_refresh_count = assert(get_journal().goods_refresh_count)
	ret.store_refresh_count_max = assert(user.store_refresh_count_max)
	return ret
end

function REQUEST:shop_refresh()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
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

function REQUEST:shop_purchase()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg	= errorcode[2].msg
		return ret
	end
	assert(user)
	assert(self.g)
	local gg = skynet.call(game, "lua", "query_g_goods", self.g[1].goods_id)
	local ug = user.u_goodsmgr:get_by_csv_id(gg.csv_id)
	if gg.currency_type == const.GOLD then
		local gold = gg.currency_num * self.g[1].goods_num
		local currency = user.u_propmgr:get_by_csv_id(const.GOLD)
		if currency.num >= gold then
			if ug.inventory == 0 then
				local now = os.time()
				local countdown = os.difftime(now, goods.st)
				if countdown > goods.cd then
					ug.inventory = ug.inventory_init
					ug.countdown = 0
					ug:__update_db({"inventory", "countdown"})
				else
					ug.countdown = countdown
					ug:__update_db({"countdown"})
					ret.errorcode = errorcode[10].code
					ret.msg = errorcode[10].msg
					ret.goods_refresh_count = assert(j.goods_refresh_count)
					ret.store_refresh_count_max = assert(user.store_refresh_count_max)
					return ret
				end
				if ug.inventory > self.g[1].goods_num then
					ug.inventory = ug.inventory - self.g[1].goods_num
					if ug.inventory == 0 then
						ug.countdown = gg.cd
						ug.st = os.time()
						ug:__update_db({"inventory", "countdown", "st"})
					else
						ug:__update_db({"inventory"})	
					end

					currency.num = currency.num - gold
					currency:__update_db({"num"})
					local prop = get_prop(gg.g_prop_csv_id)
					prop.num = prop.num + (gg.g_prop_num * self.g[1].goods_num)
					prop:__update_db({"num"})

					ret.errorcode = errorcode[1].code
					ret.msg = errorcode[1].msg
					ret.ll = { goods}
					ret.l = { prop}
					local j = assert(get_journal())
					ret.goods_refresh_count = assert(j.goods_refresh_count)
					ret.store_refresh_count_max = assert(user.store_refresh_count_max)
					return ret
				else
					ret.errorcode = errorcode[11].code
					ret.msg = errorcode[11].msg
					local j = assert(get_journal())
					ret.goods_refresh_count = assert(j.goods_refresh_count)
					ret.store_refresh_count_max = assert(user.store_refresh_count_max)
					return ret
				end
			elseif ug.inventory == 99 then
				currency.num = currency.num - gold
				currency:__update_db({"num"})
				local prop = get_prop(gg.g_prop_csv_id)
				prop.num = prop.num + (gg.g_prop_num * self.g[1].goods_num)
				prop:__update_db({"num"})

				ret.errorcode = errorcode[1].code
				ret.msg = errorcode[1].msg
				for k,v in pairs(ug) do
					gg[k] = ug[k]
				end
				ret.ll = { gg}
				ret.l = { prop}
				local j = assert(get_journal())
				ret.goods_refresh_count = assert(j.goods_refresh_count)
				ret.store_refresh_count_max = assert(user.store_refresh_count_max)
				return ret
			else
				assert(ug.inventory > 0)
				if ug.inventory > self.g[1].goods_num then
					ug.inventory = ug.inventory - self.g[1].goods_num
					if ug.inventory == 0 then
						ug.countdown = gg.cd
						ug.st = os.time()
						ug:__update_db({"inventory", "countdown", "st"})
					else
						ug:__update_db({"inventory"})
					end
					currency.num = currency.num - gold
					currency:__update_db({"num"})
					
					local prop = get_prop(gg.g_prop_csv_id)
					prop.num = prop.num + (gg.g_prop_num * self.g[1].goods_num)
					prop:__update_db({"num"})

					ret.errorcode = errorcode[1].code
					ret.msg = errorcode[1].msg
					ret.ll = { goods}
					ret.l = { prop}
					local j = assert(get_journal())
					ret.goods_refresh_count = assert(j.goods_refresh_count)
					ret.store_refresh_count_max = assert(user.store_refresh_count_max)
					return ret
				else
					ret.errorcode = errorcode[11].code
					ret.msg = errorcode[11].msg
					local j = assert(get_journal())
					ret.goods_refresh_count = assert(j.goods_refresh_count)
					ret.store_refresh_count_max = assert(user.store_refresh_count_max)
					return ret
				end
			end
		else
			ret.errorcode = errorcode[9].code
			ret.msg = errorcode[9].msg
			local j = assert(get_journal())
			ret.goods_refresh_count = assert(j.goods_refresh_count)
			ret.store_refresh_count_max = assert(user.store_refresh_count_max)
			return ret
		end
	elseif gg.currency_type == const.DIAMOND then
		local diamond = gg.currency_num * self.g[1].goods_num
		local currency = user.u_propmgr:get_by_csv_id(const.DIAMOND)
		if currency.num >= diamond then
			if ug.inventory == 0 then
				local now = os.time()
				local walk = os.difftime(now, ug.st)
				if walk > gg.cd then
					ug.inventory =gg.inventory_init
					ug.countdown = 0
					ug:__update_db({"inventory", "countdown"})
					if self.g[1].goods_num <= ug.inventory then
						ug.inventory = ug.inventory - self.g[1].goods_num
						ug:__update_db({"inventory"})
						currency.num = currency.num - diamond
						user.take_diamonds = user.take_diamonds + diamond
						context:raise_achievement(const.ACHIEVEMENT_T_4)
						local prop = get_prop(gg.g_prop_csv_id)
						prop.num = prop.num + (gg.g_prop_num * self.g[1].goods_num)
						prop:__update_db({"num"})
						ret.errorcode = errorcode[1].code
						ret.msg = errorcode[1].msg
						ret.l = { prop}
						for k,v in pairs(ug) do
							gg[k] = ug[k]
						end
						ret.ll = { gg}
						local j = assert(get_journal())
						ret.goods_refresh_count = assert(j.goods_refresh_count)
						ret.store_refresh_count_max = assert(user.store_refresh_count_max)
						return ret	
					else
						ret.errorcode = errorcode[11].code
						ret.msg = errorcode[11].msg
						local j = assert(get_journal())
						ret.goods_refresh_count = assert(j.goods_refresh_count)
						ret.store_refresh_count_max = assert(user.store_refresh_count_max)	
						return ret
					end
				else
					ug.countdown = gg.cd - walk
					ug:__update_db({"countdown"})
					ret.errorcode = errorcode[10].code
					ret.msg = errorcode[10].msg
					ret.ll = { goods}
					local j = assert(get_journal())
					ret.goods_refresh_count = assert(j.goods_refresh_count)
					ret.store_refresh_count_max = assert(user.store_refresh_count_max)
					return ret
				end
			elseif ug.inventory == 99 then
				currency.num = currency.num - diamond
				user.take_diamonds = user.take_diamonds + diamond
				context:raise_achievement(const.ACHIEVEMENT_T_4)
				local prop = get_prop(gg.g_prop_csv_id)
				prop.num = prop.num + (gg.g_prop_num * self.g[1].goods_num)
				prop:__update_db({"num"})
				ret.errorcode = errorcode[1].code
				ret.msg = errorcode[1].msg
				ret.l = { prop}
				for k,v in pairs(ug) do
					gg[k] = ug[k]
				end
				ret.ll = { gg}
				local j = assert(get_journal())
				ret.goods_refresh_count = assert(j.goods_refresh_count)
				ret.store_refresh_count_max = assert(user.store_refresh_count_max)	
				return ret
			else
				assert(ug.inventory > 0)
				if self.g[1].goods_num <= ug.inventory then
					ug.inventory = ug.inventory - self.g[1].goods_num
					if ug.inventory == 0 then
						ug.countdown = gg.cd
						ug.st = os.time()
						ug:__update_db({"inventory", "countdown", "st"})
					else
						ug:__update_db({"inventory"})	
					end
					currency.num = currency.num - diamond
					user.take_diamonds = user.take_diamonds + diamond
					context:raise_achievement(const.ACHIEVEMENT_T_4)
					local prop = get_prop(gg.g_prop_csv_id)
					prop.num = prop.num + (gg.g_prop_num * self.g[1].goods_num)
					ret.errorcode = errorcode[1].code
					ret.msg = errorcode[1].msg
					ret.l = { prop}
					for k,v in pairs(ug) do
						gg[k] = ug[k]
					end
					ret.ll = { gg}
					local j = assert(get_journal())
					ret.goods_refresh_count = assert(j.goods_refresh_count)
					ret.store_refresh_count_max = assert(user.store_refresh_count_max)	
					return ret
				else
					ret.errorcode = errorcode[11].code
					ret.msg = errorcode[11].msg
					local j = assert(get_journal())
					ret.goods_refresh_count = assert(j.goods_refresh_count)
					ret.store_refresh_count_max = assert(user.store_refresh_count_max)	
					return ret
				end
			end
		else
			ret.errorcode = errorcode[6].code
			ret.msg	= errorcode[6].msg
			local j = assert(get_journal())
			ret.goods_refresh_count = assert(j.goods_refresh_count)
			ret.store_refresh_count_max = assert(user.store_refresh_count_max)	
			return ret
		end
	else
		assert(false)
	end
end

function REQUEST:recharge_all()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	local l = {}
	local r = skynet.call(game, "lua", "query_g_recharge")
	for k,v in pairs(r) do
		table.insert(l, v)
	end
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.l = l
	return ret
end

function REQUEST:recharge_purchase()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(self.g)
	for i,v in ipairs(self.g) do
		local goods = skynet.call(game, "lua", "query_g_recharge", v.csv_id)
		assert(user.recharge_rmb)
		assert(user.recharge_diamond)
		user.recharge_rmb = user.recharge_rmb + goods.rmb * v.num
		user.recharge_diamond = user.recharge_diamond + goods.diamond * v.num
		user:__update_db({"recharge_rmb", "recharge_diamond"}, const.DB_PRIORITY_2)
		local rc = user.u_recharge_countmgr:get_by_csv_id(v.csv_id)
		if rc then
			rc.count = rc.count + 1
			assert(rc.count > 1)
			rc:__update_db({"count"})
			local diamond = user.u_propmgr:get_by_csv_id(const.DIAMOND)
			diamond.num = diamond.num + ((goods.diamond + goods.gift) * v.num)
			diamond:__update_db({"num"})
		else
			rc = user.u_recharge_countmgr.create({user_id=user.csv_id, csv_id=v.csv_id, count=1})
			user.u_recharge_countmgr:add(rc)
			rc:__insert_db(const.DB_PRIORITY_2)
			local diamond = user.u_propmgr:get_by_csv_id(const.DIAMOND)
			diamond.num = diamond.num + (assert(goods.diamond) + assert(goods.first)) * v.num
			diamond:__update_db({"num"})
		end
		local t = {user_id=assert(user.csv_id), csv_id=assert(v.csv_id), num=assert(v.num), dt=os.time()}
		rr = user.u_recharge_recordmgr.create(t)
		user.u_recharge_recordmgr:add(rr)
		rr:__insert_db(const.DB_PRIORITY_2)

		-----------------------------
		local user_vip_max
		local ptr = skynet.call(game, "lua", "query_g_config")
		tptr.createtable(ptr)
		for _,k,v in tptr.pairs(ptr) do
			if k == "user_vip_max" then
				user_vip_max = v
				break
			end
		end
		assert(user_vip_max)
		repeat
			if user.uviplevel >= user_vip_max then
				break
			end
			local condition = skynet.call(game, "lua", "query_g_recharge_vip_reward", user.uviplevel + 1)
			local progress = user.recharge_diamond / condition.diamond
			if progress >= 1 then
				assert(user.exp_max)
				assert(user.gold_max)
				assert(user.exp_max)
				assert(user.equipment_enhance_success_rate_up_p)
				user.uviplevel = user.uviplevel + 1
				user.exp_max = user.exp_max + math.floor(user.exp_max * (condition.exp_max_up_p))
				user.gold_max = user.gold_max + math.floor(user.gold_max * (condition.gold_max_up_p))
				user.equipment_enhance_success_rate_up_p = assert(condition.equipment_enhance_success_rate_up_p)
				user.store_refresh_count_max = assert(condition.store_refresh_count_max)
				user.prop_refresh = user.prop_refresh - math.floor(user.prop_refresh * (condition.prop_refresh_reduction_p/100))
				user.arena_frozen_time = user.arena_frozen_time - math.floor(user.arena_frozen_time * (condition.arena_frozen_time_reduction_p/100))
				user.gain_exp_up_p = assert(condition.gain_exp_up_p)
				user.gain_gold_up_p = assert(condition.gain_gold_up_p)
				user.purchase_hp_count_max = assert(condition.purchase_hp_count_max)
			else
				user.uvip_progress = math.floor(progress * 100)
				user:__update_db({"uvip_progress"}, const.DB_PRIORITY_2)
				break
			end
		until false
	end
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.u = {
		uname = user.uname,
    	uviplevel = user.uviplevel,
    	uexp = user.u_propmgr:get_by_csv_id(const.EXP).num,
    	config_sound = (user.config_sound == 1) and true or false,
    	config_music = (user.config_music == 1) and true or false,
    	avatar = user.avatar,
    	sign = user.sign,
    	c_role_id = user.c_role_id,
    	gold = user.u_propmgr:get_by_csv_id(const.GOLD).num,
    	diamond = user.u_propmgr:get_by_csv_id(const.DIAMOND).num,
    	recharge_total = user.recharge_rmb,
    	recharge_progress = user.uvip_progress,
    	recharge_diamond = user.recharge_diamond,
    	love = user.u_propmgr:get_by_csv_id(const.LOVE).num,
    	level = user.level
	}
	return ret
end

function REQUEST:recharge_vip_reward_all()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(user)
	local a = skynet.call(game, "lua", "query_g_recharge_vip_reward")
	local l = {}
	for k,v in pairs(a) do
		local r = {}
		r.vip = v.vip
		r.props = {}
		local t = util.parse_text(v.rewared, "%d+%*%d+%*?", 2)
		for i,v in ipairs(t) do
			table.insert(r.props, { csv_id=v[1], num=v[2]})
		end
		local reward = user.u_recharge_vip_rewardmgr:get_by_vip(v.vip)
		if reward then
			r.collected = (reward.collected == 1) and true or false
			r.purchased = (reward.purchased == 1) and true or false
		else
			r.collected = false
			r.purchased = false
		end
		table.insert(l, r)
	end
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.reward = l
	return ret
end

function REQUEST:recharge_vip_reward_collect()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	if self.vip == 0 then
		ret.errorcode = errorcode[20].code
		ret.msg = errorcode[20].msg
		return ret
	end
	if self.vip > user.uviplevel then
		ret.errorcode = errorcode[21].code
		ret.msg = errorcode[21].msg
		return ret
	end
	assert(user)
	local rc = user.u_recharge_vip_rewardmgr:get_by_vip(self.vip)
	if rc then
		if rc.collected == 1 then
			ret.errorcode = errorcode[22].code
			ret.msg = errorcode[22].msg
			return ret
		else
			local reward = skynet.call(game, "lua", "query_g_recharge_vip_reward", self.vip)
			local t = util.parse_text(reward.rewared, "%d+%*%d+%*?", 2)
			for i,v in ipairs(t) do
				local prop = user.u_propmgr:get_by_csv_id(v[1])
				if prop then
					prop.num = prop.num + assert(v[2])
					prop:__update_db({"num"})
				else
					prop = skynet.call(game, "lua", "query_g_prop", v[1])
					prop.user_id = user.csv_id
					prop.num = assert(v[2])
					prop = user.u_propmgr.create(prop)
					user.u_propmgr:add(prop)
					prop:__insert_db(const.DB_PRIORITY_2)
				end
			end
			rc.collected = 1
			rc:__update_db({"collected"})
			ret.errorcode = errorcode[1].code
			ret.msg = errorcode[1].msg
			ret.vip = user.uviplevel
			ret.collected = true
			return ret
		end
	else
		local reward = skynet.call(game, "lua", "query_g_recharge_vip_reward", self.vip)
		local t = util.parse_text(reward.rewared, "%d+%*%d+%*?", 2)
		for i,v in ipairs(t) do
			local prop = get_prop(v[1])
			prop.num = prop.num + assert(v[2])
			prop:__update_db({"num"})
		end
		local t = {user_id=user.csv_id, vip=self.vip, collected=1, purchased=0}	
		rc = user.u_recharge_vip_rewardmgr.create(t)
		user.u_recharge_vip_rewardmgr:add(rc)
		rc:__insert_db(const.DB_PRIORITY_2)
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].msg
		ret.vip = user.uviplevel
		ret.collected = true
		return ret
	end
end

function REQUEST:equipment_enhance()
	-- body
	assert(self.csv_id, string.format("from client the value is: %s", type(self.csv_id)))
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	local e = assert(user.u_equipmentmgr:get_by_csv_id(self.csv_id))
	if e.csv_id == 1 then
		local last = user.u_equipmentmgr:get_by_csv_id(4)
		assert(e.level == last.level)
	else
		local last = user.u_equipmentmgr:get_by_csv_id(e.csv_id - 1)
		assert(e.level < last.level)
	end
	local ee = skynet.call(game, "lua", "query_g_equipment_enhance", e.csv_id*1000 + e.level + 1)
	if ee.level > user.level then
		ret.errorcode = errorcode[23].code
		ret.msg = errorcode[23].msg
		return ret
	end
	local currency = user.u_propmgr:get_by_csv_id(ee.currency_type)
	if currency.num < ee.currency_num then
		ret.errorcode = errorcode[6].code
		ret.msg = errorcode[6].msg
		return ret
	else
		assert(currency.num >= ee.currency_num)
		local r = math.random(0, 100)
		if r < e.enhance_success_rate + (e.enhance_success_rate * user.equipment_enhance_success_rate_up_p/100) then
			currency.num = currency.num - ee.currency_num
			assert(currency.num > 0)
			currency:__update_db({"num"})
			for k,v in pairs(e) do
				if ee[k] then
					e[k] = ee[kk]
				end
			end	
			ret.errorcode = errorcode[1].code
			ret.msg = errorcode[1].msg
			ret.e = {}
			ret.e.csv_id = assert(e.csv_id)
			ret.e.level = assert(e.level)
			ret.e.combat = assert(e.combat)
			ret.e.defense = assert(e.defense)
			ret.e.critical_hit = assert(e.critical_hit)
			ret.e.king = assert(e.king)
			ret.e.combat_probability = assert(e.combat_probability)
			ret.e.defense_probability = assert(e.defense_probability)
			ret.e.critical_hit_probability = assert(e.critical_hit_probability)
			ret.e.defense_probability = assert(e.defense_probability)
			ret.e.enhance_success_rate = assert(e.enhance_success_rate)
			if e.csv_id == 4 and e.level % 10 == 0 then
				local equip_effect = skynet.call(game, "lua", "query_g_equipment_effect", e.level)
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

function REQUEST:equipment_all()
	-- body
	-- 1 offline 
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	local l = {}
	for k,v in pairs(user.u_equipmentmgr.__data) do
		local e = {
			csv_id = assert(v.csv_id),
			level = assert(v.level),
			combat = assert(v.combat),
			defense = assert(v.defense),
			critical_hit = assert(v.critical_hit),
			king = assert(v.king),
			combat_probability = assert(v.combat_probability),
			critical_hit_probability = assert(v.critical_hit_probability),
			defense_probability = assert(v.defense_probability),
			king_probability = assert(v.king_probability),
			enhance_success_rate = assert(v.enhance_success_rate)
		}
		table.insert(l, e)
	end
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.l = l
	return ret
end

function REQUEST:role_all()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	local l = {}
	local r = skynet.call(game, "lua", "query_g_role")
	for k,v in pairs(r) do
		local role = user.u_rolemgr:get_by_csv_id(v.csv_id)
		if role then
			role.is_possessed = true
		else
			role = v
			role.is_possessed = false
		end
		local prop = user.u_propmgr:get_by_csv_id(role.us_prop_csv_id)
		role.u_us_prop_num = prop and prop.num or 0
		table.insert(l, role)
	end
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.l = l
    return ret
end

function REQUEST:role_recruit()
	-- body
	local ret = {}
	if not ret then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(self.csv_id)
	assert(user.u_rolemgr:get_by_csv_id(self.csv_id) == nil)
	local role = skynet.call(game, "lua", "query_g_role", self.csv_id)
	local us = skynet.call(game, "lua", "query_g_role_star", role.csv_id*1000 + role.star)
	local prop = user.u_propmgr:get_by_csv_id(role.us_prop_csv_id)
	if prop and prop.num >= assert(us.us_prop_num) then
		prop.num = prop.num - us.us_prop_num
		prop:__update_db({"num"})
		role.user_id = user.csv_id
		for k,v in pairs(us) do
			role[k] = v
		end
		role.k_csv_id1 = 0
		role.k_csv_id2 = 0
		role.k_csv_id3 = 0
		role.k_csv_id4 = 0
		role.k_csv_id5 = 0
		role.k_csv_id6 = 0
		role.k_csv_id7 = 0
		if user.ifxilian == 1 then
			local n, r = xilian(role, {role_id=role.csv_id, is_locked1=false, is_locked2=false, is_locked3=false, is_locked4=false, is_locked5=false})
			assert(n == 0, string.format("%d locked.", n))
			role.property_id1 = r.property_id1
			role.value1 = r.value1
			role.property_id2 = r.property_id2
			role.value2 = r.value2
			role.property_id3 = r.property_id3
			role.value3 = r.value3
			role.property_id4 = r.property_id4
			role.value4 = r.value4
			role.property_id5 = r.property_id5
			role.value5 = r.value5
		else
			role.property_id1 = 0
			role.value1 = 0
			role.property_id2 = 0
			role.value2 = 0
			role.property_id3 = 0
			role.value3 = 0
			role.property_id4 = 0
			role.value4 = 0
			role.property_id5 = 0
			role.value5 = 0
		end
		role = user.u_rolemgr.create(role)
		user.u_rolemgr:add(role)
		role:__insert_db(const.DB_PRIORITY_2)
		context:raise_achievement(const.ACHIEVEMENT_T_5)
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].msg
		ret.r = {
			csv_id = role.csv_id,
			is_possessed = true,
			star = role.star,
			u_us_prop_num = prop.num
		}
		return ret
	else
		ret.errorcode = errorcode[3].code
		ret.msg = errorcode[3].msg
		return ret
	end
end

function REQUEST:role_battle()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(user.u_rolemgr:get_by_csv_id(self.csv_id))
	user.c_role_id = self.csv_id
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	return ret
end

function REQUEST:user_sign()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(user)
	user.sign = self.sign
	user:__update_db({"sign"}, const.DB_PRIORITY_2)
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	return ret
end

function REQUEST:user_random_name()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(user)
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.name = "lihong"
	return ret
end

function REQUEST:recharge_vip_reward_purchase()
 	-- body
 	-- 0. success
 	-- 1. offline
 	-- 2. your vip don't
 	-- 3. has purchased
 	local ret = {}
 	if not user then
 		ret.errorcode = errorcode[2].code
 		ret.msg = errorcode[2].msg
 		return ret
 	end
 	assert(self.vip > 0)
 	if self.vip > user.uviplevel then
 		ret.errorcode = errorcode[21].code
 		ret.msg = errorcode[21].msg
 		return ret
 	end
 	local l = {}
 	local rc = user.u_recharge_vip_rewardmgr:get_by_vip(self.vip)
 	if rc then
 		if rc.purchased == 1 then
 			ret.errorcode = errorcode[25].code
 			ret.msg = errorcode[25].msg
 			return ret
 		else
 			local reward = skynet.call(game, "lua", "query_g_recharge_vip_reward", self.vip)
 			local prop = user.u_propmgr:get_by_csv_id(const.DIAMOND)
 			if prop.num < reward.purchasable_diamond then
 				ret.errorcode = errorcode[6].code
 				ret.msg = errorcode[6].msg
 				return ret
 			end
 			prop.num = prop.num - reward.purchasable_diamond
 			prop:__update_db({"num"})
 			local r = util.parse_text(reward.purchasable_gift, "%d+%*%d+%*?", 2)
 			for i,v in ipairs(r) do
 				prop = user.u_propmgr:get_by_csv_id(v[1])
 				if prop then
 					prop.num = prop.num + assert(v[2])
 					prop:__update_db({"num"})
 					table.insert(l, { csv_id=prop.csv_id, num=prop.num})
 				else
 					prop = skynet.call(game, "lua", "query_g_prop", v[1])
 					prop.user_id = user.csv_id
 					prop.num = assert(v[2])
 					prop = user.u_propmgr.create(prop)
 					user.u_propmgr:add(prop)
 					prop:__insert_db(const.DB_PRIORITY_2)
 					table.insert(l, { csv_id=prop.csv_id, num=prop.num})
 				end
 			end
 			rc.purchased = 1
 			rc:__update_db({"purchased"})
 			ret.errorcode = errorcode[1].code
 			ret.msg = errorcode[1].msg
 			ret.l = l
 			return ret
 		end
 	else
 		local reward = skynet.call(game, "lua", "query_g_recharge_vip_reward", self.vip)
 		local prop = user.u_propmgr:get_by_csv_id(const.DIAMOND)
 		if prop.num < reward.purchasable_diamond then
 			ret.errorcode = errorcode[6].code
 			ret.msg = errorcode[6].msg
 			return ret
 		end
 		prop.num = prop.num - reward.purchasable_diamond
 		prop:__update_db({"num"})
 		local r = util.parse_text(reward.purchasable_gift, "%d+%*%d+%*?", 2)
 		for i,v in ipairs(r) do
 			prop = user.u_propmgr:get_by_csv_id(v[1])
 			if prop then
 				prop.num = prop.num + assert(v[2])
 				prop:__update_db({"num"})
 				table.insert(l, { csv_id=prop.csv_id, num=prop.num})
 			else
				prop = skynet.call(game, "lua", "query_g_prop", v[1])
				prop.user_id = user.csv_id
				prop.num = assert(v[2])
				prop = user.u_propmgr.create(prop)
				user.u_propmgr:add(prop)
				prop:__insert_db(const.DB_PRIORITY_2)
				table.insert(l, { csv_id=prop.csv_id, num=prop.num})
 			end
 		end
 		local t = { user_id=user.csv_id, vip=self.vip, collected=0, purchased=1}
 		rc = user.u_recharge_vip_rewardmgr.create(t)
 		user.u_recharge_vip_rewardmgr:add(rc)
 		rc:__insert_db(const.DB_PRIORITY_2)
 		ret.errorcode = errorcode[1].code
 		ret.msg = errorcode[1].msg
 		ret.l = l
 		return ret
 	end
end

local xilian_lock = 0
local xilian_role_id = 0

function REQUEST:xilian()
	-- body
	xilian_lock = 0
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
 		ret.msg = errorcode[2].msg
 		return ret
	end
	assert(self)
	xilian_role_id = self.role_id
	local role = user.u_rolemgr:get_by_csv_id(self.role_id)
	local n, r = xilian(role, self)
	assert(n >= 0)
	local xilian_cost = skynet.call(game, "lua", "query_g_xilian_cost", n)
	assert(type(xilian_cost.cost) == "string")
	local C = util.parse_text(xilian_cost.cost, "(%d+%*%d+%*?)", 2)
	for i,v in ipairs(C) do
		local prop = user.u_propmgr:get_by_csv_id(v[1])
		if prop.num < tonumber(v[2]) then
			ret.errorcode = errorcode[31].code
			ret.msg = errorcode[31].msg	
			return ret
		end
	end
	for i,v in ipairs(C) do
		local prop = user.u_propmgr:get_by_csv_id(v[1])
		prop.num = prop.num - tonumber(v[2])
	end
	
	xilian_lock = 1
	-- if type(role.backup) ~= "table" then
	-- 	role.backup = {}
	-- end
	role.backup = r
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	for k,v in pairs(r) do
		ret[k] = v
	end
	return ret
end

function REQUEST:xilian_ok()
	-- body
	local ret = {}
	if not user then
 		ret.errorcode = errorcode[2].code
 		ret.msg = errorcode[2].msg
 		return ret
 	end
 	if xilian_lock ~= 1 then
 		ret.errorcode = errorcode[32].code
 		ret.msg = errorcode[32].msg
 		return ret
 	else
 		xilian_lock = 1
 	end
	if self.ok then
		assert(self.role_id == xilian_role_id, "must be equip")
		local role = user.u_rolemgr:get_by_csv_id(self.role_id)
		assert(role.backup)
		role.property_id1 = role.backup.property_id1
		role.value1 = role.backup.value1
		role.property_id2 = role.backup.property_id2
		role.value2 = role.backup.value2
		role.property_id3 = role.backup.property_id3
		role.value3 = role.backup.value3
		role.property_id4 = role.backup.property_id4
		role.value4 = role.backup.value4
		role.property_id5 = role.backup.property_id5
		role.value5 = role.backup.value5
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].msg
		return ret
	end
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	return ret
end   

function REQUEST:checkpoint_chapter()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].code
	ret.l = {}
	for k,v in pairs(user.u_checkpointmgr.__data) do
		table.insert(ret.l, v)
	end
	return ret
end

local function hanging()
	-- body
	local r = skynet.call(game, "lua", "query_g_checkpoint", user.cp_hanging_id)
	assert(r)
	local cp_rc = user.u_checkpoint_rcmgr:get_by_csv_id(user.cp_hanging_id)
	assert(cp_rc)
	local now = os.time()
	-- cac hanging 
	local walk = now - cp_rc.hanging_starttime + cp_rc.hanging_walk
	cp_rc.hanging_starttime = now
	cp_rc.hanging_walk = (walk % r.cd)
	local n = walk / r.cd
	local l = {}
	local prop = user.u_propmgr:get_by_csv_id(const.GOLD)
	prop.num = math.floor(prop.num + (n * r.gain_gold))
	table.insert(l, prop)
	prop = user.u_propmgr:get_by_csv_id(const.EXP)
	prop.num = math.floor(prop.num + (n * r.gain_exp))
	table.insert(l, prop)
	-- cac drop
	walk = now - cp_rc.hanging_drop_starttime + cp_rc.hanging_drop_walk
	cp_rc.hanging_drop_starttime = now
	cp_rc.hanging_drop_walk = (walk % r.cd)
	n = walk / 100
	prop = user.u_propmgr:get_by_csv_id(r.drop)
	prop.num = prop.num + 1
	table.insert(l, prop)
	return l
end

function REQUEST:checkpoint_hanging()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	-- enter
	if user.cp_hanging_id > 0 then 
		local ok, result = pcall(hanging)
		if ok then
			ret.errorcode = errorcode[1].code
			ret.msg = errorcode[1].msg
			ret.props = result
			return ret
		else
			ret.errorcode = errorcode[29].code
			ret.msg = errorcode[29].msg
			return ret
		end
	else
		ret.errorcode = errorcode[34].code
		ret.msg = errorcode[34].msg
		return ret
	end
end

local function choose(csv_id, now)
	-- body
	-- first resolve last hanging
	assert(now)
	local ret = {}
	if user.cp_hanging_id > 0 then
		if user.cp_hanging_id ~= csv_id then
			local ok, result = pcall(hanging)
			if not ok then
				skynet.error(result)
				ret.errorcode = errorcode[29].code
				ret.msg = errorcode[29].msg
				return false, ret
			end
			local cp_rc = user.u_checkpoint_rcmgr:get_by_csv_id(user.cp_hanging_id)
			cp_rc.hanging_starttime = 0
			cp_rc.hanging_drop_starttime = 0
			user.cp_hanging_id = csv_id
		end
	else
		-- reslove this time hanging
		user.cp_hanging_id = csv_id
		local cp_rc = user.u_checkpoint_rcmgr:get_by_csv_id(csv_id) 
		cp_rc.hanging_starttime = now
		cp_rc.hanging_drop_starttime = now
	end

	-- in the n
	if user.cp_battle_id > 0 then
		if user.cp_battle_id ~= csv_id then
			local cp_rc = user.u_checkpoint_rcmgr:get_by_csv_id(user.cp_battle_id)
			if cp_rc.cd_finished == 0 then
				cp_rc.cd_walk = cp_rc.cd_walk + (now - cp_rc.cd_starttime)
				cp_rc.cd_starttime = 0
				local r = skynet.call(game, "lua", "query_g_checkpoint", csv_id)
				if cp_rc.cd_walk >= r.cd then
					cp_rc.cd_finished = 1
				end
			end	
			user.cp_battle_id = 0
			user.cp_battle_chapter = 0
		end
	end
	return true
end

-- alone 
function REQUEST:checkpoint_hanging_choose()
	-- body
	local ret = {}
	assert(user, "user is nil")
	assert(self.chapter*1000+self.type*100+self.checkpoint == self.csv_id)
	-- must <= cp_chapter
	assert(self.chapter <= user.cp_chapter)
	-- judge chapter 
	local now = os.time()
	local cp = user.u_checkpointmgr:get_by_chapter(self.chapter)
	local cp_chapter = skynet.call(game, "lua", "query_g_checkpoint_chapter", self.chapter)
	if self.type == 0 then
		assert(self.checkpoint <= cp_chapter.type0_max)
		assert(self.checkpoint <= cp.chapter_type0)
		local ok, result = choose(self.csv_id, now)
		if not ok then
			return result 
		end
	elseif self.type == 1 then
		assert(self.checkpoint <= cp_chapter.type1_max, string.format("checkpoint:%d from client > cp_chapter.type1_max:%d", self.checkpoint, cp_chapter.type1_max))
		assert(self.checkpoint <= cp.chapter_type1)
		local ok, result = choose(self.csv_id, now)
		if not ok then
			return result 
		end
	elseif self.type == 2 then
		assert(self.checkpoint <= cp_chapter.type2_max, string.format("checkpoint:%d from client > cp_chapter.type1_max:%d", self.checkpoint, cp_chapter.type2_max))
		assert(self.checkpoint <= cp.chapter_type2)
		local ok, result = choose(self.csv_id, now)
		if not ok then
			return result 
		end
	else
		error("wrong checkpoint type")
		ret.errorcode = errorcode[37].code
		ret.msg = errorcode[37].msg
		return ret
	end
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	return ret
end

function REQUEST:checkpoint_battle_exit()
	-- body
	local ret = {}
	assert(user ~= nil, "user is nil")
	assert(self.chapter <= user.cp_chapter, string.format("self.chapter:%d > user.cp_chapter:%d", self.chapter, user.cp_chapter))
	assert(self.chapter == user.cp_battle_chapter)
	assert(self.csv_id == user.cp_battle_id, string.format("user.cp_battle_id:%d is ", user.cp_battle_id))
	local cp_rc = user.u_checkpoint_rcmgr:get_by_csv_id(self.csv_id)
	assert(cp_rc.cd_finished == 1)
	if self.result == 1 then
		local r = skynet.call(game, "lua", "query_g_checkpoint", self.csv_id)
		local cp = user.u_checkpointmgr:get_by_chapter(r.chapter)
		local cp_chapter = skynet.call(game, "lua", "query_g_checkpoint_chapter", r.chapter)
		-- reward
		local reward = {}
		local tmp = util.parse_text(r.reward, "(%d+%*%d+%*?)", 2)
		for i,v in ipairs(reward) do
			local prop = user.u_propmgr:get_by_csv_id(v[1])
			prop.num = prop.num + v[2]
			table.insert(reward, prop)
		end
		-- unlock next checkpoint
		if r.type == 0 then
			assert(cp.chapter_type0 == r.checkpoint)  -- keep progress
			cp.chapter_type0 = cp.chapter_type0 + 1
			if cp.chapter_type0 > cp_chapter.type0_max then
				-- unlock next chapter
				if user.cp_chapter == r.chapter then
					user.cp_chapter = user.cp_chapter + 1
					local cp_chapter_max = skynet.call(game, "lua", "query_g_config", "cp_chapter_max")
					if user.cp_chapter <= cp_chapter_max then   
						local next_cp = user.u_checkpointmgr:get_by_chapter(user.cp_chapter)
						next_cp.chapter_type0 = 1
					end
				end
				-- unlock next type
				if cp.chapter_type1 ~= 0 then
					error("db is wrong")
					ret.errorcode = errorcode[35].code
					ret.msg = errorcode[35].code
					return ret
				else
					cp.chapter_type1 = 1
				end
			end
		elseif r.type == 1 then
			if cp.chapter_type1 ~= r.checkpoint then
				ret.errorcode = errorcode[35].code
				ret.msg = errorcode[35].msg
				return ret
			end
			assert(cp.chapter_type1 == r.checkpoint)
			cp.chapter_type1 = cp.chapter_type1 + 1
			if cp.chapter_type1 > cp_chapter.type1_max then
				-- unlock next type
				if cp.chapter_type2 ~= 0 then
					error("db is wrong.")
					ret.errorcode = errorcode[35].code
					ret.msg = errorcode[35].msg
					return ret
				else
					cp.chapter_type2 = 1
				end
			end
		elseif r.type == 2 then
			if cp.chapter_type2 ~= r.checkpoint then
				ret.errorcode = errorcode[35].code
				ret.msg = errorcode[35].msg
				return ret
			end
			assert(cp.chapter_type2 == r.checkpoint)
			cp.chapter_type2 = cp.chapter_type2 + 1
		end
		user.cp_battle_id = 0
		user.cp_battle_chapter = 0
		skynet.error(string.format("you passed chapter:%d, type:%d, checkpoint:%d", self.chapter, self.type, self.checkpoint))
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].msg
		ret.reward = reward
		return ret
	else
		skynet.error("you lose.")
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].code
		return ret
	end
end

function REQUEST:checkpoint_battle_enter()
	-- body
	local ret = {}
	assert(user ~= nil, "user is nil")
	assert(self.chapter <= user.cp_chapter)
	assert(self.csv_id == user.cp_hanging_id, string.format("self.csv_id:%d, user.cp_hanging_id:%d", self.csv_id, user.cp_hanging_id))
	-- check 
	local cp = user.u_checkpointmgr:get_by_chapter(self.chapter)
	if self.type == 0 then
		assert(self.checkpoint == cp.chapter_type0)
	elseif self.type == 1 then
		assert(self.checkpoint == cp.chapter_type1)
	elseif self.type == 2 then
		assert(self.checkpoint == cp.chapter_type2)
	else
		ret.errorcode = errorcode[35].code
		ret.msg = errorcode[35].msg
		return ret
	end
	local now = os.time()
	if user.cp_battle_id == 0 then
		user.cp_battle_id = self.csv_id
		user.cp_battle_chapter = self.chapter
		local cp_rc = user.u_checkpoint_rcmgr:get_by_csv_id(self.csv_id)
		assert(cp_rc.cd_starttime == 0)
		if cp_rc.cd_finished == 1 then
			ret.errorcode = errorcode[1].code
			ret.msg = errorcode[1].msg
			return ret
		else
			cp_rc.cd_starttime = now
			local r = skynet.call(game, "lua", "query_g_checkpoint", self.csv_id)
			if r.cd - cp_rc.cd_walk > 0 then
				ret.errorcode = errorcode[1].code
				ret.msg = errorcode[1].msg
				ret.cd = r.cd - cp_rc.cd_walk
				return ret
			else
				cp_rc.cd_starttime = 0
				cp_rc.cd_finished = 1
				ret.errorcode = errorcode[1].code
				ret.msg = errorcode[1].msg
				ret.cd = 0
				return ret
			end
		end
	else
		assert(user.cp_battle_id == self.csv_id)
		assert(user.cp_battle_chapter == self.chapter)
		local cp_rc = user.u_checkpoint_rcmgr:get_by_csv_id(self.csv_id)
		assert(cp_rc.cd_starttime > 0, string.format("cd_starttime:%d", cp_rc.cd_starttime))
		assert(cp_rc.cd_finished == 0)
		local walk = now - cp_rc.cd_starttime + cp_rc.cd_walk
		cp_rc.cd_walk = walk
		cp_rc.cd_starttime = now
		local r = skynet.call(game, "lua", "query_g_checkpoint", self.csv_id)
		if r.cd - cp_rc.cd_walk > 0 then
			ret.errorcode = errorcode[1].code
			ret.msg = errorcode[1].msg
			ret.cd = r.cd - cp_rc.cd_walk
			return ret
		else
			cp_rc.cd_starttime = 0
			cp_rc.cd_finished = 1
			ret.errorcode = errorcode[1].code
			ret.msg = errorcode[1].msg
			ret.cd = 0
			return ret
		end
	end
end

function REQUEST:checkpoint_exit()
 	-- body
 	local ret = {}
 	if not user then
 		ret.errorcode = errorcode[2].code
 		ret.msg = errorcode[2].msg
 		return ret
 	end
 	cp_exit()
	ret.errorcode = errorcode[1].code
 	ret.msg = errorcode[1].msg
	return ret
end

function REQUEST:ara_bat_ovr()
	-- body
	
end

function REQUEST:ara_bat_clg()
	-- body
	local t = user.u_journalmgr:get_by_today()
	if t.ara_clg_tms > 0 then
		t.ara_clg_tms = t.ara_clg_tms - 1
		-- TODO: enter ara
	end
end

function REQUEST:ara_rfh()
	-- body
	-- if user.ara_rnk
	skynet.call(lp, "lua", "")
end

function REQUEST:ara_worship()
	-- body
	local ret = {}
	local rand = math.random()
	if rand % 1 == 1 then
		local id = skynet.call(game, "lua", "worship_reward_id")
		local num = skynet.call(game, "lua", "worship_reward_num")
		local prop = user.u_propmgr:get_by_csv_id(id)
		prop.num = prop.num + num
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].msg
		return ret
	else
		ret.errorcode = errorcode[33].code
		ret.msg = errorcode[33].msg
		return ret
	end
end

function REQUEST:ara_clg_tms_purchase()
	-- body
	-- u_journalmgr
	
end

function REQUEST:ara_rnk_reward_collected()
	-- body
	local ret = {}
	local rnk = skynet.call(lp, "lua", "ranking", user.csv_id)
	local rnk_rwd = user.u_ara_rnk_rwd:get_by_csv_id(rnk)
	if rnk_rwd == nil or rnk_rwd.is_collected == 0 then
		local r = skynet.call(game, "lua", "query_g_ara_rnk_rwd", rnk)
		r = util.parse_text(r, "(%d+%*%d+%*?)", 2)
		for i,v in ipairs(r) do
			local prop = user.u_propmgr:get_by_csv_id(v[1])
			prop.num = prop.num + v[2]
		end
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].msg
		return ret
	else
		ret.errorcode = errorcode[38].code
		ret.msg = errorcode[38].msg
		return ret
	end
end

local function generate_session()
	local session = 0
	return function () 
			session = session + 1
			return session
		   end 
end

local function request(name, args, response)
	skynet.error(string.format("line request: %s", name))
    local f = nil
    if REQUEST[name] ~= nil then
    	f = REQUEST[name]
    elseif nil ~= friendrequest[ name ] then
    	f = friendrequest[name]
    else
    	for i,v in ipairs(M) do
    		if v.REQUEST[name] ~= nil then
    			f = v.REQUEST[name]
    			break
    		end
    	end
    end

    if f then
	    local ok, result = pcall(f, args)
	    if ok then
			return response(result)
		else
			skynet.error(result)
			local ret = {}
			ret.errorcode = errorcode[29].code
			ret.msg = errorcode[29].msg
			return response(ret)
		end
	else
		local ret = {}
		ret.errorcode = errorcode[39].code
		ret.msg = errorcode[39].msg
		return response(ret)
	end
end      

function RESPONSE:finish_achi( ... )
	-- body
	assert(self.errorcode == 1)
	skynet.error(self.msg)
end

local function response(session, args)
	-- body
	print( "name and args is*******************************" , session )
	assert( table_gs[tostring(session)], "has not register such session!" )
	local name = table_gs[tostring(session)]
	skynet.error(string.format("response: %s", name))
    local f = nil
    if RESPONSE[name] ~= nil then
    	f = RESPONSE[name]
    elseif nil ~= friendrequest[name] then
    	f = friendrequest[name]
    else
    	for i,v in ipairs(M) do
    		if v.RESPONSE[name] ~= nil then
    			f = v.RESPONSE[name]
    			break
    		end
    	end
    end
    assert(f)
    assert(response)
    local ok, result = pcall(f, args)

    if ok then
    	table_gs[tostring(session)] = nil
    else
    	assert(false, "pcall failed in response!")
    end
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		if sz > 0 then
			return host:dispatch(msg, sz)
		elseif sz == 0 then
			return "HEARTBEAT"
		else
			error "error"
		end
	end,
	dispatch = function (_, _, t, ...)
		if t == "REQUEST" then
			local ok, result  = pcall(request, ...)
			if ok then
				if result then
					skynet.retpack(result)
				end
			else
				assert(false, result)
			end
		elseif t == "HEARTBEAT" then
			assert(false)
			-- send_package(send_request "heartbeat")
		elseif t == "RESPONSE" then
			pcall(response, ...)
		end
	end
}	
	
function CMD.friend(source, subcmd, ... )
	-- body
	local f = assert(friendrequest[subcmd])
	local r =  f(friendrequest, ...)
	if r then
		return r
	end
end

function CMD.newemail(source, subcmd , ... )
	local f = assert( new_emailrequest[ subcmd ] )
	f( new_emailrequest , ... )
end

function CMD.login(source, uid, sid, sct, game, db)
	-- body
	skynet.error(string.format("%s is login", uid))
	gate   = source
	userid = uid
	subid  = sid
	secret = sct
	game   = game
	db     = db
	
	local times = skynet.call(".logintimes", "lua", "login", uid)
	if times == 1 then
		print("************************************123")
		local signup = require "signup"
		user = signup(uid, xilian)
		if user == nil then
			return false
		end
	else
		

		print("************************************456")
		user = loader.load_user(uid)
	end


	for k,v in pairs(M) do
		if v.REQUEST then
			v.REQUEST["login"](v.REQUEST, user)
		end
	end


	local rnk = skynet.call(lb, "lua", "push", user.csv_id, user.csv_id)
	user.ara_rnk = rnk

	dc.set(user.csv_id, { client_fd=client_fd, addr=skynet.self()})	
	context.user = user

	local onlinetime = os.time()
	user.ifonline = 1
	user.onlinetime = onlinetime
	user:__update_db({"ifonline", "onlinetime"}, const.DB_PRIORITY_2)
	user.friendmgr = friendmgr:loadfriend( user , dc )
	friendrequest.getvalue(user, send_package, send_request)
	--load public email from channel public_emailmgr
	get_public_email()

	subscribe()
	skynet.fork(subscribe)

	local ret = {}
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.u = {
		uname = user.uname,
		uviplevel = user.uviplevel,
		config_sound = (user.config_sound == 1) and true or false,
		config_music = (user.config_music == 1) and true or false,
		avatar = user.avatar,
		sign = user.sign,
		c_role_id = user.c_role_id,
		level = user.level,
		recharge_rmb = user.recharge_rmb,
		recharge_diamond = user.recharge_diamond,
		uvip_progress = user.uvip_progress,
		cp_hanging_id = user.cp_hanging_id,
		cp_chapter = user.cp_chapter,
		lilian_level = user.lilian_level
	}
	ret.u.uexp = assert(user.u_propmgr:get_by_csv_id(const.EXP)).num
	ret.u.gold = assert(user.u_propmgr:get_by_csv_id(const.GOLD)).num
	ret.u.diamond = assert(user.u_propmgr:get_by_csv_id(const.DIAMOND)).num
	ret.u.love = user.u_propmgr:get_by_csv_id(const.LOVE).num
	ret.u.equipment_list = {}
	for k,v in pairs(user.u_equipmentmgr.__data) do
		table.insert(ret.u.equipment_list, v)
	end
	ret.u.kungfu_list = {}
	for k,v in pairs(user.u_kungfumgr.__data) do
		table.insert(ret.u.kungfu_list, v)
	end
	ret.u.rolelist = {}
	for k,v in pairs(user.u_rolemgr.__data) do
		table.insert(ret.u.rolelist, v)
	end
	
	return true, send_request("login", ret)
end

local function logout()
	-- body
	if gate then
		skynet.call(gate, "lua", "logout", userid, subid)
	end
	skynet.exit()
end

function CMD.logout(source)
	-- body
	skynet.error(string.format("%s is logout", userid))
	logout()
end

function CMD.afk(source)
	-- body
	skynet.error(string.format("AFK"))
end

local function update_db()
	-- body
	while true do
		flush_db(const.DB_PRIORITY_3)
		skynet.sleep(100 * 60) -- 1ti == 0.01s
	end
end

local function start()
	-- body
	host = sprotoloader.load(1):host "package"
	send_request = host:attach(sprotoloader.load(2))
	
	context.host = host
	context.send_request = send_request
	context.game = game


	local t = loader.load_game()
	for i,v in ipairs(M) do
		v.start(fd, send_request, t)
	end	
end

skynet.start(function()
	skynet.dispatch("lua", function(_, source, command, ...)
		print("agent is called" , command)
		local f = CMD[command]
		local result = f(source, ... )
		if result then
			skynet.ret(skynet.pack(result))
		end
	end)
	skynet.fork(update_db)
	start()
end)
