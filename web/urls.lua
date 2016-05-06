local view = require "view"
local urls = {}

urls['^/$'] = assert(view["index"])
urls['^/index$'] = assert(view["index"])
urls['^/user$'] = assert(view["user"])
urls['^/role'] = assert(view["role"])
urls['^/email'] = assert(view["email"])
urls['^/props'] = assert(view["props"])
urls['^/equipments'] = assert(view["equipments"])
urls['^/validation$'] = assert(view["validation"])
urls['^/validation_ro'] = assert(view["validation_ro"])
urls['^/404'] = assert(view["_404"])

return urls

