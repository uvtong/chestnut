local skynet = require "skynet"

skynet.start(function ()
	skynet.send(".CODWEB", "lua", "kill")
end)