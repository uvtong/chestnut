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
	
function cls:lilian_main_get_by_quanguan_id(quanguan_id)
	assert(quanguan_id)

	local modelmgr = self._env:get_modelmgr()
	assert(modelmgr)
	local e = modelmgr:get_u_lilian_mainmgr()
	assert(e)

	for k, v in pairs(e.__data) do
		if v:get_quanguan_id() == quanguan_id then
			return v
		end
	end	

	return nil
end 
	
function cls:lilian_main_delete_by_id(id)
	assert(id)

	local modelmgr = self._env:get_modelmgr()
	assert(modelmgr)
	local e = modelmgr:get_u_lilian_mainmgr()
	assert(e)

	e:delete(id)
end 
		
function cls:lilian_qg_num_get_by_quanguan_id(quanguan_id)
	assert(quanguan_id)

	local modelmgr = self._env:get_modelmgr()
	assert(modelmgr)
	local e = modelmgr:get_u_lilian_qg_nummgr()
	assert(e)

	for k, v in pairs(e.__data) do
		if v:get_quanguan_id() == quanguan_id then
			return v
		end
	end	

	return nil
end 


function cls:lilian_phy_power_get_one()
	local modelmgr = self._env:get_modelmgr()
	assert(modelmgr)
	local e = modelmgr:get_u_lilian_phy_powermgr()
	assert(e)	

	for k, v in pairs(e.__data) do
		return v
	end

	return nil
end 
	
function cls:lilian_phy_power_clear()
	local modelmgr = self._env:get_modelmgr()
	assert(modelmgr)
	local e = modelmgr:get_u_lilian_phy_powermgr()
	assert(e)

	e:clear()
end 
	
function cls:kungfu_get_by_csv_id(csv_id)
	assert(csv_id)

	local modelmgr = self._env:get_modelmgr()
	assert(modelmgr)
	local e = modelmgr:get_u_kungfumgr()
	assert(e)

	for k, v in pairs(e.__data) do
		if csv_id == v:get_field("csv_id") then
			return v
		end
	end

	return nil
end 
	
return cls
		