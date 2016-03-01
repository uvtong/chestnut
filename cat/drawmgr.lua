package.path = "./../cat/?.lua;" .. package.path
local skynet = require "skynet"
local csvReader = require "csvReader"


---[[there is sth todo with the props table when deal with heart amount ]]

local drawmgr = {}
drawmgr._data = {}
local updatetime = 17	 
local MAXDRAWNUM = 5	
local day = 60 * 60 * 24

local drawtype = { FRIEND = 1 , ONETIME = 2 , TENTIME = 3 }

local user
local game

local recvtime = 0
local isfriend 

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

	n.uid = user.csv_id 
	n.drawtype =  t.drawtype
	n.cdrawtime = t.cdrawtime or 0
	n.srecvtime = os.time()
	n.propid = 0
	n.amount = 0
	n.isdealed = false
	n.iffree = ( t.iffree == false ) and 1 or 0 -- 0 free 1 not free
	n.drawnum = t.drawnum or 0

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
	--print( "get num" .. r )

	return r
end		
		
--[[function drawmgr:_db_update_prop( t )
	assert( t )
	print( "update prop is called" )
	local addr = randomaddr()
	assert( addr )

	skynet.call( addr , "lua" , "command" , "update_props" , t )

	print( "update prop over" )
end	--]]	
		
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
	
	  	
	          
local function getline_byid( list , id )
	assert( list and id )

	for i = 1 , #list do
		if list[i].id == id then
			print( "find the line " .. i  )
			return list[i]
		end
	end
	print( "not find line" )
	return nil
end		
	
function drawmgr:_db_insert_drawmsg( t )
	assert( t )
print("call drawser")
	local addr = randomaddr()
	assert( addr )
	skynet.send( addr , "lua" , "command" , "insert_drawmsg" , t )
	print( "insert a drawmsg successfully" )
end	

function drawmgr:_db_getrandomid( type )
	assert( type )
	print( "getrandomid is called" )
	local addr = randomaddr()
	assert( addr )

	local t = {}
	t.drawtype = type

	local r = skynet.call( addr , "lua" , "command" , "getrandomval" , t )
	print( "getrandomid" .. r )

	return r
end

local function splitsubreward_bytype(  mainreward , typeid )
	assert( typeid )

	local sublist = {}

	for i = 1 , #mainreward do
		if typeid == mainreward[i].id then
			print( "find >>>>>>>>>>>>>>>>>>>>>>>>>>>>>" , i )
			table.insert( sublist , mainreward[i] )
		end
	end
	print( "splitsubreward_bytype i called" )
	return sublist
end	

local function getgroupid( list , val )
	assert( val and list )

	local len = #list
	local sub = tonumber( list[len].probid )
	print( "sub and val is ")
	print( sub , val , len)
	for i = len , 1 , -1 do
		if sub < val  then
			print( sub , i )
			i = i - 1
			sub = sub + tonumber( list[i].probid )
		else
			return list[i].groupid
		end
	end
end

local function getpropidlist( dtype )
	print( "get[rp[od is called" )
	assert( dtype )
	local propidlist = {}
	propidlist.list = {}
	
	local subreward = csvReader.getcont( "subreward" )
	local mainreward = csvReader.getcont( "mainreward" )
	assert( subreward and mainreward )

	local sublist = splitsubreward_bytype( mainreward , tostring( dtype * 1000 ) )
	assert( sublist )

	if drawtype.TENTIME == dtype then
		print( "dtype id in getpropidlis is " .. dtype )
		for i = 1 , 10 do
			
			local r = skynet.call( ".randomdraw" , "lua" , "command" , "draw" , dtype ) --drawmgr:_db_getrandomid( dtype )
			print( r )
			local id = getgroupid( sublist , r )
			print( "groupid is >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" .. id )
			for i = 1 , #subreward do
				if subreward[ i ].id == id then
					table.insert( propidlist.list , { propid = tonumber( subreward[ i ].propid ) ,
						propnum = tonumber( subreward[ i ].propnum ) } )
				end 	
			end	
		end	  
	else
		print( "dtype id in getpropidlis is " .. dtype )
		local r = skynet.call( ".randomdraw" , "lua" , "command" , "draw" , dtype )
		print( r )
		print( "here" )
		local id = getgroupid( sublist , r )
		print( "groupid is >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" .. id )
		print( type( id ) )
		for i = 1 , #subreward do
			if subreward[i].id == id then
				print( type( subreward[i].id ) , type( id ) , subreward[i].id , id )
				table.insert( propidlist.list , { propid = tonumber( subreward[ i ].propid ) ,
						propnum = tonumber( subreward[ i ].propnum ) } )
				break
			end
		end
	end		

	assert( propidlist )
	propidlist.ok = true

	for k , v in ipairs( propidlist.list ) do
		local prop = user.u_propmgr:get_by_csv_id( v.propid )
		if prop then
			prop.num = prop.num + v.propnum
			prop:__update_db({"num"})
		else
			local p = game.g_propmgr:get_by_csv_id( v.propid )
			p.user_id = user.csv_id
			p.num = v.propnum
			local prop = user.u_propmgr.create(p)
			user.u_propmgr:add(prop)
			prop:__insert_db()
		end
	end

	print( "get propidlist successfully" )
	return propidlist
