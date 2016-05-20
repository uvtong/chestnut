local skynet = require "skynet"
require "skynet.manager"
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

function VIEW:index()
	-- body
	if self.method == "get" then
		local func = template.compile( path( "index.html" ) )
		return func { message = "hello, world."}
	end
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

function VIEW:user()
	-- body
	if self.method == "get" then
		local func = template.compile(path("user.html"))
		return func()
	end
end

function VIEW:role()
	-- body
	if self.method == "get" then
		local func = template.compile(path("role.html"))
		return func()
	elseif self.method == "file" then
		print(self.file)
		return "succss"
	end
end

function VIEW:email()
	-- body
	if self.method == "get" then
		local func = template.compile(path("email.html"))
		return func { message = "EMAIL"}
	elseif self.method == "post" then
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
	elseif self.method == "file" then
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
		return ret
	end
end

function VIEW:props()
	-- body
	if self.method == "get" then
		local users = skynet.call(db, "lua", "command", "select_and", "users")
		for i,v in ipairs(users) do
			for kk,vv in pairs(v) do
				print(kk,vv)
			end
		end
		local func = template.compile(path("props.html"))
		return func { message = "fill in the blank text.", users = users }
	elseif self.method == "post" then
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
		return ret
	end
end

function VIEW:equipments()
	-- body
	if self.method == "get" then
		local users = skynet.call(db, "lua", "command", "select_and", "users")
		local func = template.compile(path("equipments.html"))
		return func { message = "fill in the blank text.", users = users }
	elseif self.method == "post" then
		if self.body["cmd"] == "user" then
			local uaccount = self.body["uaccount"]
			local user = skynet.call(db, "lua", "command", "select_user", { uaccount = uaccount})
			local achievements = skynet.call(util.random_db(), "lua", "command", "select_and", "equipments", { user_id = user.id })
			local ret = {
				errorcode = 0,
				msg = "succss",
				achievements = achievements
			}
			return ret
		elseif self.body["cmd"] == "equip" then
			local user = skynet.call(db, "lua", "command", "select_user", { uaccount = uaccount})
			skynet.send(db, "lua", "command", "insert", { user_id = user.id, achievement_id = achievement_id, level = level})
			local ret = {
				ok = 1,
				msg = "send succss."
			}
			return ret
		end
	end
end

