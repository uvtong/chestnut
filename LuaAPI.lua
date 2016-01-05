require "skynet.manager"
skynet.launch(servicename:string, ...)  -- c service
skyent.kill(address)
skyent.abort()           -- exit current process
skyent.register(name:string)
skyent.name(name:string, address:integer)
skynet.filter(type, msg, sz, session, source)
skynet.monitor() -- h

local address = skynet.self()
local harbor = skynet.harbor()
local name = skynet.address(address:integer)
skynet.register(name:string)
skynet.name(name:string, address:integer) -- skynet.name(name, skeynet.self()) = skynet.register(name)
skynet.localname(name:string) -- when skynet.register(".master") len't everyone know this name.

skynet.dispatch(type, function(session, source, ...) ... end)

skynet.register_protocol {
	name = "text",
	id = skynet.PTYPE_TEXT,
	pack = function ( ... )
		-- body
		return userdata, size
	end,
	unpack = function ( userdata, size )
		-- body
		return string
	end,
	dispatch = function ( session, source, cmd, ... )
		-- body
		local f = assert(CMD[cmd])
		f(...) -- skynet.ret(skynet.pack(...))
	end
}

userdata, size skynet.pack( ... ) or string skynet.pack( ... )
string skynet.packstring( ... ) 

skynet.unpack(userdata, size)

skynet.ret(msg, size)  -- noblock

local f = skynet.response(skynet.pack( ... )) -- noblock

skynet.send(address, typename, ...)
skynet.call(address, typename, ...) --block
skynet.rawcall(address, typename, msg, size)
local session = skynet.genid()
skynet.redirect(address, source, typename, session, ...)

skynet.init(function ( ... )
	-- body
end)
skynet.start(function ( ... )
	-- body
end)

skynet.exit()
skynet.kill(address)
skynet.newservice(name:string, ...)

skynet.now()  -- 10ms /clock

function function_name( ... )
	-- body
	local result = skynet.sleep(100)  -- 1s
	if result == "BREAK" then
		skynet.error "skynet.wakeup this co"
	end
end

skynet.yield() 

skynet.yield()

skynet.sleep(ti) -- 100 ti == 1s

co = skynet.fork(function ( ... )
	-- body
	skynet.wait()
end, ...)
skynet.wakeup(co)