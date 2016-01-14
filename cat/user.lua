dbop = require "dbop"

usermgr = {}

usermgr._data = {}

function usermgr:add( u )
	-- body
	table.insert( _data, u.id, u )
end

function usermgr:delete( id )
	-- body
	table.remove(_data, id)
end

function usermgr:find( id )
	-- body
	return self._data[id]
end

local user = {}

user._nickname = "aa"

function user.new( ... )
 	-- body
 	local d = { ... }
 	for k,v in pairs(d) do
 		print(k,v)
 	end
 	local t = {}
 	setmetatable( t, { __index = user } )
 	return t
 end 

function user:nickname( ... )
	-- body
	return self._nickname
end

function user:selectdb( tvals )
	
	return dbop.tselect( tvals )
	
end

function user:insert
	
local n = { nickname = "aaa"}
local u = user.new(n)
print(u:nickname())
