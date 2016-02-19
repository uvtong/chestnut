local battlerequest = {}
local dc = require "datacenter"
local util = require "util"

local send_package
local send_request

local REQUEST = {}
local RESPONSE = {}
local SUBSCRIBE = {}
local client_fd



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

function battlerequest.start(conf, send_request, game, ...)
	-- body
	client_fd = conf.client
	send_request = send_request
	game = game
end

function battlerequest.disconnect()
	-- body
end

battlerequest.REQUEST = REQUEST
battlerequest.RESPONSE = RESPONSE
battlerequest.SUBSCRIBE = SUBSCRIBE
return battlerequest
