local skynet = require "skynet"
local netpack = require "netpack"
local socket = require "socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local mc = require "multicast"
local dc = require "datacenter"
local util = require "util"
local errorcode = require "errorcode"
local const = require "const"
local context = require "agent_context"

-- local new_friend_request = require "new_friend_request"
-- local friendmgr = require "friendmgr"

local M = {}
local new_emailrequest = require "new_emailrequest"
local checkinrequest = require "checkinrequest"
local exercise_request = require "exercise_request"
local cgold_request = require "cgold_request"
local kungfurequest = require "kungfurequest"
local new_drawrequest = require "new_drawrequest"
local lilian_request = require "lilian_request"
local core_fightrequest = require "core_fightrequest"
local new_friend_request = require "new_friend_request"


table.insert(M, checkinrequest )
table.insert(M, exercise_request )
table.insert(M, cgold_request )
table.insert(M, new_emailrequest )
table.insert(M, kungfurequest )
table.insert(M, new_drawrequest )
table.insert(M, lilian_request )
table.insert(M, core_fightrequest)
table.insert(M, new_friend_request)

-- service internal context


local host
local send_request
local gate
local userid, subid
local secret
local db
local game
local user
local stm = require "stm"
local sharemap = require "sharemap"
local sd = require "sharedata"
local env = context.new()


local CMD       = {}
local REQUEST   = {}
local RESPONSE  = {}
local SUBSCRIBE = {}

local func_gs 
local table_gs = {}

local leaderboards_name = skynet.getenv("leaderboards_name")
local lb = skynet.localname(leaderboards_name)

local global_response_session = 1

local function send_package(pack)
	-- body

	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end

local function get_journal()
	-- body
	local factory = env:get_myfactory()
	return factory:get_today()
end

local function get_prop(csv_id)
	-- body
	local factory = env:get_myfactory()
	return factory:get_prop(csv_id)
end

local function get_goods(csv_id)
	-- body
	local factory = env:get_myfactory()
	return factory:get_goods(csv_id)
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
			j:update_db({"goods_refresh_count", "goods_refresh_reset_count"})
		end
	end
end

local function xilian(role, t)
	-- body
	return env:xilian(role, t)
end

function SUBSCRIBE.update_db()
	-- body
	env:flush_db(const.DB_PRIORITY_3)
end

local function subscribe( )
	-- body				
	local c = skynet.call(".channel", "lua", "agent_start")
	local c2 = mc.new { 			
		channel = c,			
		dispatch = function ( channel, source, cmd, tvals, ... )
			-- body 
			local f = SUBSCRIBE[cmd]
			if f ~= nil then
				f(env, tvals, ...)	
			else 				
				for k,v in pairs(M) do
					if v.SUBSCRIBE[cmd] then
						local f = assert(v.SUBSCRIBE[cmd])
						f(_, env, tvals, ...)
						break		
					end 
				end 	
			end 		
		end 			
	} 					
	c2:subscribe() 		
end 					
						
