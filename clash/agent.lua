package.path = "./../cat/?.lua;" .. package.path
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

table.insert( M , checkinrequest )
table.insert( M , exercise_request )
table.insert( M , cgold_request )
table.insert( M , new_emailrequest )
table.insert( M , kungfurequest )
table.insert( M , new_drawrequest )
table.insert( M , lilian_request )

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
			print( "************************************************************************ls called" )
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
	return true
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

function CMD.gen_model(table_name)
	-- body
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