package.path = "../cat/?.lua;../lualib/?.lua;" .. package.path
package.cpath = "../lua-cjson/?.so;"..package.cpath
local skynet = require "skynet"
require "functions"
local assert = assert
local table_name = ...
local cls = require "models/ara_leaderboardsmgr"
leaderboardsmgr = cls.new()

-- {ranking=id }
local top = 0
local ranking_name = {}

local CMD = {}

local function bsearch(k)
	-- body
	assert(type(k) == "number")
	assert(#ranking_name > 0)
	local low = 1
	local high = #ranking_name
	local mid
	while low <= high do
		if name_ranking[ranking_name[low]].key == k then
			return low + 1  -- return next position
		end
		if name_ranking[ranking_name[high]].key == k then
			return high + 1 -- return next position
		end
		mid = (high + low) / 2
		if name_ranking[ranking_name[mid]].key == k then
			return mid + 1
		elseif name_ranking[ranking_name[mid]].key < k then
			low = mid + 1
		else
			high = (mid - 1 >= 1) and mid-1 or 1
		end
	end
	assert(low > high)
	return low+1
end

function CMD.swap(rnk1, rnk2)
	-- body
	local ranking1 = leaderboardsmgr:get(rnk1):get_field("ranking")
	local ranking2 = leaderboardsmgr:get(rnk2):get_field("ranking")
	leaderboardsmgr:get(rnk1):set_field("ranking", ranking2)
	leaderboardsmgr:get(rnk2):set_field("ranking", ranking1)
	ranking_name[ranking1] = rnk2
	ranking_name[ranking2] = rnk1
end

function CMD.enter(id, key)
	-- body
	assert(false)
	local idx = bsearch(k)
	local l = #ranking_name
	local p = l
	while p >= idx do
		ranking_name[p+1] = ranking_name[p]
		p = p - 1
	end
	ranking_name[p] = id
	name_ranking[id] = { id = id, ranking=p, key=k}
	return p
end

function CMD.push(id, key)
	-- body
	local u = leaderboardsmgr:get(id)
	if u then
		return u.ranking
	else
		top = top + 1
		local ranking = top
		ranking_name[ranking] = id
		local tmp = {
			uid = id,
			ranking = ranking,
			k = key
		}
		local o = leaderboardsmgr:create_entity(tmp)
		leaderboardsmgr:add(o)
		o:update()
		return ranking
	end
end

function CMD.ranking(id)
	-- body
	assert(id)
	return assert(name_ranking[id].ranking)
end

function CMD.name(rnk)
	-- body
	assert(rnk)
	return assert(ranking_name[rnk])
end

function CMD.ranking_range(s, e)
	-- body
	assert(type(s) == "number")
	assert(type(e) == "number")
	assert(e > s)
	local l = {}
	for i=s,e do
		local id = ranking_name[i]
		if id then
			local r = leaderboardsmgr:get(id)
			table.insert(l, r)
		end
	end
	return l
end

function CMD.nearby(id)
	-- body
	local res = {}
	local r = leaderboardsmgr:get(id)
	table.insert(res, r)
	local ranking = r.ranking
	local _1 = ranking_name[ranking * 0.95]
	table.insert(res, leaderboardsmgr:get(_1).__fields)
	local _2 = ranking_name[ranking * 0.9]
	table.insert(res, leaderboardsmgr:get(_2).__fields)
	local _3 = ranking_name[ranking * 0.8]
	table.insert(res, leaderboardsmgr:get(_3).__fields)
	local _4 = ranking_name[ranking * 0.7]
	table.insert(res, leaderboardsmgr:get(_4).__fields)
	return res
end

local function print_c()
	-- body
	while true do 
		print("begain to print leaderboards")
		for i,v in ipairs(ranking_name) do
			print(i,v)
		end
		leaderboardsmgr:update()
		skynet.sleep(60 * 100)
	end
end

skynet.start(function ()
	-- body
	skynet.dispatch("lua", function(_,_, command, subcmd, ...)
		if command ~= "command" then
			local f = CMD[command]
			local r = f(subcmd, ... )
			if r then
				skynet.ret(skynet.pack(r))
			end
		else
		end
	end)
	leaderboardsmgr:load_db()
	for k,v in pairs(leaderboardsmgr.__data) do
		ranking_name[v.ranking] = v.uid
		top = top + 1
	end
	skynet.fork(print_c)
end)