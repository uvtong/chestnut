local new_drawrequestrequest = {}
local dc = require "datacenter"
local util = require "util"
local skynet = require "skynet"
local const = require "const"
local socket = require "socket"
local errorcode = require "errorcode"
local context = require "agent_context"
local sd = require "sharedata"

local send_package
local send_request
	
local REQUEST = {}
local RESPONSE = {}
local SUBSCRIBE = {}
local client_fd
	
local game
local user
local dc

local DAY = 24 * 60 * 60
local drawtype = { FRIEND = 1 , ONETIME = 2 , TENTIME = 3 }
local UPDATETIME = 17
local PROPTYPE = { PROP = 0 , ROLE_SP = 1 }

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end		

function REQUEST:login( u )
	-- body
	assert( u )
	print( "**********************************new_drawrequest_login " )
	user = u
	
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
    print( "add_to_prop is called" )
    local g_role

	for k , v in ipairs( t ) do
		if v.proptype == PROPTYPE.ROLE_SP then
			print( "get a role" )
			local key = string.format("%s:%d", "g_role", v.propid)
			g_role = sd.query(key)
			--g_role = game.g_rolemgr:get_by_us_prop_csv_id( v.propid )
			assert( g_role )
			local u_role = user.u_rolemgr:get_by_csv_id( g_role.csv_id )
			if u_role then
           		local prop = user.u_propmgr:get_by_csv_id( v.propid )
   				if prop then
   					prop.num = prop.num + v.amount
   					prop:__update_db( { "num" } )
   				else 
   					print( "no a role" )
   					local key = string.format("%s:%d", "g_prop", v.propid)
   					prop = sd.query(key)
   					assert(prop)	
   					--prop = skynet.call(".game", "lua", "query_g_prop", v.propid)
   					prop.user_id = user.csv_id
   					prop.num = v.amount
   					local prop = user.u_propmgr.create( prop )
   					user.u_propmgr:add( prop )
   					prop:__insert_db( const.DB_PRIORITY_2 )
   				end 	      
			else 

				context:role_recruit(g_role.csv_id)
				context:raise_achievement(const.ACHIEVEMENT_T_5)
			end 
		else     
			local prop = user.u_propmgr:get_by_csv_id( v.propid )
   			if prop then
   				prop.num = prop.num + v.amount
   				prop:__update_db( { "num" } )
   			else 
   				print( "propid is " , v.propid )
   				local key = string.format("%s:%d", "g_prop", v.propid)
   				local p = sd.query(key)
   				--local p = game.g_propmgr:get_by_csv_id( v.propid )
   				assert( p )
   				p.user_id = user.csv_id
   				p.num = v.amount
   				local prop = user.u_propmgr.create( p )
   				user.u_propmgr:add( prop )
   				prop:update_db()
   			end 
   			if v.propid == const.GOLD then
   				--context:raise_achievement(const.ACHIEVEMENT_T_2)
   			elseif v.propid == const.EXP then
   				--c--ontext:raise_achievement(const.ACHIEVEMENT_T_3)
   			end
   		end     
   	end			
end				

function REQUEST:draw(ctx)
   	-- body		
   	assert(ctx)

   	print( "applydraw is called in drawmgr" )		
   	local ret = {} 									
   	ret.list = {} 									
   					
   	local factory = ctx:get_myfactory()
   	assert(factory)
   	local tfrienddraw =  factory:draw_get_by_type( drawtype.FRIEND )
   													
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
   	local tonetime = factory:draw_get_by_type( drawtype.ONETIME )
   	if not tonetime then
   		print( "has not draw_onetime yet" )
   		t.drawnum = 0
		t.lefttime = 0
	else
		print( "find the onetime draw" )
		t.drawtype = drawtype.ONETIME
		local key = string.format("%s:%d", "g_drawcost", drawtype.ONETIME * 1000)
		local line = sd.query(key)
		--local line = game.g_drawcostmgr:get_by_csv_id( drawtype.ONETIME * 1000 )	
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

	local g = sd.query("g_mainreward")
	for i,v in ipairs(g) do
		local key = string.format("%s:%d", "g_mainreward", v)
		local value = sd.query(key)
		if value.csv_id == typeid then
			table.insert(sublist, v)
		end
	end

	print( "splitsubreward_bytype i called" )
	return sublist
end	
	
