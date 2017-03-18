package.path = "./../../module/mahjong/sysemail/?.lua;"..package.path
local skynet = require "skynet"
require "skynet.manager"
local query = require "query"
local inbox = require "inbox"
local mail = require "mail"
local util = require "util"
local log = require "log"

local tname = "tg_count"
local sys = 3
local internal_id = 1
local myin

local cmd = {}

function cmd.start( ... )
	-- body
	myin = inbox.new(nil, nil)

	local sql = string.format("select * from %s where id = %d;", tname, sys)
	local res = query.select("tg_count", sql)
	if #res > 0 then
		internal_id = res[1].uid
	else
		internal_id = 0
		local sql = string.format("insert into %s values (%d, %d)", tname, sys, internal_id)
		query.insert("tg_count", sql)
	end

	if internal_id == 0 then
		internal_id = internal_id + 1
		local sql = string.format("update %s set uid= %d where id = %d ", tname, internal_id, sys)
		query.update("tg_count", sql)

		local m = mail.new(nil, nil, myin)
		m:set_id(internal_id)
		m:set_datetime(os.time())
		m:set_title("welcome to mahjong world")
		m:set_content("hello world.")
		m:insert_db()
		myin:add(m)
	else
		myin:load_db_to_data()
	end

	return true
end

function cmd.close( ... )
	-- body
	return true
end

function cmd.kill( ... )
	-- body
	skynet.exit()
end

function cmd.poll(cnt, viewed, ... )
	-- body
	return myin:poll(cnt, viewed)
end

function cmd.get(id, ... )
	-- body
	local mail = myin:find(id)
	local res = {}
	res.id = id
	res.title = mail.title.value
	res.content = mail.content.value
	return res
end

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function (_, _, command, subcmd, ... )
		-- body
		local f = cmd[command]
		local r = f(subcmd, ...)
		if r ~= nil then
			skynet.retpack(r)
		end
	end)
	skynet.register ".SYSEMAIL"
end)