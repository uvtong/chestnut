
package.path = "./../cat/?.lua;" .. package.path
--local db = require "db"
require "skynet.manager"
local skynet = require "skynet"
local netpack = require "netpack"
local socket = require "socket"

local emailbox = {}
emailbox._data = {}

local userid 
local MAXEMAILNUM = 50
local emailnum = 0

local email = { id , isdel , emailtype , isread , isreward , acctime , iconid , title , content , item = {} }
--local etype = { DEL_AFTER_READ = 1 , NOTDEL_AFTER_READ = 2 , DEL_AFRER_REWARD = 3 , NOTDEL_AFTER_REWARD = 4 }
local itemtable = { itemid , itemnum }
	
function itemtable._new( ... )
	local t = {}

	setmetatable( t , { __index = itemtable } )

	return t
end	
	
function emailbox:_addemail( e )
	if e == nil then
		print( "e is nil ")
	end
	--local id = tostring( e.id )

	(emailbox._data)[tostring(e.id)] = e

	print( "add email successfully!\n" ) 
end	
	
function emailbox:_delete( eid )
	assert( eid )

	( emailbox._data )[tostring( eid )] = nil
end	
	
function emailbox:_create( tvals )
	assert( tvals , "tvals is nil in emailbox:create\n" )

	local newemail = email._new()
	assert( newemail , "newemail failed\n" )

	newemail.id = tvals.id
	newemail.emailtype = tvals.emailtype
	newemail.isread = tvals.isread and ( ( tvals.isread == 0 ) and false  or true ) or false
	newemail.isreward = tvals.isreward and ( ( tvals.isreward == 0 ) and false or true )or false
	newemail.isdel = tvals.isdel and ( ( tvals.isdel == 0 ) and false or true ) or false
	--newemail.isdel = 
	newemail.acctime = tvals.acctime
	newemail.iconid = tvals.iconid
	newemail.title = tvals.title
	newemail.content = tvals.content 
	
	for i = 1 , 5 do
		local id = "itemsn" .. i
		local num = "itemnum" .. i
		if 0 ~= tvals[id] and nil ~= tvals[id] then
			print( tvals[id])
			local ni = itemtable._new()

			ni.itemid = tvals[id]
			ni.itemnum = tvals[num]
			table.insert( newemail.item , ni )
			print("insert a item to email \n")
		end
	end    		
	--TODO waiting for the format of item in tvals 

	return newemail
end

function email._new( ... )
	local t = {}

	setmetatable( t , { __index = email } ) 
	--setmetatable( t.item , { __index = ni } )

	return t
end

function email:_add( itemid , itemnum )
	assert( itemid and itemnum , "add failed in itemtable:add\n" )

	local newitem = itemtable._new()
	newitem.itemid = itemid
	newitemitemnum = itemnum

	table.insert( ( self._data ).item , newitem )
	return newitem
end	
	
function email:getallitem()
	return self.item
end		
	
local function randomaddr()
	local r = math.random( 1 , 5 )
	local addr = skynet.localname( string.format( ".db%d", math.floor( r ) ) )
	print("addr is " .. addr )
	assert( addr , "randomaddr failed\n" )

	return addr
end	
	
--**********emailbox dbop****************
	
function emailbox:_db_getallemails( uid )
	local addr = randomaddr()
	local t = {}
	t.uid = uid
	local r = skynet.call( addr, "lua", "command", "select_allemails", t )

	if nil == r then
		print( "select nil in getallemails\n" )
	end

	return r
end	
	
function emailbox:_db_wbreademail( uid , eid )
	assert( uid and eid )
	
	local addr = randomaddr()
		
	local t = {}
	t.uid = uid
	t.emailid = eid

	skynet.send( addr , "lua" , "command" , "update_reademail" ,  t )	
	print( "update reademail successfully\n" )
end		
		
function emailbox:_db_wbdelemail( uid , eid )
	assert( uid and eid )
	
	local addr = randomaddr()
	
	local t = {}
	t.uid = uid
	t.emailid = eid

	skynet.send( addr , "lua" , "command" , "update_delemail" ,  t )	
	print( "update delemail successfully\n" )
end		
		
