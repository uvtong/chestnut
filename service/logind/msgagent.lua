local skynet = require "skynet"
require "skynet.manager"
local netpack = require "netpack"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"

local host
local send_request

local gate
local userid, subid

local CMD = {}
local REQUEST = {}
local RESPONSE = {}

local function request(name, args, response)
	skynet.error(string.format("request: %s", name))
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
    assert(f)
    assert(response)
    local ok, result = pcall(f, args)
    if ok then
	    if name == "login" then
			if result.errorcode == errorcode[1].code then
				for k,v in pairs(M) do
					if v.REQUEST then
						v.REQUEST[name](v.REQUEST, user)
					end
				end
			end
		end  
		return response(result)
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return response(ret)
	end
end      

function RESPONSE:finish_achi( ... )
	-- body
	assert(self.errorcode == 1)
	skynet.error(self.msg)
end

local function response(name, args)
	-- body
	local f = assert(RESPONSE[name])
	f(args)
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
	dispatch = function (_, _, type, ...)
		if type == "REQUEST" then
			local ok, result  = pcall(request, ...)
			if ok then
				if result then
					send_package(result)
				end
			else
				skynet.error(result)
			end
		elseif type == "HEARTBEAT" then
			send_package(send_request "heartbeat")
		elseif type == "RESPONSE" then
			pcall(response, ...)
		end
	end
}

function CMD.login(source, uid, sid, secret)
	-- you may use secret to make a encrypted data stream
	skynet.error(string.format("%s is login", uid))
	gate = source
	userid = uid
	subid = sid
	-- you may load user data from database
end

local function logout()
	if gate then
		skynet.call(gate, "lua", "logout", userid, subid)
	end
	skynet.exit()
end

function CMD.logout(source)
	-- NOTICE: The logout MAY be reentry
	skynet.error(string.format("%s is logout", userid))
	logout()
end

function CMD.afk(source)
	-- the connection is broken, but the user may back
	skynet.error(string.format("AFK"))
end

skynet.start(function()
	-- If you want to fork a work thread , you MUST do it in CMD.login
	skynet.dispatch("lua", function(session, source, command, ...)
		local f = assert(CMD[command])
		skynet.ret(skynet.pack(f(source, ...)))
	end)

	-- skynet.dispatch("client", function(_,_, msg)
	-- 	-- the simple echo service
	-- 	skynet.sleep(10)	-- sleep a while
	-- 	skynet.ret(msg)
	-- end)

	host = sprotoloader.load(1):host "package"
	send_request = host:attack(sprotoloader.load(2))
end)
