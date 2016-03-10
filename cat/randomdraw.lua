package.path = "./../cat/?.lua;" .. package.path
local skynet = require "skynet"
require "skynet.manager"
local util = require "util"
local randomvalmgr = require "models/g_randomvalmgr"


local CMD = {}

local function load_g_randomval()
	local r = skynet.call( util.random_db() , "lua" , "command" , "select" , "randomval" )
	for k , v in ipairs( r ) do
		local t = randomvalmgr.create( v )
		randomvalmgr:add( t )
	end
end 
	
function CMD:draw( val )
	assert( val )
	print( "random draw is called in randomserver" .. val.drawtype )
        
	local r
	--local addr = randomaddr()
	local trandom = randomvalmgr:get_by_id( val.drawtype )
	assert( trandom )
         
	if val.drawtype == 3 then
		r = {}
        
		for i = 1 , 10 do
			trandom.val = trandom.val + trandom.step
			if trandom.val > 10000 then -- zan shi
				trandom.val = trandom.val % 10000
			end
			table.insert( r , trandom.val )
		end
	else
		trandom.val = trandom.val + trandom.step
		
		if trandom.val > 10000 then -- zan shi
			trandom.val = trandom.val % 10000
		end
        
		r = trandom.val
	end 
	    
	trandom:__update_db( { "val" } )
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
        
	load_g_randomval()
end)    
