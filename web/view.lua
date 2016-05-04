package.cpath = "../lua-cjson/?.so;" .. package.cpath
local skynet = require "skynet"
require "skynet.manager"
local json = require "cjson"
local template = require "resty.template"
local csvreader = require "csvReader"
local query = require "query"

template.caching(true)
template.precompile("index.html")

local VIEW = {}

local function path( filename )
	-- body
	assert(type(filename) == "string")
	return "../web/templates/" .. filename
end

function VIEW.index()
	-- body
	local R = {}
	function R:__get()
		-- body
		-- local query = self.query
		--for i = 1 , 100 do
		--end
		local func = template.compile( path( "index.html" ) )
		local r = func { message = "hello, world."}
		return r
	end
	function R:__post()
		-- body
		-- local body = self.body
		
				--skynet.send(".channel", "lua", "fire", 1, {head="sljd", content="jksldfj", })
	end
	function R:__file()
		-- body
		-- local file = self.file
	end
	return R
end

local function Split(szFullString, szSeparator)  
		local nFindStartIndex = 1  
		local nSplitIndex = 1  
		local counter = 1
		local counter2 = 0
		local title = {}
		local tstrcont = {}

		while true do  
   			local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)  
   			local t  = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)  
   			if t == "" then
   				break
   			end
   			if 1 == counter then
   				title = csvreader.parseline( csvreader.getStrRowContent( t ) )
   				assert( title )
   				counter = counter + 1 
   			else
   				counter2 = counter2 + 1
   				local line = csvreader.parseline( csvreader.getStrRowContent( t ) )
   				
   				local newline = {}
   				for i = 1 , #title do
        			title[i] = string.gsub( title[i] , "^%s*(.-)%s*$" , "%1" )
        			newline[ title[ i ] ] = line[ i ]
		        end

		        table.insert( tstrcont , newline )
   			end 
   			nFindStartIndex = nFindLastIndex + string.len(szSeparator)
		end  	
		return tstrcont
end

function VIEW.user()
	-- body
	local R = {}
	function R:__get()
		-- body
		-- local query = self.query
		local func = template.compile(path("user.html"))
		local r = func()
		return r	
	end         
	function R:__post()
		-- body 
		-- local body = self.body
	end 		
				
	function R:__file()
		-- body
	end 
	return R
end

function VIEW.role()
	-- body
	local R = {}
	function R:__get()
		-- body
		-- local query = self.query
		local func = template.compile(path("role.html"))
		local r = func()
		return r
	end
	function R:__post()
		-- body
		-- local body = self.body
	end
	function R:__file()
		-- body
		-- local file = self.file
		print(self.file)
		return "succss"
	end
	return R
end

function VIEW.email()
	-- body
	local R = {}
	function R:__get()
		-- body
		-- local query = self.query
		local func = template.compile(path("email.html"))
		return func { message = "EMAIL"}
	end
	function R:__post()
		-- body
		-- local body = self.body
		local send_type = tonumber(self.body["send_type"])
		local c = {}
		c["type"] = tonumber(self.body["type"])  -- 1 or 2
		c["title"] = self.body["title"]
		c["content"] = self.body["content"]
		c["itemsn1"] = tonumber(self.body["itemsn1"])
		c["itemnum1"] = tonumber(self.body["itemnum1"])
		c["itemsn2"] = tonumber(self.body["itemsn2"])
		c["itemnum2"] = tonumber(self.body["itemnum2"])
		c["itemsn3"] = tonumber(self.body["itemsn3"])
		c["itemnum3"] = assert(tonumber(self.body["itemnum3"]))
		local receiver = tonumber(self.body["receiver"])
		if send_type == 1 then
			skynet.send(".channel", "lua", "send_email_to_group", c, {{ uid = receiver }})
			local ret = {}
			ret.errorcode = errorcode[1].code
			ret.msg = errorcode[1].msg
			return json.encode(ret)
		elseif send_type == 2 then
			-- assert(false)
			skynet.send(".channel", "lua", "send_public_email_to_all", c)
			local ret = {}
			ret.errorcode = errorcode[1].code
			ret.msg = errorcode[1].msg
			return json.encode(ret)
		end
	end
	function R:__file()
		-- body
		-- local file = self.file
		local file = self.file
		assert( csvreader and file )
		print("filecont is  " , file )

		local cont = Split( file , "\r\n" )
		assert( cont )

		for k , v in ipairs( cont ) do
			local ne = {}
			ne.type = tonumber( v.email_type )
			print()
			ne.title = v.title
			ne.content = v.content
			local titem = util.parse_text( v.reward , "(%d+%*%d+%*?)" , 2 )

			assert( titem )
			local i = 1
			for sk , sv in ipairs( titem ) do

				local itemsn = "itemsn" .. i
				local itemnum = "itemnum" .. i

				ne[ itemsn ] = tonumber( sv[ 1 ] )
				ne[ itemnum ] = tonumber( sv[ 2 ] )
				print( ne[ itemsn ] , ne[ itemnum ])
				i = i + 1
			end 

			skynet.send(".channel", "lua", "send_email_to_group", ne , { { uid = assert( tonumber( v.csv_id ) ) } } )
		end

		local ret = {}
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].msg

		return json.encode(ret)
	end
	return R
