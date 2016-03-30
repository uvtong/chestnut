package.path = "./../cat/?.lua;" .. package.path

local frienddb = {}
	
local db
local cache
local function tupdate( tname , content , condition )
	
	assert( tname , content , condition )
	local ret = {}
	
	table.insert( ret , string.format("update %s SET " , tname ) )
	local index = 1
	for k , v in pairs( content ) do
		if index > 1 then
			table.insert( ret , ',' )
		end

		if type( v ) == "string" then
			table.insert( ret , string.format( "%s = '%s' " , k , v ) )
		else
			table.insert( ret , string.format( "%s = %s " , k , v ) )
		end	
		index = index + 1
	end
	
	table.insert( ret , " where " )
	local index = 1
	for k , v in pairs( condition ) do
		if index > 1 then
			table.insert( ret , " and " )
		end
		if type( v ) == "string" then
			table.insert( ret , string.format( "%s = '%s'" , k , v ) )
		else
			table.insert( ret , string.format( "%s = %s" , k , v ) )	
		end   
		index = index + 1
	end
	
	return table.concat( ret )
end

function frienddb:select_friendidlist( t )
	assert( t )
	local sql = string.format( "select friendid , recvtime , heartamount , sendtime  from u_friend where uid = %s and isdel = 0 " , t.uid )

	print( sql )
	local r = db:query( sql )
	print("select friend idlist over")
	return r
end	
			
function frienddb:select_loadavaliblefriendids( t )
	assert( t )
	
	local sql = string.format( "select csv_id from users where csv_id != %s and level > %s and level < %s and onlinetime >= %s" , t.uid , t.lowlevel , t.uplevel , t.lastday )
	print( sql )
	
	local r = db:query( sql )
	
	return r
end	
	
function frienddb:insert_newmsg( msg )
	assert( msg )

	local sql = string.format( "insert into  u_friendmsg ( fromid , toid , type , amount , propid , isread , csendtime , srecvtime , signtime ) values ( %s , %s , %s , %s , %s , %s , %s , %s , %s ) " , msg.fromid ,
								msg.toid , msg.type , msg.amount or 0 , msg.propid ,  msg.isread , msg.csendtime , msg.srecvtime , msg.signtime )

	print( sql )

	db:query( sql )
	print( 'insert a msg successfully in dbop')
end	
	
function frienddb:update_msg( msg )
	assert( msg )

	local sql = tupdate( msg.tname , msg.content , msg.condition )

	print( sql )

	db:query( sql )

	print( "update a msg successfully in frienddb" )
end
	
function frienddb:select_applied_idlist( t )
	assert( t )
    
	local sql = string.format( "select fromid , srecvtime from u_friendmsg where toid = %s and type = %s and isread = 0 " , t.uid , t.type )
	print( sql )
    
	local r = db:query( sql )
    
	return r
end	
	
function frienddb:select_apply_idlist( t )
	assert( t )
    
	local sql = string.format( "select toid from u_friendmsg where fromid = %s and type = %s and isread = 0 " , t.uid , t.type )
	print( sql )
	
	local r = db:query( sql )
	
    
	return r
end	
	
function frienddb:select_usermsg( t )
	assert( t )
	local sql = string.format( "select csv_id , uname , uviplevel , level , sign , ifonline , combat , onlinetime , iconid from users where csv_id = %s" , t.uid )
	print( sql )
    
	local r = db:query( sql )
	--assert( r )
	if not r then
		print( "r is nil in select_usermsg" )
	end
	return r
end	
	
function frienddb:insert_newfriend( t )
	assert( t )
    
	local sql = string.format( "insert into u_friend ( uid , friendid , isdel ) values ( %s , %s , %s )" , t.uid , t.friendid , 0 )
	print( sql )
    
	db:query( sql )
    
	print( "insert a friend successfully in frienddb")
    
end 
    
function frienddb:delete_friend( t )
	assert( t )
    
    local sql = tupdate( t.tname , t.content , t.condition )	
	print( sql )

	db:query( sql )

	print( "delete friend successfully" )
end 
	
function frienddb:select_getheart( t )
	assert( t )
	local sql = string.format( "select amount from u_friendmsg where toid = %s and srecvtime > %s and srecvtime < %s and isread = 1 " , t.uid ,  t.lowtime , t.hightime )
	print( sql )

	local r = db:query( sql )
	print( "get heart successfully in db_getheart" )

	return r
end 
    
function frienddb:update_friend( t )
	assert( t )
	local sql = tupdate( t.tname , t.content , t.condition )
	print( sql )

	db:query( sql )

	print( "update friend successfully in frienddb" )
end 

function frienddb.getvalue( d , c )
	db = d
	cache = c
	print("get db and cache successfully")
end	
	
return frienddb
