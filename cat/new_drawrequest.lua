local new_drawrequestrequest = {}
local dc = require "datacenter"
local util = require "util"
local skynet = require "skynet"
	
local send_package
local send_request
	
local REQUEST = {}
local RESPONSE = {}
local SUBSCRIBE = {}
local client_fd
	
local game
local user
local dc
local draw_mgr

local DAY = 24 * 60 * 60
local drawtype = { FRIEND = 1 , ONETIME = 2 , TENTIME = 3 }
local UPDATETIME = 17

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end		

function REQUEST:login( u )
	-- body
	assert( u )
	print( "**********************************new_drawrequestrequest_login " )
	user = u
	draw_mgr = user.u_drawmgr
	assert( draw_mgr )
end		
			
local function getsettime()
	local date = os.time()
	local year = tonumber( os.date( "%Y" , date ) )
	local month = tonumber( os.date( "%m" , date ) )
	local day = tonumber( os.date( "%d" , date ) )
	local hightime = { year = year , month = month , day = day , hour = UPDATETIME , min = 0 , sec = 0 }
	local hour = tonumber( os.date( "%H" , date ) )
	local settime
	if 0 <= hour and hour < UPDATETIME then
		settime = os.time( hightime ) - 60 * 60 * 24
	else
		settime = os.time( hightime )
	end		
	
	return settime
end				

local function add_to_prop( t )
	assert( t )

	for k , v in ipairs( t ) do
		--local g_role = game.g_rolemgr:get_by_us


		local prop = user.u_propmgr:get_by_csv_id( v.propid )
   		if prop then
   			prop.num = prop.num + v.amount
   			prop:__update_db( { "num" } )
   		else
   			print( "propid is " , v.propid )
   			local p = game.g_propmgr:get_by_csv_id( v.propid )
   			assert( p )
   			p.user_id = user.csv_id
   			p.num = v.amount
   			local prop = user.u_propmgr.create( p )
   			user.u_propmgr:add( prop )
   			prop:__insert_db()
   		end 
   	end		
end				
   	 	    
function REQUEST:draw()
   	-- body
   	print( "applydraw is called in drawmgr" )
   	local ret = {}
   	ret.list = {}
   	
   	local tfrienddraw = draw_mgr:get_by_type( drawtype.FRIEND )
   	
   	local settime = getsettime()
   	
   	local v = {}
   	if not tfrienddraw or ( tfrienddraw.srecvtime < settime - 60 * 60 * 24 ) or ( tfrienddraw.srecvtime < settime  and os.time() > settime ) then
   		print( "tfrienddraw is nil " , tfrienddraw )
   		v.drawtype = drawtype.FRIEND
   		v.drawnum = 0
   		isfriend = true
   	else 
   		print( "can not friend draw " , tfrienddraw.srecvtime )
   		v.drawtype = drawtype.FRIEND
   		v.drawnum = 1
   		isfriend = false
   	end 

   	table.insert( ret.list , v )
	   
   	local t = {}
   	local tonetime = draw_mgr:get_by_type( drawtype.ONETIME )
   	if not tonetime then
   		print( "has not draw_onetime yet" )
   		t.drawnum = 0
		t.lefttime = 0
	else
		print( "find the onetime draw" )
		t.drawtype = drawtype.ONETIME
		local line = game.g_drawcostmgr:get_by_csv_id( drawtype.ONETIME * 1000 )	
		assert( line )
		
		local nowtime = os.time() 
		if nowtime >= ( tonetime.srecvtime + line.cdtime ) then
			t.lefttime = 0
			t.drawnum = 1
		else
			t.lefttime = tonetime.srecvtime + line.cdtime - nowtime -- nowtime - srecvtime
		end
	end	
	table.insert( ret.list , t )			
	          
	return ret
end			
		
local ERROR = { WAI_GUA = 1 , NOT_ENOUGH_MONEY = 2 }
	
local function splitsubreward_bytype( typeid )
	assert( typeid )

	local sublist = {}
	for k , v in pairs( game.g_mainrewardmgr.__data ) do
		if v.csv_id == typeid then
			print( "********************************** find" )
			table.insert( sublist , v )
		end
	end

	print( "splitsubreward_bytype i called" )
	return sublist
end	
	
