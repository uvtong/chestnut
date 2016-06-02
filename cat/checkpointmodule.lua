local skynet = require "skynet"
local dc = require "datacenter"
local sd = require "sharedata"
local errorcode = require "errorcode"
local const = require "const"
local super = require "module"
local cls = class("arenamodule", super)

function cls:ctor(env, ... )
	-- body
	self._env = env
end

function cls:hanging()
	-- body
	local user = self._env:get_user()
	local game = self._env:get_game()
	local r = skynet.call(game, "lua", "query_g_checkpoint", user.cp_hanging_id)
	assert(r)
	local cp_rc = user.u_checkpoint_rcmgr:get_by_csv_id(user.cp_hanging_id)
	assert(cp_rc)
	local now = os.time()
	-- cac hanging 
	local walk = now - cp_rc.hanging_starttime + cp_rc.hanging_walk
	cp_rc.hanging_starttime = now
	cp_rc.hanging_walk = (walk % r.cd)
	local n = walk / r.cd
	local l = {}
	local prop = user.u_propmgr:get_by_csv_id(const.GOLD)
	prop.num = math.floor(prop.num + (n * r.gain_gold))
	table.insert(l, prop)
	prop = user.u_propmgr:get_by_csv_id(const.EXP)
	prop.num = math.floor(prop.num + (n * r.gain_exp))
	table.insert(l, prop)
	-- cac drop
	walk = now - cp_rc.hanging_drop_starttime + cp_rc.hanging_drop_walk
	cp_rc.hanging_drop_starttime = now
	cp_rc.hanging_drop_walk = (walk % r.cd)
	n = walk / 100
	prop = user.u_propmgr:get_by_csv_id(r.drop)
	prop.num = prop.num + 1
	table.insert(l, prop)
	return l
end

function cls:choose(csv_id, now)
	-- body
	-- first resolve last hanging
	assert(now)
	local ret = {}
	if user.cp_hanging_id > 0 then
		if user.cp_hanging_id ~= csv_id then
			local ok, result = pcall(hanging)
			if not ok then
				skynet.error(result)
				ret.errorcode = errorcode[29].code
				ret.msg = errorcode[29].msg
				return false, ret
			end
			local cp_rc = user.u_checkpoint_rcmgr:get_by_csv_id(user.cp_hanging_id)
			cp_rc.hanging_starttime = 0
			cp_rc.hanging_drop_starttime = 0
			user.cp_hanging_id = csv_id
		end
	else
		-- reslove this time hanging
		user.cp_hanging_id = csv_id
		local cp_rc = user.u_checkpoint_rcmgr:get_by_csv_id(csv_id) 
		cp_rc.hanging_starttime = now
		cp_rc.hanging_drop_starttime = now
	end

	-- in the n
	if user.cp_battle_id > 0 then
		if user.cp_battle_id ~= csv_id then
			local cp_rc = user.u_checkpoint_rcmgr:get_by_csv_id(user.cp_battle_id)
			if cp_rc.cd_finished == 0 then
				cp_rc.cd_walk = cp_rc.cd_walk + (now - cp_rc.cd_starttime)
				cp_rc.cd_starttime = 0
				local r = skynet.call(game, "lua", "query_g_checkpoint", csv_id)
				if cp_rc.cd_walk >= r.cd then
					cp_rc.cd_finished = 1
				end
			end	
			user.cp_battle_id = 0
			user.cp_battle_chapter = 0
		end
	end
	return true
end

function cls:cp_exit()
	-- body
	local user = self._env:get_user()
	if user.cp_battle_id > 0 then
 		local cp_rc = user.u_checkpoint_rcmgr:get_by_csv_id(user.cp_battle_id)
 		if cp_rc.cd_finished == 0 then
 			local now = os.time()
			cp_rc.cd_walk = cp_rc.cd_walk + (now - cp_rc.cd_starttime)
			cp_rc.cd_starttime = 0
		end
		user:set_field("cp_battle_id", 0)
		user:set_field("cp_battle_chapter", 0)
	end
end

-- event
function cls:checkpoint_chapter(args)
	-- body
	local ret = {}
	local u = self._env:get_user()
	if not u then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].code
	ret.l = {}
	for k,v in pairs(u.u_checkpointmgr.__data) do
		table.insert(ret.l, v)
	end
	return ret
end

