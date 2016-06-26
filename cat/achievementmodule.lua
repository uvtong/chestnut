local skynet = require "skynet"
local dc = require "datacenter"
local sd = require "sharedata"
local errorcode = require "errorcode"
local const = require "const"
local super = require "module"
local cls = class("achievementmodule", super)

function cls:ctor(env, ... )
	-- body
	self._env = env
end

function cls:raise_achievement(T)
	-- body  
	if true then
		return
	end                 
	assert(T)
	while true do 
		local a = assert(self._user.u_achievementmgr:get_by_type(T))
		if a.unlock_next_csv_id == 0 then
			break
		end
		local finished
		if T == const.ACHIEVEMENT_T_2 then
			finished = self._user.u_propmgr:get_by_csv_id(const.GOLD).num
		elseif T == const.ACHIEVEMENT_T_3 then
			finished = self._user.u_propmgr:get_by_csv_id(const.EXP).num
		elseif T == const.ACHIEVEMENT_T_4 then
			finished = self._user.take_diamonds
		elseif T == const.ACHIEVEMENT_T_5 then
			finished = self._user.u_rolemgr:get_count()
		elseif T == const.ACHIEVEMENT_T_6 then
			finished = self._user.u_checkpointmgr:get_by_csv_id(0).chapter
		elseif T == const.ACHIEVEMENT_T_7 then
			finished = self._user.level
		elseif T == const.ACHIEVEMENT_T_8 then
			finished = self._user.draw_number
		elseif T == const.ACHIEVEMENT_T_9 then
			finished = self._user.u_kungfumgr:get_count()
		else
			assert(false)
		end
		local progress = finished / a.c_num
		if progress >= 1 then
			local tmp = {}
			for k,v in pairs(a) do
				tmp[k] = v
			end
			tmp.finished = 100
			tmp.reward_collected = 0
			self:push_achievement(a)

			local rc = self._user.u_achievement_rcmgr:create(tmp)
			self._user.u_achievement_rcmgr:add(rc)
			rc:__insert_db(const.DB_PRIORITY_2)

			assert(type(a.unlock_next_csv_id), string.format("%s", type(a.unlock_next_csv_id)))
			local key = string.format("%s:%d", "g_achievement", a.unlock_next_csv_id)
			local ga = sd.query(key)
			a.csv_id = ga.csv_id
			a.finished = 0
			a.c_num = ga.c_num
			a.unlock_next_csv_id = ga.unlock_next_csv_id
			a.is_unlock = 1
		else
			a.finished = math.floor(progress * 100)
			break
		end
	end
end

function cls:achievement(args)
	-- body
	local user = self._env:get_user()
	local modelmgr = self._env:get_modelmgr()
	local u_achievementmgr = modelmgr:get_u_achievementmgr()
	local ret = {} 		
	if not user then 	
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret 		
	end 					
	local l = {} 		
	for i=1,const.ACHIEVEMENT_T_SUM do
		local cur = u_achievementmgr:get_by_csv_id(i)
		local cid = cur // 1000
		for j=1,cid do
			local T = i + 1
			local idx = i * 1000 + j

			local item = {}
			item.csv_id = idx			
			local a = user.u_achievement_rcmgr:get_by_csv_id(idx)
			if a then
				item.finished = a:get_field("finished")
				item.reward_collected = (a:get_field("reward_collected") == 1) and true or false
				item.is_unlock = (a:get_field("is_unlock") == 1) and true or false
			else
				a = u_achievementmgr:get_by_csv_id(T)
				item.finished = a:get_field("finished")
				item.reward_collected = false
				item.is_unlock = (a:get_field("is_unlock") == 1) and true or false
			end
			table.insert(l, item)
		end
	end
	ret.errorcode = errorcode[1].code
    ret.msg = errorcode[1].msg
    ret.achis = l
    return ret
end

function cls:achievement_reward_collect(args)
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(user)
	assert(self.csv_id)
	local a = user.u_achievement_rcmgr:get_by_csv_id(self.csv_id)
	if a and a.finished == 100 and a.reward_collected == 0 then
		a.reward_collected = 1
		local a_src = skynet.call(game, "lua", "query_g_achievement", a.csv_id)
		if a_src.type == 2 then
			local csv_id1 = string.gsub(a_src.reward, "(%d*)%*(%d*)", "%1")
			local num1 = string.gsub(a_src.reward, "(%d*)%*(%d*)", "%2")
			local prop = get_prop(csv_id1)

			local prop = user.u_propmgr:get_by_csv_id(csv_id1)
			if prop then
				prop.num = prop.num + num1
				prop:update_db({"num"})
			else
				prop = game.g_propmgr:get_by_csv_id(csv_id1)
				prop.user_id = user.csv_id
				prop.num = num1
				prop = user.u_propmgr.create(prop)
				
				prop:update_db(const.DB_PRIORITY_2)
			end
		end
		local next = user.u_achievement_rcmgr:get_by_csv_id(a_src.unlock_next_csv_id)
		if next then
			ret.next = {}
			for k,v in pairs(next) do
				ret.next[k] = v
			end
			ret.next.reward_collected = (next.reward_collected == 1) and true or false
			ret.next.is_unlock = (next.is_unlock == 1) and true or false
		else
			next = user.u_achievementmgr:get_by_type(a_src.type)
			if a_src.unlock_next_csv_id ~= 0 then
				assert(next.csv_id == a_src.unlock_next_csv_id, string.format("%d, %d", next.csv_id, a_src.unlock_next_csv_id))
			end
			ret.next = {}
			for k,v in pairs(next) do
				ret.next[k] = v
			end
			ret.next.reward_collected = false
			ret.next.is_unlock = true
		end
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].msg
		return ret
	end
	ret.errorcode = errorcode[26].code
	ret.msg = errorcode[26].msg
	return ret
end 

return cls