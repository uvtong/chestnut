local math3d = require "math3d"
local float = require "float"
local assert = assert
local sd = require "sharedata"

local FightingHurt = require "room.FightingHurt"



local _buffbase = require "room.BuffBase"
local _addacceleratebuff = require "room.addacceleratebuff"
local _addbloodbuff = require "room.addbloodbuff"
local _adddamagebuff = require "room.adddamagebuff"
local _minusacceleratebuff = require "room.minusacceleratebuff"
local _minusbloodbuff = require "room.minusbloodbuff"
local _minusdamagebuff = require "room.minusdamage"
local _shieidbuff = require "room.shieldbuff"


local cls = class("ball")



function cls:addbuff( type , deltaTime )
	if self.buff == nil then
		if type == bufftype.addbloodbuff then
			self.buff = addbloodbuff.new(id , type ,entity)
		elseif type == bufftype.shieldbuff then
			self.buff = _shieidbuff.new(id , type ,entity)
		elseif type == bufftype.addacceleratebuff then
			self.buff = _addacceleratebuff.new(id , type ,entity)
		elseif type == bufftype.adddamagebuff then
			self.buff = _adddamagebuff.new(id , type ,entity)
		elseif type == bufftype.minusacceleratebuff then
			self.buff = _minusacceleratebuff.new(id , type ,entity)
		elseif type == bufftype.minusbloodbuff then
			self.buff = minusbloodbuff.new(id , type ,entity)
		elseif type == bufftype.minusdamagebuff then
			self.buff = minusdamagebuff.new(id , type ,entity)
		end
	else
		if self.buff.type == type then

		else
			self.buff:remove()
			self.buff = nil
			if type == bufftype.addbloodbuff then
				self.buff = addbloodbuff.new(id , type ,entity)
			elseif type == bufftype.shieldbuff then
				self.buff = _shieidbuff.new(id , type ,entity)
			elseif type == bufftype.addacceleratebuff then
				self.buff = _addacceleratebuff.new(id , type ,entity)
			elseif type == bufftype.adddamagebuff then
				self.buff = _adddamagebuff.new(id , type ,entity)
			elseif type == bufftype.minusacceleratebuff then
				self.buff = _minusacceleratebuff.new(id , type ,entity)
			elseif type == bufftype.minusbloodbuff then
				self.buff = minusbloodbuff.new(id , type ,entity)
			elseif type == bufftype.minusdamagebuff then
				self.buff = minusdamagebuff.new(id , type ,entity)
			end
		end
	end
end

function cls:updatebuff()
	if self.buff ~= nil then
		self.buff:update()
	end
end

function cls:ctor(id, session, scene, radis, length, width, height, pos, dir, vel, accspeed,m ,thrust,resistance,... )
	-- body
	assert(id and scene and session)
	self._id = id
	self._session = session
	self._scene = scene
	self._idx = 0
	self._player = nil

	-- data
	self._radis = radis
	self._length = length
	self._width = width
	self._height = height
	
	local key =  string.format("%s:%d", "s_attribute", 1);
	local row = sd.query(key)

	self._hp = row.baseHP
	self._pos = pos
	self._dir = dir
	self._vel = row.baseVel
	self._mass = row.baseMass
	self._thrust = 0
	self._resistance = 0
	self._accspeed = 0

	self:cal_aabb()
	--
	self.buff = nil
end

function cls:cal_aabb( ... )
	-- body
	local x, y, z = self._pos:unpack()
	local nx = x - (self._length / 2)
	local ny = y - (self._width / 2)
	local nz = z - (self._height / 2)
	local xx = x + (self._length / 2)
	local xy = y + (self._width / 2)
	local xz = z + (self._height / 2)
	local min = math3d.vector3(nx, ny, nz)
	local max = math3d.vector3(xx, xy, xz)
	self._aabb = math3d.aabb(min, max)
end

function cls:get_id( ... )
	-- body
	return self._id
end

function cls:get_session( ... )
	-- body
	return self._session
end

function cls:set_session(value, ... )
	-- body
	self._session = value
end

function cls:set_idx(idx, ... )
	-- body
	self._idx = idx
end

function cls:get_idx( ... )
	-- body
	return self._idx
end

function cls:set_player(player, ... )
	-- body
	self._player = player
end

function cls:get_player( ... )
	-- body
	return self._player
end

function cls:get_radis( ... )
 	-- body
 	return self._radis
end

function cls:get_length( ... )
	-- body
	return self._length
end

function cls:get_width( ... )
	-- body
	return self._width
end

function cls:get_height( ... )
	-- body
	return self._height
