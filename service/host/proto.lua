local sprotoparser = require "sprotoparser"

local proto = {}

proto.c2s = sprotoparser.parse [[

]]

proto.s2c = sprotoparser.parse [[


]]

return proto
