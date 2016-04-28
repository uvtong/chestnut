local skynet = require "skynet"
local util = require "util"
local const = require "const"

local _M = {}
_M.__data = {}
_M.__count = 0
_M.__user_id = 0
_M.__tname = "u_checkpoint"

local _Meta = { user_id=0, 
				chapter=0, 
				chapter_type0=0, 
				chapter_type1=0, 
				chapter_type2=0 }

_Meta.__tname = "u_checkpoint"

function _Meta.__new()
 	-- body
 	local t = {}
 	setmetatable( t, { __index = _Meta } )
 	return t
end 

function _Meta:__insert_db(priority)
	-- body
	assert(priority)
	local t = {}
	for k,v in pairs(self) do
		if not string.match(k, "^__*") then
			t[k] = self[k]
		end
	end
	skynet.send(util.random_db(), "lua", "command", "insert", self.__tname, t, priority)
end

function _Meta:__update_db(t)
	-- body
	-- assert(type(t) == "table")
	-- local columns = {}
	-- for i,v in ipairs(t) do
	-- 	columns[tostring(v)] = self[tostring(v)]
	-- end
	-- skynet.send(util.random_db(), "lua", "command", "update", self.__tname, {{ id = self.id }}, columns)
end

function _M.create_with_chapter(chapter)
	-- body
	local t = {
		user_id = _M.__user_id,
		chapter = chapter,
		chapter_type0 = 0,              -- 0 means 0 checkpont no.
		chapter_type1 = 0,
		chapter_type2 = 0,
	}
	return _M.create(t)
end

function _M.create(P)
	assert(P)
	local u = _Meta.__new()
	for k,v in pairs(_Meta) do
		if not string.match(k, "^__*") then
			u[k] = assert(P[k])
		end
	end
	return u
end	

function _M:add(u)
	assert(u)
	assert(self.__data[tostring(u.chapter)] == nil, string.format("%d", u.chapter))
	self.__data[tostring(u.chapter)] = u
	self.__count = self.__count + 1
end

function _M:get_by_chapter(csv_id)
	-- body
	local r = self.__data[tostring(csv_id)]
	if r then
		return r
	else
		r = self.create_with_chapter(csv_id)
		self:add(r)
		r:__insert_db(const.DB_PRIORITY_2)
		return r
	end
end

function _M:delete_by_chapter(csv_id)
	-- body
	assert(self.__data[tostring(csv_id)])
	self.__data[tostring(csv_id)] = nil
	self.__count = self.__count - 1
end

function _M:get_count()
	-- body
	return self.__count
end

function _M:clear()
	self.__data = {}
	self.__count = 0
end

function _M:update_db(priority)
	-- body
	assert(priority, "you must")
	if self.__count >= 1 then
		local columns = { "chapter_type0", "chapter_type1", "chapter_type2"}
		local condition = { {user_id = self.__user_id}, {chapter = {}}}
		skynet.send(util.random_db(), "lua", "command", "update_all", _Meta.__tname, condition, columns, self.__data, priority)
	end
end

return _M
