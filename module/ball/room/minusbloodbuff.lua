local math3d = require "math3d"
local buffbase = require "room.BuffBase"
local float = require "float"
local sd = require "sharedata"
local assert = assert
local cls = class("minusbloodbuff",buffbase)

local oncetime = 1

function cls:ctor( id ,type , entity)
	cls.super.ctor(self , id ,type ,entity)
	-- 
	local buffconfigkey = string.format("%s:%d",self.configname,buffid )
	self.continuedtime = sd.query(buffconfigkey).time
	self.hp = sd.query(buffconfigkey).hpminus
end

function cls:update( deltaTime )
	self.continuedtime = self.continuedtime - deltaTime
	-- time over ?
	if self.continuedtime <=0 then
		return
	end

	--add blood 1miao
	oncetime = oncetime - deltaTime
	if oncetime <=0 then 
		self:deal()
		oncetime = 1
	end
end

function deal()
	self.entity.minushp( self.hp )
end