local function getgroupid( list , val )
	assert( val and list )

	local len = #list
	local sub = list[len].probid
	print( len , val , #list )
	for i = len , 1 , -1 do
		if sub < val  then
			i = i - 1
			sub = sub + list[i].probid
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
			
	local sublist = splitsubreward_bytype( dtype * 1000 )
	assert( sublist )

	if drawtype.TENTIME == dtype then
		print( "dtype id in getpropidlis is " .. dtype )
		local trn = skynet.call( ".randomdraw" , "lua" , "command" , "draw" , { drawtype = dtype }  )
		assert( trn )

		for k , v in ipairs( trn ) do
			local id = getgroupid( sublist , v )
			print( "reward groupid is " , id )

			local r = game.g_subrewardmgr:get_by_csv_id( id )
			assert( r )
			print( r.propid , r.propnum )
			table.insert( propidlist.list , { propid = r.propid , amount = r.propnum } )
		end                                                                            
	else                                                                                                    
		print( "dtype id in getpropidlis is " .. dtype )
		local rn = skynet.call( ".randomdraw" , "lua" , "command" , "draw" , { drawtype = dtype } )
		assert( rn )
         
		local id = getgroupid( sublist , rn )
		print( "groupid is >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" .. id )
		local r = game.g_subrewardmgr:get_by_csv_id( id )
		assert( r )
		table.insert( propidlist.list , { propid = r.propid , amount = r.propnum } )
	end		
        
	assert( propidlist )
	propidlist.ok = true
    	
    add_to_prop( propidlist.list )
	print( "get propidlist successfully" )
	return propidlist
end				
			
local function frienddraw()
	local proplist = {}

	if false == isfriend then
		proplist.ok = false
		proplist.errorcode = ERROR.WAI_GUA
		return proplist
	end 

	local line = game.g_drawcostmgr:get_by_csv_id( drawtype.FRIEND * 1000 )	
	assert( line )

	local prop = user.u_propmgr:get_by_csv_id( line.cointype )
	print( "***************************line.cointype is " , line.cointype )

	local tfriend = draw_mgr:get_by_type( drawtype.FRIEND )

	if not prop or prop.num < line.price then
		print( "money is less then price" )
		local ret = {}
		ret.ok = false
		ret.errorcode = ERROR.NOT_ENOUGH_MONEY
		ret.msg = "not enough money"

		return ret
	else
		print( "money is enough in frienddraw" )
		local date = os.time()

		if not tfriend then
			tfriend = {}
			tfriend.uid = user.csv_id
			tfriend.drawtype = drawtype.FRIEND 
			tfriend.srecvtime = date
			tfriend.propid = 0
			tfriend.amount = 0
			tfriend.iffree = 1

			tfriend = draw_mgr.create( tfriend )
			assert( tfriend )
			draw_mgr:add( tfriend )	
		else
			tfriend.srecvtime = date
		end


		print( "line price is " , line.price )
		prop.num = prop.num - line.price
		proplist = getpropidlist( drawtype.FRIEND )

		prop:__update_db( { "num" } )
		isfriend = false
		
		tfriend:__insert_db()

		print( "update prop successfully in tentimedraw" )
	end	
		
	return proplist
end 	
		
local function onetimedraw( iffree )
	assert( iffree )
	        
	local proplist = {}

	local tonetime = draw_mgr:get_by_type( drawtype.ONETIME )    
	assert( tonetime )
	local date = os.time()

	if true == iffree then
		print( "for free**********************************" )
		if not tonetime then
			tonetime = {}
			tonetime.uid = user.csv_id
			tonetime.drawtype = drawtype.ONETIME
			tonetime.srecvtime = date
			tonetime.propid = 0;
			tonetime.amount = 0;
			tonetime.iffree = 0;

			tonetime = draw_mgr.create( tonetime )
			assert( tonetime )
			draw_mgr:add( tonetime )
		else
			local line = game.g_drawcostmgr:get_by_csv_id( drawtype.ONETIME * 1000 )	
			assert( line )

			if date < ( tonetime.srecvtime + line.cdtime ) then
				proplist.ok = false
				proplist.errorcode = ERROR.WAI_GUA
			
				return proplist
			end

			tonetime.srecvtime = date
		end 

		tonetime:__insert_db()

		proplist = getpropidlist( drawtype.ONETIME )
		assert( proplist )

		print( "get for free successfully" )
		proplist.lefttime = DAY

		return proplist
	else	
		print( "not free**********************************" )
		local t = {}
		local line = game.g_drawcostmgr:get_by_csv_id( drawtype.ONETIME * 1000 )
		assert( line )
            
    	local prop = user.u_propmgr:get_by_csv_id( line.cointype )

		if not prop or prop.num < line.price then
			local ret = {}
			ret.ok = false
			ret.errorcode = ERROR.NOT_ENOUGH_MONEY
			ret.msg = "not enough money"
			
			return ret
		else
			print( "update prop is called in" )

			prop.num = prop.num - line.price
			proplist = getpropidlist( drawtype.ONETIME )
			
			print( "*******************" , now , recvtime , recvtime + day - date )

			if date > recvtime + day then
				print( " >>>>>>>>" )
				proplist.lefttime = 0
			else
				print( "<<<<<<<<" )
				proplist.lefttime = recvtime + day - now
			end 
			print("**********************")
			prop:__update_db( { "num" } )
			
			print( "update prop successfully in tentimedraw" )
		end	
	end
	return proplist
end 	
		
local function tentimedraw()
	local proplist = {}

	local line = game.g_drawcostmgr:get_by_csv_id( drawtype.TENTIME * 1000 )
	assert( line )

    local prop = user.u_propmgr:get_by_csv_id( line.cointype )

	if not prop or prop.num < line.price then
		print( "not enough money in tentime" )
		local ret = {}
		ret.ok = false
		ret.errorcode = ERROR.NOT_ENOUGH_MONEY
		ret.msg = "not enough money"

		return ret
	else 
		print( "insert drawmsg over" )

		prop.num = prop.num - line.price
		prop:__update_db( { "num" } )

		proplist = getpropidlist( drawtype.TENTIME )		
	end 

	print( "ten time draw is over" )

	return proplist
end 	
						
function REQUEST:applydraw()
	print( "applydraw is called ******************" , self.drawtype )

	print( self.drawtype , self.iffree )
	local ret = {}

	if self.drawtype == drawtype.FRIEND then
		ret = frienddraw()
	elseif self.drawtype == drawtype.ONETIME then
		ret = onetimedraw( self.iffree )
	else
		ret = tentimedraw()
	end 	

	return assert( ret )
end		

function RESPONSE:abc()
	-- body	
end			
			
function new_drawrequestrequest.start(c, s, g, ...)
	-- body	
	print( "*********************************new_drawrequest_start" )
	client_fd = c
	send_request = s
	game = g
end			
			
function new_drawrequestrequest.disconnect()
	-- body	
end			
			
new_drawrequestrequest.REQUEST = REQUEST
new_drawrequestrequest.RESPONSE = RESPONSE
new_drawrequestrequest.SUBSCRIBE = SUBSCRIBE
		
return new_drawrequestrequest
