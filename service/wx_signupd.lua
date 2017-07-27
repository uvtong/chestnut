package.path = "./../../module/mahjong/lualib/?.lua;../../lualib/?.lua;"..package.path
local skynet = require "skynet"
require "skynet.manager"
local crypt = require "skynet.crypt"
local redis = require "skynet.db.redis"
local log = require "skynet.log"
local query = require "query"
local httpsc = require "https.httpc"
local json = require "cjson"
local queue = require "queue"
local dbmonitor = require "dbmonitor"
local const = require "const"

local server_win = { ["sample1"] = true }
local server_adr = { ["sample"]  = true }
local appid  = "wx3207f9d59a3e3144"
local secret = "d4b630461cbb9ebb342a8794471095cd"
local db

local conf = {
	host = "127.0.0.1" ,
	port = 6379 ,
	db = 0
}

local server_id = 1
local server_id_shift = 24
local internal_id = 1
local internal_id_mask = 0xffffff
local id_mask = 0xffffffff

local function gen_uid(id, ... )
	-- body
	local uid = db:incr(string.format("tb_count:%d:uid", const.UID_ID))
	uid = ((server_id << server_id_shift) | uid)
	dbmonitor.cache_update(string.format("tb_count:%d:uid", const.UID_ID))
	return uid
end

local function gen_nameid(id, ... )
	-- body
	local nameid = ""
	local id = db:incr(string.format("tb_count:%d:uid", const.NAME_ID))
	id = ((server_id << server_id_shift) | id)
	local hex = "0123456789abcdef"
	for i=1,8 do
		local idx = (id >> ((8 - i) * 4)) & 0xf
		nameid = nameid .. hex:sub(idx, idx)
	end
	dbmonitor.cache_update(string.format("tb_count:%d:uid", const.NAME_ID))
	return nameid
end

local function new_user(uid, sex, nickname, province, city, country, headimg, openid, nameid)
	-- body
	assert(uid and sex and nickname and province and city and country and headimg)
	db:set(string.format("tb_user:%d:uid", uid), uid)
	db:set(string.format("tb_user:%d:gold", uid), 0)
	db:set(string.format("tb_user:%d:diamond", uid), 0)
	db:set(string.format("tb_user:%d:checkin_month", uid), 0)
	db:set(string.format("tb_user:%d:checkin_count", uid), 0)
	db:set(string.format("tb_user:%d:checkin_mcount", uid), 0)
	db:set(string.format("tb_user:%d:checkin_lday", uid), 0)
	db:set(string.format("tb_user:%d:rcard", uid), 8)
	db:set(string.format("tb_user:%d:sex", uid), sex)
	db:set(string.format("tb_user:%d:nickname", uid), nickname)
	db:set(string.format("tb_user:%d:province", uid), province)
	db:set(string.format("tb_user:%d:city", uid), city)
	db:set(string.format("tb_user:%d:country", uid), country)
	db:set(string.format("tb_user:%d:headimg", uid), headimg)
	db:set(string.format("tb_user:%d:openid", uid), openid)
	db:set(string.format("tb_user:%d:nameid", uid), nameid)
	
	dbmonitor.cache_insert(string.format("tb_users:%d", uid))
end

local function new_unionid(unionid, uid, ... )
	-- body
	assert(unionid and uid)
	db:set(string.format("tg_openid:%s:openid", unionid), unionid)
	db:set(string.format("tg_openid:%s:uid", unionid), uid)
	--
	dbmonitor.cache_insert(string.format("tb_openid:%s", unionid))
end

local function new_nameid(nameid, uid, ... )
	-- body
	assert(nameid and uid)
	db:set(string.format("tb_nameid:%s:nameid", nameid), nameid)
	db:set(string.format("tb_nameid:%s:uid", nameid), uid)
	-- 
	dbmonitor.cache_insert(string.format("tb_nameid:%s", nameid))
end

local function auth_win_myself(code, ... )
	-- body
	local unionid = code
	local uid = db:get(string.format("tb_openid:%s:uid", unionid))
	if uid and math.tointeger(uid) > 0 then
		return uid
	else
		local uid = gen_uid()
		local nameid = gen_nameid()
		assert(uid and nameid)

		local sex = 1
		local r = math.random(1, 10)
		if r > 5 then
			sex = 1
		else
			sex = 2
		end
		
		local nickname = "hell"
		local province = 'Beijing'
		local city     = "Beijing"
		local country  = "CN"
		local headimg  = "xx"
		new_unionid(unionid, uid)
		new_nameid(nameid, uid)
		new_user(uid, sex, nickname, province, city, country, headimg, unionid, uid)

		return uid
	end
end

local function auth_android_wx(code, ... )
	-- body
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
	local access_token  = res["access_token"]
	local expires_in    = res["expires_in"]
	local refresh_token = res["refresh_token"]
	local openid        = res["openid"]
	local scope         = res["scope"]
	local unionid       = res["unionid"]
	log.info("access_token = " .. access_token)
	log.info("openid = " .. openid)

	local uid = db:get(string.format("tb_openid:%s:uid", unionid))
	if uid and uid > 0 then
		return uid
	else
		url = "https://api.weixin.qq.com/sns/userinfo?access_token=%s&openid=%s"
		url = string.format(url, access_token, openid)
		local ok, body, code = skynet.call(".https_client", "lua", "get", "api.weixin.qq.com", url)
		if not ok then
			error("access api.weixin.qq.com wrong")
		end

		local res = json.decode(body)
		local nickname   = res["nickname"]
		local sex        = res["sex"]
		local province   = res["province"]
		local city       = res["city"]
		local country    = res["country"]
		local headimgurl = res["headimgurl"]
		url = string.sub(headimgurl, 19)
		log.info(url)
		local statuscode, body = httpc.get("wx.qlogo.cn", url, respheader)
		local headimg = crypt.base64encode(body)

		local uid = gen_uid()
		local nameid = gen_nameid()

		new_unionid(unionid, uid)
		new_nameid(nameid, uid)
		new_user(uid, sex, nickname, province, city, country, headimg, unionid, uid)

		return uid
	end
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
	if server_adr[server] then
		local ok, err = pcall(auth_android_wx, code)
		if ok then
			local res = {}
			res.code = 200
			res.uid = err
			return res
		else
			local res = {}
			res.code = 501
			return res
		end
	elseif server_win[server] then
		local ok, err = pcall(auth_win_myself, code)
		if ok then
			local res = {}
			res.code = 200
			res.uid = err
			return res
		else
			local res = {}
			res.code = 501
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