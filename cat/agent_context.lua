local skynet = require "skynet"
local const = require "const"
local _M = {}

_M.WATCHDOG = nil
_M.host = nil
_M.send_request = nil

_M.client_fd = nil

_M.game = nil
_M.user = nil

function _M:send_package(pack)
	-- body
	local package = string.pack(">s2", pack)
	socket.write(self.client_fd, package)
end

function _M:push_achievement(achievement)
	-- body
	ret = {}
	ret.which = {
		csv_id = achievement.csv_id,
		finished = achievement.finished
	}
	-- self:send_package(self.send_request("finish_achi", ret))
end

function _M:raise_achievement(T)
	-- body
	assert(T)
	while true do 
		local a = assert(self.user.u_achievementmgr:get_by_type(T))
		if a.unlock_next_csv_id == 0 then
			break
		end
		local finished
		if T == const.ACHIEVEMENT_T_2 then
			finished = self.user.u_propmgr:get_by_csv_id(const.GOLD).num
		elseif T == const.ACHIEVEMENT_T_3 then
			finished = self.user.u_propmgr:get_by_csv_id(const.EXP).num
		elseif T == const.ACHIEVEMENT_T_4 then
			finished = self.user.take_diamonds
		elseif T == const.ACHIEVEMENT_T_5 then
			finished = self.user.u_propmgr:get_count()
		elseif T == const.ACHIEVEMENT_T_6 then
			finished = self.user.u_checkpointmgr:get_by_csv_id(0).chapter
		elseif T == const.ACHIEVEMENT_T_7 then
			finished = self.user.level
		elseif T == const.ACHIEVEMENT_T_8 then
			finished = self.user.draw_number
		elseif T == const.ACHIEVEMENT_T_9 then
			finished = self.user.u_kungfumgr:get_count()
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

			local rc = self.user.u_achievement_rcmgr.create(tmp)
			self.user.u_achievement_rcmgr:add(rc)
			rc:__insert_db(const.DB_PRIORITY_2)

			assert(type(a.unlock_next_csv_id), string.format("%s", type(a.unlock_next_csv_id)))
			local ga = skynet.call(self.game, "lua", "query_g_achievement", a.unlock_next_csv_id)
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

return _M
