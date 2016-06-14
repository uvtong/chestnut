local skynet = require "skynet"
local util = require "util"
local const = require "const"

local MAXEMAILNUM = 50

local _M = {}
_M.__data = {}
_M.__count = 0

local _Meta = { csv_id = 0 , uid=0, type=0, title=0, content = 0 , acctime = 0 , deltime = 0 , isread = 0 , isdel = 0 , itemsn1 = 0 , itemnum1 = 0 , 
			itemsn2 = 0 , itemnum2 = 0 ,itemsn3 = 0 , itemnum3 = 0 ,itemsn4 = 0 , itemnum4 = 0 ,itemsn5 = 0 , itemnum5 = 0 , iconid = 0 , isreward = 0 }

_Meta.__tname = "u_new_email"

function _Meta.__new()
 	-- body
 	local t = {}
 	setmetatable( t, { __index = _Meta } )
 	return t
end 

function _Meta:__insert_db()
	-- body
	local t = {}
	for k,v in pairs(self) do
		if not string.match(k, "^__*") then
			t[k] = self[k]
		end
	end
	skynet.send(util.random_db(), "lua", "command", "insert", self.__tname, t)
end

function _Meta:__update_db(t)
	-- body
	assert(type(t) == "table")
	local columns = {}
	for i,v in ipairs(t) do
		columns[tostring(v)] = self[tostring(v)]
	end
	skynet.send(util.random_db(), "lua", "command", "update", self.__tname, { { csv_id = self.csv_id , uid = self.uid } }, columns)
end

function _Meta:__getallitem()
	local item_list = {}
	print( "********************___getallitem is called" )
	for i = 1 , 5 do
		local id = "itemsn" .. i
		local num = "itemnum" .. i
		
		if nil ~= self[id] and 0 ~= self[num] then
			local ni = {}
			
			ni.itemsn = self[id]
			ni.itemnum = self[num]
			table.insert( item_list , ni )
		end
	end

	return item_list	
end

function _M.insert_db( values )
	assert(type(values) == "table" )
	local total = {}
	for i,v in ipairs(values) do
		local t = {}
		for kk,vv in pairs(v) do
			if not string.match(kk, "^__*") then
				t[kk] = vv
			end
		end
		table.insert(total, t)
	end
	skynet.send( util.random_db() , "lua" , "command" , "insert_all" , _Meta.__tname , total )
end 

function _M.create( P )
	assert(P)
	local u = _Meta.__new()
	for k , v in pairs( _Meta ) do
		if not string.match( k, "^__*" ) then
			--print( k , v , P[k])
			u[ k ] = assert( P[ k ] )
		end
	end
	return u
end	

function _M:add( u )
	assert(u)
	self.__data[tostring(u.csv_id)] = u
	self.__count = self.__count + 1
end
	
function _M:get_by_csv_id(csv_id)
	-- body
	return self.__data[tostring(csv_id)]
end

function _M:delete_by_csv_id(csv_id)
	-- body
	self.__data[tostring(csv_id)] = nil
	self.__count = self.__count - 1
end 
    
function _M:get_all_emails()
	for k , v in pairs( self.__data ) do
		print( k , v )
	end
	return self.__data
end 
	
function _M:get_count()
	-- body
	return self.__count
end 
	
function _M:recvemail( tvals )
	assert( tvals )
	if self.__count >= MAXEMAILNUM then
		self:sysdelemail()
	end

	local newemail = self.create( tvals )
	assert( newemail )
	self:add( newemail )
	newemail:__insert_db()

	print("add email succe in recvemail\n")
	return newemail
end 
	
function _M:sysdelemail()
	local readrewarded = {}
	local readunrewarded = {}
	local unread = {}
	
	local i = 1
	for k ,  v in pairs( self.__data ) do
		if i == 1 then 
			print( type( k ) , type( v ) )
			i = 2
		end	
			
		if true == v.isread then
			if true == v.isreward then
				table.insert( readrewarded , v.csv_id )
			else
				table.insert( readunrewarded , v.csv_id )
			end
		else
			table.insert( unread , { v.csv_id , v.acctime } )
		end 
	end	
  --delete read and getrewarded first  

	for _ , v in ipairs( readrewarded ) do
		self.__data[ tostring( v.csv_id ) ] = nil 
		self.__count = self.__count - 1
	end

	if self.__count <= MAXEMAILNUM then
		return
	end
  -- if still more than MAXEMAILNUMM then delete read , unrewarded 	
	for _ , v in ipairs( readunrewarded ) do
		self.__data[ tostring( v.csv_id ) ] = nil
		self.__count = self.__count - 1 
	end
	
	if self.__count <= MAXEMAILNUM then
		return
	end
 	
 	-- last delete the earlist unread emails  
	table.sort( unread , function ( a , b )  
			return ( a.acctime < b.acctime )
		end )
	
	local diff = self.__count - MAXEMAILNUM

	for i = 1 , diff do
		self.__data[ tostring( unread[ i ].csv_id ) ] = nil
		self.__count = self.__count - 1
	end
end	
	
return _M
