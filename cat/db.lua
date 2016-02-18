package.path = "./../cat/?.lua;" .. package.path
local skynet = require "skynet"
local mysql = require "mysql"
local redis = require "redis"
local csvreader = require "csvReader"
local util = require "util"
local dbop = require "dbop"
local emaildb = require "emaildb"
local frienddb = require "frienddb"
local drawdb = require "drawdb"

local db
local cache 

local function dump(obj)
    local getIndent, quoteStr, wrapKey, wrapVal, dumpObj
    getIndent = function(level)
        return string.rep("\t", level)
    end
    quoteStr = function(str)
        return '"' .. string.gsub(str, '"', '\\"') .. '"'
    end
    wrapKey = function(val)
        if type(val) == "number" then
            return "[" .. val .. "]"
        elseif type(val) == "string" then
            return "[" .. quoteStr(val) .. "]"
        else
            return "[" .. tostring(val) .. "]"
        end
    end
    wrapVal = function(val, level)
        if type(val) == "table" then
            return dumpObj(val, level)
        elseif type(val) == "number" then
            return val
        elseif type(val) == "string" then
            return quoteStr(val)
        else
            return tostring(val)
        end
    end
    dumpObj = function(obj, level)
        if type(obj) ~= "table" then
            return wrapVal(obj)
        end
        level = level + 1
        local tokens = {}
        tokens[#tokens + 1] = "{"
        for k, v in pairs(obj) do
            tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
        end
        tokens[#tokens + 1] = getIndent(level - 1) .. "}"
        return table.concat(tokens, "\n")
    end
    return dumpObj(obj, 0)
end
		
local QUERY = {}

function QUERY:query( sql )
	-- body
	return db:query(sql)
end

function QUERY:select( table_name, condition, columns)
	-- body
	local sql = util.select(table_name, condition, columns)
	-- return db:query(sql, condition)
	return db:query(sql)
end

function QUERY:update( table_name, condition, columns )
	-- body
	local sql = util.update(table_name, condition, columns)
	db:query( sql )
end

function QUERY:insert( table_name, columns )
	-- body
	local sql = util.insert(table_name, columns)
	db:query(sql)
end

function QUERY:signup( t )
	-- body
	local sql = util.insert("users", { uaccount = t.uaccount, upassword = t.upassword, uviplevel = 1, config_music = 0, confg_sound = 0, c_role_id = 1, })
	local r = db:query(sql)

	dump(r)
	sql = util.insert("roles", { user_id = 1})
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
	
function QUERY:update_onlinestate( t )
	assert( t )

	local sql = dbop.tupdate( t.tname , t.content , t.condition )
	print( sql )

	db:query( sql )
	print( "update online state over in db" )
end	
	
function QUERY:insert_skill( ... )
	-- body
	local t = { ... }
	sql = tinsert( t )
	db:query( sql )
end	
	
function QUERY:select_user( condition, columns )
	-- body
	-- userid, uaccount, upassword
	local sql = util.select("users", condition, columns)
	local r = db:query(sql, condition)
	--cache:get()
	return r[1]
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

function QUERY:select_roles( condition )
	-- body
	local sql = util.select("roles", condition)
	return db:query(sql)
end

function QUERY:select_props( condition )
	-- body
	local sql = util.select("props", condition)
	return db:query(sql)
end

function QUERY:update_prop( user_id, csv_id, num )
	local sql = util.update("props", {{ user_id = user_id, csv_id = csv_id}}, { num = num })
	db:query(sql)
end

function QUERY:select_all_achi( type, min, max )
	-- body
	local sql = string.format("select * from achievement where type = \"%s\" level > %d and level < %d", type, min, max)
	local r = db:query(sql)
	return r
end

function QUERY:select_achievements( condition )
	-- body
	local sql = util.select("achievements", condition)
	return db:query(sql)
end	
	
function QUERY:update_achi( user_id, csv_id, finished )
	assert(finished <= 100)
	local sql = string.format("update achievements set finished = %d where csv_id = %d", csv_id)
	local r = db:query(sql)
	return r
end	

function QUERY:insert_prop( user_id, csv_id, num )
	-- body
	local columns = {user_id = user_id, csv_id = csv_id, num = num}
	local sql = util.insert("props", columns)
	db:query(sql)
end

function QUERY:getrandomval( drawtype )
	assert( drawtype )
	local sql3 = string.format( "select step from randomval" )
	local r = db:query( sql3 )
	if #r == 0 then
		print( "r == 3 " )
	end
		
	local step = r[drawtype].step

	local sql1 = string.format( "update randomval set val = val + %s where id = %s" , step , drawtype )
	
	local sql2 = string.format( "select val from randomval where id = %s" , drawtype )
	print( sql1 )
	print( sql2 )
	
	db:query( sql1 )
	local r = db:query( sql2 )
	print( "update randomval is over" )
	print( r[1].val , drawtype , r  )
	return r[1].val % 10000
end	
	
local CMD = {}
		
function CMD:disconnect_redis( ... )
	cache:disconnect()
end	
	
function CMD:disconnect_mysql( ... )
	db:disconnect()
end	
	
function CMD:command( subcmd, ... )
	local f = nil
    if nil ~= QUERY[subcmd] then
    	f = assert(QUERY[ subcmd ])
		return f(QUERY, ... )
	elseif nil ~= emaildb[ subcmd ] then	
		f = assert( emaildb[ subcmd ] )
		return f(emaildb, ...)
	elseif nil ~= frienddb[ subcmd ] then
		f = assert( frienddb[ subcmd ] )
		return f(frienddb, ...)
	elseif nil ~= drawdb[ subcmd ] then
		f = assert( drawdb[ subcmd ] )
		return f(drawdb, ...) 
	else
		print(subcmd)
		assert( f )
    end
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

local
function watching(conf)
	local w = redis.watch( conf )
	w:subscribe "foo"
	w:psubscribe "hello.*"
	
	while true do
		print( "watch" , w:message() )
	end
end	

local
function connect_redis( conf )
	--skynet.fork( watching, conf )
	local cache = redis.connect( conf )	
	return cache
end	

skynet.start( function () 
	skynet.dispatch( "lua" , function( _, _, cmd, subcmd, ... )
		if cmd == "command" then
			local f = assert( CMD[ cmd ] )
			local result = f(CMD, subcmd, ... )
			if result then
				skynet.ret( skynet.pack( result ) )
			end
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

	emaildb.getvalue( db , cache )
	frienddb.getvalue( db , cache )
	drawdb.getvalue( db , cache )

	--skynet.call( ".channel" , "lua" , "get_db_cache" , emaildb )

	print("emaildb.getvalue is called\n")
end)
