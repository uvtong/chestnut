package.path = "./../cat/?.lua;" .. package.path
local skynet = require "skynet"
local csvReader = require "csvReader"
require "skynetmanager"

local drawmgr = {}
drawmgr._data = {}
local updatetime = 17	 
local MAXDRAWNUM = 5	

local drawtype = { FRIEND = 1 , ONETIME = 2 , TENTIME = 3 }
local bdraw_isfriend = false
local bdraw_isfree = false
local bdraw_isonetime = false
local bdraw_istentime = false
			 	
local draw = { uid , drawtype , cdrawtime , srecvtime , cdtime , consumetype , propid , amount , isdealed }
	
function draw:_new()
	local t = {}

	setmetatable( t , { __index = draw } )

	return t
end	

function drawmgr:_create( t )
	assert( t )

	local n = draw:_new()
	assert( n )

	n.uid = user.id 
	n.drawtype =  t.drawtype
	n.cdrawtime = t.cdrawtime or 0
	n.srecvtime = os.time()
	n.propid = 0
	n.amount = 0
	n.isdealed = false
	iffree = t.iffree or 1 -- 0 free 1 not free

	print( "create successfully" )

	return n
end	
	
local function randomaddr()
	local r = math.random( 1 , 5 )
	local addr = skynet.localname( string.format( ".db%d", math.floor( r ) ) )
	print("addr is " .. addr )
	assert( addr , "randomaddr failed\n" )

	return addr
end

function drawmgr:_db_getdioment_or_heart_num( t )
	assert( t )

	local addr = randomaddr()
	assert( addr )

	local r = skynet.call( addr , "lua" , "command" , "select_dioment_or_heart_num" , t )
	print( "get num" .. r )

	return r
end		
		
function drawmgr:_db_update_prop( t )
	assert( t )

	local addr = randomaddr()
	assert( addr )

	skynet.call( addr , "lua" , "command" , "" , t )

	print( "update prop over" )
end		
		
function drawmgr:_db_select_drawtime( t )
	assert( t )

	local addr = randomaddr()
	assert( addr )

	local r = skynet.call( addr , "lua" , "command" , "" , t )
	print( "print drawtime is called " .. r )

	return r
end		
		
local function getsettime()
	local year = tonumber( os.date( "%Y" , os.time() ) )
	local month = tonumber( os.date( "%m" , os.time() ) )
	local day = tonumber( os.date( "%d" , os.time() ) )
	local hightime = { year = year , month = month , day = day , hour = updatetime , min = 0 , sec = 0 }
	local hour = tonumber( os.date( "%H" , os.time() ) )
	local settime
	if 0 <= hour and hour < updatetime then
		settime = os.time( hightime ) - 60 * 60 * 24
	else
		settime = os.time( hightime )
	end		
	
	return settime
end			
				
function drawmgr:_db_select_drawmsg( t )
	assert( t )

	local addr = randomaddr()
	assert( addr )
	local r = skynet.call( addr , "lua" , "command" , "" , t )
	print( "get drawmsg successful" )

	return r
end 			
	
function drawmgr:_db_select_onetimedraw( t )
	assert( t )
		
	local addr = randomaddr()
	local r = skynet.call( addr , "lua" , "command" , "select_onetimedraw" , t )

	print( "select onetimedraw is called" )
	return r
end			
	
function drawmgr:_db_select_frienddraw( t )
	assert( t )

	local addr = randomaddr()
	local r = skynet.call( addr , "lua" , "command" , "select_frienddraw" , t )

	print( "select frienddraw is called" )
	return r
end	
	
function drawmgr:applydraw()
	print( "applydraw is called in drawmgr" )
	local ret = {}
	ret.list = {}
	
	local t = {}
	t.uid = user.id
	t.drawtype = drawtype.FRIEND
	local r = drawmgr:_db_select_frienddraw( t )
	local settime = getsettime()
	
	local v = {}
	if nil == r or ( r < settime - 60 * 60 * 24 ) or ( r < settime  and os.time() > settime ) then
		v.drawtype = drawtype.FRIEND
		v.drawnum = 0
	else 
		v.drawtype = drawtype.FRIEND
		v.drawnum = 1
	end 

	table.insert( ret.list , v )

	t.drawtype = drawtype.ONETIME

	local r = drawmgr:_db_select_onetimedraw( t ) -- if free == 1
	if nil == r then
		local t.drawnum = MAXDRAWNUM
		local t.lefttime = 0
	else
		local left = MAXDRAWNUM - r.drawnum 
		t.drawtype = drawtype.ONETIME
		t.drawnum = ( left == 0 ) and MAXDRAWNUM or left
		local nowtime = os.time() 
		if nowtime >= ( srecvtime + 60 * 60 * 24 ) then
			t.lefttime = 0
		else
			t.lefttime = nowtime - srecvtime
		end
	end	
	table.insert( ret.list , t )			
	          
	return ret
end			  	
	          
function drawmgr:_db_insert_drawmsg( t )
	assert( t )

	local addr = randomaddr()
	assert( addr )
	skynet.call( addr , "lua" , "command" , "insert_drawmsg" , t )
	print( "insert a drawmsg successfully" )
end

