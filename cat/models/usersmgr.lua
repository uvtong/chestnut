local skynet = require "skynet"
local util = require "util"

local _M = {}
_M.__data = {}
_M.__count = 0

local _Meta = { id=0, uname=0, uviplevel=0, uexp=0, config_sound=0, config_music=0, avatar=0, sign=0, c_role_id=0, ifonline=0, level=0, combat=0, defense=0, critical_hit=0, modify_uname_count=0, onlinetime=0, iconid=0, recharge_total=0, recharge_count=0, is_valid=0, goods_refresh_count=0, goods_refresh_reset_dt=0}

_Meta.__tname = "users"

function _Meta:__insert_db()
	-- body
	local t = {}
	t.id = self.id
	t.uname = self.uname
	t.uviplevel = self.uviplevel
	t.uexp = self.uexp
	t.config_sound = self.config_sound
	t.config_music = self.config_music
	t.avatar = self.avatar
	t.sign = self.sign
	t.c_role_id = self.c_role_id
	t.ifonline = self.ifonline
	t.level = self.level
	t.combat = self.combat
	t.defense = self.defense
	t.critical_hit = self.critical_hit
	t.modify_uname_count = self.modify_uname_count
	t.onlinetime = self.onlinetime
	t.iconid = self.iconid
	skynet.send(util.random_db(), "lua", "command", "insert", self.__tname, t)
end

function _Meta:__update_db(t)
	-- body
	assert(type(t) == "table")
	local columns = {}
	for i,v in ipairs(t) do
		columns[tostring(v)] = self[tostring(v)]
	end
	skynet.send(util.random_db(), "lua", "command", "update", self.__tname, {{ id = self.id }}, columns)
end

function _Meta.__new()
 	-- body
 	local t = {}
 	setmetatable( t, { __index = _Meta } )
 	return t
end 

function _M.create( P )
	assert(P)
	local u = _Meta.__new()
	for k,v in pairs(_Meta) do
		if not string.match(k, "^__*") then
			u[k] = P[k]
		end
	end
	return u
end	

function _M:add( u )
	assert(u)
	self.__data[tostring(u.id)] = u
	self.__count = self.__count + 1
end
	
function _M:delete(id)
	assert(id)
	self.__data[tostring(id)] = nil
end

function _M:get(id)
	-- body
	return self.__data[tostring(id)]
end

function _M:get_count()
	-- body
	return self.__count
end

return _M
