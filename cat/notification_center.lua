local cls = class("notification_center")

cls.events = {}
cls.events.EGOLD        = 1
cls.events.EEXP         = 2
cls.events.EUSER_LEVEL  = 3

function cls:ctor( ... )
	-- body
	self._rt = {}
	self.events = cls.events
end

function cls:register(event, callback, ud, ... )
	-- body
	local cb = { callback = callback, ud = ud}
	local q = self._rt[event]
	if q == nil or type(q) ~= "table" then
		self._rt[event] = {}
		q = self._rt[event]
	end
	table.insert(q, cb)
end

function cls:fire(event, ... )
	-- body
	local cb = self._rt[event]
	if cb then
		local callback = cb.callback
		local ud = cb.ud
		callback(ud, ...)
	end
end

return cls
