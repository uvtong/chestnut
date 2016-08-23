local skynet = require "skynet"
local module_path = 1

local box = {}

local CMD = {}

function CMD.send(mail, ... )
	-- body
	local sender = mail.sender
	local recipient = mail.recipient
	local head = mail.head
	local content = mail.content
	local mailbox = box[recipient]
	mailbox:recive(mail)
end

function CMD.box( ... )
	-- body
end

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function ( ... )
		-- body
	end)
end)