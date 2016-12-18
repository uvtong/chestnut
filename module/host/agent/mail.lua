local entity = require "entity"
local query = require "query"
local cls = class("mail", entity)

function cls:ctor(ctx, dbctx, dbset, id, from, to, title, content, date, ... )
	-- body
	self._ctx = ctx
	self._dbctx = dbctx
	self._dbset = dbset
	self._id = id
	self._from = from
	self._to = to
	self._title = title
	self._content = content
	self._date = date
end

function cls:get_id( ... )
	-- body
	return self._id
end

function cls:get_from( ... )
	-- body
	return self._from
end

function cls:get_to( ... )
	-- body
	return self._to
end

function cls:update( ... )
	-- body
	-- local table_name = self._dbset:get_tname()
	-- local sql = "update u_inbox set id=%d, from "
end

function cls:insert( ... )
	-- body
	local sql = string.format("insert into u_inbox (id, from, to, title, content, date) values(%d, %d, %d, %d, %s, %s, %d)", self._id, self._from, self._to, self._title, self._content, self._date)
	query.insert("u_inbox", sql)
end

return cls