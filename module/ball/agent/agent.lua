local skynet = require "skynet"
local netpack = require "skynet.netpack"
local mc = require "skynet.multicast"
local dc = require "skynet.datacenter"
local redis = require "skynet.db.redis"
local log = require "skynet.log"
local util = require "util"
local const = require "const"
local errorcode = require "errorcode"

local context = require "agent.acontext"
local CMD = require "agent.cmd"
local REQUEST = require "agent.request"
local RESPONSE = require "agent.response"

local assert = assert
local pcall = skynet.pcall

local ctx       = false
local SUBSCRIBE = {}


local function subscribe()
	-- body
	local u = env:get_user()
	local addr = skynet.self()
	local uid = u:get_uid()
	local c = skynet.call(".channel", "lua", "agent_start", uid, addr)
	local c2 = mc.new {
		channel = c,
		dispatch = function ( channel, source, cmd, args, ... )
			-- body
			local f = SUBSCRIBE[cmd]
			f(env, args)
		end
	}
	c2:subscribe()
end

local function request(name, args, response, msg, sz)
	log.info("agent request [%s]", name)
    local f = REQUEST[name]
    local ok, result = xpcall(f, debug.msgh, ctx, args, msg, sz)
    if ok then
    	if result then
    		return response(result)
    	end
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
			local ok, result = xpcall(request, debug.msgh, ...)
			if ok then
				if result then
					ctx:send_package(result)
				end
			end
		elseif type == "RESPONSE" then
			pcall(response, ...)
		else
			assert(false, result)
		end
	end
}

skynet.start(function()
	skynet.dispatch("lua", function(_, source, cmd, ...)
		log.info("agent cmd [%s] is called", cmd)
		local f = assert(CMD[cmd])
		local ok, err = xpcall(f, debug.msgh, ctx, ...) 
		if ok then
			if err ~= errorcode.NORET then
				skynet.retpack(err)
			end
		end
	end)
	-- slot 1,2 set at main.lua
	ctx = context.new()
end)
