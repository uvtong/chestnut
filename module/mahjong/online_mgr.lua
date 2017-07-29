local skynet = require "skynet"
require "skynet.manager"
local log = require "skynet.log"
local query = require "query"
local context = require "context"

local noret = {}
local users = {}
local subusers = {}

local cmd = {}

function cmd.start( ... )
	-- body
	return true
end

function cmd.close( ... )
	-- body
	return true
end

function cmd.kill( ... )
	-- body
	skynet.exit()
end

function cmd.login(uid, subid, agent, fd, ... )
	-- body
	local u = {}
	u.uid = uid
	u.agent = agent
	u.fd = fd

	users[uid] = u
	return noret
end

function cmd.logout(uid, subid, ... )
	-- body
	local u = users[uid]
	assert(u.subid == subid)
	users[uid] = nil
	subusers[subid] = nil	
end

function cmd.authed(uid, subid, ... )
	-- body
	local u = users[uid]
	u.subid = subid
	subusers[subid] = u
end

function cmd.afk(uid, subid, ... )
	-- body
	local u = users[uid]
	assert(u.subid == subid)
	assert(subusers[subid] == u)
	u.subid = nil
	subusers[subid] = nil
	return true
end

function cmd.add_rcard(name, num, ... )
	-- body
	-- 0 success
	-- 1 no one
	-- 2 num is wrong
	local number = math.tointeger(num)
	if number <= 0 then
		return 2
	end
	local agent = users[name]
	if agent then
		skynet.send(agent, "lua", "add_rcard", number)
	else
		local sql = string.format("select * from tg_users where name = %d", name)
		local res = query.select("tg_users", sql)
		if #res > 0 then
			local rcard = res[1].rcard
			rcard = rcard + number
			sql = string.format("update tg_users set rcard=%d where name=%d", rcard, name)
			query.update("tg_users", sql)
			return 0
		else
			return 1
		end
	end
end

local REQUEST = {}

function REQUEST.toast1(args, ... )
	-- body

end

local function request(name, args, response, msg, sz)
	log.info("ONLINE_MGR request [%s]", name)
	local u = users[args.uid]
    local f = REQUEST[name]
    local ok, result = xpcall(f, debug.msgh, ctx, args, msg, sz)
    if ok then
    	return response(result), u.fd
    end
end

local function response(session, args, msg, sz)
	-- body
	local name = ctx:get_name_by_session(session)
	-- log.info("agent response [%s]", name)
    local f = RESPONSE[name]
    local ok, result = pcall(f, ctx, args)
    if ok then
    else
    	log.error(result)
    end
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		if sz > 0 then
			local host = ctx:get_host()
			return host:dispatch(msg, sz)
		else 
			assert(false)
		end
	end,
	dispatch = function (session, source, type, ...)	
		if type == "REQUEST" then
			local ok, result, id = xpcall(request, debug.msgh, ...)
			if ok then
				if result then
					ctx:send_package_id(result, id)
				end
			end
		elseif type == "RESPONSE" then
			pcall(response, ...)
		else
			assert(false, result)
		end
	end
}

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function (_, source, command, ... )
		-- body
		local f = assert(cmd[command])
		local r = f( ... )
		if r ~= noret then
			skynet.retpack(r)
		end
	end)
	skynet.register ".ONLINE_MGR"
end)