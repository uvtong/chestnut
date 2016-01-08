local skynet = require "skynet"
require "skynet.manager"
local sproto = require "sproto"
local crypt = require "crypt"

skynet.start(function()
	skynet.uniqueservice("protoloader")
	local db = skynet.uniqueservice('db')
	local loginserver = skynet.newservice("logind")
	skynet.name("LOGIND", loginserver)

	--local gate = skynet.newservice("gated", loginserver)

	--skynet.call(gate, "lua", "open" , {
	--	port = 8888,
	--	maxclient = 64,
	--	servername = "sample",
	--})
	-- proto = [[
	-- 	.user {
	-- 		name 0 : string
	-- 		age 1 : integer
	-- 	}
	-- ]]
	-- local sp = sproto.parse(proto)
	-- local c = {
	-- 	name = "hubing",
	-- 	age = 2
	-- }
	-- local e =  sp:encode("user", c)
	-- local t = sp:decode("user", e)
	-- for k,v in pairs(t) do
	-- 	print(k,v)
	-- end
	-- print(crypt.base64encode(e))
	skynet.exit()
end)
