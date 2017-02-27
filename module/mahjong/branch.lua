local skynet = require "skynet"

local CMD = {}

function CMD.start( ... )
	-- body
end

function CMD.kill( ... )
	-- body
end

skynet.start(function()
	-- local channel = skynet.newservice("channel", game)
	-- skynet.name(".channel", channel)

	skynet.exit()
end)