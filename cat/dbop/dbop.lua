local skynet = require "skynet"
local mysql = require "mysql"

local function dump( obj )
	local getIndent , quoteStr , wrapKey , wrapVal , dumpObj
	getIndent = function( level )
					return string.rep( "\t" , level )
				end
	quoteStr = function( str )
					return '"' .. string.gsub( str , '"' , '\\"' ) .. '"'
				end
	wrapKey = function( val )
					if type( val ) == "number" then
						return "[" .. val .. "]"
					elseif type( val ) == "string" then
						return "[" .. quoteStr(val) .. "]"
					else
						return "[" .. tostring( val ) .. "]"
					end
			   end
	wrapVal = function( val , level )
					if type( val ) == "table" then
						return dumpObj( val , level )
					elseif type( val ) == "number" then
						return val
					elseif type( val ) == "string" then
						return quoteStr( val )
					else
						return tostring( val )
					end
				end
	dumpObj = function( obj , level )
					if type( obj ) ~= "table" then
						return wrapVal( obj )
					end

					level = level + 1
					local tokens = {}
					tokens[ #tokens + 1 ] = "{"
					for k , v in pairs( obj ) do
						tokens[ #tokens + 1 ] = getIndent( level ) .. wrapKey( k ) .. " = " .. wrapVal( v , level ) .. ","
					end
					tokens[ #tokens + 1 ] = getIndent( level - 1 ) .. "}"

					return table.concat( token , "\n")
			   end
	
	return dumpObj( obj , 0 )
end


skynet.start( function()
	local function on_connect( db )
			db:query( "set charset utf8" )
		  end


	local db = mysql.connect( {
		host = "" ,
		port = 3306 ,
		database = "mysql" ,
		user = "root" ,
		password = "1" ,
		max_packet_size = 1024 * 1024 ,
		on_connect = on_connect
		} )

		if  db then 
			print( "connect successfully" )
		end
	)
