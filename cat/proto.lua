local sprotoparser = require "sprotoparser"

local proto = {}

proto.c2s = sprotoparser.parse [[
.package {
	type 0 : integer
	session 1 : integer
}

handshake 1 {
    request {
        secret 0 : string
    }
    response {
        msg 0  : string
    }
}

role 2 {
    response {
        id 0 : integer
        wake_level 1 : integer
        level 2 : integer
        combat 3 : integer
        defense 4 : integer
        critical_hit 5 : integer
        skill 6 : integer
        c_equipment 7 : integer
        c_dress 8 : integer
        c_kungfu 9 : integer
    }
}

mail 3 {
    request {
        from 0 : integer
        to 1 : integer
        head 2 : string
        msg 3 : string
    }
    response {
        ok 0 : boolean 
        error 1 : integer
        msg 2 : string
    }
}


]]

proto.s2c = sprotoparser.parse [[
.package {
	type 0 : integer
	session 1 : integer
}

heartbeat 1 {}

mail 2 {
    request {
        from 0 : integer
        to 1 : integer
        head 2 : string
        msg 3 : string   
    }
    response {
        ok 0 : boolean 
        error 1 : integer
        msg 2 : string
    }
}
]]

return proto