end

function cls:get_dir( ... )
	-- body
	return self._dir
end

function cls:set_dir(copy, ... )
	-- body
	self._dir:copy(copy)
end

function cls:get_vel( ... )
	-- body
	return self._vel
end

function cls:set_vel(value, ... )
	-- body
	self._vel = value
end

function cls:set_hp(v, ... )
	-- body
	self._hp = v
end

function cls:get_hp( ... )
	-- body
	return self._hp
end

function cls:get_accspeed( ... )
	-- body
	return self._accspeed
end

function cls:set_accspeed( value,... )
	-- body
	self._accspeed = value
end

function cls:get_mass( ... )
	-- body
	return self._mass
end

function cls:set_mass(value ,... )
	-- body
	self._mass = value
end

function cls:get_thrust( ... )
	-- body
	return self._thrust
end

function cls:set_thrust(value ,... )
	-- body
	self._thrust = value;
end

function cls:get_resistance( ... )
	-- body
	return self._resistance
end

function cls:set_resistance(value ,... )
	-- body
	self._resistance = value;
end

function cls:get_pos( ... )
	-- body
	return self._pos
end

function cls:get_aabb( ... )
	-- body
	return self._aabb
end

function cls:move_by(vec3, ... )
	-- body
	local x1, y1, z1 = self._pos:unpack()
	local x2, y2, z2 = vec3:unpack()
	local x = x1 + x2
	local y = y1 + y2
	local z = z1 + z2
	self._pos:pack(x, y, z)
	
	local t = math3d.matrix()
	t:trans(x2, y2, z2)
	self._aabb:transform(t)
end

function cls:pack_pos( ... )
	-- body
	local x, y, z = self._pos:unpack()
	local res = string.pack("<fff", x, y, z)
	return res
end

function cls:pack_sproto_px( ... )
	-- body
	local x, y, z = self._pos:unpack()
	return float.encode(x)
end

function cls:pack_sproto_py( ... )
	-- body
	local x, y, z = self._pos:unpack()
	return float.encode(y)
end

function cls:pack_sproto_pz( ... )
	-- body
	local x, y, z = self._pos:unpack()
	return float.encode(z)
end

function cls:pack_dir( ... )
	-- body
	local x, y, z = self._dir:unpack()
	local res = string.pack("<fff", x, y, z)
	return res
end

function cls:pack_sproto_dx( ... )
	-- body
	local x, y, z = self._dir:unpack()
	return float.encode(x)
end

function cls:pack_sproto_dy( ... )
	-- body
	local x, y, z = self._dir:unpack()
	return float.encode(y)
end

function cls:pack_sproto_dz( ... )
	-- body
	local x, y, z = self._dir:unpack()
	return float.encode(z)
end

function cls:pack_vel( ... )
	-- body
	local res = string.pack("<f", self._vel)
	return res
end

function cls:pack_sproto_vel( ... )
	-- body
	return float.encode(self._vel)
end



-- send hurt data to client when is hurting with role
function  cls:hurtToClient(currHP,hurtValue, ... )
	-- body
	local hurtTable = { session = self:get_session(),ballid = self:get_id(),currHp = currHp,hurtvalue = hurtvalue }
	local agent = self._player:get_agent()
	agent.post.hurt(hurtTable);
end
-- send die state to client when is die with role
function cls:dieToClient(isdie, ... )
	-- body
	--local dieTable = {session = self:get_session(),ballid = self:get_id()}
	local agent = self._player:get_agent();
	agent.post.die({session =self:get_session(), ballid = ball:get_id()})	
end
function cls:sendHPBuf(value,hp, ... )
	-- body
	local  buff = {session =self:get_session(),ballid = self:get_id(),valueAdded=value,currBuffData = thrust,buffType = 1}
	agent.post.SendBuff(buff);
end
function cls:sendDamageBuf(value,hurt, ... )
	-- body
	local  buff = {session =self:get_session(),ballid = self:get_id(),valueAdded=value,currBuffData = hurt,buffType = 2}
	agent.post.SendBuff(buff);
end
function cls:sendInvincibleCountBuf(value,invincibleCount, ... )
	-- body
	local  buff = {session =self:get_session(),ballid = self:get_id(),valueAdded=value,currBuffData = invincibleCount,buffType = 3}
	agent.post.SendBuff(buff);
end

function cls:sendAccelerateBuf(value,thrust, ... )
	-- body
	local  buff = {session =self:get_session(),ballid = self:get_id(),valueAdded=value,currBuffData = thrust,buffType = 4}
	agent.post.SendBuff(buff);
end




return cls
