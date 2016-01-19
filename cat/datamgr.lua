--local skynet = require "skynet"
csvreader = require "csvReader"
	
datamgr = {}
datamgr._data = {}
local csvname = { --[[attribute = "Attribute" , level = "Level" ,--]] wakecost = "Wakecost" --[[, wakeattr = "Wakeattr"--]] } 
local path = "./../cat/csv/" --should be set in a conf file
	
function datamgr:add( name , content )
	if nil == name or nil == content then
		--skynet.error( "wrong arg in csvmgr:add\n" )
		print( "wrong arg in csvmgr:add\n" )		
		return nil
	end

	( self._data )[ name ] = content
end	
	
function datamgr:find( name )
		print( name )
	if nil ~= name then
		return (self._data)[name]
	else
		print( string.format("no data in %s" , name ) )
		return nil
	end 	
	
end 
    
function datamgr:findattributeItem( col , colval ) -- columnname and colvalue you want to search
	local tmp = datamgr:find("attribute")
	if tmp ~= nil then
		return csvreader.getline( tmp , col , tostring( colval ))
	end
end
	
function datamgr:findLevelItem( col , colval  )
	local tmp = datamgr:find("level")
	if tmp ~= nil then
		return csvreader.getline( tmp , col , tostring( colval ))
	end
end

function datamgr:findwakecostItem( col , colval)
	local tmp = datamgr:find("wakecost")
	if tmp ~= nil then
		return csvreader.getline( tmp , col , tostring( colval ) )
	end
end

function datamgr:findwakeattrItem(col , colval)
	local tmp = datamgr:find("wakeattr")
	if tmp ~= nil then
		return csvreader.getline( tmp , col , tostring( colval ) )
	end
end

function datamgr:startload()
	for k , v in pairs( csvname ) do
		local cont = csvreader.getcont ( path .. v )
		
		if nil ~= cont then 
			datamgr:add( k , cont )
			print(string.format("load successful %s\n" , v ) )
			cont = nil
		else
			--skynet.error( string.format( "load '%s' failed!\n"  , k ) )
			print( string.format( "load '%s' failed!\n"  , k ) )			
			return nil
		end 
	end
	return datamgr._data
end



return datamgr
