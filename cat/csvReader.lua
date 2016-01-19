local csvreader = {} --store function 
local csvcont = {}  --store csvcont

local function trim_left(s)  
    return string.gsub(s, "^%s+", "");  
end  
    
-- 去掉字符串右空白  
local function trim_right(s)  
    return string.gsub(s, "%s+$", "");  
end  
  
-- 解析一行  
local function parseline(line)  
    local ret = {};  
  
    local s = line .. ",";  -- 添加逗号,保证能得到最后一个字段  
  
    while (s ~= "") do  
        --print(0,s);  
        local v = "";  
        local tl = true;  
        local tr = true;  
  
        while(s ~= "" and string.find(s, "^,") == nil) do  
            --print(1,s);  
            if(string.find(s, "^\"")) then  
                local _,_,vx,vz = string.find(s, "^\"(.-)\"(.*)");  
                --print(2,vx,vz);  
                if(vx == nil) then  
                    return nil;  -- 不完整的一行  
                end  
  
                -- 引号开头的不去空白  
                if(v == "") then  
                    tl = false;  
                end  
  
                v = v..vx;  
                s = vz;  
  
                --print(3,v,s);  
  
                while(string.find(s, "^\"")) do  
                    local _,_,vx,vz = string.find(s, "^\"(.-)\"(.*)");  
                    --print(4,vx,vz);  
                    if(vx == nil) then  
                        return nil;  
                    end  
  
                    v = v.."\""..vx;  
                    s = vz;  
                    --print(5,v,s);  
                end  
  
                tr = true;  
            else  
                local _,_,vx,vz = string.find(s, "^(.-)([,\"].*)");  
                --print(6,vx,vz);  
                if(vx~=nil) then  
                    v = v..vx;  
                    s = vz;  
                else  
                    v = v..s;  
                    s = "";  
                end  
                --print(7,v,s);  
  
                tr = false;  
            end  
        end  
  
        if(tl) then v = trim_left(v); end  
        if(tr) then v = trim_right(v); end  
  
        ret[#ret+1] = v;  
        --print(8,"ret["..table.getn(ret).."]=".."\""..v.."\"");  
  		--print( v , string.len( v ) )
        if(string.find(s, "^,")) then  
            s = string.gsub(s,"^,", "");  
        end  
  
    end  
  
    return ret;  
end  
  
  
  
--解析csv文件的每一行  
local function getRowContent(file)  
    local content;  
  
    local check = false  
    local count = 0  
    while true do  
        local t = file:read()  
        if not t then  if count==0 then check = true end  break end  
  
        if not content then  
            content = t  
        else  
            content = content..t  
        end  
  
        local i = 1  
        while true do  
            local index = string.find(t, "\"", i)  
            if not index then break end  
            i = index + 1  
            count = count + 1  
        end  
  
        if count % 2 == 0 then check = true break end  
    end  
  
    if not check then  assert(1~=1) end  
    return content  
end  
  
--解析csv文件  
function csvreader.getcont( fileName )
	assert(type(fileName) == "string")
	fileName = fileName .. ".csv"
	-- csv folder.
	local path = "./../cat/csv/" .. fileName
    local file = io.open(path, "r") 
    if file == nil then	
    	file = io.open(fileName, "r") 
    end
    assert(file)  
    local title = parseline( getRowContent(file))
    -- for k ,v in pairs( title ) do
    -- 	print("...............................................")
    -- 	print( k , v , string.len( v ) )
    -- end

    local content = {}  
    while true do

        local line = getRowContent( file )   
        if not line then break end 
        local parasedline = parseline( line )
        local newline = {}

        -- for i = 1 , #title do
        -- 	newline[title[i]] = parasedline[i]
        -- 	print("****************************")
        -- 	print(title[i] , parasedline[i])
        -- end
         
        table.insert(content, newline)  
    end  
    file:close()  
    return content 
end  



--[[local function trim_left(s)  
    return string.gsub(s, "^%s+", "");  
end  
  
-- 去掉字符串右空白  
local function trim_right(s)  
    return string.gsub(s, "%s+$", "");  
end  
  
-- 解析一行  
local function splitstr( line )  
    local ret = {};  
  
    local s = line .. ",";  -- 添加逗号,保证能得到最后一个字段  
  
    while (s ~= "") do  
        --print(0,s);  
        local v = "";  
        local tl = true;  
        local tr = true;  
  
        while(s ~= "" and string.find(s, "^,") == nil) do  
            --print(1,s);  
            if(string.find(s, "^\"")) then  
                local _,_,vx,vz = string.find(s, "^\"(.-)\"(.*)");  
                --print(2,vx,vz);  
                if(vx == nil) then  
                    return nil;  -- 不完整的一行  
                end  
  
                -- 引号开头的不去空白  
                if(v == "") then  
                    tl = false;  
                end  
  
                v = v..vx;  
                s = vz;  
  
                --print(3,v,s);  
  
                while(string.find(s, "^\"")) do  
                    local _,_,vx,vz = string.find(s, "^\"(.-)\"(.*)");  
                    --print(4,vx,vz);  
                    if(vx == nil) then  
                        return nil;  
                    end  
  
                    v = v.."\""..vx;  
                    s = vz;  
                    --print(5,v,s);  
                end  
  
                tr = true;  
            else  
                local _,_,vx,vz = string.find(s, "^(.-)([,\"].*)");  
                --print(6,vx,vz);  
                if(vx~=nil) then  
                    v = v..vx;  
                    s = vz;  
                else  
                    v = v..s;  
                    s = "";  
                end  
                --print(7,v,s);  
  
                tr = false;  
            end  
        end  
  
        if(tl) then v = trim_left(v); end  
        if(tr) then v = trim_right(v); end  
  
        ret[ #ret + 1 ] = v;  
        print(v , string.len( v ) )
        --print(8,"ret["..table.getn(ret).."]=".."\""..v.."\"");  
  
        if(string.find(s, "^,")) then  
            s = string.gsub(s,"^,", "");  
        end  
		  
    end  
    print("len " .. #ret )

    print(ret[1] , string.len(ret[1]))
    print(ret[#ret] , string.len(ret[#ret]))
  	ret[1] = string.gsub( ret[1] , " " , "" )
  	ret[#ret] = string.gsub( ret[#ret] , " " , "" )
  	print(ret[1] , string.len(ret[1]))
    print(ret[#ret] , string.len(ret[#ret]))
    return ret;  
end  

local 
function init_title( title )
		local titlecont = {}
		if nil == title then
			print("empty title")
			return nil 
		end
		print(title)
		local pos = 1
		
		local temp = splitstr( title )
		print("value in title is \n")
  			for k , v in ipairs( temp ) do
  				print( k , v )
  				print(string.len( v ))
  			end
		if temp ~= nil then
			for _ , val in ipairs( temp ) do
				
				titlecont[val] = {}
			end
		end
		return temp , titlecont
end	

local	
function getindex( content , col , colval ) -- format ( csvtable , columnname , columnval ) all prags should be string
	assert( content , col , colval )
	print(colval)
	print(content)
	print(col)

	for k , v in pairs(content) do
		print( k , v)
		
		if type(v) == "table" then
			for sk , sv in pairs( v ) do
				print( sk , sv)
			end
		end
	end
	local tab = content[col]
	if tab == nil then
		print("tab is nil")
	end
	local index = 0	
	
	for i = 1, #tab do
		if tab[i] == idval then
			print( i )
			return i
		end
	end
	
	print("can not find the idval : " .. colval)
	
	return nil
end	
								
function csvreader.getcont( filename )	
	local csvcont = {}
	local file = assert( io.open( filename , "r" ) )
	local title = file:read()
	local titlename = {}

	titlename , csvcont = init_title( title )

	if titlename == nil then
		return nil
	else		
		local tmp = {}			

		for line in file:lines() do
			local index = 1

			if line ~= nil then
				tmp = splitstr( line )
				if tmp ~= nil then
					for _, val in ipairs( tmp ) do
						print( titlename[index] , csvcont[titlename[index]]--)
						--table.insert( csvcont[titlename[index]] , val )
						--[[index = index + 1
					end
				end
			end
		end
	end		
	file.close()	

	return csvcont
end	
--]]
--[[function csvreader.findval( content , idval , clomnname2 )  This func is not in use for the timebing
	print( content , idval , clomnname2 )
	assert( content == nil or clomnname1 == nil or clomnname2 == nil )

	local index = getindex( content , idval )

	if index then
		return csvcont[clomnname2][index]
	end
	
	return nil
end

function csvreader.__getline( content , col , colval)

	assert( content and colval and col)
	local val = {}
	
	local index = getindex( content , col , colval )
	
	if index then
		for i , v in pairs( content ) do
			print( i, v[index])
			if i ~= "id" then
				val[i] = v[index]
			end
		end

		return val
	end
	
	return nil
end
		--]]		
return csvreader	
			
	
	
	
