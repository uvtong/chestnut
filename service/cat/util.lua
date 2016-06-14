package.path = "./../cat/?.lua;" .. package.path
local skynet = require "skynet"
require "skynet.manager"
local const = require "const"
local query = require "query"
local util = {}

function util.random_db( ... )
	-- body
	return ".db"
end

function util.parse_text(src, parten, D)
	-- body
	-- src = "1000*10*10*10*10*10"
	-- D = 2
	-- parten = "(%d+%*%d+%*%d+%*?)"
	-- print( "src , parten , D is " , src , parten , D )
	assert( src and parten and D )
	local xparten = ""
	string.gsub(parten, "(%%%w%+)%%%*", function (s)
		-- body
		xparten = xparten .. "(" .. s .. ")" .. "%*"
	end)
	xparten = xparten .. "?"
	local r = {}
	string.gsub(src, parten, function (s)
		-- body
		local t = {}
		for i=1,D do
			local x = string.gsub(s, xparten, string.format("%%%d", i))
			table.insert(t, assert(tonumber(x)))
		end
		table.insert(r, t)
	end)
	return r
end 		
			
local function collect_info_from_g_role_effect( bufferid , ttotal )
	assert( bufferid and ttotal )

	gre = skynet.call( ".game" , "lua" , "query_g_role_effect" , bufferid )
	assert( gre )

	local i = 1
	while i <= 8 do
		local property_id = "property_id" .. i
		local value = "value" .. i
		
		local index = gre[ property_id ] 
		assert( index )
		--print( index , gre[ value ] )
		if 0 ~= index then
			ttotal[ index ] = ttotal[ index ] + gre[ value ]
		end 
		i = i + 1
	end		
end		
	--[[ if online ( user , nil , propertyname ) , if not online ( nil , uid , propertyname )                  ]]
