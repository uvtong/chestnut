local skynet = require "skynet"
require "skynet.manager"
local util = {}

function util.random_db()
	-- body
	local r = math.random(1, 5)
	local addr = skynet.localname(string.format(".db%d", math.floor(r))) 
	return addr
end

local function __and( t )
	-- body
	assert(type(t) == "table")
	local seg = "("
	for k,v in pairs(t) do
		assert(type(v) ~= "table")
		local seg1 = ""
		if type(v) == "number" then
			seg1 = string.format("%s = %d", k, v)
		elseif type(v) == "string" then
			seg1 = string.format("%s = \"%s\"", k, v)
		else
			assert(false)
		end
		seg = seg .. seg1 .. " and "
	end
	return string.gsub(seg, "(.*)%sand%s$", "%1)")
end

local function __or( t )
	-- body
	assert(type(t) == "table")
	local seg = "("
	for i,v in ipairs(t) do
		assert(type(v) == "table")
		assert(#v == 1)
		local seg1 = ""
		for kk,vv in pairs(v) do
			if type(vvv) == "number" then
				seg1 = string.format("%s = %d", k, v)
			elseif type(v) == "string" then
				seg1 = string.format("%s = \"%s\"", k, v)
			else
				assert(false)
			end	
		end
		seg = seg .. seg1 .. " or "
	end
	return string.gsub(seg, "(.*)%sor%s$", "%1%)")
end

local function __condition( t )
	-- body
	-- { { k1 = {{},{} }, k2 = "" }, {}} ===> (((A or B) and C) or D)
	assert(type(t) == "table")
	local seg = ""
	for i,v in ipairs(t) do
		assert(type(v) == "table")
		local r1 = {}
		local r2 = {}
		for kk,vv in pairs(v) do
			if type(vv) == "table" then
				r1[kk] = __or(vv)
			else
				r2[kk] = vv
			end
		end
		if #r1 > 0 then
			r1["other"] = __and(r2)
			local seg1 = "("
			for k,v in pairs(r1) do
				r3 = r3 .. v .. " and "
			end
			t[i] = string.gsub(seg1, "(.*)%sand%s$", "%1)")
		else
			t[i] = __and(r2)
		end
		seg = seg .. t[i] .. " or "
	end
	return string.gsub(seg, "(.*)%sor%s$", "%1")
end

local function print_sql( sql )
	-- body
	assert(type("sql") == "string")
	print("\\**" .. sql .. "**\\")
end

function util.select( table_name, condition, columns )
	-- body
	local columns_str = "("
	if not columns then
		columns_str = "*"
	else
		for k,v in pairs(columns) do
			columns_str = columns_str .. v .. ", "	
		end
		columns_str = string.gsub(columns_str, "(.*)%,%s$", "%1")
		columns_str = columns_str .. ")"
	end
	local condition_str 
	if type(condition) == "table" then
		condition_str = __condition(condition)
		if #condition_str > 0 then
			condition_str = " where " .. condition_str
		end
	elseif type(condition) == "string" then
		condition_str = condition
		if #condition_str > 0 then
			condition_str = " where " .. condition_str
		end
	elseif type(condition) == "nil" then
		condition_str = ""
	else
		assert(false)
	end
	local sql = string.format("select %s from %s", columns_str, table_name) .. condition_str
	print_sql(sql)
	return sql
end

function util.update( table_name, condition, columns )
	-- body
	assert(type(condition) == "table")
	assert(type(columns) == "table")
	local columns_str = "set "
	for k,v in pairs(columns) do
		print(k, v)
		local seg = ""
		if type(v) == "string" then
			seg = string.format("%s = \"%s\"", k, v)
		elseif type(v) == "number" then
			-- seg = string.format("%s = %d", k, math.tointeger(v))
			seg = string.format("%s = %d", k, v)
		else
			assert(false)
		end
		columns_str = columns_str .. seg .. ", "
	end
	print(columns_str)
	columns_str = string.gsub(columns_str, "(.*)%,%s$", "%1")
	local condition_str = __condition(condition)
	if #condition_str > 0 then	
		condition_str = " where " .. condition_str
	end
	local sql = string.format("update %s ", table_name) .. columns_str .. condition_str
	print_sql(sql)
	return sql
end

function util.insert( table_name, columns )
	-- body
	assert(type(columns) == "table")
	local columns_str = "("
	local values_str = "("
	for k,v in pairs(columns) do
		columns_str = columns_str .. k .. ", "	
		if type(v) == "string" then
			v = "\'" .. v .. "\'"
		end
		values_str = values_str .. v .. ", "
	end
	columns_str = string.gsub(columns_str, "(.*)%,%s$", "%1)")
	values_str = string.gsub(values_str, "(.*)%,%s$", "%1)")
	local sql = string.format("insert into %s ", table_name) .. columns_str .. " values " .. values_str
	print_sql(sql)
	return sql
end

function util.set_timeout(ti, f, ... )
	-- body
	assert(ti and f)
	local function cb( ... )
		-- body
		if f then
			f()
		end
	end
	skynet.timeout(ti, cb)
	return function ( ... )
		-- body
		f = nil
	end
end

function util.cm_sec()
	-- body
	local nt = os.date("*t")
	local t = {}
	t.year  = nt.year
	t.month = nt.month
	t.day   = 1
	return os.time(t), nt.month
end

function util.cd_sec( ... )
	-- body
	local nt = os.date("*t")
	local t = {}
	t.year  = nt.year
	t.month = nt.month
	t.day   = nt.day
	return os.time(t), nt.day
end

function util.redis_hval(hval, ... )
	-- body
	local h = {}
	local key
	for i,v in ipairs(hval) do
		if i % 2 == 1 then
			key = v
		else
			h[key] = v
		end
	end
	return h
end

return util