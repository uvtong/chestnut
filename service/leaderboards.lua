local skynet = require "skynet"
local assert = assert

-- {id = { id=0, ranking=0, key=} }
local name_ranking = {}
-- {ranking=id }
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
	local u1 = ranking_name[rnk1]
	local u2 = ranking_name[rnk2]
	name_ranking[u1].ranking = rnk2
	name_ranking[u2].ranking = rnk1
	ranking_name[rnk1] = u2
	ranking_name[rnk2] = u1
end

function CMD.enter(id, k)
	-- body
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

function CMD.push(id, k)
	-- body
	local l = #ranking_name
	local rnk = l+1
	ranking_name[rnk] = id
	name_ranking[id] = {id=id, ranking=rnk, key=k}
	return rnk
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

skynet.start(function ()
	-- body
	skynet.dispatch("lua", function(_,_, command, subcmd, ...)
		if command ~= "command" then
			local f = CMD[command]
			local r = f( ... )
			if r then
				skynet.ret(skynet.pack(r))
			end
		else
		end
	end)
end)