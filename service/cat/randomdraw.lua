package.path = "./../cat/?.lua;" .. package.path
local skynet = require "skynet"
require "skynet.manager"
local util = require "util"
local const = require "const"
local game
local loader = require "load_game"
local trandom
	
local CMD = {}
	
function CMD.draw( val )
	assert( val )
	local r
		
	trandom = game.g_randomvalmgr:get_by_csv_id( val.drawtype )
	assert( trandom )

	print( "drawtype is ***************************" , val.drawtype , trandom.val , trandom.step )
	if val.drawtype == 3 then
		r = {}
		for i = 1 , 10 do
			trandom.val = ( trandom.val + trandom.step ) % 10000
			table.insert( r , trandom.val )
		end
		print( trandom.val )
	else
		trandom.val = ( trandom.val + trandom.step ) % 10000 
		r = trandom.val
	end 
	return r
end	
	
local function update_db()
	-- body
	while true do
		if game then
			game.g_randomvalmgr:update_db(const.DB_PRIORITY_3)
		end
		skynet.sleep(const.DB_DELTA) -- 1ti == 0.01s
	end
end

skynet.start( function () 
	skynet.dispatch( "lua" , function( _, _, cmd , subcmd , ... )
		print( "random draw is called" , cmd , subcmd )
		local f = assert( CMD[ cmd ] )
		local result = f(subcmd, ... )
		if result then
			skynet.ret( skynet.pack( result ) )
		end
	end)	
	skynet.register ".randomdraw"
	skynet.fork(update_db)
	game = loader.load_randomval()
end)    
