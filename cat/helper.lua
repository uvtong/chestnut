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
	
function cls:lilian_sub_get_lilian_sub()
	local modelmgr = self._env:get_modelmgr()
	assert(modelmgr)
	local e = modelmgr:get_u_lilian_submgr()
	assert(e)

	for k, v in pairs(e.__data) do
		return v
	end

	return nil
end	
	
function cls:lilian_qg_num_clear_by_settime(settime)
	assert(settime)
	local modelmgr = self._env:get_modelmgr()
	assert(modelmgr)
	local e = modelmgr:get_u_lilian_qg_nummgr()
	assert(e)

	for k, v in pairs(e.__data) do
		if v:get_start_time() ~= settime then
			v = nil
			e.__count = e.__count - 1
		end
	end
end 

function cls:lilian_qg_num_get_lilian_num_list()
	local ret = {}

	local modelmgr = self._env:get_modelmgr()
	assert(modelmgr)
	local e = modelmgr:get_u_lilian_qg_nummgr()
	assert(e)

	for k, v in pairs(e.__data) do
		table.insert(ret, {quanguan_id = v:get_quanguan_id(), num = v:get_num(), reset_num = v:get_reset_num()})
	end

	return ret
end 
	
return cls














