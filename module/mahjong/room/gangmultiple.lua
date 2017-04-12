local opcode = require "opcode"

local _M = {}

_M[opcode.bugang] = 1
_M[opcode.zhigang] = 2
_M[opcode.angang] = 2

local function multiple(code, ... )
	-- body
	if _M[code] then
		return _M[code]
	else
		assert(false)
	end
end

return multiple