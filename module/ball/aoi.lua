local skynet = require "skynet"
local snax = require "snax"
local aoiaux = require "aoiaux"
local room
local aux
local CMD = {}

local function aoi_Callback(id, id, ... )
	-- body
	-- skynet.send(room, "lua", "message")
end

function CMD.start(conf, ... )
	-- body
	local handle = conf.handle
	room = snax.bind(handle , "room")
end

function CMD.update( ... )
	-- body
	aoiaux.update(aux, ...)
end

function CMD.message( ... )
	-- body
	aoiaux.message(aux, ...)
end

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function(_,_, cmd, subcmd, ...)
		local f = CMD[cmd]
		local r = f(subcmd, ... )
		if r then
			skynet.ret(skynet.pack(r))
		end
	end)
	aux = aoiaux.new(aoi_Callback)
end)