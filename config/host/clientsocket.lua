package.cpath = "./../../skynet/luaclib/?.so;./../../lua-socket/?.so"
package.path = "./../../skynet/lualib/?.lua"

local packagesocket = require "packagesocket"
local crypt = require "crypt"
local proto = require "proto"
local sproto = require "sproto"

local token = {
	server = "sample",
	user = "125",
	pass = "123",
}

local function encode_token(token)
	return string.format("%s@%s:%s",
		crypt.base64encode(token.user),
		crypt.base64encode(token.server),
		crypt.base64encode(token.pass))
end

local clientkey
local challenge
local secret
local g = packagesocket.new()
local fd = packagesocket.socket(g)
ssert(packagesocket.connect("192.168.1.239", 3002) == packagesocket.SOCKET_OPEN)
local step = 1
while true do 
	local t = packagesocket.poll(g)
	if t[fd] then
		local line = t[fd]
	end
	if line then
		if step == 1 then
			challenge = crypt.base64decode(line)
			step = step + 1
		elseif step == 2 then
			clientkey = crypt.randomkey()
			packagesocket.sendline(g, fd, crypt.base64encode(crypt.dhexchange(clientkey)))
			step = step + 1
		elseif step == 3 then
			secret = crypt.dhsecret(crypt.base64decode(line), clientkey)
			print("sceret is ", crypt.hexencode(secret))
			local hmac = crypt.hmac64(challenge, secret)
			packagesocket.sendline(g, fd, crypt.base64encode(hmac))
			step = step + 1
		elseif step == 4 then
			local etoken = crypt.desencode(secret, encode_token(token))
			local b = crypt.base64encode(etoken)

			packagesocket.sendline(g, fd, crypt.base64encode(etoken))
			step = step + 1
		elseif step == 5 then
			local code = tonumber(string.sub(line, 1, 3))
			assert(code == 200)
			packagesocket.closesocket(g, fd)
		end
	end
end