package.path = "./../cat/?.lua;" .. package.path
local skynet = require "skynet"
require "skynet.manager"
local mc = require "multicast"
local util = require "util"
local loader = require "loader"
local const = require "const"

local game
local channel
local u_client_id = {} -- if

local CMD = {}		

function CMD:agent_start( user_id, addr )
	u_client_id.user_id = user_id
	u_client_id.addr = addr 

	assert(channel.channel)
	return channel.channel
end			
			
function CMD:send_email_to_all( ... )
end

function CMD:send_email_to_group( ... )
end

function CMD:hello( tval , ... )
	-- body	
	print("hello is callled\n")

	channel:publish( "email" , { emailtype = , tval )
	local addr = util.random_db()
	skynet.send( addr, "lua", "command" , "insert_offlineemail", tval)

	-- local t = {csv_id=util.u_guid(user_id, game, const.UEMAILENTROPY), uid=user.csv_id, type=}
	-- tval.csv_id = 
	-- tval.user_id = user_id
	-- local u_emailmgr = require "u_emailmgr"
	-- local email = u_emailmgr.create(tvalh)
	-- email:__insert_db()
end		   			

--[[local T = { QF=1, ZF=2, DS = 3}

function CMD:fire(countdowk, type, {}, {})
	it type == T.QF then
		elseif type == T.ZF then
	skynent.timeout(coutnfd. CMD:hell(type, {}, {})

end

function CMD.ds()
{
	now	os.time()
	t= {
	lsf
sfllj
sf
local s = os.time(t)
s - now
 skynet.timeout(ssf, funcito)
--]]
skynet.start( function () 
	skynet.dispatch( "lua" , function( _, _, cmd, ... )
		print("channel is called")
		local f = assert( CMD[ cmd ] )
		local result = f(CMD, ... )
		if result then
			skynet.ret( skynet.pack( result ) )
		end
	end)
	channel = mc.new()
	skynet.register ".channel"
	
	game = loader.load_channel_game()
end)
