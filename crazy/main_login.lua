local skynet = require "skynet"
require "skynet.manager"

skynet.start(function()
	local db = skynet.newservice('db')
	local loginserver = skynet.newservice("logind", db)
	skynet.name("LOGIND", loginserver)

	--local gate = skynet.newservice("gated", loginserver)

	--skynet.call(gate, "lua", "open" , {
	--	port = 8888,
	--	maxclient = 64,
	--	servername = "sample",
	--})
	
	skynet.exit()
end)
