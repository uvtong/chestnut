package.path = "./../../module/mahjong/room/?.lua;./../../module/mahjong/lualib/?.lua;../../lualib/?.lua;"..package.path
local skynet = require "skynet"
local log = require "skynet.log"
local context = require "rcontext"
local errorcode = require "errorcode"
local gs = require "gamestate"
local util = require "util"
local opcode = require "opcode"
local assert = assert
local REQUEST = require "request"
local RESPONSE = require "response"
local CMD = require "cmd"

local id = tonumber(...)
local ctx
local NORET = {}

local function request(name, args, response, msg, sz)
	-- log.info("agent request [%s]", name)
    local f = REQUEST[name]
    local msgh = function ( ... )
		-- body
		log.info(tostring(...))
		log.info(debug.traceback())
	end
    local ok, result = xpcall(f, msgh, ctx, args, msg, sz)
    if ok then
    	return response(result)
    end
end

local function response(session, args, msg, sz)
	-- body
	local name = ctx:get_name_by_session(session)
	-- log.info("agent response [%s]", name)
	local ok, result = pcall(room_response, name, args)
	if ok then
		if result then
			return
		end
	end
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
		local host = ctx:get_host()
		return host:dispatch(msg, sz)
	end,
	dispatch = function (session, source, type, ...)	
		if type == "REQUEST" then
			local ok, result = pcall(request, ...)
			if ok then
				if result then
					skynet.rawsend(source, "")
					-- ctx:send_package(result)
				end
			else
				log.error(result)
			end
		elseif type == "RESPONSE" then
			pcall(response, ...)
		else
			assert(false, result)
		end
	end
}

skynet.start(function ()
	-- body
	skynet.dispatch("lua", function(_, source, cmd, ...)
		log.info("room [%s] is called", cmd)
		local f = CMD[cmd]
		local msgh = function ( ... )
			-- body
			log.info(tostring(...))
			log.info(debug.traceback())
		end
		local ok, err = xpcall(f, msgh, ctx, ...)
		if ok then
			if err ~= NORET then
				skynet.retpack(err)
			end
		end
	end)
	ctx = context.new()
	ctx:set_id(id)
end)