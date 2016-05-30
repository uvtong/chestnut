package.path = "./../cat/?.lua;./../lualib/?.lua;" .. package.path
package.cpath = "./../lua-cjson/?.so;"..package.cpath
local skynet = require "skynet"
require "skynet.manager"
local mc = require "multicast"
local util = require "util"
local loader = require "load_game"
local const = require "const"
local dc = require "datacenter"
local u_emailmgr = require "models/u_new_emailmgr"	
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
	
function CMD.agent_start(source)
	if register_updatedb[source] then
		return 0
	else
		register_updatedb[source] = true
		return channel.channel
	end
end			
			
local function get_public_email_index( signup_time )
	assert( signup_time )

	local b = 1 
	local e = public_emailmgr:get_count()
	local mid = 1

	while b <= e do
		mid = math.floor( ( b + e ) / 2 )

		local tmp = public_emailmgr.__data[ mid ]
		assert( tmp )

		if tmp.acctime == signup_time then
			return true , mid
		end 

		if signup_time < tmp.acctime then
			e = mid - 1
		else
			b = mid + 1
		end 
	end      

	return false , mid
end 		
		
function CMD.agent_get_public_email(source, ucsv_id , pemail_csv_id , signup_time )
	print( "agent_get_public_email****************************** is called" )
	print( ucsv_id , pemail_csv_id , signup_time )
	assert( ucsv_id and pemail_csv_id and signup_time )
	local counter = 1
	local sign 
	local len = public_emailmgr:get_count()
	print( "counter is and len is " , counter , len )
	if 0 == pemail_csv_id then
		sign , counter = get_public_email_index( signup_time )
		print( sign , counter )
		if sign or ( not sign and counter >= len ) then
			counter = len + 1
		end  
	else   
		counter = pemail_csv_id + 1
	end  
	print( "sign and counter and len is **********************" , sign , counter , len )
	local t = {}
	for i = counter , len do
		print( "i is " , i )
		local tmp = public_emailmgr.__data[ i ]
		assert( tmp )
        
		tmp.pemail_csv_id = tmp.csv_id -- record public email id
        
		tmp.csv_id = skynet.call( ".game" , "lua" , "u_guid" , ucsv_id , const.UEMAILENTROPY ) -- change pemail_csv_id into user's email csv_id
		print( "tmp.csv_id is **********************************" , tmp.csv_id )
		table.insert( t , tmp )
	end 
	return t
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
	print( "tvals.csv_id is ******************************" , tvals.csv_id )
	assert( tvals.csv_id )
		
	channel:publish( "email" , tvals )

	tvals = public_emailmgr:create( tvals )
	assert( tvals )
	public_emailmgr:add( tvals )
	tvals:__insert_db( const.DB_PRIORITY_2 )
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
	assert(false)
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
		print("********************************eamil", tval.csv_id)
		local t = dc.get( v.uid )
		--[[ id user online then send directly , else insert into db --]]
		if t then 
			skynet.send( t.addr , "lua" , "newemail" , "newemail" , tval )
		else
			print( "get a new useremail**************************" )

			local ne = u_emailmgr.create( tval )
			ne:__insert_db( const.DB_PRIORITY_2)
		end	
	end 	

end 		

local function load_public_email()
	-- body
	local sql = string.format("select * from public_email")
	local r = query.read(".rdb", "public_email", sql)
	assert(r.errno == nil)

	for i , v in ipairs ( r ) do
		local t = public_emailmgr:create( v )
		public_emailmgr:add( t )
	end
end

local function update_db()
	-- body
	while true do 
		channel:publish("update_db")
		skynet.sleep(100 * 60)
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
