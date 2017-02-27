local set = require "db.dbset"
local cls = class("inbox", set)

function cls:ctor( ... )
	-- body
end

function cls:get_tname( ... )
	-- body
	return "gu_inbox"
end

function cls:recv( ... )
	-- body
	local now = os.date("*t")
	local res = skynet.call(".EMAIL", "lua", "recv", now)
	
end

return cls