package.path = "../cat/?.lua;" .. package.path
local view = require "web.view"
local urls = {}

urls['^/$'] = assert(view["index"]())
urls['^/user'] = assert(view["user"]())
urls['^/role'] = assert(view["role"]())
urls['^/email'] = assert(view["email"]())

return urls