function drawmgr:tentimedraw( tv )
	assert( tv )
	local proplist = {}
	local drawcost = csvReader.getcont( "drawcost" )
	assert( drawcost )
	local dm = drawmgr:_create( tv ) 
	assert( dm )
	drawmgr:_db_insert_drawmsg( dm )
	print( "insert drawmsg over" )

	local line = drawcost[tostring( id * 1000 )]
	assert( line )

	local v = {}
	v.uid = user.id
	v.csvid = tonumber( line.cointype )

	local num = drawmgr:_db_getdioment_or_heart_num( v )
    				
	if num < tonumber( drawcost.price ) then
		local ret = {}
		ret.ok = false
		ret.msg = "not enough money"

		return ret
	else 
		num = num - tonumber( drawcost.price )
		proplist = getpropidlist( drawtype.TENTIME )
		
		local t = {}
		t.tname = "props"
		t.content = { num = num }
		t.condition = { user_id = user.id , csv_type = v.csvid }

		drawmgr:_db_update_prop( t )
		print( "update prop successfully in tentimedraw" )
	end

	print( "ten time draw is over" )

	return proplist
end	
	
function drawmgr:_db_getrandomid( type )
	assert( type )

	local addr = randomaddr()
	assert( addr )

	local t = {}
	t.drawtype = type

	local r = skynet.call( addr , "lua" , "command" , "" , t )
	print( "getrandomid" .. r )

	return r
end

local function getgroupid( list , val )
	assert( val )

	local len = #list
	local sub = tonumber( list[len].probid )
	for len , 1 do
		if sub < val  then
			len = len - 1
			sub = sub + tonumber( list[len].probid )
		else
			return tonumber( list[len].groupid )
		end
	end
end

local function splitsubreward_bytype(  mainreward , typeid )
	assert( typeid )

	local sublist = {}

	for i = 1 , #mainreward do
		if typeid == mainreward[i].typeid then
			table.insert( sublist , mainreward[i] )
		end
	end

	return sublist
end		
	
local function getpropidlist( type )
	assert( type )
	local propidlist = {}
	propidlist.list = {}
		
	local subreward = csvReader.getcont( "subreward" )
	local mainreward = csvReader.getcont( "mainreward" )
	assert( subreward and mainreward )

	local sublist = splitsubreward_bytype( mainreward , type * 1000 )
	assert( sublist )

	if drawtype.TENTIME == type then
		for i = 1 , 10 do
			local r = drawmgr:_db_getrandomid( type )
			print( r )
			local id = getgroupid( sublist , r )
			for i = 1 , #subreward do
				if tonumber( subreward[ i ].groupid ) == id then
					table.insert( propidlist.list , { propid = tonumber( subreward[ i ].propid ) ,
						propnum = tonumber( subreward[ i ].num ) } )
				end 	
			end	
		end	  
	else
		local r = drawmgr:_db_getrandomid( type )
		print( r )
		local id = getgroupid( sublist , r )
		table.insert( propidlist.list , { propid = tonumber( subreward[ id ].propid ) ,
						propnum = tonumber( subreward[ id ].num ) })
	end		

	assert( propidlist )
	print( "get propidlist successfully" )
	return propidlist
end			

function drawmgr:onetimedraw( tv )
	assert( tv )
	local id = tv.drawtype
	local dm = drawmgr:_create( tv ) 
	assert( dm )
	drawmgr:_db_insert_drawmsg( dm )
	print( "insert drawmsg over" )

	if true == tv.iffree then
		local proplist = getpropidlist( id )
		assert( proplist )
		print( "get for free successfully" )
		return proplist
	else	
		local t = {}
		local drawcost = csvReader.getcont( "drawcost" )
		assert( drawcost )

		local line = drawcost[tostring( id * 1000 )]
		assert( line )

		local t = {}
		t.uid = user.id
		t.csvid = tonumber( line.cointype )

		local num = drawmgr:_db_getdioment_or_heart_num( t )
    		
		if num < tonumber( drawcost.price ) then
			local ret = {}
			ret.ok = false
			ret.msg = "not enough money"
			return ret
		else
			diomentnum = diomentnum - tonumber( drawcost.price )
			local t = {}
			t.tname = "props"
			t.content = { num = diomentnum }
			t.condition = { user_id = user.id , csv_type = 1 }

			drawmgr:_db_update_prop( t )
			print( "update prop successfully in tentimedraw" )
		end	
end 
		
function drawmgr:frienddraw( tv )
	assert( tv )
	local id = tv.drawtype
	local t = {}
	local proplist = {}
	local drawcost = csvReader.getcont( "drawcost" )
	assert( drawcost )
	local dm = drawmgr:_create( tv ) 
	assert( dm )
	drawmgr:_db_insert_drawmsg( dm )
	print( "insert drawmsg over" )

	local line = drawcost[tostring( id * 1000 )]
	assert( line )

	local t = {}
	t.uid = user.id
	t.csvid = tonumber( line.cointype )

	local num = drawmgr:_db_getdioment_or_heart_num( t )
    		
	if num < tonumber( drawcost.price ) then
		local ret = {}
		ret.ok = false
		ret.msg = "not enough money"

		return ret
	else
		num = num - tonumber( drawcost.price )
		proplist = getpropidlist( drawtype.FRIEND )

		local t = {}
		t.tname = "props"
		t.content = { num = num }
		t.condition = { user_id = user.id , csv_type = 1 }

		drawmgr:_db_update_prop( t )
		print( "update prop successfully in tentimedraw" )
	end	
	return proplist
end

return drawmgr