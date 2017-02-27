local log = require "log"
local cls = class("player")

function cls:ctor(uid, session, ... )
	-- body
	assert(uid and session)
	self._uid = uid
	self._session = session
	self._secret = nil
	self._agent = nil
end

function cls:get_uid( ... )
	-- body
	return self._uid
end

function cls:get_session( ... )
	-- body
	return self._session
end

function cls:set_secret(v, ... )
	-- body
	self._secret = v
end

function cls:get_secret( ... )
	-- body
	return self._secret
end

function cls:set_agent(v, ... )
	-- body
	self._agent = v
end

function cls:get_agent( ... )
	-- body
	return self._agent
end

return cls