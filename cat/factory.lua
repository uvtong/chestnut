local cls = class("factory")

function cls:ctor(env, user, ... )
	-- body
	self._env = env
	self._user = user
end

function cls:create_journal( ... )
	-- body
	local t = {}
	t["user_id"] = self._user:get_csv_id()
	t["date"] = sec
	t["goods_refresh_count"] = 0
	t["goods_refresh_reset_count"] = 0
	t["ara_rfh_tms"] = 5
	t["ara_bat_ser"] = 0
	j = self._user.u_journalmgr:create_entity(t)
	self._user.u_journalmgr:add(j)
	j:update()
	return j
end

function cls:get_today( ... )
	-- body
	local t = os.date("*t", os.time())
	t = { year=t.year, month=t.month, day=t.day}
	local sec = os.time(t)
	local j = self._user.u_journalmgr:get_by_date(sec)
	if j then
		return j
	else
		return self:create_journal()
	end
end

function cls:create_ara_bat(p )
	-- body
	local ser = p:get_ser()
	local tmp = {}
	tmp["id"] = genpk_2(self._user:get_csv_id(), ser)
	tmp["user_id"] = self._user:get_csv_id()

end

return cls