function REQUEST:achievement(ctx)
	-- body				
	local m = ctx:get_module("achievement")
	local ok, result = pcall(m.achievement, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:achievement_reward_collect(ctx)
	-- body
	local m = ctx:get_module("achievement")
	local ok, result = pcall(m.achievement_reward_collect, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end 
	
local function get_public_email(ctx)
	assert(ctx)
	
	local r = skynet.call( ".channel" , "lua" , "agent_get_public_email" , ctx:get_user():get_csv_id() , ctx:get_user():get_pemail_csv_id() , ctx:get_user():get_signup_time() )
	assert( r )
	local pemail_csv_id = ctx:get_user():get_pemail_csv_id()
	local sign = false
	
	if #r >= 1 then
		pemail_csv_id = r[1].pemail_csv_id
		print("user.pemail_csv_id is ", ctx:get_user():get_pemail_csv_id(), r[1].pemail_csv_id)
		sign = true
	end
	
	for k , v in ipairs( r ) do		
		v.id = genpk_2(ctx:get_user():get_field("csv_id"), genpk_3(2, v.pemail_csv_id))
		v.pemail_csv_id = nil
		new_emailrequest:public_email(ctx:get_myfactory(), v , ctx:get_user() )
	end 

	if sign then
		ctx:get_user():set_pemail_csv_id(pemail_csv_id)
		ctx:get_user():update_db()
	end
end    	
	 	
function REQUEST:role_info()
	local m = ctx:get_module("role")
	local ok, result = pcall(m.role_info, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end	

function REQUEST:choose_role()
	assert(false)
end	
	
function REQUEST:role_upgrade_star()
	local m = ctx:get_module("role")
	local ok, result = pcall(m.role_upgrade_star, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end
		
function REQUEST:wake()
	assert(false)
end		

function REQUEST:props(ctx)
	-- body
	local m = ctx:get_module("prop")
	local ok, result = pcall(m.props, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:use_prop(ctx)
	-- body
	local m = ctx:get_module("prop")
	local ok, result = pcall(m.use_prop, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:user(ctx)
	-- body
	local m = ctx:get_module("user")
	local ok, result = pcall(m.user, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:user_can_modify_name(ctx)
	-- body
	local m = ctx:get_module("user")
	local ok, result = pcall(m.user_can_modify_name, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:user_modify_name(ctx)
	-- body
	local m = ctx:get_module("user")
	local ok, result = pcall(m.user_modify_name, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:user_upgrade(ctx)
	-- body
	local m = ctx:get_module("user")
	local ok, result = pcall(m.user_upgrade, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:shop_all(ctx)
	-- body
	local m = ctx:get_module("shop")
	local ok, result = pcall(m.shop_all, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:shop_refresh(ctx)
	-- body
	local m = ctx:get_module("shop")
	local ok, result = pcall(m.shop_refresh, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:shop_purchase(ctx)
	-- body
	local m = ctx:get_module("shop")
	local ok, result = pcall(m.shop_purchase, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:recharge_all(ctx)
	-- body
	local m = ctx:get_module("recharge")
	local ok, result = pcall(m.recharge_all, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:recharge_purchase(ctx)
	-- body
	local m = ctx:get_module("recharge")
	local ok, result = pcall(m.recharge_purchase, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:recharge_vip_reward_all(ctx)
	-- body
	local m = ctx:get_module("recharge")
	local ok, result = pcall(m.recharge_vip_reward_all, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:recharge_vip_reward_collect()
	-- body
	local m = ctx:get_module("recharge")
	local ok, result = pcall(m.recharge_vip_reward_collect, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:recharge_vip_reward_purchase()
 	-- body
 	local m = ctx:get_module("recharge")
	local ok, result = pcall(m.recharge_vip_reward_purchase, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:equipment_enhance()
	-- body
	local m = ctx:get_module("equipment")
	local ok, result = pcall(m.equipment_enhance, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:equipment_all()
	-- body
	-- 1 offline 
	local m = ctx:get_module("equipment")
	local ok, result = pcall(m.equipment_all, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:role_all(ctx)
	-- body
	local m = ctx:get_module("role")
	local ok, result = pcall(m.role_all, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:role_recruit(ctx)
	-- body
	local m = ctx:get_module("role")
	local ok, result = pcall(m.role_recruit, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:role_battle(ctx)
	-- body
	local m = ctx:get_module("role")
	local ok, result = pcall(m.role_battle, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
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
	user:update_db({"sign"}, const.DB_PRIORITY_2)
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

function REQUEST:checkpoint_chapter(ctx)
	-- body
	local m = ctx:get_module("checkpoint")
	local ok, result = pcall(m.checkpoint_chapter, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:checkpoint_hanging(ctx)
	-- body
	local m = ctx:get_module("checkpoint")
	local ok, result = pcall(m.checkpoint_hanging, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

-- alone 
function REQUEST:checkpoint_hanging_choose(ctx)
	-- body
	local m = ctx:get_module("checkpoint")
	local ok, result = pcall(m.checkpoint_hanging_choose, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:checkpoint_battle_exit(ctx)
	-- body
	local m = ctx:get_module("checkpoint")
	local ok, result = pcall(m.checkpoint_battle_exit, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:checkpoint_battle_enter(ctx)
	-- body
	local m = ctx:get_module("checkpoint")
	local ok, result = pcall(m.checkpoint_battle_enter, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:checkpoint_exit(ctx)
 	-- body
 	local m = ctx:get_module("checkpoint")
	local ok, result = pcall(m.checkpoint_exit, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:checkpoint_drop_collect(ctx, ... )
	-- body
	local m = ctx:get_module("checkpoint")
	local ok, result = pcall(m.checkpoint_drop_collect, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		return ret
	end
end

function REQUEST:ara_enter(ctx, ... )
	-- body
	local m = ctx:get_module("arena")
	local ok, result = pcall(m.ara_enter, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:ara_exit(ctx, ... )
	-- body
	local m = ctx:get_module("arena")
	local ok, result = pcall(m.ara_exit, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:ara_choose_role_enter(ctx, ... )
	-- body
	local m = ctx:get_module("arena")
	local ok, result = pcall(m.ara_choose_role_enter, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:ara_choose_role(ctx, ... )
	-- body
	local m = ctx:get_module("arena")
	local ok, result = pcall(m.ara_choose_role, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:ara_bat_enter(ctx, ... )
 	-- body
end 

function REQUEST:ara_bat_exit(ctx)
	-- body
end

function REQUEST:ara_rfh(ctx)
	-- body
	-- first test when to reset
	local m = ctx:get_module("arena")
	local ok, result = pcall(m.ara_rfh, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:ara_worship(ctx)
	-- body
	local m = ctx:get_module("arena")
	local ok, result = pcall(m.ara_worship, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end	
end

function REQUEST:ara_rnk_reward_collected(ctx)
	-- body
	local m = ctx:get_module("arena")
	local ok, result = pcall(m.ara_rnk_reward_collected, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:ara_convert_pts(ctx, ... )
	-- body
	local m = ctx:get_module("arena")
	local ok, result = pcall(m.ara_convert_pts, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:ara_lp(ctx, ... )
	-- body
	local m = ctx:get_module("arena")
	local ok, result = pcall(m.ara_lp, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:logout(ctx)
	-- body
	local u = ctx:get_user()
	u:set_ifonline(0)
	ctx:logout()
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
    elseif nil ~= new_friend_request[name] then
    	f = new_friend_request[name]
    else
    	for i,v in ipairs(M) do
    		if v.REQUEST[name] ~= nil then
    			f = v.REQUEST[name]
    			break
    		end
    	end
    end

    if f then
	    local ok, result = pcall(f, args, env)
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
    elseif nil ~= new_friend_request[name] then
    	f = new_friend_request[name]
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
    local ok, result = pcall(f, args, env)

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
	
function CMD:friend(source, subcmd, ... )
	-- body
	local f = assert(new_friend_request[subcmd])
	local r =  f(new_friend_request, env, ...)
	if r then
		return r
	end
end

function CMD:newemail(source, subcmd , ... )
	local f = assert( new_emailrequest[ subcmd ] )
	f( _ , env, ... )
end

function CMD:ara_user(source)
	-- body
	local modelmgr = self:get_modelmgr()
	local r = modelmgr:gen_remote()
	print("###################################################ara_user")
	for k,v in pairs(r) do
		for kk,v in pairs(v) do
			print(kk,vv)
		end
	end
	return r
end 
	
local function enter_ara(u, ... )
	-- body
	local key = string.format("%s:%d", "g_config", 1)
	local r = sd.query(key)
	local ara_clg_tms_rst_tp = r["ara_clg_tms_rst_tm"]
	local ara_clg_tms_rst_tm = u:get_ara_clg_tms_rst_tm()
	local now = os.time()
	local m = now - ara_clg_tms_rst_tm
	if ara_clg_tms_rst_tm == 0 or ara_clg_tms_rst_tm == nil then
		local tmp = os.date("*t", os.time())
		tmp = { year=tmp.year, month=tmp.month, day=tmp.day, hour=ara_clg_tms_rst_tp}
		local sec = os.time(tmp)
		user:set_ara_clg_tms_rst_tm(sec)
	elseif m > 0 then
		m = m // 86400
		if m % 3600 > 0 then
			m = m + 1
		end
		ara_clg_tms_rst_tm = ara_clg_tms_rst_tm + (m * 86400)
		-- u:set_ara_clg_tms_rst_tm(ara_clg_tms_rst_tm)
	end
end 
	
function CMD:signup(source, uid, sid, sct, g, d)
	-- body
	skynet.error(string.format("%s is login", uid))
	gate   = source
	userid = uid
	subid  = sid
	secret = sct
	game   = ".game"
	db     = ".db"

	env:set_gate(source)
	env:set_userid(userid)
	env:set_subid(subid)
	env:set_secret(secret)
	local modelmgr = self:get_modelmgr()
	user = modelmgr:signup(userid)
		
	local onlinetime = os.time()
	user.ifonline = 1
	user.onlinetime = onlinetime
	new_friend_request.init(env)
	--user.friendmgr = friendmgr:loadfriend( user , dc )
	--new_friend_request.getvalue(user, send_package, send_request)

	-- online
	for k,v in pairs(M) do
		if v.REQUEST then
			v.REQUEST["login"](v.REQUEST, user)
		end
	end

	dc.set(user.csv_id, "client_fd", client_fd)
	dc.set(user.csv_id, "online", true)
	dc.set(user.csv_id, "addr", skynet.self())
	env:set_user(user)

	self:login(user)


	return true
end 
	
function CMD:login(source, uid, sid, sct, g, d)
	-- body
	skynet.error(string.format("%s is login", uid))
	gate   = source
	userid = uid
	subid  = sid
	secret = sct
	game   = ".game"
	db     = ".db"
	
	env:set_gate(source)
	env:set_userid(userid)
	env:set_subid(subid)
	env:set_secret(secret)

	local modelmgr = env:get_modelmgr()
	user = modelmgr:load(uid)

	local onlinetime = os.time()
	user.ifonline = 1
	user.onlinetime = onlinetime
	new_friend_request.init(env)
	--user.friendmgr = friendmgr:loadfriend( user , dc )
	--new_friend_request.getvalue(user, send_package, send_request)

	assert(user, "user must be a certernaly value.")

	for k,v in pairs(M) do
		if v.REQUEST then
			v.REQUEST["login"](v.REQUEST, user)
		end
	end

	dc.set(user.csv_id, "client_fd", client_fd)
	dc.set(user.csv_id, "online", true)
	dc.set(user.csv_id, "addr", skynet.self())

	self:set_user(user)
	self:login(user)
	subscribe()

	get_public_email(self)
	print("#####################################123ab")
	print("************************************8", self:get_userid())

	

	return true
end

function CMD:logout(source)
	-- body
	skynet.error(string.format("%s is logout", self:get_userid()))
	self:logout()
end

function CMD:afk(source)
	-- body
	skynet.error(string.format("AFK"))
end

function CMD:user(source, ... )
	-- body
	local u = self:get_user()
	local r = {}
	r.uname = u:get_uname()
	r.total_combat = 10
	return r
end

local function update_db()
	-- body
	while true do
		env:flush_db(const.DB_PRIORITY_3)
		skynet.sleep(100 * 60) -- 1ti == 0.01s
	end
end

local START_SUBSCRIBE = {}

function START_SUBSCRIBE:finish(source, ...)
	-- body
	self:flush_db(const.DB_PRIORITY_1)
	print(string.format("the node agent %d will be finished. you should clean something.", skynet.self()))
	skynet.send(source, "lua", "exit")
end

local function start_subscribe()
	-- body
	local c = skynet.call(".start_service", "lua", "register")
	local c2 = mc.new {
		channel = c,
		dispatch = function (channel, source, cmd, ...)
			-- body
			local f = START_SUBSCRIBE[cmd]
			if f then
				f(env, source, ...)
			end
		end
	}
	c2:subscribe()
end 
	
local function start()
	-- body
	host = sprotoloader.load(1):host "package"
	send_request = host:attach(sprotoloader.load(2))

	env:set_host(host)
	env:set_send_request(send_request)
	env:set_game(".game")
end 
	
skynet.start(function()
	skynet.dispatch("lua", function(_, source, command, ...)
		print("agent is called" , command)
		local f = CMD[command]
		local result = f(env, source, ... )
		if result then
			skynet.ret(skynet.pack(result))
		end
	end)
	skynet.fork(update_db)
	start()
	start_subscribe()
end)
