package.path = "./../cat/?.lua;" .. package.path
local skynet = require "skynet"
require "skynet.manager"
	
local CMD = {}
		
local function randomaddr()
	local r = math.random( 1 , 5 )
	local addr = skynet.localname( string.format( ".db%d", math.floor( r ) ) )
	print("addr is " .. addr )
	assert( addr , "randomaddr failed\n" )

	return addr
end	
	
function CMD:draw( val )
	assert( val )
	print( "random draw is called in randomserver" .. val )
	local addr = randomaddr()

	local r = skynet.call( addr , "lua" , "command" , "getrandomval" , val )
	print( r )
	return r	
end	
	
skynet.start( function () 
	skynet.dispatch( "lua" , function( _, _, cmd , subcmd , ... )
		print( "random draw is called" )
			local f = assert( CMD[ subcmd ] )
			local result = f(CMD , ... )
			print( result )
		skynet.ret( skynet.pack( result ) )
	end)	
	skynet.register ".randomdraw"
end)