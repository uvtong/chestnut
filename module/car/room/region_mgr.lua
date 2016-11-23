local skynet = require "skynet"
local sd = require "sharedata"
local gs = require "room.gamestate"
local buff = require "room.buff"
local region = require "room.region"
local cls = class("buff_mgr")

function cls:ctor(ctx, id, ... )
	-- body
	self._ctx = ctx
	self._id = id
	self._regions = {}

	local key = string.format("%s:%d", "s_leveldistrictinfo", self._id)
	local ids = sd.query(key).IncidentID
	local arr = string.split(ids, ",")
	for i,v in ipairs(arr) do
		local key = string.format("%s:%d", "s_level_incident", tonumber(v))
		local raw = sd.query(key)

		local re = region.new(self._ctx, self, raw.id, raw.time * 100, raw.continuedtime * 100)
		self:add(re)
	end

	return self
end

function cls:add(re, ... )
	-- body
	self._regions[re] = re
end

function cls:remove(re, ... )
	-- body
	self._regions[re] = nil
end

return cls