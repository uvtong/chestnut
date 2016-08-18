local skynet = require "skynet"
require "skynet.manager"
local const = require "const"
local util = {}

function util.random_db()
	-- body
	local addr = ".db"
	return addr
end

function util.RSHash()
	-- body
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
	local uequip
	local role 
	local roles
	local u
 	
 	local tmpname = propertyname

	if user then
		uequip = assert( user.u_equipmentmgr.__data )

		local id
		if not onbattleroleid then
			id = user.c_role_id
		else
			id = onbattleroleid
		end
		print("id is ************************************", id)
		role = user.u_rolemgr:get_by_csv_id( id )
		assert(role)
		roles = user.u_rolemgr.__data
		u = user
	else    
		local sql = string.format( "select * from u_equipment where user_id = %s " , uid )
		uequip = skynet.call( util.random_db() , "lua" , "command" , "query" , sql )
		assert( uequip )
 		sql = string.format( "select * from u_role where user_id = %s " , uid )
 		print( sql )
 		roles = skynet.call( util.random_db() , "lua" , "command" , "query" , sql )
 		assert( roles )
		
 		if "king" == propertyname then
 			tmpname = "blessing"
 		end

 		sql = string.format( "select c_role_id , combat , defense , critical_hit , blessing , ifxilian from users where csv_id = %s " , uid )
		print( sql )
		local tmp = skynet.call( util.random_db() , "lua" , "command" , "query" , sql )

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
	end 

	----all equipment property
	local ttotal = { 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 }
	local tproperty = { "combat" , "defense" , "critical_hit" , "king" }

	for k , v in ipairs( tproperty ) do
		local probability = v .. "_probability"
		print( "property is ***************************************" , probability )
		for kk , vv in pairs( uequip ) do
			if 0 ~= vv[ v ] then 
				ttotal[ k ] = ttotal[ k ] + vv[ v ]
				ttotal[ k  + 4 ] = ttotal[ k + 4 ] + vv[ probability ]
			end
		end		
	end 	    

	-- role battle property
	collect_info_from_g_role_effect( role.battle_buffer_id , ttotal )

	-- xilian property
	if 1 == u.ifxilian then
		local i = 1 
		while i <= 5 do
			local property_id = "property_id" .. i
			local value = "value" .. i
			local index = role[ property_id ]
			if 0 ~= index then
				ttotal[ index ] = ttotal[ index ] + role[ value ]
			end

			i = i + 1
		end 
	end     

	--kungfu property
	local i = 1
	while i <= 7 do 
		local sk_csv_id = "k_csv_id" .. i
		local ik_csv_id = role[ sk_csv_id ]

		if 0 ~= ik_csv_id then
			local gk = skynet.call( ".game" , "lua" , "query_g_kungfu" , ik_csv_id )
			assert( gk )

			collect_info_from_g_role_effect( gk.buff_id , ttotal )
		end 

		i = i + 1 
	end     

	--rolecollect property
	for k , v in pairs( roles ) do
		collect_info_from_g_role_effect( v.gather_buffer_id , ttotal )
	end
	--basic property
	ttotal[ 1 ] = ttotal[ 1 ] + u.combat
	ttotal[ 2 ] = ttotal[ 2 ] + u.defense
	ttotal[ 3 ] = ttotal[ 3 ] + u.critical_hit
	ttotal[ 4 ] = ttotal[ 4 ] + u.blessing

	local result = { }
	local i = 1
	while i <= 4 do
		table.insert( result , math.floor( ( ttotal[ i ] * ( 1 + ttotal[ i + 4 ] / 100 ) ) ) )
		i = i + 1
	end	  

	print( "final combat and percent is ************" , result[ 1 ] , result[ 2 ] , result[ 3 ] , result[ 4 ] )

	return result
end  			
			
return util 
	