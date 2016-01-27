--local dbop = require "dbop"
package.path = "./../cat/?.lua;" .. package.path
local skynet = require "skynet"
local emailbox = require "emailbox"

local emaildb = {}
local req = { ... }
local db
local cache

function emaildb:select_allusers()
	print("alluser db = " , db )
	local sql = string.format( "select * from users where ifonline = 0" )
	print( sql )
	local au = db:query( sql )
	print("select all users successfully\n")

	return au
end

function emaildb:select_allemails( tvals )
	
	local sql = string.format( "select * from email where uid = %d and isdel = 0" , tvals.uid ) --lack time compare
	local ret = db:query( sql )
	
	print("select successfully in emaildb:select\n")
	return ret
end	
	
function emaildb:insert_newemail( tvals )
	--local sql = dbop:tinsert( tvals )
	print( tvals.uid , tvals.item)

	
	local sql
	if tvals.item then
	for k , v in pairs( tvals.item ) do
		print( k , v )
	end
	 sql = string.format( "insert into email (uid , type , title , content , acctime , isread , isdel , itemsn1 , itemnum1 , itemsn2 , itemnum2 , itemsn3 , itemnum3 , itemsn4 , itemnum4 , itemsn5 , itemnum5 , iconid , isreward ) values ( %s , %s , '%s' , '%s' , %s , %s , %s , %s , %s , %s ,%s  ,%s ,%s ,%s ,%s ,%s ,%s ,%s ,%s , %s , '%s')",  
								tvals.uid , tvals.emailtype , tvals.title , tvals.content , tvals.content , tvals.acctime , 0 , 0 , tvals.item.itemsn1 or 0, tvals.item.itemnum1 or 0 , tvals.item.itemsn2 or 0, tvals.item.itemnum2 or 0 , tvals.item.itemsn3 or 0, tvals.item.itemnum3 or 0 ,tvals.item.itemsn4 or 0 , tvals.item.itemnum4 or 0,
								tvals.item.itemsn5 or 0 , tvals.item.itemnum5 or 0 , tvals.iconid , 0 )
	else
		sql = string.format( "insert into email ( uid , type , title , content , acctime , isread , isdel , iconid , isreward ) values ( %s , %s , '%s' , '%s' , %s , %s , %s , %s , %s )",  
								 tvals.uid , tvals.emailtype , tvals.title , tvals.content ,tvals.acctime , 0 , 0 , tvals.iconid , 0 )
	end

	print( sql )
	db:query( sql )

	print( "emaildb:insert finished\n" )
end	
	
function emaildb:update_reademail( tvals )
	--local sql = dbop:tupdate( tvals )
	print( tvals.uid , tvals.emailid )
	local sql = string.format( "update email set isread = 1 where uid = %d and id = %d " , tvals.uid , tvals.emailid )
	
	print( "sql in email:update is " .. sql )
	local ok = db:query( sql )
	if not ok then
		print("insert a email failed\n")
	end
	print("query successfully in emaildb:update\n")
end	
	
function emaildb:update_delemail( tvals )
	assert( tvals )

	local sql = string.format( "update email set isdel = 1 where uid = %d and id = %d " , tvals.uid , tvals.emailid )
	
	db:query( sql )

	print("query successfully in emaildb:delemail\n")
end	

function emaildb:update_getreward( tvals )
	assert( tvals )

	local sql = string.format( "update email set isreward = 1 where uid = %d and id = %d " , tvals.uid , tvals.emailid )
	
	db:query( sql )

	print("query successfully in emaildb:update_getreward\n")
end


function emaildb:insert_offlineemail( tvals )
	local au = emaildb:select_allusers()
	if au == nil then
		print( "au is nil" )
	end
	--local e = emailbox:_create( tvals )
	 		
		for k , v in pairs( au ) do
			print( k , v.id )
			tvals.uid = v.id
			tvals.acctime = os.time()
	 		emaildb:insert_newemail( tvals )
	 		--db.query( "select id from users where ifonline = 0")
	 		print("insert successfully\n")
	 	end	
end

function emaildb.getvalue( v1 , v2 )
	db = v1
	cache = v2
end 

return emaildb
