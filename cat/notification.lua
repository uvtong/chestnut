local cls = class("notification")

cls.events = {}
cls.events.EGOLD        = 1
cls.events.EEXP         = 2
cls.events.EUSER_LEVEL  = 3

function cls:ctor( ... )
	-- body
	self._egold = {}
	self._eexp  = {}
	self._euser_level = {}
end

function cls:register(event, callback, ... )
	-- body
	local params = {...}
	local cb = { callback = callback, params = params}
	if event == cls.events.EGOLD then
		table.insert(self._egold, cb)
	elseif event == cls.events.EEXP then
		table.insert(self._eexp, cb)
	elseif event == cls.events.EUSER_LEVEL then
		table.insert(self._euser_level, cb)
	end
end

function cls:fire(event, ... )
	-- body
	if event == cls.event.EGOLD then
		for i,v in ipairs(self._egold) do
			v.callback(v.params)
		end
	elseif event == cls.event.EEXP then
		for i,v in ipairs(self._eexp) do
			v.callback(v.params)
		end
	elseif event == cls.event._euser_level then
		for i,v in ipairs(self._euser_level) do
			v.callback(v.params)
		end
	end
end

return cls
