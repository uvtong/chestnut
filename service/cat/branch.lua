local skynet = require "skynet"
require "skynet.manager"

skynet.start(function()
	-- local channel = skynet.newservice("channel")
	-- skynet.name(".channel", channel)

	skynet.exit()
end)