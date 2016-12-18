package.path = "./../../cat/?.lua;./../lualib/?.lua;" .. package.path
package.cpath = "./../lua-cjson/?.so;"..package.cpath
local skynet = require "skynet"
require "skynet.manager"
local mc = require "multicast"
local util = require "util"
local loader = require "load_game"
local const = require "const"
local dc = require "datacenter"
local u_emailmgr_cls = require "models/u_new_emailmgr"
local u_emailmgr = u_emailmgr_cls.new()	
local public_emailmgr_cls = require "models/public_emailmgr"
local public_emailmgr = public_emailmgr_cls.new()
local query = require "query"
						
local game = ".game" 	
						
local register_updatedb = {}
local channel 			
local u_client_id = {} -- if
local R = {} 			
						
local CMD = {}			
local SEND_TYPE = { TO_ALL = 1 , TO_GROUP = 2 } 
local totalemail = {}	
						
function CMD.agent_start(source)
	if register_updatedb[source] then
		return 0 		
	else 				
		

		return channel.channel
	end
end			
			
-- local function get_public_email_index( signup_time )
-- 	assert( signup_time )

-- 	local b = 1 
-- 	local e = public_emailmgr:get_count()
-- 	local mid = 1

-- 	while b <= e do
-- 		mid = math.floor( ( b + e ) / 2 )
-- 		print("mid is ", mid)
-- 		local tmp = public_emailmgr.__data[ mid ]
-- 		assert( tmp )

-- 		if tmp.acctime == signup_time then
-- 			return true , mid
-- 		end 

-- 		if signup_time < tmp.acctime then
-- 			e = mid - 1
-- 		else
-- 			b = mid + 1
-- 		end 
-- 	end      

-- 	return false , mid
-- end 		
				
function CMD.agent_get_public_email(source, ucsv_id , pemail_csv_id , signup_time )
	print( "agent_get_public_email****************************** is called" )
	print( ucsv_id , pemail_csv_id , signup_time )
	assert( ucsv_id and pemail_csv_id and signup_time )

	local tmp = {}
	for i = #totalemail , 1 , -1 do
		local t = (public_emailmgr:get(totalemail[i])).__fields

		if 0 == pemail_csv_id then
			if t.acctime >= signup_time then
				t.pemail_csv_id = t.csv_id -- record public email id
	 			t.csv_id = skynet.call( ".game" , "lua" , "u_guid" , ucsv_id , const.UEMAILENTROPY ) -- change pemail_csv_id into user's email csv_id
				table.insert(tmp, t)
			else 
				break
			end 
		else 	
			print("sdfsdfsdfsdfffffffffffffffff", t.csv_id, pemail_csv_id, totalemail[i])
			if t.csv_id > pemail_csv_id then
				t.pemail_csv_id = t.csv_id -- record public email id
	 			t.csv_id = skynet.call( ".game" , "lua" , "u_guid" , ucsv_id , const.UEMAILENTROPY )
				table.insert(tmp, t)
			else
				break
			end
		end    
	end 	

	return tmp
	-- local counter = 1
	-- local sign 
	-- local len = public_emailmgr:get_count()
	-- print( "counter is and len is " , counter , len )
	-- if 0 == pemail_csv_id then
	-- 	sign , counter = get_public_email_index( signup_time )
	-- 	print( sign , counter )
	-- 	if sign or ( not sign and counter >= len ) then
	-- 		counter = len + 1
	-- 	end  
	-- else   	
	-- 	counter = pemail_csv_id + 1
	-- end 	
	-- print( "sign and counter and len is **********************" , sign , counter , len )
	-- local t = {}
	-- for i = counter , len do
	-- 	print( "i is " , i )
	-- 	local tmp = public_emailmgr.__data[ i ]
	-- 	assert( tmp )
        	
	-- 	tmp.pemail_csv_id = tmp.csv_id -- record public email id
        	
	-- 	tmp.csv_id = skynet.call( ".game" , "lua" , "u_guid" , ucsv_id , const.UEMAILENTROPY ) -- change pemail_csv_id into user's email csv_id
	-- 	print( "tmp.csv_id is **********************************" , tmp.csv_id )
	-- 	table.insert( t , tmp )
	-- end 	

