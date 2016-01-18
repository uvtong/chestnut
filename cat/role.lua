--dbop = require "dbop"
redis = require "redis"
mysql = require "mysql"

rolemgr = {}
rolemgr._data = {}
	
function rolemgr:create( tvals )	
	if nil == tvals then
		print( "tvals is empty\n" )
		return nil
	end

	local r = role.new()
	r.setid( tvals[id])
	r.setnickname( tvals[nickname] )
	r.setwake_level( tvals[wake_level] )
	r.setlevel( tvals[level] )
	r.setcombat( tvals[combat] )
	r.setdefense( tvals[defense] )
	r.setcritical_bit( tvals[critical_hit] )
	r.setskill( tvals[skill] )
	r.setc_equipment( tvals[c_equipment] )
	r.setc_dress( tvals[c_dress] )
	r.setc_kungfu( tvals[ c_kungfu] )

	(rolemgr._data) [ tostring(r._id) ] = r 
end

function rolemgr:find( roleid )
	return rolemgr._data[ roleid ]
end	
	
function rolemgr:remove( roleid )
	rolemgr._data[ roleid ] = nil
end	
	
role = { _id , _nickname , _user_id , _wake_level , _level , _combat , _defense , _critical_hit , _skill , _c_equipment , _c_dress , _c_kungfu }
	
function role.new( ... )
	local t = {}
	setmetatable( t , { __index = role } ) 
	
	return t
end	
	
function role:wakeup( ... )

end	
	
function role:levelup( ... )

end	
	
function role:getMsg( tvals )
	
end	
	
function role:getDataFromdb( tvals )
	local sql = tselect( tvals )
	if nil == sql then
		print( "create sql failed!\n" )
		return nil
	end

	local sqlresult = db:query( sql )
	if nil == sqlresult then
		print( string.format(" '%s' returns no result\n" , sql ) )
		return nil
	end
	return sqlresult
end	
	
--local 	
--function role:getid()
--	return self._id
--end	


function role:setid( id )
		self._id = id 
	--  body
end


function role:getnickname()
	return self._nickname
	-- body
end


function role:setnickname( nickname )
	self._nickname = nickname
end


function role:getwake_level()
	return self._wake_level
end

function role:setwake_level( wake_level )
	self._wake_level = wake_level
end


function role:getlevel()
	return self._level
end


function role:setlevel( level )
	self._level = level
end


function role:getcombat()
	return self._combat
end


function role:setcombat( combat )
	self._combat = combat
end

 
function role:getdefense()
	return self._defence;
end


function role:setdefense( defense )
	self._defense = defense
end

 
function role:getcritical_hit()
	return self._critical_hit
end


function role:setcritical_bit( critical_bit )
	self._critical_bit = critical_bit
end


function role:getskill()
	return self._skill
end


function role:setskill( skill )
	self._skill = skill
end
	

function role:getc_equipment()
	return self._c_equipment
end
	
 
function role:setc_equipment( equipment )
	self._c_equipment = equipment
end
	

function role:getc_dress()
	return self._c_dress
end
	

function role:setc_dress( dress )
	self._c_dress = dress
end


function role:getc_kungfu()
	return self._c_kungfu
end


function role:setc_kungfu( kungfu )
	self._kungfu = kungfu
end
