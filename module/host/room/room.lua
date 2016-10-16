package.path = "./../../module/host/room/?.lua;./../../module/host/lualib/?.lua;../../lualib/?.lua;"..package.path
local skynet = require "skynet"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local context = require "context"
local log = require "log"
local player = require "player"
local errorcode = require "errorcode"
local assert = assert
local ctx
local NORET = {}

local function init( ... )
	-- body
	ctx = context.new()
	local host = sprotoloader.load(1):host "package"
	local send_request = host:attach(sprotoloader.load(2))
	ctx:set_host(host)
	ctx:set_send_request(send_request)
end

local REQUEST   = {}

function REQUEST:enter_room(source, uid, agent, ... )
	-- body
	log.info("uid %d enter room", uid)
	local p = self:create_player(uid, source)
	if p then
		local myplayer = {}
		myplayer.uid = p:get_uid()

		local players = {}
		local last = p:get_last()
		if last then
			myplayer.orientation = 1
			local agent = assert(last:get_agent())
			local info = skynet.call(agent, "lua", "enter_room", myplayer)
			-- left is -1
			local player = {
				uid = last:get_uid(),
				name = info.name,
				orientation = -1,
			}
			table.insert(players, player)
		end
		local next = p:get_next()
		if next then
			myplayer.orientation = -1
			local agent = assert(last:get_agent())
			local info = skynet.call(agent, "lua", "enter_room", myplayer)
			-- right is 1
			local player = {
				uid = next:get_uid(),
				name = info.name,
				orientation = 1
			}
			table.insert(players, player)
		end
		if #self:get_players() >= 3 then
			local controller = self:get_controller("game")
			controller:start()
		end
		local res = {}
		res.errorcode = errorcode.SUCCESS
		res.players = players
		return res
	else
		local res = {}
		res.errorcode = errorcode.FAIL
		return res
	end
end

function CMD:leave_room(source, uid, ... )
	-- body
	log.info("room leave_room: %d", uid)
	local player = self:get_player_by_uid(uid)
	self:remove(player)
	skynet.call(".ROOM_MGR", "lua", "leave_room", uid)
end

function REQUEST:ready(args, ... )
	-- body
	local player = self:get_player_by_uid(args.uid)
	local controller = self:get_controller("game")
	return controller:ready(player, args.ready)
end

function REQUEST:mp(args, ... )
	-- body
end

function REQUEST:am(args, ... )
	-- body
end

function REQUEST:rob(args, ... )
	-- body
	local uid = args.uid
	local rob = args.rob
	local player = self:get_player_by_uid(uid)
	local controller = self._env:get_controller("game")
	return controller:rob(player, rob)
end

function REQUEST:lead(args, ... )
	-- body
	local uid = args.uid
	local player = self:get_player_by_uid(uid)
	local controller = self._env:get_controller("game")
	return controller:lead(player, flag, args.cards)
end

local function request(name, args, response)
	log.print_info("room request: %s", name)
    local f = REQUEST[name]
    local ok, result = pcall(f, ctx, args)
    if ok then
    	return result
    else
    	log.print_error(result)
    	local ret = {}
    	ret.errorcode = errorcode.FAIL
    	return ret
    end
end

local RESPONSE = {}

function RESPONSE:enter_room(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end

function RESPONSE:ready(args, ... )
	-- body
end

function RESPONSE:mp(args, ... )
	-- body
end

function RESPONSE:rob(args, ... )
	-- body
end

function RESPONSE:deal(args, ... )
	-- body
	local errorcode = args.errorcode
	assert(errorcode == errorcode.SUCCESS)
end

local function response(name, args)
	-- body
	log.print_info("room response: %s", name)
    local f = RESPONSE[name]
    local ok, result = pcall(f, ctx, args)
    if ok then
    else
    	log.print_error(result)
    end
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = skynet.unpack,
	dispatch = function (session, source, type, ...)	
		if type == "REQUEST" then
			local ok, result = pcall(request, ...)
			if ok then
				if result then
					skynet.retpack(result)
				end
			else
				skynet.error(result)
			end
		elseif type == "RESPONSE" then
			pcall(response, ...)
		else
			assert(false, result)
		end
	end
}

local CMD = {}

skynet.start(function ()
	-- body
	skynet.dispatch("lua", function(_, source, cmd, ...)
		log.info("room [%s] is called", cmd)
		local f = CMD[cmd]
		local ok, err = pcall(f, ctx, source, ...)
		if ok then
			if err ~= NORET then
				skynet.retpack(err)
			end
		else
			log.error(err)
		end
	end)
	init()
end)