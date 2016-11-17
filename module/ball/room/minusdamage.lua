local math3d = require "math3d"
local buffbase = require "room.BuffBase"
local float = require "float"
local sd = require "sharedata"
local assert = assert
local cls = class("minusdamagebuff",buffbase)


function cls:ctor( id ,type , entity)
	cls.super.ctor(self , id ,type ,entity)
	-- 
	local buffconfigkey = string.format("%s:%d",self.configname,buffid )
	self.continuedtime = sd.query(buffconfigkey).time
	self.damage = sd.query(buffconfigkey).damageminus
	self:deal()
end

function cls:update( deltaTime )
	self.continuedtime = self.continuedtime - deltaTime
	-- time over ?
	if self.continuedtime <=0 then
		self:remove()
		return
	end
end

function deal()
	self.entity.minusdamage(self.damage)
end

function remove()
	self.entity.adddamage(self.damage)
end

