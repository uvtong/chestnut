package.path = "./../cat/?.lua;" .. package.path
local dbop = require "dbop"

local drawdb = {}

local db 
local cache

function drawdb:select_dioment_or_heart_num( t )
	assert( t )

	local sql = string.format( "select num from u_prop where user_id = %s and csv_id = %s" , t.uid , t.csvid )
	print( sql )

	local t = db:query( sql )

	if t[ 1 ] then
		print( t[1].num )
		return t[ 1 ].num
	else
		print( "not find num" )
		return nil
	end
end

function drawdb:update_props( t )
	assert( t )

	local sql = dbop.tupdate( t.tname , t.content , t.condition )
	print( sql )

	db:query( sql )

	print( "update props over" )
end	
	
function drawdb:select_frienddraw( t )
	assert( t )

	--local sql = string.format( "select srecvtime from u_draw where srecvtime = ( select max( srecvtime ) from u_draw where uid = %s and drawtype = %s )" , t.uid , t.drawtype )
	local sql = string.format( " select * from u_draw where srecvtime = ( select srecvtime from  u_draw where uid = %s and drawtype = %s ORDER BY srecvtime DESC  limit 1 )" ,  t.uid , t.drawtype )
	print( sql )
	local r = db:query( sql )
	if not r[1] then
		print( "nil" )
		return {}
	else	
		print( "r length is " .. #r , r[1].srecvtime)
		return r[1].srecvtime
	end
end	
	
function drawdb:select_onetimedraw( t ) -- 0 free , 1 not free
	--local sql = string.format( "select srecvtime , drawnum from u_draw where srecvtime = 
		--( select max( srecvtime ) from u_draw where uid = %s and drawtype = %s and iffree = 0 )" , t.uid , t.drawtype )

	local sql = string.format( " select * from u_draw where srecvtime = ( select srecvtime from  u_draw where uid = %s and drawtype = %s and iffree = 0 ORDER BY srecvtime DESC  limit 1 )" ,  t.uid , t.drawtype )
	print( sql )
	local r = db:query( sql )
	if not r[1] then
		return {}
	else	
		print( "r length is " .. #r , r[1].srecvtime)
		return r[1].srecvtime
	end
end 
	
function drawdb:insert_drawmsg( t )
	assert( t )

	local sql = string.format( "insert into u_draw ( uid , drawtype , cdrawtime , srecvtime , drawnum , iffree ) values ( %s , %s , %s , %s , %s , %s )", t.uid , t.drawtype , t.cdrawtime or 0 , t.srecvtime , t.drawnum , t.iffree )
	print( sql )
	db:query( sql )

	print( "insert drawmsg successfully in db" )
end	

function drawdb.getvalue( d , c )
	assert( d and c )
	
	db = d
	cache = c

	print( "get value successfully" )
end

return drawdb