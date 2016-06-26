local skynet = require "skynet"
local dc = require "datacenter"
local sd = require "sharedata"
local errorcode = require "errorcode"
local const = require "const"
local super = require "module"
local cls = class("checkpointmodule", super)

function cls:ctor(env, ... )
	-- body
	self._env = env
end

function cls:gen_csv_id(chapter, type, checkpoint, ... )
	-- body
	return chapter*1000+type*100+checkpoint
end

function cls:cp_progress( ... )
	-- body
	local modelmgr = self._env:get_modelmgr()
	local u_checkpointmgr = modelmgr:get_u_checkpointmgr()
	local r = {}
	for k,v in pairs(u_checkpointmgr.__data) do
		local item = {}
		item.chapter = v:get_field("chapter")
		item.chapter_type0 = v:get_field("chapter_type0")
		item.chapter_type1 = v:get_field("chapter_type1")
		item.chapter_type2 = v:get_field("chapter_type2")
		table.insert(r, item)
	end
	return r
end

function cls:hanging()
	-- body

	local l = {}

	local user = self._env:get_user()
	local game = self._env:get_game()

	local ochapter = user:get_field("cp_chapter")
	local otype = user:get_field("cp_type")
	local ocheckpoint = user:get_field("cp_checkpoint")
	local ocsv_id = self:gen_csv_id(ochapter, otype, ocheckpoint)

	local key = string.format("%s:%d", "g_checkpoint", ocsv_id)
	local g_cp_rc = sd.query(key)

	local cp_rc = u_checkpoint_rcmgr:get_by_csv_id(ocsv_id)   -- unlock
	local hanging_walk = cp_rc:get_field("hanging_walk")
	hanging_walk = hanging_walk + (now - cp_rc:get_field("hanging_starttime"))
	
	local prop = u_propmgr:get_by_csv_id(const.GOLD)
	local num = prop:get_field("num") + g_cp_rc.gain_gold * hanging_walk
	prop:set_field("num", num)
	local item = {}
	item.csv_id = const.GOLD
	item.num = num
	table.insert(l, item)

	prop = u_propmgr:get_by_csv_id(const.EXP)
	num = prop:get_field("num") + g_cp_rc.gain_exp * hanging_walk
	prop:set_field("num", num)
	local item = {}
	item.csv_id = const.GOLD
	item.num = num
	table.insert(l, item)

	cp_rc:set_field("hanging_walk", 0)
	cp_rc:set_field("hanging_starttime", 0)

	local hanging_drop_walk = cp_rc:get_field("hanging_drop_walk")
	hanging_drop_walk = hanging_drop_walk + (now - cp_rc:get_field("hanging_drop_starttime"))
	cp_rc:set_field("hanging_drop_starttime", 0)

	return l
end

