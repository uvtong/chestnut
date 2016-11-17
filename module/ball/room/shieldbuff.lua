local math3d = require "math3d"
local buffbase = require "room.BuffBase"
local float = require "float"
local sd = require "sharedata"
local assert = assert
local cls = class("shieldbuff",buffbase)


function cls:ctor( id ,type )
	cls.super.ctor(self , id ,type ,entity)
	-- 
	local buffconfigkey = string.format("%s:%d",self.configname,buffid )
	self.continuedtime = sd.query(buffconfigkey).time
	self.invinciblecount = sd.query(buffconfigkey).invinciblecount
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
	self.entity.addinvinciblecount(self.invinciblecount)
end

function remove()
	self.entity.minusinvinciblecount(self.invinciblecount)
end

