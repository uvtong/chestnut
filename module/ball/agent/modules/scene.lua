local M = require "module"

local cls = class("scene", M)

function cls:ctor(env, name, ... )
	-- body
	cls.super.ctor(self, name)

end

function cls:set_db(value, ... )
	-- body
	cls.super.set_db(self, value)
end

function cls:login( ... ) 
	cls.super.login(self)
end

function cls:logout( ... )
	-- body
	cls.super.logout(self)
end

function cls:authed( ... )
	-- body
	cls.super.authed(self)
end

function cls:afx( ... )
	-- body
	cls.super.afx(self)
end

function cls:load_cache_to_data( ... )
	-- body
	cls.super.load_cache_to_data(self)
	
end

return cls