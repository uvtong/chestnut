local skynet = require "skynet"

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function ( ... )
		-- body
	end)
	
end)