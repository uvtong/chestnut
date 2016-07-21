local query = require "query"
local json = require "cjson"
local sd = require "sharedata"

local cls = class("entity")

function cls:ctor()
	return self
end

function cls:set(pk, key, value)
end

function cls:get(pk, key)
end

return cls