function emailbox:_db_wbrecvreward( uid , eid , etype )
	assert( uid and eid )
	
	local addr = randomaddr()
	
	local t = {}
	t.uid = uid
	t.emailid = eid

	skynet.send( addr , "lua" , "command" , "update_getreward" ,  t )

	if 1 == etype then -- accreward at one time
		skynet.send( addr , "lua" , "command" , "update_reademail" , t )		
	end		 
	
	print( "update rewardemail successfully\n" )
end		
		
function emailbox:_db_wbaddemail( tvals )
	assert( tvals )
	local addr = randomaddr()
	
	print( "content of new email is :" )
	for k , v in pairs( tvals ) do
		print( k , v )
	end 

	skynet.send( addr , "lua" , "command" , "insert_newemail" , tvals )
end	
	
--************************************************	
--************************************************
	
function emailbox:loademails( uid )
	userid = uid
	local r = emailbox:_db_getallemails( uid )
	
	if r then
		for i , v in ipairs( r ) do
    		local t = emailbox:_create( v )
    		assert( t )
    		print("add email id " .. t.id )
    		emailbox:_addemail( t )
    		print( "emailbox create an email successfully" ) 
    	end 
	end

	if  #r > MAXEMAILNUM then
		emailbox:_sysdelemail()
	end	

	emailnum = emailbox:_getemailnum()

	return emailbox
end	
   	
function emailbox:reademail( uid , id_list )
	assert( uid and id_list )
	for k , v in pairs( id_list ) do
		print( k , v , v.id )
		
		local e = self._data[ tostring( v.id ) ]
		assert( e ) 
		e.isread = true
		emailbox:_db_wbreademail( uid , v.id )
	end 
end	
 	
function emailbox:deleteemail( uid , id_list )
	assert( uid and id_list )
	for k , v in pairs( id_list ) do
		self._data[ tostring( v.id ) ].isdel = true
		emailbox:_db_wbdelemail( uid , v.id )
		emailnum = emailnum - 1
	end
end	
	
function emailbox:getreward( uid , id_list )
	assert( uid and id_list )
	for k , v in pairs( id_list ) do
		self._data[ tostring( v.id ) ].isreward = true
		emailbox:_db_wbrecvreward( uid , v.id , v.type )
	end
end	
	
function emailbox:recvemail( tvals )
	assert( tvals )
	if emailnum >= MAXEMAILNUM then
		emailbox:_sysdelemail()
		emailnum = emailbox:_getemailnum()
	end

	tvals.acctime = os.time() -- an integer
	local newemail = emailbox:_create( tvals )
	assert( newemail )
	emailbox:_addemail( newemail )
	print( "recve a email" )

	newemail.uid = userid
	emailbox:_db_wbaddemail( newemail )
	emailnum = emailnum + 1
	print("add email succe in recvemail\n")

	return newemail
end	
	
function emailbox:sendemail( )	
	
end	
	
function emailbox:_getemailnum()
	local index = 0
	for i , v in pairs( self._data ) do
		index = index + 1
	end 
	
	return index
end	
	
function emailbox:_sysdelemail()
	local readrewarded = {}
	local readunrewarded = {}
	local unread = {}
	
	local i = 1
	for k ,  v in pairs( user.exailbox._data ) do
		if i == 1 then 
			print( type( k ) , type( v ) )
			i = 2
		end	
			
		if true == v.isread then
			if true == v.isreward then
				table.insert( readrewarded , v.id )
			else
				table.insert( readunrewarded , v.id )
			end
		else
			table.insert( unread , { v.id , v.acctime } )
		end 
	end	
  --delete read and getrewarded first  

	for _ , v in ipairs( readrewarded ) do
		self._data[ tostring( v.id ) ] = nil 
	end

	if emailbox:_getemailnum() <= MAXEMAILNUM then
		return
	end
  -- if still more than MAXEMAILNUMM then delete read , unrewarded 	
	for _ , v in ipairs( readunrewarded ) do
		self._data[ tostring( v.id ) ] = nil 
	end

	local all
	all = emailbox:_getemailnum()
	if all <= MAXEMAILNUM then
		return
	end
 	
 	-- last delete the earlist unread emails  
	table.sort( unread , function ( a , b )  
			return ( a.acctime < b.acctime )
		end )
	
	local diff = all - MAXEMAILNUM

	for i = 1 , diff do
		self._data[ tostring( unread[ i ].id ) ] = nil
	end

end	
	
return emailbox