function cls:checkpoint_hanging(args, ... )
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	-- enter
	if user.cp_hanging_id > 0 then 
		local ok, result = pcall(hanging, self)
		if ok then
			ret.errorcode = errorcode[1].code
			ret.msg = errorcode[1].msg
			ret.props = result
			return ret
		else
			ret.errorcode = errorcode[29].code
			ret.msg = errorcode[29].msg
			return ret
		end
	else
		ret.errorcode = errorcode[34].code
		ret.msg = errorcode[34].msg
		return ret
	end
end

function cls:checkpoint_hanging_choose(args, ... )
	-- body
	local user = self._env:get_user()
	local ret = {}
	assert(user, "user is nil")
	assert(self.chapter*1000+self.type*100+self.checkpoint == self.csv_id)
	-- must <= cp_chapter
	assert(self.chapter <= user.cp_chapter)
	-- judge chapter 
	local now = os.time()
	local cp = user.u_checkpointmgr:get_by_csv_id(self.chapter)
	local cp_chapter = skynet.call(game, "lua", "query_g_checkpoint_chapter", self.chapter)
	if self.type == 0 then
		assert(self.checkpoint <= cp_chapter.type0_max)
		assert(self.checkpoint <= cp.chapter_type0)
		local ok, result = choose(self.csv_id, now)
		if not ok then
			return result 
		end
	elseif self.type == 1 then
		assert(self.checkpoint <= cp_chapter.type1_max, string.format("checkpoint:%d from client > cp_chapter.type1_max:%d", self.checkpoint, cp_chapter.type1_max))
		assert(self.checkpoint <= cp.chapter_type1)
		local ok, result = choose(self.csv_id, now)
		if not ok then
			return result 
		end
	elseif self.type == 2 then
		assert(self.checkpoint <= cp_chapter.type2_max, string.format("checkpoint:%d from client > cp_chapter.type1_max:%d", self.checkpoint, cp_chapter.type2_max))
		assert(self.checkpoint <= cp.chapter_type2)
		local ok, result = choose(self.csv_id, now)
		if not ok then
			return result 
		end
	else
		error("wrong checkpoint type")
		ret.errorcode = errorcode[37].code
		ret.msg = errorcode[37].msg
		return ret
	end
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	return ret
end

function cls:checkpoint_battle_exit()
	-- body
	local ret = {}
	assert(user ~= nil, "user is nil")
	assert(self.chapter <= user.cp_chapter, string.format("self.chapter:%d > user.cp_chapter:%d", self.chapter, user.cp_chapter))
	assert(self.chapter == user.cp_battle_chapter)
	assert(self.csv_id == user.cp_battle_id, string.format("user.cp_battle_id:%d is ", user.cp_battle_id))
	local cp_rc = user.u_checkpoint_rcmgr:get_by_csv_id(self.csv_id)
	assert(cp_rc.cd_finished == 1)
	if self.result == 1 then
		local r = skynet.call(game, "lua", "query_g_checkpoint", self.csv_id)
		local cp = user.u_checkpointmgr:get_by_csv_id(r.chapter)
		local cp_chapter = skynet.call(game, "lua", "query_g_checkpoint_chapter", r.chapter)
		-- reward
		local reward = {}
		local tmp = util.parse_text(r.reward, "(%d+%*%d+%*?)", 2)
		for i,v in ipairs(reward) do
			local prop = user.u_propmgr:get_by_csv_id(v[1])
			prop.num = prop.num + v[2]
			table.insert(reward, prop)
		end
		-- unlock next checkpoint
		if r.type == 0 then
			assert(cp.chapter_type0 == r.checkpoint)  -- keep progress
			cp.chapter_type0 = cp.chapter_type0 + 1
			if cp.chapter_type0 > cp_chapter.type0_max then
				-- unlock next chapter
				if user.cp_chapter == r.chapter then
					user.cp_chapter = user.cp_chapter + 1
					local cp_chapter_max = skynet.call(game, "lua", "query_g_config", "cp_chapter_max")
					if user.cp_chapter <= cp_chapter_max then   
						local next_cp = user.u_checkpointmgr:get_by_csv_id(user.cp_chapter)
						next_cp.chapter_type0 = 1
					end
				end
				-- unlock next type
				if cp.chapter_type1 ~= 0 then
					error("db is wrong")
					ret.errorcode = errorcode[35].code
					ret.msg = errorcode[35].code
					return ret
				else
					cp.chapter_type1 = 1
				end
			end
		elseif r.type == 1 then
			if cp.chapter_type1 ~= r.checkpoint then
				ret.errorcode = errorcode[35].code
				ret.msg = errorcode[35].msg
				return ret
			end
			assert(cp.chapter_type1 == r.checkpoint)
			cp.chapter_type1 = cp.chapter_type1 + 1
			if cp.chapter_type1 > cp_chapter.type1_max then
				-- unlock next type
				if cp.chapter_type2 ~= 0 then
					error("db is wrong.")
					ret.errorcode = errorcode[35].code
					ret.msg = errorcode[35].msg
					return ret
				else
					cp.chapter_type2 = 1
				end
			end
		elseif r.type == 2 then
			if cp.chapter_type2 ~= r.checkpoint then
				ret.errorcode = errorcode[35].code
				ret.msg = errorcode[35].msg
				return ret
			end
			assert(cp.chapter_type2 == r.checkpoint)
			cp.chapter_type2 = cp.chapter_type2 + 1
		end
		user.cp_battle_id = 0
		user.cp_battle_chapter = 0
		skynet.error(string.format("you passed chapter:%d, type:%d, checkpoint:%d", self.chapter, self.type, self.checkpoint))
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].msg
		ret.reward = reward
		return ret
	else
		skynet.error("you lose.")
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].code
		return ret
	end
