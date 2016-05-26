local cls = class("arena")

function cls:ctor( ... )
	-- body
	self._me = false
	self._enemy = false
	self._me_modelmgr = false
	self._en_modelmgr = false
	return self
end

function cls:set_me(v, ... )
	-- body
	self._me = v
end

function cls:set_enemy(v, ... )
	-- body
	self._enemy = v
end

function cls:get_me( ... )
	-- body
	return self._me
end

function cls:get_enemy( ... )
	-- body
	return self._enemy
end

function cls:set_me_modelmgr(v, ... )
	-- body
	self._me_modelmgr = v
end

function cls:get_me_modelmgr( ... )
	-- body
	return self._me_modelmgr
end

function cls:set_en_modelmgr(v, ... )
	-- body
	self._en_modelmgr = v
end

function cls:get_en_modelmgr( ... )
	-- body
	return self._en_modelmgr
end

return cls