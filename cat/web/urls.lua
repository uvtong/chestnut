local urls = { }

urls['^/$'] = "_"
urls['^/index'] = "_"
urls['^/home'] = "_"
urls['^/admin$'] = "_admin"
urls['^/user'] = "user"
urls['^/role'] = "role"
urls['^/email'] = "email"

return urls