local function getgroupid( list , val )
	assert( val and list )

	local len = #list
	local sub = 0 --list[len].probid
	print( len , val , #list , sub )
	for i = len , 0 , -1 do
		if sub < val  then
			sub = sub + list[i].probid
		else    
			print( "group is ************************" , list[ i + 1 ].groupid )
			return list[i + 1].groupid
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
		local trn = skynet.call( ".randomdraw" , "lua" , "draw" , { drawtype = dtype }  )
		assert( trn )

		for k , v in ipairs( trn ) do
			local id = getgroupid( sublist , v )
			print( "reward groupid is " , id )
			local key = string.format("%s:%d", "g_subreward", id)
			local r = sd.query(key)
			--local r = game.g_subrewardmgr:get_by_csv_id( id )
			assert( r )
			if PROPTYPE.ROLE_SP == r.proptype then
				print( "propid is " , r.propid )
				local t = skynet.call( ".game" , "lua" , "query_g_draw_role" , r.propid )
				assert( t )
				if r.propnum == t.num then
					print( "num is and get a tnum" , t.num )
					table.insert( propidlist.list , { propid = r.propid , amount = r.propnum , proptype = PROPTYPE.ROLE_SP } )
				else
					print( "num is and get a tnum" , r.propnum )
					table.insert( propidlist.list , { propid = r.propid , amount = r.propnum , proptype = PROPTYPE.PROP } )
				end
			else
				print( "do not get a role" )
				table.insert( propidlist.list , { propid = r.propid , amount = r.propnum , proptype = PROPTYPE.PROP } )
			end
		end                                                                            
	else                                                                                                    
		print( "dtype id in getpropidlis is " .. dtype )
		local rn = skynet.call( ".randomdraw" , "lua" , "draw" , { drawtype = dtype } )
		assert( rn )
        
		local id = getgroupid( sublist , rn )
		print( "groupid is >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" .. id )
		local key = string.format("%s:%d", "g_subreward", id)
		local r = sd.query(key)
		--local r = game.g_subrewardmgr:get_by_csv_id( id )
		assert( r )
		
		if PROPTYPE.ROLE_SP == r.proptype then
			local key = string.format("%s:%d", "g_draw_role", r.propid)
			local t = sd.query(key)

			--local t = skynet.call( ".game" , "lua" , "query_g_draw_role" , r.propid )
			assert( t )
			if r.propnum == t.num then
				table.insert( propidlist.list , { propid = r.propid , amount = r.propnum , proptype = PROPTYPE.ROLE_SP } )
			else
				table.insert( propidlist.list , { propid = r.propid , amount = r.propnum , proptype = PROPTYPE.PROP } )
			end
		else
			table.insert( propidlist.list , { propid = r.propid , amount = r.propnum , proptype = PROPTYPE.PROP } )
		end
	end		
        
	assert( propidlist )
	
    add_to_prop( propidlist.list )
	print( "get propidlist successfully" )
	return propidlist
end				
			
local function frienddraw(ctx)
	assert(ctx)

	local factory = ctx:get_myfactory()
	local proplist = {}
	if false == isfriend then
		proplist.errorcode = errorcode[ 61 ].code
		proplist.msg = errorcode[ 61 ].msg

		return proplist
	end 

	local key = string.format("%s:%d", "g_drawcost", drawtype.FRIEND * 1000)
	local line = sd.query(key)
	--local line = ctx:get_game().g_drawcostmgr:get_by_csv_id( drawtype.FRIEND * 1000 )	
	assert( line )

	local prop = user.u_propmgr:get_by_csv_id( line.cointype )
	print( "***************************line.cointype is " , line.cointype )

	local tfriend = factory:draw_get_by_type( drawtype.FRIEND )
	if not prop or prop.num < line.price then
		print( "money is less then price" , prop.num, line.price)
		local ret = {}
		ret.errorcode = errorcode[ 16 ].code
		ret.msg = errorcode[ 16 ].msg

		return ret
	else
		print( "money is enough in frienddraw" )
		local date = os.time()

		if not tfriend then
			tfriend = {}
			tfriend.id = skynet.call( ".game" , "lua" , "guid" , const.DRAW )
			tfriend.uid = user.csv_id
			tfriend.drawtype = drawtype.FRIEND 
			tfriend.srecvtime = date
			tfriend.propid = 0
			tfriend.amount = 0
			tfriend.iffree = 1

			tfriend = user.u_drawmgr:create( tfriend )
			assert( tfriend )
			user.u_drawmgr:add( tfriend )	
		else
			tfriend.srecvtime = date
		end


		print( "line price is " , line.price )
		prop.num = prop.num - line.price
		proplist = getpropidlist( drawtype.FRIEND )

		prop:update_db()
		isfriend = false
		
		tfriend:update_db()

		print( "update prop successfully in tentimedraw" )
	end	
	proplist.errorcode = errorcode[ 1 ].code
	proplist.msg = errorcode[ 1 ].msg	

	return proplist
end 	
		
local function onetimedraw(ctx, iffree )
	assert(ctx)	

	local proplist = {}
	local factory = ctx:get_myfactory()
	assert(factory)
	local tonetime = factory:draw_get_by_type( drawtype.ONETIME )    
	
	local date = os.time()

	if true == iffree then
		print( "for free**********************************" )
		if not tonetime then
			tonetime = {}
			tonetime.id = skynet.call( ".game" , "lua" , "guid" , const.DRAW )
			tonetime.uid = user.csv_id
			tonetime.drawtype = drawtype.ONETIME
			tonetime.srecvtime = date
			tonetime.propid = 0;
			tonetime.amount = 0;
			tonetime.iffree = 0;

			tonetime = user.u_drawmgr.create( tonetime )
			assert( tonetime )
			user.u_drawmgr:add( tonetime )
		else
			local key = string.format("%s:%d", "g_drawcost", drawtype.ONETIME * 1000)
			local line = sd.query(key)

			assert( line )

			if date < ( tonetime.srecvtime + line.cdtime ) then
				proplist.errorcode = errorcode[ 61 ].code
				proplist.msg = errorcode[ 61 ].msg
			
				return proplist
			end

			tonetime.srecvtime = date
		end 

		tonetime:update_db()

		proplist = getpropidlist( drawtype.ONETIME )
		assert( proplist )

		print( "get for free successfully" )
		proplist.lefttime = DAY
		proplist.errorcode = errorcode[ 1 ].code
		proplist.msg = errorcode[ 1 ].msg 

		return proplist
	else	
		print( "not free**********************************" )
		local t = {}
		local key = string.format("%s:%d", "g_drawcost", drawtype.ONETIME * 1000)
		local line = sd.query(key)

		--local line = game.g_drawcostmgr:get_by_csv_id( drawtype.ONETIME * 1000 )
		assert( line )
            
    	local prop = user.u_propmgr:get_by_csv_id( line.cointype )

		if not prop or prop.num < line.price then
			local ret = {}
			ret.errorcode = errorcode[ 16 ].code
			ret.msg = errorcode[ 16 ].msg
			
			return ret
		else
			print( "update prop is called in" )

			prop.num = prop.num - line.price
			proplist = getpropidlist( drawtype.ONETIME )
			
			print( "*******************" , date , tonetime.srecvtime, tonetime.srecvtime + DAY - date )

			if date > tonetime.srecvtime + DAY then
				print( " >>>>>>>>" )
				proplist.lefttime = 0
			else
				print( "<<<<<<<<" )
				proplist.lefttime = tonetime.srecvtime + DAY - date
			end 
			print("**********************")
			prop:update_db()
			
			print( "update prop successfully in tentimedraw" )
		end	
	end
	proplist.errorcode = errorcode[ 1 ].code
	proplist.msg = errorcode[ 1 ].msg

	return proplist
end 	
		
local function tentimedraw(ctx)
	assert(ctx)

	local proplist = {}
	
	local key = string.format("%s:%d", "g_drawcost", drawtype.TENTIME * 1000)
	local line = sd.query(key)
	--local line = game.g_drawcostmgr:get_by_csv_id( drawtype.TENTIME * 1000 )
	assert( line )

    local prop = user.u_propmgr:get_by_csv_id( line.cointype )

	if not prop or prop.num < line.price then
		print( "not enough money in tentime" , prop.num, line.price)
		local ret = {}
		ret.errorcode = errorcode[ 16 ].code
		ret.msg = errorcode[ 16 ].msg

		return ret
	else 
		print( "insert drawmsg over", prop.num, line.price )

		prop.num = prop.num - line.price
		prop:update_db()

		proplist = getpropidlist( drawtype.TENTIME )		
	end 

	print( "ten time draw is over" )
	proplist.errorcode = errorcode[ 1 ].code
	proplist.msg = errorcode[ 1 ].msg

	return proplist
end 	
						
function REQUEST:applydraw(ctx)
	assert(ctx)
	local ret = {}
	if self.drawtype == drawtype.FRIEND then
		ret = frienddraw(ctx)
	elseif self.drawtype == drawtype.ONETIME then
		ret = onetimedraw( ctx,self.iffree )
	else
		ret = tentimedraw(ctx)
	end 	

	if 1 == ret.errorcode then
		if self.drawtype == 3 then
			user.draw_number = user.draw_number + 10
		else
			user.draw_number = user.draw_number + 1
		end
		--context:raise_achievement(const.ACHIEVEMENT_T_8)
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
