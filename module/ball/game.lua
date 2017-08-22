local skynet = require "skynet"
require "skynet.manager"
local log = require "skynet.log"
local dbmonitor = require "dbmonitor"


local CMD = {}

function CMD.start( ... )
	-- body
	return true
end

function CMD.close( ... )
	-- body
	return true
end

function CMD.kill( ... )
	-- body
	skynet.exit()
end

function CMD.load( ... )
	-- body
	dbmonitor.cache_select('tb_count')
	-- dbmonitor.cache_select('tb_nameid')
	dbmonitor.cache_select('tb_openid')
	-- dbmonitor.cache_select('tb_record')
	-- dbmonitor.cache_select('tb_sysmail')
	dbmonitor.cache_select('tb_user')

	-- -- 2.0
	-- skynet.call(".SYSEMAIL", "lua", "load")
	-- skynet.call(".RECORD_MGR", "lua", "load")

	log.info("load over")
	return true
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		local result = f(...)
		if result then
			skynet.ret(skynet.pack(result))
		end
	end)
	
	skynet.register "game"
end)
