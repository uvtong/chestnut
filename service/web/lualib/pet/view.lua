local skynet = require "skynet"
local query = require "query"
local errorcode = require "errorcode"
local json = require "cjson"
local dbutil = require "dbutil"
local rdb = ".DB"
local wdb = ".DB"

local function root(filename, ... )
	-- body
	return "../../"..filename
end

local function current(filename, ... )
	-- body
	return "./../../service/web/"..filename
end

local VIEW = {}

function VIEW:pull()
	-- body
	if self.method == "get" then
	elseif self.method == "post" then
		local uid = self.body[uid]
		local pet_id = self.body[pet_id]
		local table_name = "u_pet"
		local sql = dbutil.select(table_name, {{uid=uid, pet_id=pet_id}})
		local r = query.read(rdb, table_name, sql)
		if r then
			assert(uid == r[1]["uid"])
			assert(pet_id == r[1]["pet_id"])
			local ret = {}
			ret["errorcode"] = errorcode.E_SUCCUSS
			ret["uid"] = uid
			ret["pet_id"] = pet_id
			ret["gold"] = r[1]["gold"]
			ret["stage"] = r[1]["stage"]
			ret["level"] = r[1]["level"]
			return ret
		else
			local ret = {}
			ret["errorcode"] = errorcode.E_FAIL
			return ret
		end
	end
end

function VIEW:push( ... )
	-- body
	if self.method == "post" then
		local uid = self.body[uid]
		local pet_id = self.body[pet_id]
		skynet.error("uid:", uid, "pet_id:", pet_id)
		local table_name = "u_pet"
		local sql = dbutil.select(table_name, {{uid=uid, pet_id=pet_id}})
		skynet.error(sql)
		local r = query.read(rdb, table_name, sql)
		if r and #r > 0 then
			assert(uid == r[1]["uid"])
			assert(pet_id == r[1]["pet_id"])
			local gold = self.body["gold"]
			local stage = self.body["stage"]
			local level = self.body["level"]
			gold = gold > r[1]["gold"] and gold or r[1]["gold"]
			stage = stage > r[1]["stage"] and stage or r[1]["stage"]
			level = level > r[1]["level"] and level or r[1]["level"]
			local sql = dbutil.update(table_name, {{uid=uid, pet_id=pet_id}}, {gold=gold, stage=stage, level=level}) 
			local r = query.write(wdb, table_name, sql)
			local ret = {}
			ret.errorcode = errorcode.E_SUCCUSS
			return ret
		else
			local id = cc.genpk_2(uid, pet_id)
			local sql = dbutil.insert(table_name, {id=id, uid=uid, pet_id=pet_id, gold=self.body["gold"], stage=self.body["stage"], level=self.body["level"]})
			local r = query.write(wdb, table_name, sql)
			local ret = {}
			ret.errorcode = errorcode.E_SUCCUSS
			return ret
		end
	else
	end
end

function VIEW:pet()
	if self.method == "post" then
		local res = json.decode(self.args)
		for i=1,18 do
			local key = tostring(i)
			local v = res[key]
			if v["hunger_max"] ~= nil then
			end
			if v["hunger"] ~= nil then
			end
			if v["joyful_max"] ~= nil then
			end
			if v["joyful"] ~= nil then
			end
			if v["joyful_desc"] ~= nil then
			end
			if v["gold"] ~= nil then
			end
			if v["experience"] ~= nil then
			end
			if v["experience_desc"] ~= nil then
			end
			if v["faecesNum"] ~= nil then
			end
			if v["faecesNum"] ~= nil then
			end
			if v["liceNum"] ~= nil then
			end
			if v["growth"] ~= nil then
			end
			if v["level"] ~= nil then
			end
			if v["name"] ~= nil then
			end
			if v["sex"] ~= nil then
			end
			if v["petId"] ~= nil then
			end
			if v["growthState"] ~= nil then
			end
			if v["petBirthday"] ~= nil then
			end
			if v["masterName"] ~= nil then
			end
			if v["isSick"] ~= nil then
			end
			if v["isASick"] ~= nil then
			end
			if v["isBSick"] ~= nil then
			end
			if v["signInTime"] ~= nil then
			end
			if v["exitTime"] ~= nil then
			end
			if v["lasttm_sick"] ~= nil then
			end
			if v["lasttm_lice"] ~= nil then
			end
			if v["lasttm_faeces"] ~= nil then
			end
		end
	end
end

return VIEW
