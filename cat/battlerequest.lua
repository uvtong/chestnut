local battlerequest = {}
local util = require "util"

local send_package
local send_request

local REQUEST = {}
local RESPONSE = {}
local client_fd

local dc

local game
local user

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end

function REQUEST:login(user)
	-- body
	user = user
end

function REQUEST:abc()
	-- body
end

function RESPONSE:abc()
	-- body
end

function battlerequest.start(conf, send_request, game, dc, ...)
	-- body
	client_fd = conf.client
	send_request = send_request
	game = game
	dc = dc
end

function battlerequest.disconnect()
	-- body
end

battlerequest.REQUEST = REQUEST
battlerequest.RESPONSE = RESPONSE
return battlerequest
