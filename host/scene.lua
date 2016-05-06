local skynet = require "skynet"
local queue = require "queue"

local q = queue.new()

local internal_id = 1
local rooms = {}

local CMD = {}

function CMD.register(src)
	-- body
	rooms[internal_id] = src
	internal_id = internal_id + 1
	return internal_id
end

function CMD.enqueue(src)
	-- body
	queue.enqueue(q, src)
	
end

skynet.start(function ()
	-- body
	skynet.dispatch("lua", function(_, source, command, ...)
		print("agent is called" , command)
		local f = CMD[command]
		local result = f(source, ... )
		if result then
			skynet.ret(skynet.pack(result))
		end
	end)

end)