local function print_table(table_name)
	-- body
	local sql = string.format("select * from columns where table_name=\"%s\";", table_name)
		local r = query.read(".rdb", table_name, sql)
		if #r == 0 then
			ret.ok = 0
			ret.msg = "failture"
			return ret
		end
		local pk = ""
		local fk = ""
		local funcs = ""
		local count = "{\n"
		local fields = "{\n"
		local head = "{\n"
		local head_ord = ""
		for i,v in ipairs(r) do
			head_ord = head_ord..string.format(
[[
	self.__head_ord[%d] = self.__head[%s]
]], i, v.COLUMN_NAME)
			local seg = "\t"..v.COLUMN_NAME.." = {\n"
			local pk_seg = string.format("\t\tpk = false,\n")
			local fk_seg = string.format("\t\tfk = false,\n")
			if v.COLUMN_KEY == "PRI" then
				pk = v.COLUMN_NAME
				pk_seg = string.format("\t\tpk = true,\n")
			else
				local sql = string.format("select * from INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_NAME ='%s' and COLUMN_NAME = '%s'", table_name, v.COLUMN_NAME)
				local r = query.read(".rdb", table_name, sql)
				for i,vv in ipairs(r) do
					if vv.CONSTRAINT_NAME == "PRIMARY" then
						print(sql)
						ret.ok = 0
						ret.msg = "PRIMARY failture"
						return ret
					end	
					local sql = string.format("select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS t where t.TABLE_NAME='%s' and CONSTRAINT_TYPE='FOREIGN KEY' and CONSTRAINT_NAME = '%s'", table_name, vv.CONSTRAINT_NAME)
					local r = query.read(".rdb", table_name, sql)
					print(sql)
					if #r == 1 then
						fk_seg = string.format("\t\tfk = true,\n")	
						fk = v.COLUMN_NAME
					end	
				end
			end
			seg = seg .. pk_seg
			seg = seg .. fk_seg
			seg = seg .. string.format("\t\tcn = \"%s\",\n", v.COLUMN_NAME)
			seg = seg .. string.format("\t\tuq = false,\n")
			if v.DATA_TYPE=="int" or v.DATA_TYPE=="bigint" or v.DATA_TYPE=="tinyint" or v.DATA_TYPE=="smallint" then
				seg = seg .. string.format("\t\tt = \"%s\",\n", "number")
			elseif v.DATA_TYPE == "varchar" or v.DATA_TYPE == "char" then
				seg = seg .. string.format("\t\tt = \"%s\",\n", "string")
			end
			seg = seg .. "\t},\n"
			head = head .. seg

			seg = seg .. string.format("\tc = 0,\n")
			count = count .. string.format("\t\t\t%s = 0,\n", v.COLUMN_NAME)
			fields = fields .. string.format("\t\t\t%s = 0,\n", v.COLUMN_NAME)
			funcs = funcs .. string.format(
[[
function cls:set_%s(v, ... )
	-- body
	assert(v)
	self.__fields.%s = v
end

function cls:get_%s( ... )
	-- body
	return self.__fields.%s
end

]], v.COLUMN_NAME, v.COLUMN_NAME, v.COLUMN_NAME, v.COLUMN_NAME)
		end
		head = head.."}\n"
		fields = fields.."\t\t}\n"
		count = count.."\t\t}\n"
		
		local dir = skynet.getenv("pro_dir")
		
		local s = require("entitycppt")
		local entitycls = table_name.."entity"
		local addr = io.open(dir.."models/"..table_name.."entity.lua", "w")
		local content = string.format(s, entitycls, fields, count, funcs)
		addr:write(content)
		addr:close()

		local s = require("modelcppt")
		local mgrcls = table_name.."mgr"
		local addr = io.open(dir.."models/"..table_name.."mgr.lua", "w")
		local content = string.format(s, mgrcls, table_name, head, head_ord, pk, fk, entitycls)
		addr:write(content)
		addr:close()
end

function VIEW:validation()
	-- body
	if self.method == "post" then
		local r = query.read(".rdb", "all", "select table_name from information_schema.tables where table_schema='project' and table_type='base table'")
		if r then
			local ok, result = pcall(function ()
				-- body
				for i,v in ipairs(r) do
					for kk,vv in pairs(v) do
						print_table(vv)
					end
				end
			end)
			if ok then
				local ret = {}
				ret.ok = 1
				ret.msg = "succss"
				return ret
			else
				local ret = {}
				ret.ok = 0
				ret.msg = "failture"
				return ret
			end
		end
	end
end

function VIEW:validation_ro()
	-- body
	if self.method == "post" then
		local ret = {}
		local table_name = self.body["table_name"]
		local sql = string.format("select * from columns where table_name=\"%s\";", table_name)
		local r = query.select_sql_wait(table_name, sql, query.DB_PRIORITY_1)
		if #r == 0 then
			ret.ok = 0
			ret.msg = "failture"
			return ret
		end
		local head = "{\n"
		for i,v in ipairs(r) do
			local seg = ""..v.COLUMN_NAME.." = {\n"
			if v.DATA_TYPE == "int" then
				seg = seg .. string.format("\tt = \"%s\",\n", "number")
			elseif v.DATA_TYPE == "varchar" or v.DATA_TYPE == "char" then
				seg = seg .. string.format("\tt = \"%s\",\n", "string")
			end
			seg = seg .. "},"
			head = head .. seg
		end
		head = head.."}\n"
		local s = require "tool"
		s = string.format(s, head)
		local dir = skynet.getenv("pro_dir")
		local addr = io.open(dir.."models/"..table_name.."mgr.lua", "w")
		addr:write(s)
		addr:close()
		ret.ok = 1
		ret.msg = "succss"
		return ret
	end
end

function VIEW:_404()
	-- body
	if self.method == "get" then
		return "404"
	end
end

return VIEW
