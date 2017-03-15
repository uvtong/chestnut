package.path = "./../../module/mahjong/sysemail/?.lua;"..package.path
local skynet = require "skynet"
require "skynet.manager"
local query = require "query"
local inbox = require "inbox"
local mail = require "mail"
local util = require "util"

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
		local sql = string.format("insert into %s values (%d, %d)", tname, sys, internal_id)
		query.insert("tg_count", sql)

		local m = mail.new(nil, nil, myin)
		m:set_id(internal_id)
		m:set_datetime(os.time())
		m:set_title("welcome to mahjong world")
		m:set_content("hello world.")
		m:insert_db()
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