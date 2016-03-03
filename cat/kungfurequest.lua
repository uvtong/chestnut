local kungfurequest = {}
local dc = require "datacenter"
local util = require "util"
	
local send_package
local send_request
	
local REQUEST = {}
local RESPONSE = {}
local SUBSCRIBE = {}
local client_fd

local KUNGFU_NUM = 7 -- ZAN DING

local game
local user
local dc
local kungfu_mgr

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end		
	
function REQUEST:login( u )
	-- body
	assert( u )
	print( "**********************************kungfurequest_login " )
	user = u
	
	kungfu_mgr = user.u_kungfumgr
	assert( kungfu_mgr )
end		
		
local function get_g_kungfu_by_skill_type_and_level( skill_type , level )
	assert( skill_type and level )
	
	local t = game.g_kungfumgr:get_by_g_csv_id( skill_type , level )
	assert( t )
	print( "type and level is over " )
	return t
end		
			
function REQUEST:kungfu()
	-- body
	print( "*-------------------------* kungfu is called")

	local ret = {}
	ret.k_list = {}
	ret.role_kid_list = {}

	for k , v in pairs( kungfu_mgr.__data ) do
		local tmp = {}

		local tprop = user.u_propmgr:get_by_csv_id( v.sp_id )
		assert( tprop )

		tmp.csv_id = v.csv_id
		--tmp.isequipment = ( sv.isequipment == 1 ) and true or false
		tmp.k_level = v.level
		tmp.k_type = v.type
		tmp.k_sp_num = tprop.num
		print( v.csv_id , v.level , v.type )
		table.insert( ret.k_list , tmp )
	end		  	
	print( "length of is *****************" , #( user.u_rolemgr.__data ) )
	for k , v in pairs( user.u_rolemgr.__data ) do
		print( "in the kungfu" )
		local tmp = {}

		tmp.pos_list = {}	
		tmp.r_csv_id = v.csv_id
		
		for i = 1 , KUNGFU_NUM do
			local f = {}
			local kcsv_id = "k_csv_id" .. i
			
			if 0 ~= v[ kcsv_id ] then
				f.position = i
				f.k_csv_id = v[ kcsv_id ]
				print( f.position , f.k_csv_id )
				table.insert( tmp.pos_list , f )
			end 
		end
 		table.insert( ret.role_kid_list , tmp )
	end				

	return ret
end		
		
local ERROR = { K_NOT_EXIST = 1 , LEVEL_NOT_MATCH = 2 , NOT_ENOUGH_PROP = 3 }
		
function REQUEST:kungfu_levelup()
	print( "*-----------------------------* kungfu_day is called" )
	print( self.csv_id , self.k_level , self.k_type )
	--assert( self.k_csv_id )
	local ret = {}
	print( self.csv_id, self.k_level , self.r_csv_id , self.k_type )
	local g_tk = get_g_kungfu_by_skill_type_and_level( self.csv_id , self.k_level )
	assert( g_tk )		
	local tprop_prop = user.u_propmgr:get_by_csv_id( g_tk.prop_csv_id )
	local tprop_currency = user.u_propmgr:get_by_csv_id( g_tk.currency_type )

	local tkungfu = kungfu_mgr:get_by_type( self.csv_id ) 

	if not tprop_prop or tprop_prop.num < g_tk.prop_num or not tprop_currency or tprop_currency.num < g_tk.currency_num then
		print( " not enough money" )
		ret.ok = false
		ret.errorcode = NOT_ENOUGH_PROP

		return ret
	else    
		--print( t , t[ tostring( self.k_csv_id) ] )
		if not tkungfu then
			print( "******************************************")
			local tkungfu = { }
			tkungfu.user_id = user.csv_id
			tkungfu.csv_id= self.csv_id
			tkungfu.level = self.k_level
			tkungfu.type = self.k_type
			tkungfu.sp_id = g_tk.prop_csv_id			
			tkungfu = kungfu_mgr.create( tkungfu )
 
			assert( tkungfu )
			kungfu_mgr:add( tkungfu )
                              
			tkungfu:__insert_db()
		else				  		
			print( "_______________________________________________________")
			--local tmp = kungfu_mgr:get_by_type( self.k_type )
			print( tkungfu.level + 1 , self.k_level )
			if tkungfu.level + 1 ~= self.k_level then
				print( "not match" )
				ret.ok = false
				ret.errorcode = ERROR.LEVEL_NOT_MATCH
				ret.msg = "level not match"

				return ret
			end

			tkungfu.level = tkungfu.level + 1
			tkungfu:__update_db( { "level" } )
		end	

		tprop_prop.num = tprop_prop.num - g_tk.prop_num
		tprop_prop:__update_db( { "num" } )

		tprop_currency.num = tprop_currency.num - g_tk.currency_num
		tprop_currency:__update_db( { "num" } )	
	end 	

	ret.ok = true
	ret.errorcode = 0				
			
	return ret
end				
			
function REQUEST:kungfu_chose()
	print( "kungfu chose is calle****************************" )
	assert( self.r_csv_id and self.idlist )
	print( self.r_csv_id , self.idlist )
	local ret = {}
	local t = user.u_rolemgr:get_by_csv_id( self.r_csv_id )
	assert( t )

	for i = 1 , KUNGFU_NUM do
		local k_csv_id = "k_csv_id" .. i
		t[ k_csv_id ] = 0	
	end

	for _ , v in pairs( self.idlist ) do
		local k_csv_id = "k_csv_id" .. v.position
		t[ k_csv_id ] = v.k_csv_id
	end

	t:__update_db( { "k_csv_id1" , "k_csv_id2" , "k_csv_id3" , "k_csv_id4" , "k_csv_id5" , "k_csv_id6" , "k_csv_id7" } )
end			
			
function RESPONSE:abc()
	-- body	
end			
			
function kungfurequest.start(c, s, g, ...)
	-- body	
	print( "*********************************kungfu_start" )
	client_fd = c
	send_request = s
	game = g
end			
			
function kungfurequest.disconnect()
	-- body	
end			
			
kungfurequest.REQUEST = REQUEST
kungfurequest.RESPONSE = RESPONSE
kungfurequest.SUBSCRIBE = SUBSCRIBE

return kungfurequest