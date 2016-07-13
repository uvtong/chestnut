local kungfurequest = {}
local dc = require "datacenter"
local util = require "util"
local errorcode = require "errorcode"
local const = require "const"
local context = require "agent_context"
local sd = require "sharedata"
local skynet = require "skynet"

local send_package
local send_request
	
local REQUEST = {}
local RESPONSE = {}
local SUBSCRIBE = {}
local client_fd

local MAX_KF_LEVEL = 9 
local KUNGFU_NUM = 7 -- ZAN DING
		
local game
local user
local dc
		
local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end	   	
	   	
function REQUEST:login( u )
	-- body
	-- assert( u )
	-- print( "**********************************kungfurequest_login " )
	-- user = u
	   	
	-- assert(user.u_kungfumgr )
end		
		
local function get_g_kungfu_by_skill_type_and_level( skill_type , level )
	print("skill_type and level is ", skill_type, level)
	assert( skill_type and level )

	local t = skynet.call(".game", "lua", "query_g_kungfu_by_csv_id_and_level", skill_type, level)
	assert( t )
	return t
end		
		
function REQUEST:kungfu(ctx)
	assert(ctx)
	-- body
	print( "*-------------------------* kungfu is called")
	
	local ret = {}
	ret.k_list = {}
	ret.role_kid_list = {}
	
	for k , v in pairs(ctx:get_user().u_kungfumgr.__data ) do
		local t = v.__fields

		local tmp = {}
		
		local tprop = ctx:get_user().u_propmgr:get_by_csv_id( v.sp_id )
		assert( tprop )
		
		tmp.csv_id = t.csv_id
		tmp.k_level = t.level
		tmp.k_type = t.type
		tmp.k_sp_num = tprop:get_field("num")
		print( v.csv_id , v.level , v.type )
		table.insert( ret.k_list , tmp )
	end	
	local counter = 0	  	
	for k , v in pairs( ctx:get_user().u_rolemgr.__data ) do
		local t = v.__fields

		counter = counter + 1
		local tmp = {}
		
		tmp.pos_list = {}	
		tmp.r_csv_id = t.csv_id
		
		for i = 1 , KUNGFU_NUM do
			local f = {}
			local kcsv_id = "k_csv_id" .. i
			
			if 0 ~= t[ kcsv_id ] then
				f.position = i
				f.k_csv_id = t[ kcsv_id ]
				print( f.position , f.k_csv_id , t[ kcsv_id ] )
				table.insert( tmp.pos_list , f )
			end 
		end
 		table.insert( ret.role_kid_list , tmp )
	end			

	print( "***********************************************counter in kungfu" , counter )
	return ret
end		
	
function REQUEST:kungfu_levelup(ctx)

	print( "*-----------------------------* kungfu_day is called" )
	print( self.csv_id , self.k_level , self.k_type )
	assert(ctx)
	local ret = {}
	print( self.csv_id, self.k_level , self.r_csv_id , self.k_type )
	local g_tk = get_g_kungfu_by_skill_type_and_level( self.csv_id , self.k_level )
	assert( g_tk )		
	local tprop_prop = ctx:get_modelmgr():get_u_propmgr():get_by_csv_id( g_tk.prop_csv_id )
	local tprop_currency = ctx:get_modelmgr():get_u_propmgr():get_by_csv_id( g_tk.currency_type )
	
	local helper = ctx:get_helper()
	assert(helper)	
	local tkungfu = helper:kungfu_get_by_csv_id( self.csv_id ) 

	print( g_tk.prop_csv_id , tprop_prop:get_field("num") , g_tk.prop_num , tprop_currency:get_field("num") , g_tk.currency_num )
	if not tprop_prop or tprop_prop:get_field("num") < g_tk.prop_num or not tprop_currency or tprop_currency:get_field("num") < g_tk.currency_num then
		print( " not enough money" )
		ret.errorcode = errorcode[3].code
		ret.msg = errorcode[3].msg
		return ret
	else    
		if not tkungfu then
			local tkungfu = {}
			tkungfu.id = skynet.call(".game", "lua", "guid", const.KUNGFU)
			tkungfu.user_id = ctx:get_user():get_field("csv_id")
			tkungfu.csv_id= self.csv_id
			tkungfu.level = self.k_level
			tkungfu.type = self.k_type                  --unknown
			tkungfu.sp_id = g_tk.prop_csv_id 
			tkungfu.g_csv_id = g_tk.g_csv_id

			tkungfu = ctx:get_modelmgr():get_u_kungfumgr():create( tkungfu )
 			
			assert( tkungfu )
			ctx:get_modelmgr():get_u_kungfumgr():add( tkungfu )
			tkungfu:update_db()
			--context:raise_achievement(const.ACHIEVEMENT_T_9)
		else				  		
			print( "_______________________________________________________")
			print( tkungfu:get_field("level") + 1 , self.k_level )
			if tkungfu:get_field("level") + 1 ~= self.k_level then
				print( "not match" )
				ret.errorcode = errorcode[ 52 ].code --  ERROR.LEVEL_NOT_MATCH
				ret.msg = errorcode[ 52 ].msg
				
				return ret
			elseif tkungfu:get_field("level") >= MAX_KF_LEVEL then
				assert(false, "level is top")
			end 

			tkungfu:set_field("level", tkungfu:get_field("level") + 1)
			tkungfu:set_field("g_csv_id", g_tk.g_csv_id)

			
			tkungfu:update_db()
		end	
		tprop_prop:set_field("num", tprop_prop:get_field("num") - g_tk.prop_num)
		tprop_prop:update_db()

		tprop_currency:set_field("num", tprop_currency:get_field("num") - g_tk.currency_num)
		tprop_currency:update_db()	

		local g_tk = get_g_kungfu_by_skill_type_and_level( self.csv_id , self.k_level + 1 ) -- dai gai
		if not g_tk then
			ret.amount = 0
		else
			local tprop = ctx:get_modelmgr():get_u_propmgr():get_by_csv_id( g_tk.prop_csv_id )
			if not tprop then
				ret.amount = 0
			else
				ret.amount = tprop:get_field("num")
			end
		end 
	end 	

	ret.errorcode = errorcode[ 1 ].code			
	ret.msg = errorcode[ 1 ].msg
	return ret
end				
	
function REQUEST:kungfu_chose(ctx)
	print( "kungfu chose is calle****************************" , self.r_csv_id , self.idlist )

	assert(self.r_csv_id and ctx)
	--print( self.r_csv_id , self.idlist, #self.idlist )

	local ret = {}
	local t = ctx:get_modelmgr():get_u_rolemgr():get_by_csv_id( self.r_csv_id )
	assert( t )

	for i = 1 , KUNGFU_NUM do
		local k_csv_id = "k_csv_id" .. i
		t:set_field(k_csv_id, 0)
	end

	if self.idlist then
		for _ , v in pairs( self.idlist ) do
			local k_csv_id = "k_csv_id" .. v.position
			t:set_field(k_csv_id, v.k_csv_id)
		end
	end

	t:update_db()

	ret.errorcode = errorcode[ 1 ].code			
	ret.msg = errorcode[ 1 ].msg
	return ret
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