end

function cls:checkpoint_battle_enter(args, ... )
	-- body
	local ret = {}
	assert(user ~= nil, "user is nil")
	assert(self.chapter <= user.cp_chapter)
	assert(self.csv_id == user.cp_hanging_id, string.format("self.csv_id:%d, user.cp_hanging_id:%d", self.csv_id, user.cp_hanging_id))
	-- check 
	local cp = user.u_checkpointmgr:get_by_csv_id(self.chapter)
	if self.type == 0 then
		assert(self.checkpoint == cp.chapter_type0)
	elseif self.type == 1 then
		assert(self.checkpoint == cp.chapter_type1)
	elseif self.type == 2 then
		assert(self.checkpoint == cp.chapter_type2)
	else
		ret.errorcode = errorcode[35].code
		ret.msg = errorcode[35].msg
		return ret
	end
	local now = os.time()
	if user.cp_battle_id == 0 then
		user.cp_battle_id = self.csv_id
		user.cp_battle_chapter = self.chapter
		local cp_rc = user.u_checkpoint_rcmgr:get_by_csv_id(self.csv_id)
		assert(cp_rc.cd_starttime == 0)
		if cp_rc.cd_finished == 1 then
			ret.errorcode = errorcode[1].code
			ret.msg = errorcode[1].msg
			return ret
		else
			cp_rc.cd_starttime = now
			local r = skynet.call(game, "lua", "query_g_checkpoint", self.csv_id)
			if r.cd - cp_rc.cd_walk > 0 then
				ret.errorcode = errorcode[1].code
				ret.msg = errorcode[1].msg
				ret.cd = r.cd - cp_rc.cd_walk
				return ret
			else
				cp_rc.cd_starttime = 0
				cp_rc.cd_finished = 1
				ret.errorcode = errorcode[1].code
				ret.msg = errorcode[1].msg
				ret.cd = 0
				return ret
			end
		end
	else
		assert(user.cp_battle_id == self.csv_id)
		assert(user.cp_battle_chapter == self.chapter)
		local cp_rc = user.u_checkpoint_rcmgr:get_by_csv_id(self.csv_id)
		assert(cp_rc.cd_starttime > 0, string.format("cd_starttime:%d", cp_rc.cd_starttime))
		assert(cp_rc.cd_finished == 0)
		local walk = now - cp_rc.cd_starttime + cp_rc.cd_walk
		cp_rc.cd_walk = walk
		cp_rc.cd_starttime = now
		local r = skynet.call(game, "lua", "query_g_checkpoint", self.csv_id)
		if r.cd - cp_rc.cd_walk > 0 then
			ret.errorcode = errorcode[1].code
			ret.msg = errorcode[1].msg
			ret.cd = r.cd - cp_rc.cd_walk
			return ret
		else
			cp_rc.cd_starttime = 0
			cp_rc.cd_finished = 1
			ret.errorcode = errorcode[1].code
			ret.msg = errorcode[1].msg
			ret.cd = 0
			return ret
		end
	end
end

function cls:checkpoint_exit(args, ... )
	-- body
	local ret = {}
 	if not user then
 		ret.errorcode = errorcode[2].code
 		ret.msg = errorcode[2].msg
 		return ret
 	end
 	self:cp_exit()
	ret.errorcode = errorcode[1].code
 	ret.msg = errorcode[1].msg
	return ret
end

return cls