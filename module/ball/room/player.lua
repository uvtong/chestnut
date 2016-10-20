local cls = class("player")

function cls:ctor(session, ... )
	-- body
	assert(session)
	self._session = session
	self._myballs = {}
end

function cls:add(ball, ... )
	-- body
	table.insert(self._myballs, ball)
end

function cls:remove(ball, ... )
	-- body

end

return cls