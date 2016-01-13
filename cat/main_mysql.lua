local skynet = require "skynet"


skynet.start(function()
	print("Main Server start")
	local console = skynet.newservice("testmysql2")
	
	print("Main Server exit")
	skynet.exit()
end)