function cls:choose(chapter, type, checkpoint, csv_id, now)
	-- body
	-- first resolve last hanging
	local user = self._env:get_user()
	local modelmgr = self._env:get_modelmgr()
	local u_checkpoint_rcmgr = modelmgr:get_u_checkpoint_rcmgr()
	local u_propmgr = modelmgr:get_u_propmgr()
	local ochapter = user:get_field("cp_chapter")
	local otype = user:get_field("cp_type")
	local ocheckpoint = user:get_field("cp_checkpoint")
	local ocsv_id = self:gen_csv_id(ochapter, otype, ocheckpoint)
	local cp_rc = u_checkpoint_rcmgr:get_by_csv_id(ocsv_id)   -- unlock
	local hanging_walk = cp_rc:get_field("hanging_walk")
	hanging_walk = hanging_walk + (now - cp_rc:get_field("hanging_starttime"))
	
	local key = string.format("%s:%d", "g_checkpoint", ocsv_id)
	local g_cp_rc = sd.query(key)

	local prop = u_propmgr:get_by_csv_id(const.GOLD)
	local num = prop:get_field("num") + g_cp_rc.gain_gold * hanging_walk
	prop:set_field("num", num)

	prop = u_propmgr:get_by_csv_id(const.EXP)
	num = prop:get_field("num") + g_cp_rc.gain_exp * hanging_walk
	prop:set_field("num", num)

	cp_rc:set_field("hanging_walk", 0)
	cp_rc:set_field("hanging_starttime", 0)

	local hanging_drop_walk = cp_rc:get_field("hanging_drop_walk")
	hanging_drop_walk = hanging_drop_walk + (now - cp_rc:get_field("hanging_drop_starttime"))
	cp_rc:set_field("hanging_drop_starttime", 0)

	-- hanging_drop_walk

	if cp_rc:get_field("passed") == 0 then
		if cp_rc:get_field("cd_finished") == 1 then
		else
			local walk = now - cp_rc:get_field("cd_starttime")
			walk = cp_rc:get_field("cd_walk") + walk
			if walk >= g_cp_rc.cd then
				cp_rc:set_field("cd_walk", walk)
				cp_rc:set_field("cd_finished", 1)
			else
				cp_rc:set_field("cd_walk", walk)
			end
			cp_rc:set_field("cd_starttime", 0)
		end
	end

	user:set_field("cp_chapter", chapter)
	user:set_field("cp_type", type)
	user:set_field("cp_checkpoint", checkpoint)	
	local cp_rc = u_checkpoint_rcmgr:get_by_csv_id(csv_id)   -- unlock 
	cp_rc:set_field("hanging_starttime", now)
	cp_rc:set_field("hanging_drop_starttime", now)
	if cp_rc:get_field("passed") == 1 then
		local ret = {}
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].msg
		return ret
	else
		if cp_rc:get_field("cd_finished") == 1 then
			local ret = {}
			ret.errorcode = errorcode[1].code
			ret.msg = errorcode[1].msg
			ret.passed = 0
			ret.cd = 0
			return ret
		else
			local key = string.format("%s:%d", "g_checkpoint", csv_id)
			local g_cp_rc = sd.query(key)
			cp_rc:set_field("cd_starttime", now)
			local ret = {}
			ret.errorcode = errorcode[1].code
			ret.msg = errorcode[1].msg
			ret.passed = 0
			ret.cd = g_cp_rc.cd - cp_rc:get_field("cd_walk")
			return ret
		end
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
	ret.l = self:cp_progress()
	ret.chapter = u:get_field("cp_chapter")
	ret.type = u:get_field("cp_type")
	ret.checkpoint = u:get_field("cp_id")
	ret.drop_id1 = u:get_field("cp_drop_id1")
	ret.drop_id2 = u:get_field("cp_drop_id2")
	ret.drop_id3 = u:get_field("cp_drop_id3")
	return ret
end

function cls:checkpoint_hanging(args, ... )
	-- body
	local user = self._env:get_user()
	if not user then
		local ret = {}
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	-- enter
	local ok, result = pcall(self.hanging, self)
	if ok then
		return result
	else
		local ret = {}
		ret.errorcode = errorcode[34].code
		ret.msg = errorcode[34].msg
		return ret
	end
end

