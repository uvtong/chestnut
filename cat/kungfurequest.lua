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

		local tprop = user.u_propmgr:get_by_csv_id( user.id )
		assert( tprop )

		tmp.k_csv_id = v.csv_id
		--tmp.isequipment = ( sv.isequipment == 1 ) and true or false
		tmp.k_level = v.level
		tmp.k_type = v.type
		tmp.k_sp_num = tprop.num

		table.insert( ret.k_list , f )
	end		  	
			 
	for k , v in pairs( user.u_rolemgr.__data ) do
		local tmp = {}

		tmp.pos_list = {}	
		tmp.r_csv_id = v.csv_id
		local f = {}
		for i = 1 , KUNGFU_NUM do
			
			local k_csv_id = "k_csv_id" .. i
			if 0 ~= v[ k_csv_id ] then
				f.position = 0 
				f.k_csv_id = v[ k_csv_id ]
			end 
		end
 		table.insert( tmp.pos_list , f )
 		table.insert( ret.role_kid_list , tmp )
	end				

	return ret
end		
		
local ERROR = { K_NOT_EXIST = 1 , LEVEL_NOT_MATCH = 2 , NOT_ENOUGH_PROP = 3 }
		
function REQUEST:kungfu_levelup()
	print( "*-----------------------------* kungfu_day is called" )
	assert( self.k_csv_id and self.k_level and self.k_type )
	local ret = {}
	print( self.k_csv_id, self.k_level , self.r_csv_id , self.k_type )
	local g_tk = get_g_kungfu_by_skill_type_and_level( self.k_type , self.k_level )
	assert( g_tk )		
	local tprop_prop = user.u_propmgr:get_by_csv_id( g_tk.prop_csv_id )
	local tprop_currency = user.u_propmgr:get_by_csv_id( g_tk.currency_type )

	local t = kungfu_mgr:get_by_r_csv_id( self.r_csv_id ) 

	if not tprop_prop or tprop_prop.num < g_tk.prop_num or not tprop_currency or tprop_currency.num < g_tk.currency_num then
		print( " not enough money" )
		ret.ok = false
		ret.error = NOT_ENOUGH_PROP

		return ret
	else    
		if not t or not t[ tostring( self.k_csv_id) ] then
			tkungfu = { }
			tkungfu.user_id = user.csv_id
			tkungfu.csv_id= self.k_csv_id
			tkungfu.level = self.k_level
			tkungfu.type = self.k_type
			tkungfu.sp_id = g_tk.prop_csv_id			
			tkungfu = kungfu_mgr.create( tkungfu )

			assert( tkungfu )
			kungfu_mgr:add( tkungfu )

			tkungfu:__insert_db()
		else
			local tmp = kungfu_mgr:get_by_csv_id( self.k_csv_id )
			
			if tmp.level ~= self.k_level then
				ret.ok = false
				ret.error = ERROR.LEVEL_NOT_MATCH
				ret.msg = "level not match"

				return ret
			end

			tmp.level = tkungfu.level + 1
			tkungfu:__update_db( { "level" } )
		end	

		tprop_prop.num = tprop_prop.num - t.prop_num
		tprop_prop:__update_db( { "num" } )

		tprop_currency.num = tprop_currency.num - t.currency_num
		tprop_currency:__update_db( { "num" } )	
	end

	ret.ok = true				
	
	return ret
end				
		
function REQUEST:kungfu_chose()
	assert( self.r_csv_id and self.idlist )
	local ret = {}
	local t = user.u_rolemgr:get_by_csv_id( self.r_csv_id )
	assert( t )

	for i = 1 , KUNGFU_NUM do
		local k_csv_id = "k_csv_id" .. k
		t[ k_csv_id ] = 0	
	end

	for k , v in pairs( self.idlist ) do
		local k_csv_id = "k_csv_id" .. k
		t[ k_csv_id ] = v
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