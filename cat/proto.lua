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
        errorcode 0 : integer
        msg 1 : string
        id 2 : integer
        wake_level 3 : integer
        level 4 : integer
        combat 5 : integer
        defense 6 : integer
        critical_hit 7 : integer
        skill 8 : integer
        c_equipment 9 : integer
        c_dress 10 : integer
        c_kungfu 11 : integer
    }
}

mail 3 {
    request {
        from 0 : integer
        to 1 : integer
        title 2 : string
        msg 3 : string
    }
    response {
        ok 0 : boolean 
        error 1 : integer
        msg 2 : string
    }
}

signup 4 {
	request {
		account 0 : string
		password 1 : string
	}
}

login 5 {
    request {
        account 0 : string
        password 1 : string
    }
    response {
        errorcode 0 : integer
        msg 1 : string
        user_id 2 : integer
        uname 3 : string 
        uviplevel 4 : integer
        uexp 5 : integer
        config_sound 6 : boolean
        config_music 7 : boolean
        avatar 8 : integer
        sign 9 : string
        .role {
            role_id 0 : integer
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
        rolelist 10 : *role
    }
}

upgrade 6 {
	response {
		errorcode 0 :integer
		msg 1 : string
		role_id 2 : integer
        wake_level 3 : integer
        level 4 : integer
        combat 5 : integer
        defense 6 : integer
        critical_hit 7 : integer
        skill 8 : integer
        c_equipment 9 : integer
        c_dress 10 : integer
        c_kungfu 11 : integer
	}
}

choose_role 7 {
    request {
        role_id 0 : integer
    }
    response {
        errorcode 0 : integer
        msg 1 : string
    }
}

wake 8 {
    response {
        errorcode 0 :integer
        msg 1 : string
        role_id 2 : integer
        wake_level 3 : integer
        level 4 : integer
        combat 5 : integer
        defense 6 : integer
        critical_hit 7 : integer
        skill 8 : integer
        c_equipment 9 : integer
        c_dress 10 : integer
        c_kungfu 11 : integer
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
