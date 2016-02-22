local wash = {}
local const = require "const"

function wash.push_achievement(achievement)
	-- body
	ret = {}
	ret.which = {
		csv_id = achievement.csv_id,
		finished = achievement.finished
	}
	send_package(send_request("finish_achi", ret))
end

function wash.raise_achievement(type, user, game)
	-- body
	if type == "combat" then
		local n = 0
		local l = user.achievementmgr:get(type)
		for i,v in ipairs(l) do
			local z = n / v.combat
			if z > 1 then
				send_achi(v.csv_id, z)
			end
			v.finished = z
			local addr = random_db()
			skynet.send(addr, "lua", "command", "update", "achievements", {user_id = user.id, type = "combat", combat= v.combat}, {finished = v.finished})	
		end
		for k,v in pairs(l) do
			print(k,v)
		end
		if num > 1000 then
			send_achi()
		end
	elseif type == const.A_T_GOLD then -- 2
		repeat
			local a = user.u_achievementmgr:get_by_type(const.A_T_GOLD)
			assert(a) -- must be only one
			local gold = user.u_propmgr:get_by_csv_id(const.GOLD) -- abain prop by type (type -- csv_id -- prop.id)		
			local progress = gold.num / a.c_num
			print("***********************************ccbc", progress)
			if progress >= 1 then -- success
				a.finished = 100
				a.reward_collected = 0
				wash.push_achievement(a)
				
				
				-- insert achievement rc	
				local rc = user.u_achievement_rcmgr.create(a)
				rc:__insert_db()

				local a_src = game.g_achievementmgr:get_by_csv_id(a.unlock_next_csv_id)

				a.csv_id = a_src.csv_id
				a.finished = 0
				a.c_num = a_src.c_num
				a.unlock_next_csv_id = a_src.unlock_next_csv_id
				a.is_unlock = 1
				a:__update_db({"csv_id", "finished", "c_num", "unlock_next_csv_id"})
			else
				a.finished = progress * 100
				a:__update_db({"finished"})
				break
			end
		until false
	elseif type == const.EXP then

	elseif type == "level" then
	end
end

return wash