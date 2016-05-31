local cls = class("helper")

function cls:ctor(env, ... )
	-- body
	self._env = env
end

function cls:exercise_get_exercise()
	local modelmgr = self._env:get_modelmgr()
	assert(modelmgr)
	local e = modelmgr:get_u_exercisemgr()
	assert(e)

	for k, v in pairs(e.__data) do
		return v
	end

	return nil
end

function cls:cgold_get_cgold()
	local modelmgr = self._env:get_modelmgr()
	assert(modelmgr)
	local e = modelmgr:get_u_cgoldmgr()
	assert(e)

	for k, v in pairs(e.__data) do
		return v
	end

	return nil

end

return cls














