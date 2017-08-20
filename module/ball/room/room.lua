local skynet = require "skynet"
require "skynet.manager"
local errorcode = require "errorcode"
local math3d = require "math3d"
local float = require "float"
local crypt = require "crypt"
local log = require "log"
local list = require "list"
local context = require "room.context"
local player = require "room.player"

-- context variable
local id = ...
local ctx
local k = 0
local lasttick = 0



skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function(_,_, cmd, subcmd, ...)
		local f = CMD[cmd]
		local r = f(subcmd, ... )
		if r ~= nil then
			skynet.ret(skynet.pack(r))
		end
	end)

	ctx = context.new(id)

	-- local aoi = skynet.newservice("aoi")
	local battle = skynet.launch("battle")

	-- ctx:set_aoi(aoi)
	ctx:set_battle(battle)
end)

