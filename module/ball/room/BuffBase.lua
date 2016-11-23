local math3d = require "math3d"
local float = require "float"
local assert = assert
local cls = class("BuffBase")


function cls:ctor( id , type , entity)
 self.entity = entity
 self.buffid = id
 self.bufftype = type
 self.configname = "s_buff"
end

function cls:update( deltaTime )

end

function cls:deal()

end

function cls:remove()

end

return cls