end				

function drawmgr:applydraw( u , g )
	assert( u )
	user = u
	game = g

	print( "applydraw is called in drawmgr" )
	local ret = {}
	ret.list = {}
	
	local t = {}
	t.uid = user.csv_id
	t.drawtype = drawtype.FRIEND
	local r = drawmgr:_db_select_frienddraw( t )
	local settime = getsettime()
	
	local v = {}
	if type( r ) == "table" or ( r < settime - 60 * 60 * 24 ) or ( r < settime  and os.time() > settime ) then
		v.drawtype = drawtype.FRIEND
		v.drawnum = 0
		isfriend = true
	else 
		v.drawtype = drawtype.FRIEND
		v.drawnum = 1
		isfriend = false
	end 

	table.insert( ret.list , v )

	t.drawtype = drawtype.ONETIME

	local r = drawmgr:_db_select_onetimedraw( t ) -- if free == 1
	if type( r ) == "table" then
		print( "r == nil" )
		 t.drawnum = 0
		 t.lefttime = 0
	else
		--local left = MAXDRAWNUM - r.drawnum 
		print( "find the onetime draw" )
		t.drawtype = drawtype.ONETIME
		--t.drawnum = ( r.drawnum == MAXDRAWNUM ) and  or left
		local drawcost = csvReader.getcont( "drawcost" )
		local line = getline_byid( drawcost , tostring( drawtype.ONETIME * 1000 ) )   --drawcost[tostring( id * 1000 )]
		assert( line )
		local nowtime = os.time() 
		if nowtime >= ( r +  tonumber( line.cdtime ) ) then
			print( nowtime , r , line.cdtime )
			print( "nowtime >= ..." )
			t.lefttime = 0
		else
			print( nowtime , r , line.cdtime )
			print( "nowtime < ..." )
			t.lefttime = r + tonumber( line.cdtime ) - os.time() -- nowtime - srecvtime
		end
	end	
	table.insert( ret.list , t )			
	          
	return ret
end		

function drawmgr:tentimedraw( tv )
	assert( tv )
	local proplist = {}
	local drawcost = csvReader.getcont( "drawcost" )
	assert( drawcost )
	local dm = drawmgr:_create( tv ) 
	assert( dm )
	

	local line = getline_byid( drawcost , tostring( tv.drawtype * 1000 ) )   --drawcost[tostring( id * 1000 )]
	assert( line )

	local v = {}
	v.uid = user.csv_id
	v.csvid = tonumber( line.cointype )

	--local num = drawmgr:_db_getdioment_or_heart_num( v )
    local prop = user.u_propmgr:get_by_csv_id( tonumber( line.cointype ) )

	if nil == prop or prop.num < tonumber( line.price ) then
		print( "not enough money in tentime" )
		local ret = {}
		ret.ok = false
		ret.msg = "not enough money"

		return ret
	else 
		drawmgr:_db_insert_drawmsg( dm )
		print( "insert drawmsg over" )

		prop.num = prop.num - tonumber( line.price )
		proplist = getpropidlist( drawtype.TENTIME )
		
		prop:__update_db( {"num"} )
		--[[local t = {}
		t.tname = "u_prop"
		t.content = { num = num }
		t.condition = { user_id = user.csv_id , csv_id = v.csvid }

		drawmgr:_db_update_prop( t )--]]
		print( "update prop successfully in tentimedraw" )
	end

	print( "ten time draw is over" )

	return proplist
