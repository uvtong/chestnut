local skynet = require "skynet"
require "skynet.manager"
local gateserver = require "snax.gateserver"
local netpack = require "netpack"
local socket = require "socket"
local crypt = require "crypt"
local table = table
local string = string
local assert = assert

local server = {
	host = "127.0.0.1",
	port = 8002,
	name = "signup_master"
}

local server_list = {}

local secrite = 1
local last = ""
local connection = {}

local function writeline(fd, text)
	socket.send(fd, text .. "\n")
end

local function unpack_line(text)
	local from = text:find("\n", 1, true)
	if from then
		return text:sub(1, from-1), text:sub(from+1)
	end
	return nil, text
end

local handler = {}

function handler.open(source, conf)
	-- body
end

function handler.message(fd, msg, sz)
	local str = netpack.tostring(msg, sz)
	last = last .. str
	local line = unpack_line(last)

end

function handler.connect(fd, addr)
	local c = {
		fd = fd,
		ip = addr,
	}
	connection[fd] = c
end

local function unforward(c)
	if c.agent then
		forwarding[c.agent] = nil
		c.agent = nil
		c.client = nil
	end
end

local function close_fd(fd)
	local c = connection[fd]
	if c then
		unforward(c)
		connection[fd] = nil
	end
end

function handler.disconnect(fd)
	close_fd(fd)
	skynet.send(watchdog, "lua", "socket", "close", fd)
end

function handler.error(fd, msg)
	close_fd(fd)
	skynet.send(watchdog, "lua", "socket", "error", fd, msg)
end

function handler.warning(fd, size)
	skynet.send(watchdog, "lua", "socket", "warning", fd, size)
end



local CMD = {}

function CMD.start()
	-- body
end

function CMD.register_gate(server, address)
	-- body
	server_list[server] = address
end

function handler.command(cmd, source, ...)
	local f = assert(CMD[cmd])
	return f(source, ...)
end

gateserver.start(handler)