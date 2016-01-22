package.path = "./../cat/?.lua;" .. package.path
local skynet = require "skynet"
local mysql = require "mysql"
local redis = require "redis"
local csvreader = require "csvReader"
local edb = require("edb", mysql, redis)

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

	return condition and table.concat( ret ) .. "where" .. condition or table.concat( ret ) 
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
	
	return ( condition and table.concat( ret ) .. " where " .. condition or table.concat( ret ))
end

local 
function delete( tvals )
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

function QUERY:signup( t )
	-- body
	local sql
	sql = string.format("select * from users where uaccount = '%s' and upassword = '%s'", t.uaccount, t.upassword)
	local r = db:query(sql)
	if #r > 0 then
		return false
	else
		-- insert user
		sql = string.format("insert into users (uname, uaccount, upassword, uviplevel, uexp, config_music, confg_sound, avatar, sign, c_role_id) values (\"\", \"%s\", \"%s\", 0, 0, 0, 0, 0, \"\", 0)", t.account, t.password)
		r = db:query(sql)
		-- insert role
		local role = csvreader.getcont("role")
		for i=1,2 do
			sql = string.format("insert into role (nickname, user_id, wake_level, level, combat, defense, critical_hit, skill, c_equipment, c_dress, c_kungfu) values (\"\", %d, %d, %d, %d, %d, %d, %d, %d, %d, %d)", r[0].id, 0, level[0].level, level[0].combat, level[0].defense, level[0].critical_hit, level[0].skill, 0, 0, 0)
			db:query(sql)
		end
		-- insert props. all table
		sql = stirng.format("select name from prop")
		r = db:query(sql)
		for k,v in pairs(r) do
			sql = string.format("insert into props (user_id, name, num) values (user_id, \"%s\", 0)", v.name)
			db:query(sql)
		end
		
		-- inset equipment
		-- insert dress
		-- inset kungfu
		return true
	end
end

function QUERY:insert_skill( ... )
	-- body
	local t = { ... }
	sql = tinsert( t )
	db:query( sql )
end	
	
function QUERY:select_users( t )
	-- body
	local sql = string.format("select * from users where uaccount = '%s' and upassword = '%s'", t.uaccount, t.upassword)
	local r = db:query(sql)
	--cache:get()
	print("select_users is called\n")
	for k , v in pairs( r ) do
		print( k , v )
		if type( v ) == "table" then
			for sk , sv in pairs( v ) do
				print( sk , sv )
			end
		end
	end
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

function QUERY:select_roles_by_userid( user_id )
	-- body
	local sql = string.format("select * from role where user_id = %d", user_id)
	local r = db:query(sql)
	return r
end

function QUERY:select_prop( user_id, type)
	-- body
	if type == nil then
		local sql = string.format("select * from props where user_id = %d", user_id)
		local r = db:query(sql)
		return r
	else
		local sql = string.format("select * from props where user_id = %d, name = \"%s\"", name)
		local r = db:query(sql)
		return r
	end
end

-- 
function QUERY:update_prop( user_id, type, num )
	-- body
	-- local sql = string.format("update props set num = %d where user_id = %d and type = %d", num, user_id, type)
	-- local r = db:query(sql)
	-- return r
end

function QUERY:select_all_achi( type, min, max )
	-- body
	local sql = string.format("select * from achievement where type = \"%s\" level > %d and level < %d", type, min, max)
	local r = db:query(sql)
	return r
end

function QUERY:select_achi( user_id )
	-- body
	local sql = string.format("select * from achievements where user_id = %d", user_id)
	local r = db:query(sql)
	return r
end

function QUERY:update_achi( user_id, csv_id, finished )
	assert(finished <= 100)
	local sql = string.format("update achievements set finished = %d where csv_id = %d", csv_id)
	local r = db:query(sql)
	return r
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
	if f then
		return f(QUERY, ... )
	else
		local f = assert(edb[subcmd])
		return f(edb, ... )
	end
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

