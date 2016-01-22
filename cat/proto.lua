local sprotoparser = require "sprotoparser"

local proto = {}

proto.c2s = sprotoparser.parse [[
.package {
	type 0 : integer
	session 1 : integer
}

.role {
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

.user {
    uname 0 : string 
    uviplevel 1 : integer
    uexp 2 : integer
    config_sound 3 : boolean
    config_music 4 : boolean
    avatar 5 : integer
    sign 6 : string
    c_role_id 7 : integer
    rolelist 8 : *role
}

.prop {
    csv_id 0 : integer
    num 1 : integer
}

.achi {
    csv_id 0 : integer
    finished 1 : integer
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
    request {
        role_id 0 : integer
    }
    response {
        errorcode 0 : integer
        msg 1 : string
        r 2 : role
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
    response {
        errorcode 0 : integer
        msg 1 : string
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
        u 2 : user
    }
}

upgrade 6 {
    request {
        role_id 0 : integer
    }
	response {
		errorcode 0 :integer
		msg 1 : string
        r 2 : role
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
    request {
        role_id 0 : integer
    }
    response {
        errorcode 0 :integer
        msg 1 : string
        r 2 : role
    }
}

props 9 {
    response {
        l 0 : *prop
    }
}

use_prop 10 {
    request {
        role_id 0 : integer
        props 1 : *prop
    }
    response {
        errorcode 0 : integer
        msg 1 : string
        r 2 : role
        props 3 : *prop
    }
}

achievement 11 {
    response {
        errorcode 0 : integer
        msg 1 : string  
        achis 2 : *achi
    }
}

]]

proto.s2c = sprotoparser.parse [[
.package {
	type 0 : integer
	session 1 : integer
}

.achi {
    csv_id 0 : integer
    finished 1 : integer
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

finish_achi 3 {
    request {
        which 0 : achi
    }
    response {
        errorcode 0 : integer
        msg 1 : string
    }
}

]]

return proto
