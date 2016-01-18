local skynet = require "skynet"
local mysql = require "mysql"
local redis = require "redis"

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
	
local
function connect_mysql( ... )
	local function on_connect( db )
		db:query( "set charset utf8" )
	end
	
	local db = mysql.connect({ 
		host="192.168.1.116",
		port=3306,
		database="project",
		user="root",
		password="yulei",
		max_packet_size = 1024 * 1024,
		on_connect = on_connect
	})

	return db
end

local
function watching( conf )
	local w = redis.watch( conf )
	w:subscribe "foo"
	w:psubscribe "hello.*"
	
	while true do
		print( "watch" , w:message() )
	end
end	
	
local
function connect_redis( conf )
	-- skynet.fork( watching )
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
	
function QUERY:select_users( account, password )
	-- body
	local sql = string.format("select * from users where uaccount = %s, upassword = %s", account, password)
	local r = db:query(sql)
	--cache:get()
	return r
end 

function QUERY:create_user( t )
	-- body
	local sql = string.format("insert into users (uname, uaccount, upassword, uviplevel, uexp, config_music, config_sound, avatar, sign) values (\"%s\", \"%s\", \"%s\", %d, %d, %d, %d, %d, \"%s\")", u.uname, u.uaccount, u.upassword, u.uviplevel, u.uexp, u.config_music, u.config_sound, u.avatar, v.sign);
	local r = db:query(sql)
	dump(r)
	--cache:get()
	return r
end

function QUERY:select( tvals )
end	
	
function QUERY:insert( tvals )
end	
	
function QUERY:update( tvals )
end	
	
function QUERY:delete( tvals )
end	
	
local CMD = {}
	
function CMD:disconnect_redis( ... )
	cache:disconnect()
end

function CMD:disconnect_mysql( ... )
	db:disconnect()
end

function CMD:command( subcmd, ... )
	local f = assert(QUERY[subcmd])
	return f( ... )
end


skynet.start( function () 
	skynet.dispatch( "lua" , function( _, _, cmd, ... )
		if cmd == "command" then
			local f = assert( CMD[ cmd ] )
			skynet.ret( skynet.pack( f( ... ) ) )
		else
			local f = assert( CMD[ cmd ] )
			skynet.ret( skynet.pack( f( ... ) ) )
		end
	end)

	db = connect_mysql()
	local conf = {
		host = "192.168.1.116" ,
		port = 6379 ,
		db = 0
	}
	cache = connect_redis( conf )
end)