end

function VIEW.props()
	-- body
	local R = {}
	function R:__get()
		-- body
		-- local query = self.query
		local users = skynet.call(db, "lua", "command", "select_and", "users")
		for i,v in ipairs(users) do
			for kk,vv in pairs(v) do
				print(kk,vv)
			end
		end
		local func = template.compile(path("props.html"))
		return func { message = "fill in the blank text.", users = users }
	end
	function R:__post()
		-- body
		-- local body = self.body
		local uaccount = self.body["uaccount"]
		local csv_id = tonumber(self.body["csv_id"])
		local num = tonumber(self.body["num"])
		if not csv_id and not num then
			local ret = {
				ok = 0,
				msg = "failture",
			}
			return json.encode(ret)
		end
		local user = skynet.call(db, "lua", "command", "select_user", { uaccount = uaccount})
		print(user.id, csv_id, num)
		skynet.send(util.random_db(), "lua", "command", "insert_prop", user.id, csv_id, num)
		local ret = {
			ok = 1,
			msg = "send succss."
		}
		return json.encode(ret)
	end
	function R:__file()
		-- body
		-- local file = self.file
		print(self.file)
	end
	return R
end

function VIEW.equipments()
	-- body
	local R = {}
	function R:__get()
		-- body
		-- local query = self.query
		local users = skynet.call(db, "lua", "command", "select_and", "users")
		local func = template.compile(path("equipments.html"))
		return func { message = "fill in the blank text.", users = users }
	end
	function R:__post()
		-- body
		-- local body = self.body
		if self.body["cmd"] == "user" then
			local uaccount = self.body["uaccount"]
			local user = skynet.call(db, "lua", "command", "select_user", { uaccount = uaccount})
			local achievements = skynet.call(util.random_db(), "lua", "command", "select_and", "equipments", { user_id = user.id })
			local ret = {
				errorcode = 0,
				msg = "succss",
				achievements = achievements
			}
			return json.encode(ret)
		elseif self.body["cmd"] == "equip" then
			local user = skynet.call(db, "lua", "command", "select_user", { uaccount = uaccount})
			skynet.send(db, "lua", "command", "insert", { user_id = user.id, achievement_id = achievement_id, level = level})
			local ret = {
				ok = 1,
				msg = "send succss."
			}
			return json.encode(ret)
		end
	end
	function R:__file()
		-- body
		-- local file = self.file
		print(self.file)
	end
	return R
end

function VIEW.validation()
	-- body
	local R = {}
	function R:__post()
		-- body
		local ret = {}
		local table_name = self.body["table_name"]
		local sql = string.format("select * from columns where table_name=\"%s\";", table_name)
		local r = query.select_sql_wait(table_name, sql, query.DB_PRIORITY_2)
		if #r == 0 then
			ret.ok = 0
			ret.msg = "failture"
		end
		local fields = "{\n"
		local head = "{\n"
		for i,v in ipairs(r) do
			local seg = ""..v.COLUMN_NAME.." = {\n"
			seg = seg .. string.format("\tpk = false,\n")
			seg = seg .. string.format("\tfk = false,\n")
			seg = seg .. string.format("\tuq = false,\n")
			if v.DATA_TYPE == "int" then
				seg = seg .. string.format("\tt = \"%s\",\n", "number")
			elseif v.DATA_TYPE == "varchar" or v.DATA_TYPE == "char" then
				seg = seg .. string.format("\tt = \"%s\",\n", "string")
			end
			seg = seg .. "},"
			head = head .. seg

			seg = seg .. string.format("\tc = 0,\n")
			fields = fields .. string.format("\t%s = { c = 0, v = nil },\n", v.COLUMN_NAME)
		end
		head = head.."}\n"
		fields = fields.."}\n"

		local s, ss = require("model")()
		local dir = skynet.getenv("pro_dir")
		local addr = io.open(dir.."models/"..table_name.."mgr.lua", "w")
		local content = string.format(s, table_name, head, ss, table_name, fields)
		addr:write(content)
		addr:close()
		ret.ok = 1
		ret.msg = "succss"
		return json.encode(ret)
	end
	return R
end

return VIEW
