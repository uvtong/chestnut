local skynet = require "skynet"
require "skynet.manager"

local noret = {}
local CMD = {}

function CMD.start( ... )
	-- body
	return true
end

function CMD.close( ... )
	-- body
	return false
end

function CMD.exit( ... )
	-- body
end

function CMD.load(uid, ... )
	-- body
	local tables = {"tg_users"}
	for i,v in ipairs(tables) do
		local sql = string.format("select * from %s where uid = %d", v, uid)
	end
end

function CMD.update( ... )
	-- body
end

function CMD.insert( ... )
	-- body
end

skynet.start(function()
	skynet.dispatch("lua", function(_, source, cmd, ...)
		local f = assert(CMD[cmd])
		local ok, err = pcall(f, ...) 
		if ok then
			if err ~= noret then
				skynet.retpack(err)
			end
		else
			log.error(err)
		end
	end)
end)
