package.path = "./../cat/?.lua;" .. package.path
local skynet = require "skynet"
require "skynet.manager"
local util = require "util"

local CMD = {}

function CMD.draw( val )
	assert( val )
	local r
	--local addr = randomaddr()
	local trandom = skynet.call(".game", "lua", "query_g_randomval" , val.drawtype)     
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
	return r	
end	    
	    
skynet.start( function () 
	skynet.dispatch( "lua" , function( _, _, cmd , subcmd , ... )
		print( "random draw is called" )
		local f = assert( CMD[ subcmd ] )
		local result = f( ... )
		print( result )
		skynet.ret( skynet.pack( result ) )
	end)	
	skynet.register ".randomdraw"

end)    
