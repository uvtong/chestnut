function genpk_1(_1, ... )
	-- body
	return _1
end

function genpk_2(_1, _2, ... )
    -- body
    local pk = (~(1 << 33 -1) & _1)
    pk = pk << 16
    pk = (pk | (~(1 << 33 -1) & _2 ))
    return pk
end