end	
	
function drawmgr:onetimedraw( tv )
	assert( tv )
	local id = tv.drawtype
	local proplist = {}
	local dm = drawmgr:_create( tv ) 
	
	assert( dm )
	
	local freetime = 1
	print( tv.freetime )
	print( "dm.srecvtime is " , dm.srecvtime )
	if true == tv.iffree then
		drawmgr:_db_insert_drawmsg( dm )
		print( "insert drawmsg over" )

		print( "is free" )
		if freetime > 1 then
			proplist.ok = false
			return proplist 
		else
			freetime = freetime + 1
		end
		proplist = getpropidlist( id )
		assert( proplist )
		print( "get for free successfully" )
		proplist.lefttime = day
		recvtime = dm.srecvtime
		print( "________________recvtime is " .. recvtime )
		return proplist
	else	
		print( "not free" )
		local t = {}
		local drawcost = csvReader.getcont( "drawcost" )
		assert( drawcost )

		local line = getline_byid( drawcost , tostring( id * 1000 ) )   --drawcost[tostring( id * 1000 )]
		assert( line )

		local t = {}
		t.uid = user.csv_id
		t.csvid = tonumber( line.cointype )
		print( "t.csvid" )
		-- num = drawmgr:_db_getdioment_or_heart_num( t )
    	local prop = user.u_propmgr:get_by_csv_id( tonumber( line.cointype ) )
    	print( "get prop" )
		if nil == prop or prop.num < tonumber( line.price ) then
			local ret = {}
			ret.ok = false
			ret.msg = "not enough money"
			return ret
		else
			drawmgr:_db_insert_drawmsg( dm )
			print( "insert drawmsg over" )

			print( "update prop is called in " )

			prop.num = prop.num - tonumber( line.price )
			proplist = getpropidlist( drawtype.ONETIME )
						print( "*******************" , os.time() , recvtime , recvtime + day - os.time() )
			if os.time() > recvtime + day then
				print( " >>>>>>>>" )
				proplist.lefttime = 0
			else
				print( "<<<<<<<<" )
				proplist.lefttime = recvtime + day - os.time()
			end 
			print("**********************")
			prop:__update_db( {"num"} )
			--[[local t = {}
			t.tname = "u_prop"
			t.content = { num = num }
			t.condition = { user_id = user.csv_id , csv_id = 1 }
			
			drawmgr:_db_update_prop( t )--]]
			print( "update prop successfully in tentimedraw" )
		end	
	end
	return proplist
end 

function drawmgr:frienddraw( tv )
	assert( tv )
	local proplist = {}

	if false == isfriend then
		proplist.ok = false
		return proplist
	end

	local id = tv.drawtype
	local t = {}
	
	local drawcost = csvReader.getcont( "drawcost" )
	assert( drawcost )
	local dm = drawmgr:_create( tv ) 
	assert( dm )
	drawmgr:_db_insert_drawmsg( dm )
	print( "insert drawmsg over" )
	frecvtime = dm.srecvtime
	local line = getline_byid( drawcost , tostring( id * 1000 ) )   --drawcost[tostring( id * 1000 )]
	assert( line )


	local t = {}
	t.uid = user.csv_id
	t.csvid = tonumber( line.cointype )

	local prop = user.u_propmgr:get_by_csv_id( tonumber( line.cointype ) )
	print( "***************************line.cointype is " , line.cointype )
	--assert( prop )
	--local num = drawmgr:_db_getdioment_or_heart_num( t )
    --print( "money from db  is " .. prop.num )
    --print( prop.num , line.price )
	if nil == prop or prop.num < tonumber( line.price ) then
		print( "money is less then price" )
		local ret = {}
		ret.ok = false
		ret.msg = "not enough money"

		return ret
	else
		print( "line price is " , tonumber( line.price ) )
		prop.num = prop.num - tonumber( line.price )
		proplist = getpropidlist( drawtype.FRIEND ) 
		print( "update prop is called in " )

		prop:__update_db( {"num"} )

		--[[local v = {}
		v.tname = "u_prop"
		v.content = { num = num }
		v.condition = { user_id = user.csv_id , csv_id = tonumber( abortine.cointype ) }

		drawmgr:_db_update_prop( v )--]]
		print( "update prop successfully in tentimedraw" )
	end	

	return proplist
end

return drawmgr