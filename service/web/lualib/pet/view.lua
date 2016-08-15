local skynet = require "skynet"
local template = require "resty.template"
local csvreader = require "csvReader"
local query = require "query"
local errorcode = require "errorcode"
local json = require "cjson"

template.caching(true)
template.precompile("index.html")

local function root(filename, ... )
	-- body
	return "../../"..filename
end

local function path( filename )
	-- body
	assert(type(filename) == "string")
	return "../../service/web/templates/" .. filename
end

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

local VIEW = {}

function VIEW:index()
	-- body
	if self.method == "get" then
		local func = template.compile( path( "index.html" ) )
		return func { message = "hello, world."}
	end
end

function VIEW:user()
	-- body
	if self.method == "post" then
		local func = template.compile(path("user.html"))
		return func()
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