function util.get_total_property( user , uid , onbattleroleid)   -- zhijie ti sheng zhan dou li gu ding zhi hai mei you ,  
	local uequip --zhuangbei
	local role 
	local roles
	local u
	local ukf = {} --user kungfu
 			
 	local tmpname = propertyname
 		print("uid is ****************************", onbattleroleid)
	if user then
		uequip = user:get_u_equipmentmgr().__data
        
		local id
		if not onbattleroleid then
			id = user:get_field("c_role_id")
		else 
			id = onbattleroleid 
		end 
		print("id is ************************************", id)
		role = user:get_u_rolemgr():get_by_csv_id( id )

		assert(role)
		roles = user:get_u_rolemgr().__data
		u = user
            
		for k , v in pairs(user:get_u_kungfumgr().__data) do
			table.insert(ukf, v:get_field("g_csv_id"))
		end 
	else    
		local sql = string.format( "select * from u_equipment where user_id = %s " , uid )
		print(sql)
		uequip = skynet.call( util.random_db() , "lua" , "command" , "query" , sql )
		assert( uequip )
 		sql = string.format( "select * from u_role where user_id = %s " , uid )
 		print( sql )
 		roles = skynet.call( util.random_db() , "lua" , "command" , "query" , sql )
 		--roles = query:read(".rdb", "u_role", sql)
 		assert( roles )
		    
 		if "king" == propertyname then
 			tmpname = "blessing"
 		end 
            
 		sql = string.format( "select c_role_id , combat , defense , critical_hit , blessing , ifxilian from users where csv_id = %s " , uid )
		print( sql )
		local tmp = skynet.call( util.random_db() , "lua" , "command" , "query" , sql )
		--local tmp = query(".rdb", "users", sql)
		u = tmp[ 1 ]
		assert( u )

		local roleid
		if not onbattleroleid then
			roleid = u.c_role_id
		else
			roleid = onbattleroleid
		end

 		for k , v in pairs( roles ) do
 			print( k , v , v.csv_id )
			if v.csv_id == roleid then
				role = v
				print( "find the role ********************************" )
				break
			end
 		end
 		assert( role )

 		sql = string.format("select csv_id from u_kungfu where user_id = %s", uid)
 		--print(sql)
 		--local tmp = skynet.call( util.random_db() , "lua" , "command" , "query" , sql )
 		local tmp = query.read(".rdb", "u_kungfu", sql)
 		for k , v in ipairs(tmp) do
 			table.insert(ukf, v.g_csv_id)
 		end
	end 

	----all equipment property
	local ttotal = { 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 }
	local tproperty = { "combat" , "defense" , "critical_hit" , "king" }

	for k , v in ipairs( tproperty ) do
		local probability = v .. "_probability"
		print( "property is ***************************************" , probability )
		for kk , vv in pairs( uequip ) do
			print("************************property :", vv[ v ], vv[ probability])
			if 0 ~= vv:get_field(v) then 
				ttotal[ k ] = ttotal[ k ] + vv:get_field(v)
				ttotal[ k  + 4 ] = ttotal[ k + 4 ] + vv:get_field(probability)
				if k == 1 then
					print("total[k] in equipment is ", ttotal[k])
				end
			end
		end		
	end 	    
	print("after equipment is ************************", ttotal[1], ttotal[5], ttotal[4], ttotal[8])
	-- role battle property
	collect_info_from_g_role_effect(role:get_field("battle_buffer_id"), ttotal)
	print("after role battle is ****************************", ttotal[1], ttotal[5], ttotal[4], ttotal[8])

	-- xilian property
	if 1 == u:get_field("ifxilian") then
		local i = 1 
		while i <= 5 do
			local property_id = "property_id" .. i
			local value = "value" .. i
			local index = role:get_field(property_id)
			if 0 ~= index then
				ttotal[ index ] = ttotal[ index ] + role:get_field(value)
				if index == 1 then
					print("total[k] in xilian is ", ttotal[index])
				end
			end

			i = i + 1
		end 
	end     
	print("after xilian is***************************************", ttotal[1], ttotal[5], ttotal[4], ttotal[8])
	--role equiped kungfu property
	local i = 1
	while i <= 7 do 
		local sk_csv_id = "k_csv_id" .. i
		local ik_csv_id = role:get_field(sk_csv_id)

		if 0 ~= ik_csv_id then
			local gk = skynet.call( ".game" , "lua" , "query_g_kungfu" , ik_csv_id )
			assert( gk )

			collect_info_from_g_role_effect( gk.buff_id , ttotal )
		end 

		i = i + 1 
	end     
	print("after equiped kungfu is *****************************", ttotal[1], ttotal[5], ttotal[4], ttotal[8])
	--user kungfu property
	for k, v in ipairs(ukf) do
		local gk = skynet.call( ".game" , "lua" , "query_g_kungfu" , v )
		assert( gk )
		collect_info_from_g_role_effect( gk.equip_buff_id , ttotal )
	end

	print("after user kungfu is ************************************", ttotal[1], ttotal[5], ttotal[4], ttotal[8])
	--rolecollect property
	for k , v in pairs( roles ) do
		print("v.gather_buffer_id is ***********************************", v:get_field("gather_buffer_id")) 
		collect_info_from_g_role_effect( v:get_field("gather_buffer_id") , ttotal )
	end

	print("after rolwcollect is ***************************************", ttotal[1], ttotal[5], ttotal[4], ttotal[8])
	--basic property
	ttotal[ 1 ] = ttotal[ 1 ] + u:get_field("combat")
	ttotal[ 2 ] = ttotal[ 2 ] + u:get_field("defense")
	ttotal[ 3 ] = ttotal[ 3 ] + u:get_field("critical_hit")
	ttotal[ 4 ] = ttotal[ 4 ] + u:get_field("blessing")
	print("user basic prop is ", u:get_field("combat"), u:get_field("defense"), u:get_field("critical_hit"), u:get_field("blessing"))
	local result = { }
	local i = 1
	while i <= 4 do
		table.insert( result , math.floor( ( ttotal[ i ] * ( 1 + ttotal[ i + 4 ] / 100 ) ) ) )
		print("ttotal is ",ttotal[i], ttotal[ i ] * ( 1 + ttotal[ i + 4 ] / 100 ), ( 1 + ttotal[ i + 4 ] / 100 ))
		i = i + 1
	end	  

	print( "final combat and percent is ************" , result[ 1 ] , result[ 2 ] , result[ 3 ] , result[ 4 ])
	return result
end  			
			
return util 
	