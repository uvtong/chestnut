local skynet = require "skynet"
-- local luapack = require "luapack"
local test = require "test"

local function cb( ... )
	-- body
	local cmd, ud = skynet.call(".TEST", "text")
	skynet.error(cmd, ud)
end

skynet.register_protocol {
	name = "text",
	id = skynet.PTYPE_TEXT,
	pack = test.pack,
	unpack = test.unpack,
	dispatch = test.dispatch
}

skynet.start(function ( ... )
	-- body
	skynet.timeout(10, cb)
end)