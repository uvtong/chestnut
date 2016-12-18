local skynet = require "skynet"

local _M = {}

function _M.login(uid, agent, ... )
	-- body
	skynet.send(".CHAT", "lua", "login", uid, agent)
end

function _M.afx(uid, ... )
	-- body
	skynet.send(".CHAT", "lua", "afx", uid)
end

function _M.say(from, to, word, ... )
	-- body
	skynet.send(".CHAT", "lua", "say", from, to, word)
end

return _M