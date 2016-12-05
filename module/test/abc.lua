local skynet = require "skynet"
local luapack = require "luapack"
local test = require "test"

skynet.register_protocol {
	name = "text",
	id = skynet.PTYPE_TEXT,
	unpack = function (msg, sz)
		return luapack.unpack(msg, sz)
	end,
	dispatch = test.dispatch
	dispatch = function (session, source, type, ...)
		if type == "REQUEST" then
			local ok, result = pcall(request, ...)
			if ok then
				if result then
					ctx:send_package(result)
				end
			else
				log.error(result)
			end
		elseif type == "RESPONSE" then
			pcall(response, ...)
		else
			assert(false, result)
		end
	end
}

skynet.start(function ( ... )
	-- body
end)