package.path = "./../../module/mahjong/lualib/?.lua;../../lualib/?.lua;"..package.path
local skynet = require "skynet"
require "skynet.manager"
local log = require "log"
local query = require "query"
local httpc = require "http.httpc"
local httpsc = require "httpsc"
local json = require "cjson"
local log = require "log"
local redis = require "redis"
local queue = require "queue"
local dbmonitor = require "dbmonitor"
local const = require "const"

local appid = "wx3207f9d59a3e3144"
local secret = "d4b630461cbb9ebb342a8794471095cd"
local db

local conf = {
	host = "127.0.0.1" ,
	port = 6379 ,
	db = 0
}

local function new_user(uid, sex, nickname, province, city, country, headimg )
	-- body
	assert(uid and sex and nickname and province and city and country and headimg)
	db:set(string.format("tg_users:%d:uid", uid), uid)
	db:set(string.format("tg_users:%d:gold", uid), 0)
	db:set(string.format("tg_users:%d:diamond", uid), 0)
	db:set(string.format("tg_users:%d:checkin_month", uid), 0)
	db:set(string.format("tg_users:%d:checkin_count", uid), 0)
	db:set(string.format("tg_users:%d:checkin_mcount", uid), 0)
	db:set(string.format("tg_users:%d:checkin_lday", uid), 0)
	db:set(string.format("tg_users:%d:rcard", uid), 0)
	db:set(string.format("tg_users:%d:sex", uid), sex)
	db:set(string.format("tg_users:%d:nickname", uid), nickname)
	db:set(string.format("tg_users:%d:province", uid), province)
	db:set(string.format("tg_users:%d:city", uid), city)
	db:set(string.format("tg_users:%d:country", uid), country)
	db:set(string.format("tg_users:%d:headimg", uid), headimg)
	
	dbmonitor.cache_insert(string.format("tg_users:%d", uid))
end

local function new_unionid(unionid, suid, nickname_uid, ... )
	-- body
	assert(unionid and suid and nickname_uid)
	db:set(string.format("tg_uid:%s:uid", unionid), unionid)
	db:set(string.format("tg_uid:%s:suid", unionid), suid)
	db:set(string.format("tg_uid:%s:nickname_uid", unionid), nickname_uid)

	dbmonitor.cache_insert(string.format("tg_uid:%s", unionid))
end

local CMD = {}

function CMD.start( ... )
	-- body
	db = redis.connect(conf)
	return true
end

function CMD.close( ... )
	-- body
	db:disconnect()
	return true
end

function CMD.kill( ... )
	-- body
	skynet.exit()
end

function CMD.signup(server, code, ... )
	-- body
	if server == "sample" then
		httpc.dns()
		httpc.timeout = 1000 -- set timeout 1 second
		local respheader = {}
		local url = "/sns/oauth2/access_token?appid=%s&secret=%s&code=%s&grant_type=authorization_code"
		url = string.format(url, appid, secret, code)
		
		local ok, body, code = skynet.call(".https_client", "lua", "get", "api.weixin.qq.com", url)
		if not ok then
			local res = {}
			res.code = 201
			res.uid  = 0
			return res
		end
			
		local res = json.decode(body)
		local access_token = res["access_token"]
		local expires_in   = res["expires_in"]
		local refresh_token = res["refresh_token"]
		local openid = res["openid"]
		local scope = res["scope"]
		local unionid = res["unionid"]
		log.info("access_token = " .. access_token)
		log.info("openid = " .. openid)
		local res = query.select("tg_uid", string.format("seclect * from tg_uid where uid = '%s'", unionid))
		if #res > 0 then
			local res = {}
			res.code = 200
			res.uid  = unionid
			return res
		else
			url = "https://api.weixin.qq.com/sns/userinfo?access_token=%s&openid=%s"
			url = string.format(url, access_token, openid)
			local ok, body, code = skynet.call(".https_client", "lua", "get", "api.weixin.qq.com", url)
			if not ok then
				local res = {}
				res.code = 202
				res.uid  = 0
				return res
			end
			log.info(body)
			local res = json.decode(body)
			local nickname = res["nickname"]
			local sex = res["sex"]
			local province = res["province"]
			local city = res["city"]
			local country = res["country"]
			local headimgurl = res["headimgurl"]
			url = string.sub(headimgurl, 19)
			log.info(url)
			local statuscode, body = httpc.get("wx.qlogo.cn", url, respheader)
			local headimg = body

			local res = skynet.call(".UID_MGR", "lua", "login", unionid)
			assert(res.new)
			local nickname_uid = skynet.call(".UNAME_MGR", "lua", "name")
			
			skynet.fork(new_unionid, unionid, suid, nickname)
			skynet.fork(new_user, uid, sex, nickname, province, city, country, headimg)

			local res = {}
			res.code = 200
			res.uid  = unionid
			return res
		end
	else
		local unionid = code
		unionid = db:get(string.format("tg_uid:%s:uid", unionid))
		if unionid then
			local res = {}
			res.code = 200
			res.uid  = unionid
			return res
		else
			unionid = code
			local suid = db:incr(string.format("tg_count:%d:uid", const.UID_ID))
			local nickname_uid = db:incr(string.format("tg_count:%d:uid", const.NAME_ID))
			dbmonitor.cache_update(string.format("tg_count:%d:uid", const.UID_ID))
			dbmonitor.cache_update(string.format("tg_count:%d:uid", const.NAME_ID))						

			local sex = 1
			local nickname = "hell"
			local province = 'SC'
			local city = "x"
			local country = "CN"
			local headimg = "xx"
			new_unionid(unionid, suid, nickname_uid)
			new_user(suid, sex, nickname, province, city, country, headimg)

			local res = {}
			res.code = 200
			res.uid  = unionid
			return res
		end
	end
end

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function (_, source, command, ... )
		-- body
		local f = assert(CMD[command])
		local r = f( ... )
		if r ~= noret then
			skynet.retpack(r)
		end
	end)
	skynet.register ".WX_SIGNUPD"
end)