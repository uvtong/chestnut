local skynet = require "skynet"
local mysql = require "mysql"
local redis = require "redis"

local cache 
local x = 1
local db

local
function tinsert( tvals ) --{ tname = "" , cont = { {colname = val} ,  ... } }
	if nil == tvals then 
		print( "empty argtable\n" )
		return nil
	end

	local tname = tvals["tname"]
	if nil == tname then
		print( "No tname\n" )
		return nil
	end

	local cont = tvals["content"]
	if nil == cont then
		print( "No Cont\n" )
		return nil
	end

	local ret = { key = "" , val = "" }

	ret["key"] = string.format( "insert into %s (" , tname ) 
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
	ret["key"] = string.sub( ret["key"] , 1 , -2)
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

	return condition and table.concat( ret ) or table.concat( ret ) .. "where" .. condition
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
		return nil
	end
	
	local condition = tvals["condition"]
	if nil == condition then
		print( "No condition\n" )
		return nil
	end
	
	return string.format( "delete from %s where " , tname ) .. conditon 
end	
	
--[[local	
function get_from_redis()
	local result = {}
	local resultset_id = md5( strsql ) --待定 
	local redis_row_set_key = "resultset" .. ":" .. resultset_id
	local mysqldb
	local mysqlres

	local redisdb = redis.connect( redisconf )
	assert( redisdb == nil )
		
	local redisres = redis:smembers( redis_row_set_key )
	if nil == redisres then
		redis.disconnect()

		mysqldb = mysql.connect( mysqlconf )
		assert( nil == mysqldb )
		
		mysqlres = mysqldb:query( strsql )
		redis_row_set_key = mysql2redis( mysqlres , resultset_id )

		redisdb = redis.connect( redisconf )
		assert( nil == redisdb )

		redisres = redisdb:smembers( redis_row_set_key )
	end
	-- TODO
end

local 
function mysql2redis( tmysqlres , nresultset_id )
	if nil == mysqlres then
		print("no data in mysql")
		return
	end

	local prefix = "cache.string:" .. resultset_id .. ":"
	local num_row = 1


end
--]]
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
	print( "mysql server is connected\n" )
	return db
end



local
function disconnect_mysql( db )	local redis_row_set_key
	db:disconnect()
end

local
conf = 
{
	host = "127.0.0.1",
	port = 6379,
	db = 0
}

local
function watching()
	local w = redis.watch( conf )
	w:subscribe "foo"
	w:psubscribe "hello.*"
	
	while true do
		print( "watch" , w:message() )
	end
end

local
function connect_redis( ... )
	--skynet.fork( watching )
	local db = redis.connect( conf )
	print( "redis is connect\n" )
	return db
end

local
function disconnect_redis( cache )
	cache:disconnect()
end

local CMD = {}

function CMD:disconnect_redis( ... )
	disconnect_redis( cache )
end

function CMD:command( ... )
	local key = tostring( ... )
	
	local result = cache:hmget( key )
	if type( result ) == "table" then
		for k , v in pairs( result ) do
				
		end	
	end
	print( "unknown type\n" )
	return
end

function CMD:disconnect_mysql( ... )
	disconnect_mysql( db )
end

local 
function fetchvalues()
	local id = cache:hget( "skills" , "abc" )
	print( type(id) )
	
	local result = cache:hmget( string.format( "abc:%s" , id ) , "id" , "sklname" , "skldsb" , "sklactive" , "playtime")
	if type( result ) == "table" then
		for k , v in pairs( result ) do
			print( string.format("%s , %s " , k , v) , type( v ) )			
		end	
	end
	--print( "unknown type\n" )
	print( type( "2.345" + 0 ) )
	return	
end	
	
skynet.start( function () 
	skynet.dispatch( "lua" , function( _, _, cmd, ... )
		local f = assert( CMD[ cmd ] )
		skynet.ret( skynet.pack( f( ... ) ) )
	end	
		)
		
		db = connect_mysql()
		
		tvals = nil
		tvals = { tname = "skill" , condition = "id = 1" }
		sql = tselect( tvals )
		print( sql )
		if nil == sql then
			print( "select failed\n" )
			return		
		end
		sqlresult = db:query( sql )
		local redisval = {}
		if sqlresult ~= nil then
			for k, v in pairs( sqlresult ) do
				print( k , v )
				index = 1
				for sk , sv in pairs( v ) do
					
					redisval[2 * index - 1] = tostring(sk)
					redisval[ 2 * index ] = tostring(sv)
					index = index + 1
				end
			end
		end
		
		cache = connect_redis()
		str = string.format( "%s:%s" , sqlresult[1]["sklname"] , sqlresult[1]["id"] )
			
		cache:hmset( str , table.unpack( redisval ) )
		cache:hset( "skills",  sqlresult[1]["sklname"], sqlresult[1]["id"] )
		--fetchvalues()
		print("stored in hash successfully\n")
	end	
	)	
