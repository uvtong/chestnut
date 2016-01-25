package.path = "../cat/?.lua;" .. package.path
local view = require "web.view"
local urls = {}

urls['^/$'] = { name = "index", func = assert(view[name])}
urls['^/user'] = "user"
urls['^/role'] = "role"
urls['^/email'] = "email"

return urls