end 		
		         
function CMD.send_public_email_to_all(source, tvals )
	print( "channel send_public_email_to_all is called" )
	assert( tvals )
	tvals.acctime = os.time() -- an integer
	tvals.isread = 0
	tvals.isreward = 0
	tvals.isdel = 0
	tvals.deltime = 0
	for i = 1 , 5 do
		local id = "itemsn" .. i
		local num = "itemnum" .. i
		print( id , tvals[id] , num , tvals[num] )
		if nil == tvals[id] then
			assert( tvals[num] == nil )
				 	
			tvals[id] = 0
			tvals[num] = 0
		end      
	end          
		
	tvals.csv_id = skynet.call( ".game" , "lua" , "guid" , const.PUBLIC_EMAILENTROPY )
	print("tvals.csv_id is ******************************" , tvals.csv_id)
	assert(tvals.csv_id)

	table.insert(totalemail, tvals.csv_id)
	channel:publish( "email" , tvals )
	
	tvals = public_emailmgr:create( tvals )
	assert( tvals )
	public_emailmgr:add( tvals )
	tvals:update_db()
	print( "channel send_public_email_to_all is called" )
	--[[local sql = "select csv_id from users where ifonline = 0" -- in users , csv_id now is "uid".
	local r = skynet.call( util.random_db() , "lua" , "command" , "query" , sql )
	print( "sizeof r = " , #r )
			
	print( "begin to insert" )
	local tmp = {}
	for _ , v in ipairs( r ) do
		tvals.csv_id =  skynet.call(game, "lua" , "u_guid" , v.csv_id , const.UEMAILENTROPY ) --util.u_guid( v.csv_id , game, const.UEMAILENTROPY ) 
		tvals.uid = v.csv_id
		local ne = u_emailmgr.create( tvals )
		--assert( ne )
		--ne:__insert_db()
		table.insert( tmp , ne )	
	end 
	
	u_emailmgr.insert_db( tmp )--]]
end 	
		
--[[function CMD:send_email_to_all( tvals )
	print( "channel send_email_to_all is called" )
	
	assert( tvals )

	tvals.acctime = os.time() -- an integer
	tvals.isread = 0
	tvals.isreward = 0
	tvals.isdel = 0
	tvals.deltime = 0
	for i = 1 , 5 do
		local id = "itemsn" .. i
		local num = "itemnum" .. i
		print( id , tvals[id] , num , tvals[num] )
		if nil == tvals[id] then
			assert( tvals[num] == nil )
			
			tvals[id] = 0
			tvals[num] = 0
		end
	end

	channel:publish( "email" , tvals )
	local sql = "select csv_id from users where ifonline = 0" -- in users , csv_id now is "uid".
	local r = skynet.call( util.random_db() , "lua" , "command" , "query" , sql )
	print( "sizeof r = " , #r )
		
	print( "begin to insert" )
	local tmp = {}
	for _ , v in ipairs( r ) do
		tvals.csv_id =  skynet.call(game, "lua" , "u_guid" , v.csv_id , const.UEMAILENTROPY ) --util.u_guid( v.csv_id , game, const.UEMAILENTROPY ) 
		tvals.uid = v.csv_id
		local ne = u_emailmgr.create( tvals )
		--assert( ne )
		--ne:__insert_db()
		table.insert( tmp , ne )	
	end 

	u_emailmgr.insert_db( tmp )
end --]]
	
function CMD.send_email_to_group(source, tval , tucsv_id )
	assert( tval and tucsv_id )
	print( "send to group is called" )
	tval.acctime = os.time() -- an integer
	tval.isread = 0
	tval.isreward = 0
	tval.isdel = 0
	tval.deltime = 0
	for i = 1 , 5 do
		local id = "itemsn" .. i
		local num = "itemnum" .. i
		if nil == tval[id] then
			assert( tval[num] == nil )
			tval[id] = 0
			tval[num] = 0
		end
	end

	for _ , v in ipairs( tucsv_id ) do
		assert(v.uid)
		tval.csv_id = skynet.call(".game", "lua" , "u_guid" , v.uid, const.UEMAILENTROPY )
		tval.uid = v.uid
		tval.id = genpk_2(tval.uid, genpk_3(1, tval.csv_id))
		print("********************************eamil", tval.csv_id, tval.id)
		local t = dc.get( v.uid )
		--[[ id user online then send directly , else insert into db --]]
		if t then 
			skynet.send( t.addr , "lua" , "newemail" , "newemail" , tval )
		else
			print( "get a new useremail**************************" )

			local ne = u_emailmgr:create(tval)
			ne:update_db()
		end	
	end 	
end 		
		
--[[function CMD:hello( tval , ... )
	-- body	
	print( "hello is called\n" )

	--channel:publish( "email" , { emailtype = , tval )
	local addr = util.random_db()


	-- local t = {csv_id=util.u_guid(user_id, game, const.UEMAILENTROPY), uid=user.csv_id, type=}
	-- tval.csv_id = 
	-- tval.user_id = user_id
	-- local u_emailmgr = require "u_emailmgr"
	-- local email = u_emailmgr.create(tvalh)
	-- email:__insert_db()
end    		   			
	
local ROUTINE = { TIME = -1 , ECONTENT = {} }
--[[ ROUTINE_TIME = -1 , donot send ROUTINE_EMAIL --]]
--[[function CMD:change_routin_values( time , tval )
	assert( time and tval )
	ROUTINE.TIME = time
	ROUTINE.ECONTENT = tval
end		

function CMD:start_routine( )
end	
		
--[[function CMD:get_emailcontent( delay_time , type , temailcontent , tuser_list )
	if type == SEND_TYPE.TO_ALL then
		skynet.timeout( delay_time , send_email_to_all( temailcontent ) )
	elseif type == SEND_TYPE.TO_GROUP then
		skynet.timeout( )	  	
	end 					  
	skynet.timeout(coutnfd. CMD:hello( type , {} , {} )
end --]]						  

-- local function send(coutdown, count, content, type, l)
-- 	-- body
-- 	if type == QF then
-- 		skynet.send()
-- 		channel.publish(content)
-- 		skynet.timeout(cd, function function_name(ftype, content, l)
-- 			-- body
-- 			send_email_to_all()
-- 			if R[ftype].count == 0 then
-- 				os.time(R[ftype].coutdown)

-- 				send()

-- 		end)
-- 	else
-- end

-- function CMD.send_email(ftype, coutdown, count, content, type, l)
-- 	-- body
-- 	if ttype == "xx" then
-- 		if R[ftype] then
-- 			R[ftype].coutdown
-- 			else
-- 		R[ftype] == { coutdown = coutdown, count = count}
-- 		local s = os.time(coutdown)
-- 		local now os.time()
-- 		local cd = s - now

-- 	else
	
-- end

local function load_public_email()
	-- body
	local sql = string.format("select * from public_email")
	print(sql)
	local r = query.read(".rdb", "public_email", sql)
	assert(r.errno == nil)

	for i , v in ipairs ( r ) do
		local t = public_emailmgr:create( v )
		public_emailmgr:add( t )
		table.insert(totalemail, v.csv_id)
	end
end

skynet.start( function () 
	skynet.dispatch("lua" , function( _, source, command, ... )
		local f = assert(CMD[command])
		local r = f(source, ...)
		if r then
			skynet.ret(skynet.pack(r))
		end
	end)
	load_public_email()
	channel = mc.new()
	skynet.fork(update_db)
	skynet.register ".channel"
end)
