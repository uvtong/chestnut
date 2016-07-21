-- module proto as examples/proto.lua

local skynet = require "skynet"
local sprotoparser = require "sprotoparser"
local sprotoloader = require "sprotoloader"
-- local proto = require "proto"

skynet.start(function()
	local proto = {}
	local addr = io.open("./../../service/host/proto/proto.c2s.sproto")
	proto.c2s = addr:read("a")
	addr = io.open("./../../service/host/proto/proto.s2c.sproto")
	proto.s2c = addr:read("a")
	
	sprotoloader.save(proto.c2s, 1)
	sprotoloader.save(proto.s2c, 2)
	-- don't call skynet.exit() , because sproto.core may unload and the global slot become invalid
end)
