local skynet = require "skynet"
local mysql = require "mysql"
local redis = require "redis"
 

local db
local cache 

local
function tinsert( tvals ) --{ tname = "" , cont = { {colname = val} ,  ... } }
	if nil == sqltable then 
		print( "empty argtable\n" )
		return nil
	end

	local tname = sqltable["tname"]
	if nil == tname then
		print( "No tname\n" )
		return nil
	end

	local cont = sqltable["cont"]
	if nil == cont then
		print( "No Cont\n" )
		return nil
	end

	local ret = { key = "" , val = "" }

	ret["key"] = string.format( "insert into '%s' (" , tname ) 
	for k , v in ipairs( cont ) do
		for subk , subv in pairs( v ) do
			ret["key"] = ret["key"] .. subk .. ','
			if type (subv ) == "string" then
				ret["val"] = ret["val"] .. ',' .. string.format( "'%s'" , subv )
			else
				ret["val"] = ret["val"] .. ',' .. subv
			end
		end
	end

	--去掉 ret["key"] 的最后一个 ','
	ret["key"] = string.sub( ret["key"] , 1 , -1 )
	ret["val"] = string.sub( ret["val"] , 2 )
	ret["key"] = ret["key"] .. ") values ("
	ret["val"] = ret["val"] .. ")"

	return ret["key"] .. ret["val"]
end
	
local 
function tselect( tvals )
	if nil == tvals then
		print( "tvals is empty" )
		return
	end
	
	local tname = tvals["tname"]
	if nil == tname then
		print("tname is empty\n")
		return nil
	end
	
	local content = tvals["content"]
	
	local condition = tvals["condition"]
	
	local ret = {}
	if nil == content then
		table.insert( ret , string.format( "select * from %s " , tname ) )
	else
		table.insert( ret , string.format( "select " ))
		for k , v in ipairs( content ) do
			if k > 1 then
				table.insert( ret , "," )
			end
			
			table.insert( ret , string.format( "%s" , v ) )
		end
		table.insert( ret , string.format( " from %s " , tname ) )
	end

	return condition and table.concat( ret ) or table.concat( ret ) .. where .. condition
end 
	
local
function tupdate( tvals )
	if nil == tvals then
		print( "No vals in tvals \n" )
		return nil
	end

	local tname = tvals["tname"]
	if nil == tname then
		print("No tname\n")
		return nil
	end
	
	local content = tvals["content"]
	if nil == content then
		print("No content\n")
		return nil
	end

	local condition = tvals["condition"]

	local ret = {}
	
	table.insert( ret , string.format("update %s SET " , tname ) )
	for k , v in ipairs( content ) do
		if k > 1 then
			table.insert( ret , ',' )
		end

		for subk , subv in pairs( v ) do
			if type( subv ) == "string" then
				table.insert( ret , string.format( "%s = '%s'" , subk , subv ) )
			else
				table.insert( ret , string.format( "%s = %s" , subk , subv ) )
			end	
		end
	end
	
	return ( condition and table.concat( ret ) or table.concat( ret ) .. " where " .. condition )
end

local 
function tdelete( tvals )
	if nil == tvals then 
		print( "tvals is empty\n" )
		return nil
	end 
	
	local tname = tvals["tname"]
	if nil == tname then
		print( "No tname\n" )
	skynet.fork( watching )	return nil
	end
	
	local condition = tvals["condition"]
	if nil == condition then
		print( "No condition\n" )
		return nil
	end
	
	return string.format( "delete from %s where " , tname ) .. conditon 
end	
	
local
function connect_mysql( ... )
	local function on_connect( db )
		db:query( "set charset utf8" )
	end
	
	local db = mysql.connect( { 
		host = "192.168.1.116",
		port = 3306,
		database = "project",
		user = "root",
		password = "yulei",
		max_packet_size = 1024 * 1024,
		on_connect = on_connect,
	} )

	return db
end

--[[local
function watching()
	local w = redis.watch( conf )
	w:subscribe "foo"
	w:psubscribe "hello.*"
	
	while true do
		print( "watch" , w:message() )
	end
end	
	--]]
local
function connect_redis( conf )
	--skynet.fork( watching )
	local cache = redis.connect( conf )	
	return cache
end	
	
local QUERY = {}
	
function QUERY:insert_skill( ... )
	-- body
	local t = { ... }
	sql = tinsert( t )
	db:query( sql )
end	
	
function QUERY:select_users( tvals )
	-- body
	print("calling select _ users\n")
	local sql = tselect( tvals ) --string.format("select * from users where uaccount = %s and upassword = %s", account, password)
	print( sql )
	local r = db:query(sql)
	--cache:get()
	print("select_users is called\n")
	print( r )
	return r
end 	
	
function QUERY:select_rolebyroleid( )
end	
	
function QUERY:select_rolebyuid( tvals )
	local sql = tselect( tvals ) --string.format( "select * from role where uid = %s" , uid )
	local r = db:query( sql )

	return r
end	
	
function QUERY:update_roleby_roleid( tvals )
	local sql = tupdate( tvals )
	local r = db:query( sql )

	return true
end	
	
function QUERY:select_equipment()
	
end	

function QUERY:abc( ... )
	-- body
	print(tostring(...))
	return "hello"
end
		
local CMD = {}
	
function CMD:disconnect_redis( ... )
	cache:disconnect()
end	
	
function CMD:disconnect_mysql( ... )
	db:disconnect()
end	
	
function CMD:command( subcmd, ... )
	print(subcmd, type(subcmd))
	local f = assert(QUERY[subcmd])
	return f(QUERY, ... )
end


skynet.start( function () 
	skynet.dispatch( "lua" , function( _, _, cmd, subcmd, ... )
		if cmd == "command" then
			local f = assert( CMD[ cmd ] )
			skynet.ret( skynet.pack( f(CMD, subcmd, ... ) ) )
		else
			local f = assert( CMD[ cmd ] )
			skynet.ret( skynet.pack( f( subcmd, ... ) ) )
		end
	end)

	db = connect_mysql()
	local conf = {
		host = "192.168.1.116",
		port = 6379,
		db = 0
	}
	cache = connect_redis( conf )
end)