function cls:checkpoint_hanging_choose(args, ... )
	-- body
	local user = self._env:get_user()
	local game = self._env:get_game()
	local modelmgr = self._env:get_modelmgr()
	local u_checkpointmgr = modelmgr:get_u_checkpointmgr()
	assert(self.chapter*1000+self.type*100+self.checkpoint == self.csv_id)
	-- must <= cp_chapter
	if args.chapter > user:get_field("cp_chapter") and args.chapter <= 0 then
		local ret = {}
		ret.errorcode = errorcode[37].code
		ret.msg  = errorcode[37].msg
		return ret
	else
		local now = os.time()
		local cp = user.u_checkpointmgr:get_by_csv_id(args.chapter)
		if args.type == 0 then
			if args.checkpoint <= cp.chapter_type0 then
				local ok, result = pcall(self.choose, self, args.chapter, args.type, args.checkpoint, args.csv_id, now)
				if ok then
					return result 
				else
					local ret = {}
					ret.errorcode = errorcode[37].code
					ret.msg  = errorcode[37].msg
					return ret
				end
			else
				local ret = {}
				ret.errorcode = errorcode[37].code
				ret.msg = errorcode[37].msg
				return ret
			end
		elseif self.type == 1 then
			if args.checkpoint <= cp.chapter_type1 then
				local ok, result = pcall(self.choose, self, args.chapter, args.type, args.checkpoint, args.csv_id, now)
				if ok then
					return result 
				else
					local ret = {}
					ret.errorcode = errorcode[37].code
					ret.msg  = errorcode[37].msg
					return ret
				end
			else
				local ret = {}
				ret.errorcode = errorcode[37].code
				ret.msg = errorcode[37].msg
				return ret
			end
		elseif self.type == 2 then
			if args.checkpoint <= cp.chapter_type1 then
				local ok, result = pcall(self.choose, self, args.chapter, args.type, args.checkpoint, args.csv_id, now)
				if ok then
					return result 
				else
					local ret = {}
					ret.errorcode = errorcode[37].code
					ret.msg  = errorcode[37].msg
					return ret
				end
			else
				local ret = {}
				ret.errorcode = errorcode[37].code
				ret.msg = errorcode[37].msg
				return ret
			end
		else
			local ret = {}
			ret.errorcode = errorcode[37].code
			ret.msg = errorcode[37].msg
			return ret
		end
	end
end

function cls:checkpoint_battle_play(args, ... )
	-- body
	local user = self._env:get_user()
	local modelmgr = self._env:get_modelmgr()
	local u_checkpoint_rcmgr = modelmgr:get_u_checkpoint_rcmgr()
	local chapter = user:get_field('cp_chapter')
	local type = user:get_field("cp_type")
	local checkpoint = user:get_field("cp_checkpoint")
	assert(chapter == args.chapter)
	assert(type == args.type)
	assert(checkpoint == args.checkpoint)
	local csv_id = self:gen_csv_id(chapter, type, checkpoint)
	local cp_rc = u_checkpoint_rcmgr:get_by_csv_id(csv_id)
	assert(cp_rc:get_field("passed") == 0)
	assert(cp_rc:get_field("cd_finished") == 0)
	local now = os.time()
	cp_rc:set_field("cd_starttime", now)
	cp_rc:set_field("cd_walk", 0)
	local key = string.format("%s:%d", "g_checkpoint", csv_id)
	local g_cp_rc = sd.query(key)
	local ret = {}
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.cd = g_cp_rc.cd
	return ret
end

function cls:checkpoint_battle_exit(args)
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
	local user = self._env:get_user()
	local cp_fighting = user:get_field("cp_fighting")
	if cp_fighting == 1 then
	else
	end
	local ret = {}
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	return ret
end

function cls:checkpoint_exit(args, ... )
	-- body
	local ret = {}
 	if not user then
 		ret.errorcode = errorcode[2].code
 		ret.msg = errorcode[2].msg
 		return ret
 	end
	ret.errorcode = errorcode[1].code
 	ret.msg = errorcode[1].msg
	return ret
end


function cls:checkpoint_drop_collect(args, ... )
	-- body
	local user = self._env:get_user()
	local modelmgr = self._env:get_modelmgr()
	local u_propmgr = modelmgr:get_u_propmgr()
	local factory = self._env:get_myfactory()
	if #args.drop_slot <= 3 then
		for i,v in ipairs(args.drop_slot) do
			local key = string.format("cp_drop_id%d", v)
			local drop_id = user:get_field(key)
			assert(drop_id ~= 0)
			local prop = factory:get_prop(drop_id)
			prop:set_field("num", prop:get_field("num") + 1)
			user:set_field(key, 0)
		end
		local ret = {}
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].msg
		return ret
	else
		local ret = {}
		ret.errorcode = errorcode[37].code
		ret.msg = errorcode[37].msg
		return ret
	end
end

return cls