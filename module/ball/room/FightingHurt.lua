local sd = require "sharedata"
local float = require "float"
local string = require "string"
local cls = class("FightingHurt")

function cls:ctor(ctx, scene, ... )
	-- body
	self._ctx = ctx
	self._scene = scene
	
	local key =  string.format("%s:%d", "s_attribute", 1);
	local row = sd.query(key)
	
	self._playerbaseHurt = row.playerbaseHurt
	
end

function cls:OnHurt(enemyId, enemyvel, ... )
	-- body
	
	local enemyDataTable = sharedata.query(enemyId);

	local hurtValue =  enemyDataTable.baseHurt * enemyvel;

	local hp = self:get_baseHP() - hurtValue;

	if hp <0 then
		self:set_baseHP(0);
	else
		self:set_baseHP(hp);
	end

	if self:get_baseHP() >0 then
		self:get_ball():hurtToClient(self:get_baseHP(),hurtValue);
	else
		self:get_ball():dieToClient(true);
    end
end

-- update hurt and hp of data in the role
function cls:UpdateHurt(enemyId, enemyvel, ... )
	-- body
    self:OnHurt(enemyId,enemyvel);
end

function cls:get_baseHP( ... )
	-- body
	return self.baseHP
end

function cls:set_baseHP(value, ... )
	-- body
	self.baseHP = value;
end
function cls:get_baseHurt( ... )
	-- body
	return self.baseHurt;
end
function cls:set_baseHurt(value, ... )
	-- body
	self.baseHurt = value
end
function cls:get_baseMass( ... )
	-- body
	return self.baseMass;
end
function cls:set_baseMass(value, ... )
	-- body
	self.baseMass = value
end

function cls:get_ball( ... )
	-- body
	return self.ball
end
function cls:get_thrust( ... )
	-- body
	return self.thrust;
end
function cls:set_thrust(value, ... )
	-- body
	self.thrust = value
end
function cls:get_resistance( ... )
	-- body
	return self.resistance;
end
function cls:set_resistance(value, ... )
	-- body
	self.resistance = value
end
function cls:get_invincibleCount( ... )
	-- body
	return self.invincibleCount;
end
function cls:set_invincibleCount(value, ... )
	-- body
	self.invincibleCount = value
end
function cls:addinvinciblecount(value, ... )
	-- body
	local  invincibleCount = self:get_invincibleCount() + value;
	set_invincibleCount(invincibleCount);

	self.ball:sendInvincibleCountBuf(value,invincibleCount);
end

function cls:minusinvinciblecount(value, ... )
	-- body
	local  invincibleCount = self:get_invincibleCount()-value;
	set_invincibleCount(invincibleCount);
	self.ball:sendInvincibleCountBuf(-value,invincibleCount);
end
function cls:addaccelerate(value, ... )
	-- body
	local thrust = self:get_thrust()+value;
	set_thrust(thrust);
	self.ball:sendAccelerateBuf(value,thrust);
end
function cls:minusaccelerate(value, ... )
	-- body
	local thrust = self:get_thrust()-value;
	set_thrust(thrust);
	self.ball:sendAccelerateBuf(-value,thrust);
end
function cls:addhp(value, ... )
	-- body
	local  hp = self:get_baseHP()+value;
	set_baseHP(hp);
	self.ball:sendHPBuf(value,hp);
end
function cls:minushp(value, ... )
	-- body
	local  hp = self:get_baseHP()-value;
	set_baseHP(hp);
	self.ball:sendHPBuf(-value,hp);
end
function cls:minusdamage(value, ... )
	-- body
	local  hurt = self:get_baseHurt()-value;
	set_baseHurt(hurt);
	self.ball:sendDamageBuf(-value,hurt);
end
function cls:adddamage(value, ... )
	-- body
	local  hurt = self:get_baseHurt()+value;
	set_baseHurt(hurt);
	self.ball:sendDamageBuf(value,hurt);
end
return cls