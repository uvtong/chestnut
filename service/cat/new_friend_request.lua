package.path = "./../cat/?.lua;" .. package.path
	 	
local new_friend_request = {}
local user 			
local friendmgr 	
local sendpackage 	
local sendrequest 	
local errorcode = require "errorcode"
local query = require "query"
local dc = require "datacenter"
local skynet = require "skynet"
local const = require "const"

local send_package
local send_request
																			
local REQUEST = {}
local RESPONSE = {}
local SUBSCRIBE = {}
local client_fd
local func_gs
local table_gs = {}
		
local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end

local recommand_idlist = {} --dui jian hao you lie biao
local apply_idlist = {}	 	--wan jia yi shen qing lei biao
local applied_idlist = {}   --wan jia bei shen qing lie biao 
local friend_idlist = {}	  

local MAXHEARTNUM = 100
local MAX_RECOMMAND_FRIENDNUM = 10
local MAXFRIENDNUM = 50
local SENDHEART_DEFAULT_NUM = 10  		--DEFAULT SENDHEART NUM
local recvheartnum	= 0
local user
local UPDATETIME = 17
local total = 50 --dai ding
local game 								   						
local SENDTYPE = 4 -- dai ding 4 presents heart
	 									   	
local msgtype = {APPLY = 1 , DELETE = 5 , ACCEPT = 3 , REFUSE = 4 , SENDHEART = 2 , ACCEPTHEART = 6 , OTHER = 7}										   		

function REQUEST:login(ctx)
	print("friendrequset_login&************************************")
	-- body
	-- assert( u )
	-- print("**********************************lilianrequest_login")
	-- user = u
end	

local function getupdatetime(date) 		   	
	local date = date or os.time()

	local year = tonumber( os.date( "%Y" , date ) )
	local month = tonumber( os.date( "%m" , date ) )
	local day = tonumber( os.date( "%d" , date ) )
	local hightime = { year = year , month = month , day = day , hour = UPDATETIME , min = 0 , sec = 0 }
	local hour = tonumber( os.date( "%H" , date ) )
	local settime
	if 0 <= hour and hour < UPDATETIME then
		settime = os.time( hightime ) 
	else
		settime = os.time( hightime ) + 24 * 60 * 60
	end 				
					
	return settime	
end					
					
local function createfriend( tfriend )
	assert( tfriend )
						
	local r = {}	

	r.id = tfriend.csv_id
	r.name = tfriend.uname
	r.level = tfriend.level
	r.viplevel = tfriend.uviplevel
	r.iconid = tfriend.iconid
	r.sign = tfriend.sign
	r.fightpower = tfriend.combat
	r.online_time = os.date( "%Y%m%d%H%M%S" , tfriend.onlinetime) 	--tfriend.onlinetime
	r.ifonline = tfriend.ifonline 									--( tfriend.ifonline == 0 ) and false or true
	r.heartamount = tfriend.heartamount or 0 						-- the heart num that sended by another user
	r.heart = tfriend.heart
	r.apply = true
	r.receive = tfriend.receive
	--r.signtime = tfriend.signtime
	
	--TODO
	print( "create friend successfully" )
	return r
end	
	
local function createmsg( tvals )
    assert( tvals )

    local nm = {}
    nm.id = tvals.id
    nm.fromid =tvals.fromid
    nm.toid = tvals.toid
    nm.type = tvals.type
    --nm.propid = tvals.propid or 0
    nm.amount = tvals.amount or SENDHEART_DEFAULT_NUM
    nm.srecvtime = tvals.srecvtime or os.time()
    --nm.csendtime = 0												--tvals.csendtime or 0
    nm.updatetime = tvals.updatetime or 0 
    nm.isread = tvals.isread or 0
    
    return nm
end 		
	
local function getupdate(date)
	local year = tonumber( os.date( "%Y" , date ) )
	local month = tonumber( os.date( "%m" , date ) )
	local day = tonumber( os.date( "%d" , date ) )
	local hightime = { year = year , month = month , day = day , hour = UPDATETIME , min = 0 , sec = 0 }
	local hour = tonumber( os.date( "%H" , date ) )
	local settime
	if 0 <= hour and hour < UPDATETIME then
		settime = os.time( hightime ) 
	else	
		settime = os.time( hightime ) + 60 * 60 * 24
	end 		
	
	return settime
end 		

function REQUEST:friend_list(ctx)
	assert(ctx) 

	local ret = {}
	ret.friendlist = {}
	local date = os.time()

	for k, v in pairs(ctx:get_modelmgr():get_u_new_friendmgr().__data) do
		local tmp 
		local t = dc.get(v:get_field("friendid") )
				
		--if online
		if t then
			print("friend is online****************************")
			tmp = skynet.call(t.addr, "lua", "friend", "agent_friendmsg")
			assert(tmp)
		else 	
			print("not online***********************************")
			local sql = string.format( "select csv_id , uname , uviplevel , level , sign , ifonline, onlinetime , iconid , ara_r2_sum_combat from users where csv_id = %d" , v:get_field("friend_csv_id"))
			local r = query.read(".rdb", "users", sql)
			assert(nil == r.errno and r[1])
			tmp = r[1]					

			--util.get_total_property(nil , v:get_field("friendid")) --zong zhan li
			tmp.combat = tmp.ara_r2_sum_combat 						
			tmp.ara_r2_sum_combat = nil
			tmp.csv_id = v:get_field("id")
		end 					
								
		local ut = ctx:get_user():get_field("friend_update_time")
		print("ut is ", ut)
		local updatetime = getupdatetime(date)

		-- 0 means this is the first time to open friend function,set the update_time	
		if 0 == ut then
			ctx:get_user():set_field("friend_update_time", updatetime)
			ctx:get_user():update_db()				
		else 	
			-- if date > update then reset 
			if date > ut then
				--update can recv heartamount 0
				v:set_field("heartamount", 0)
				v:set_field("update_time", updatetime)
				v:set_field("ifsent", 0)
				v:update_db()

				ctx:get_user():set_field("daily_recv_heart", 0)

				-- 0 means has not sent heart today
				ctx:get_user():set_field("friend_update_time", updatetime)
				ctx:get_user():update_db()
			end 
		end 	

		tmp.heartamount = v:get_field("heartamount")
		if 0 == v:get_field("ifsent") then
			-- if can sent heart to this friend
			print("ifsent is 0")
			tmp.heart = true
		else
			print("ifsent is 1")
			tmp.heart = false
		end 
		
		if MAXHEARTNUM - ctx:get_user():get_field("daily_recv_heart") > 0 then
			print("ifreceive is true")
			tmp.receive = true
		else 	
			print("ifreceive is ralse")
			tmp.receive = false
		end

		local f = createfriend(tmp)
   		assert(f)
		table.insert(ret.friendlist, f)
	end 	

	 	

	ret.today_left_heart = MAXHEARTNUM - ctx:get_user():get_field("daily_recv_heart")
	ret.errorcode = errorcode[1].code
	        
	return ret
end 		
		
local function get_friend_basic_info(uid)
	assert(uid)

	local tmp 

	local t = dc.get( uid )
	-- if online  
	if t then     
		print( "online" )
		tmp = skynet.call( t.addr , "lua" , "friend" , "agent_friendmsg")
		assert( tmp )
	else 		  
		print( "not online" )
		local sql = string.format("select csv_id , uname , uviplevel , level , sign , ifonline, onlinetime , iconid , ara_r2_sum_combat from users where csv_id = %d" , uid)
		local r = query.read(".rdb", "users", sql)
		assert(nil == r.errno and r[1])
				  
		tmp = r[1]
		tmp.combat = tmp.ara_r2_sum_combat
		tmp.ara_r2_sum_combat = nil
	end 		  
	assert(tmp)   
		          
	return tmp    
end		          
	
function REQUEST:applied_list(ctx)
	assert(ctx)

	local ret = {}
	ret.friendlist = {}
	-- local uid = ctx:get_user():get_field("csv_id")
	-- for k, v in pairs(ctx:get_modelmgr():get_u_new_friendmsgmgr().__data) do
	-- 	if v:get_field("toid") == uid and v:get_field("type") == msgtype.APPLY then
	-- 		local tmp = get_friend_basic_info(v:get_field("fromid"))
	-- 		table.insert(ret, createfriend(tmp))
	-- 	end
	-- end	

	for k, v in pairs(applied_idlist) do
		local tmp = get_friend_basic_info(v.csv_id)
		table.insert(ret.friendlist, createfriend(tmp))
	end

	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg

	return ret
end 	
		
function new_friend_request.init(ctx)
	assert(ctx)
	print("in init*****************************************")
	local uid = ctx:get_user():get_field("csv_id")
	assert(uid)

	for k, v in pairs(ctx:get_modelmgr():get_u_new_friendmsgmgr().__data) do
		if v:get_field("fromid") == uid then
			apply_idlist[tostring(v:get_field("toid"))] = {csv_id = v:get_field("toid"), id = v:get_field("id")}
		end	   
    	
		if v:get_field("toid") == uid then 
			applied_idlist[tostring(v:get_field("fromid"))] = {csv_id = v:get_field("fromid"), id = v:get_field("id")}
		end    	
	end 

	for k, v in pairs(ctx:get_user().u_new_friendmgr.__data) do
		friend_idlist[tostring("friend_csv_id")] = {csv_id = v:get_field("friend_csv_id"), id = v:get_field("id")}
	end 
end 	
		
function new_friend_request:loadfriend(uid, lowlevel, uplevel)
	assert(uid and lowlevel and uplevel)

	local i = 1     
	local step = 20 
	local lastday = os.time() - 24 * 60 * 60
	local ok = false
	local tmp_recommand_idlist
	-- select friend on different condition
	while i <= 3 do
		local sql = string.format("call qy_select_friend_msg(%d, %d, %d, %d)", uid, lowlevel, uplevel, lastday)
		print( sql )

		tmp_recommand_idlist = query.read(sql)        --two tables return, first holds value, second hold return info
		assert(recommand_idlist.errno == nil) 

		if #tmp_recommand_idlist[1] < 10 then    
			tmp_recommand_idlist = {}
			step = step + 10 
		else 
			ok = true
			break
		end 

		i = i + 1
	end     
	
	if not ok then
		step = 20
		i = 1
		lastday = 0

		while i <= 3 do
			local sql = string.format("call qy_select_friend_msg(%d, %d, %d, %d)", uid, lowlevel, uplevel, lastday)
			print( sql )

			tmp_recommand_idlist = query.read(sql)        --two tables return, first holds value, second hold return info
			assert(tmp_recommand_idlist.errno == nil)

			if #tmp_recommand_idlist[1] < 10 then
				tmp_recommand_idlist = {}
				step = step + 10
			else 
				break
			end
			
			i = i + 1
		end 
	end     

	assert(tmp_recommand_idlist[1])

	if #tmp_recommand_idlist[1] < MAX_RECOMMAND_FRIENDNUM then
	   	print( "avalible friends num < 10" )
	end		
    print("________________________load friend over")

    recommand_idlist = tmp_recommand_idlist[1]
end 			
				
local function findexist( idlist , id )
	assert( idlist and id )
    			
    for k, v in pairs(idlist) do
    	if v.csv_id == id then
    		return true
    	end 		
    end			

	return false 
end		
		
local function pickfriends()
   	local f = {}
   	local index 
   	local counter = 0
   	local tmp = {}
   	--filter id in friendlist and appliedlist
   	for k , v in pairs( recommand_idlist ) do
   		if false == findexist(friend_idlist,  v) and false == findexist(apply_idlist, v) then
   			table.insert(tmp, v.csv_id)
		end 
   	end		
   	
   	if not tmp then
   		--TODO lower the fileter condition
   		return nil	
   	end		

   	recommand_idlist = tmp

   	local f = {}
   	if #recommand_idlist < MAX_RECOMMAND_FRIENDNUM then
   		print("avalible friends is less than 10")
   		return recommand_idlist
   	else	
   		while true do
	    	index = math.floor(math.random(1 , #recommand_idlist))
	    	local uid = recommand_idlist[index]
    		if not f[index] then
				table.insert(f, uid)
				counter = counter + 1
				if counter >= MAX_RECOMMAND_FRIENDNUM then
					break
				end
			end
		end 	
    end			
              
	return f  
end 		  
			  
function REQUEST:otherfriend_list(ctx)
	assert(ctx)
	local ret = {}
	local ol = pickfriends()
	assert(ol)

	print("getback from pickfriends")

	for k ,uid in pairs(ol) do
		local f = get_friend_basic_info(uid)
		local n = createfriend(f)
		table.insert(ret, n)
	end 	
	
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg

	return ret
end 		
			
function REQUEST:applyfriend(ctx)
	assert(ctx)

	local ret = {}

	for k, v in pairs(self.friendlist) do
		local sign = false
		print("applyfriend id", v.friendid)

		-- judge if apply self
		if v.friendid == ctx:get_user():get_field("csv_id") then
			print("can not apply yourself")
			assert(false)
			ret.errorcode = errorcode[63].code
			ret.msg = errorcode[63].msg
			return ret
		end 

		-- judge if friendid is in a friend already
		for sk, sv in pairs(ctx:get_modelmgr():get_u_new_friendmgr().__data) do
			if sv:get_field("friendid") == v.friendid then
				print("already friend")
				isfind = true
				break
			end
		end	

		--judeg if is applied or applied me already
		if not isfind then
			if apply_idlist[tostring(v.friendid)] or applied_idlist[tostring(v.friendid)] then
				isfind = true
			end
		end 

		if not isfind then
			--record the friendid
			local n = {}     
			n.id = skynet.call(".game", "lua", "guid", const.FRIENDMSG)
			n.fromid = ctx:get_user():get_field("csv_id")
			n.toid = v.friendid
			n.type = msgtype.APPLY
            
			local nm = createmsg(n)
			assert(nm)         
			apply_idlist[tostring(v.friendid)] = {csv_id = v.friendid, id = n.id}
            
			local t = ctx:get_modelmgr():get_u_new_friendmsgmgr():create(nm)
			ctx:get_modelmgr():get_u_new_friendmsgmgr():add(t)
            
			local r = dc.get(v.friendid)
			if r then          
				skynet.send( r.addr , "lua" , "friend", "agent_request_handle" , nm )
				print( "notify an agent " , v.friendid ) 
			else 			   
				--if not online insert msg into db directly	
				t:update_db()  	
				print( "insert a new msg to db" )
			end                
			
			ret.errorcode = errorcode[ 1 ].code
			ret.msg = errorcode[ 1 ].msg
			print( "apply end******************************" )
			return ret         
		end                    
	end   			                   

	ret.errorcode = errorcode[ 70 ].code
	ret.msg = errorcode[ 70 ].msg
	return ret 		
end 	  			
	
function REQUEST:recvfriend(ctx)
	assert(ctx and self.friendlist)
	local date = os.time()

	local ret = {}	
	if ctx:get_modelmgr():get_u_new_friendmgr():get_count() + #self.friendlist > MAXFRIENDNUM then
		-- too many friends
		ret.errorcode = errorcode[60].code
		ret.msg = errorcode[60].msg
        		  	 
		return ret 	
	end 			

	for k, v in ipairs(self.friendlist) do 
		local id = applied_idlist[tostring(v.friendid)].id
		assert(id)	
		local t = ctx:get_modelmgr():get_u_new_friendmsgmgr():get(id)
		assert(t)	
        local friendid = 0

		local r = dc.get(v)
		if r then          
			skynet.send( r.addr , "lua" , "friend", "agent_request_handle" , {fromid = ctx:get_user():get_field("csv_id"), type = msgtype.APPLY, id = id})
			print("notify an agent" , v) 
		else   			   
			--update msg first
			t:set_field("isread", 1)
			t:update_db()  	
            
            --create friend  
			local nf = {}
			friendid = skynet.call(".game", "lua", "guid", const.FRIEND)
			assert(friendid)
			nf.id = friendid
			nf.self_csv_id = t:get_field("toid")
			nf.friend_csv_id = t:get_field("fromid")
			nf.recvtime = date
			nf.isdelete = 0
			nf.heartamount = 0
			nf.update_time = 0
			nf.ifrecved = 0
			nf.ifsent = 0
			local r = ctx:get_modelmgr():get_u_new_friendmgr():create(nf)
			assert(r)
			ctx:get_modelmgr():get_u_new_friendmgr():add(r)
			r:update_db()

			nf.id = skynet.call(".game", "lua", "guid", const.FRIEND)
			nf.self_csv_id = t:get_field("fromid")
			nf.friend_csv_id = t:get_field("toid")
			r = ctx:get_modelmgr():get_u_new_friendmgr():create(nf)
			assert(r)
			r:update_db()

			ctx:get_modelmgr():get_u_new_friendmsgmgr():delete(t:get_field("id"))

			print( "insert a new msg to db" )
		end  

		applied_idlist[tostring(v)] = nil
		friend_idlist[tostring(v)] = {csv_id = v, id = friendid}       
	end 		

	ret.errorcode = errorcode[ 1 ].code
	ret.msg = errorcode[ 1 ].msg
	print( "apply end******************************" )
	return ret      	
end 					
		
function REQUEST:deletefriend(ctx)
	assert(ctx and self.friendid)

	local ret = {}
	local id = friend_idlist[tostring(self.friendid)].id
	assert(id)

	local t = ctx:get_modelmgr():get_u_new_friendmgr():get(id)
	t:set_field("isdelete", 1)
	t:update_db()
	assert(t)

	local r = dc.get(self.friendid)
	if r then          
		skynet.send( r.addr , "lua" , "friend", "agent_request_handle" , {type = msgtype.DELETE, fromid = t:get_field("self_csv_id") } )
		print( "notify an agent " , self.friendid ) 
	else 			                               
		--if not online insert msg into db directly
		local sql = string.format("update from u_new_friend set isdelete = 1 where self_csv_id = %d and friend_csv_id = %d and isdelete = 0", t:get_field("friend_csv_id"), t:get_field("self_csv_id"))
		print(sql)

		local r = query.read(sql)
		assert(r.errno == nil)
		print( "update a new msg to db" )
	end 			

	friend_idlist[tostring(self.friendid)] = nil
	ctx:get_modelmgr():get_u_new_friendmgr():delete(id)

	ret.errorcode = errorcode[ 1 ].code
	ret.msg = errorcode[ 1 ].msg
	print( "apply end******************************" )
	return ret 	
end				
				
function REQUEST:refusefriend(ctx)
	print("refusefriend is called**************************************")
	assert(ctx and self.friendlist)

	for k, v in ipairs(self.friendlist) do
		local id = applied_idlist[tostring(v)].id
		assert(id)
						
		local r = dc.get(self.friendid)
		if r then          
			skynet.send( r.addr , "lua" , "friend", "agent_request_handle" , {type = msgtype.REFUSE, id = id, fromid = ctx:get_user():get_field("csv_id")})
			print( "notify an agent " , v ) 
		else 			                               
			--if not online insert msg into db directly
			local t = ctx:get_modelmgr():get_u_new_friendmsgmgr():get(id)
			assert(t)
			t:set_field("isread", 1)
			t:update_db()
		end 	

		ctx:get_modelmgr():get_u_new_friendmsgmgr():delete(id)
		apply_idlist[tostring(v)] = nil
	end 		

	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	return ret 	
end 		
		 
function REQUEST:findfriend(ctx)
	assert(ctx and self.id)
         
	local ret = {}
	local t = get_friend_basic_info(self.id)
	local f = createfriend(t)
	assert( f )
	ret.errorcode = errorcode[ 1 ].code
	ret.msg = errorcode[ 1 ].msg
	ret.friend = {}
	print( "**************************************************findfriend " , f.id )
	table.insert(ret.friend, f)

	return ret
end 	 	
							   		 
function REQUEST:sendheart(ctx) 
	print("sentheart is called*********************************")
	assert(ctx and self.hl and self.totalamount)
	local ret = {} 		   	   	
   				   		   	   	
   	local prop = ctx:get_modelmgr():get_u_propmgr():get_by_csv_id(const.LOVE)
   	if not prop or prop:get_field("num") < self.totalamount then
   		ret.errorcode = errorcode[ 68 ].code
		ret.msg = errorcode[ 68 ].msg
                                 
		return ret 		   		 
   	end 		   		   
   			               
   	for k, v in pairs(self.hl) do
   		for k, v in pairs(v) do
   			print(k, v)
   		end
   		local nm = {}      
		nm.id = skynet.call(".game", "lua", "guid", const.FRIENDMSG)
		nm.fromid = ctx:get_user():get_field("csv_id")
		nm.toid = v.friendid
		nm.type = msgtype.SENDHEART
    	nm.srecvtime = date    	
    	nm.isread = 1		
    	
		local nm = createmsg(nm)			
		assert(nm)         				
        		   		   				
        --create a sendheart msg and insert into db							
		local t = ctx:get_modelmgr():get_u_new_friendmsgmgr():create(nm)
		assert(t)  		   				
		--ctx:get_modelmgr():get_u_new_friendmsgmgr():add(t)
		t:update_db()  					
											
		local r = dc.get(v.friendid)	
		if r then          				
			skynet.send(r.addr , "lua" , "friend", "agent_request_handle" , nm)
			print("notify an agent " , v.friendid ) 
		else 	   						
			--if not online insert msg into db directly
			local sql = string.format("update from u_new_friend set heartamount = %d where self_csv_id = %d and friend_csv_id = %d and isdelete = 0;", v.amount, v.friendid, ctx:get_user():get_field("csv_id"))
			print(sql)
			query.read(".rdb", "u_new_friend", sql)				
			print( "insert a new msg to db" )
		end                				
										
		--sub prop 						
		prop:set_field("num", prop:get_field("num") - v.amount)           

		--update "ifsent sign"			
		local id = friend_idlist[tostring(v.friendid)].id
		assert(id) 	
		local t = ctx:get_modelmgr():get_u_new_friendmgr():get(id)
		assert(t)  	
		t:set_field("ifsent", 1)
		t:update_db()   
   	end 

   	--update num
   	prop:update_db()

   	ret.errorcode = errorcode[1].code
   	ret.msg = errorcode[1].msg
   	print( "apply end******************************" )

   	return ret 		
end    			   
	   			 
function REQUEST:recvheart(ctx)
	assert(ctx and self.hl and self.totalamount)
    print("self.totalamount", self.totalamount)	
    	    		
	local ret = {}

	if ctx:get_user():get_field("daily_recv_heart") + self.totalamount > MAXHEARTNUM then
		ret.errorcode = errorcode[69].code
		ret.msg = errorcode[69].msg
						
		return ret 	
	end 		  	

	local prop = ctx:get_modelmgr():get_u_propmgr():get_by_csv_id(const.LOVE)

	for k, v in ipairs(self.hl) do
		--if not online insert msg into db directly
		local sql = string.format("update from u_new_friend set heartamount = %d where self_csv_id = %d and friend_csv_id = %d and isdelete = 0;", v.amount, v.friend, ctx:get_user():get_field("csv_id"))
		query.read(sql)
				     
		local id = friend_idlist[tostring(v.friendid)].id
		assert(id)   
		local t = ctx:get_modelmgr():get_u_new_friendmsgmgr():get(id)
		assert(t) 	  
		t:set_field("heartamount", 0)
		t:set_field("ifrecved", 1)
		t:update_db()

		ctx:get_user():set_field("daily_recv_heart", ctx:get_user():get_field("daily_recv_heart") + v.amount)
		
		if prop then
			prop:set_field("num", prop:get_field("num") + v.amount)
		else
			local key = string.format("%s:%d", "g_prop", const.LOVE)

			local p = sd.query(key)
			assert(p)
			p.user_id = ctx:get_user():get_field("csv_id")
			p.num = v.amount
			p.id = genpk_2(p.user_id, p.csv_id)
			local prop = ctx:get_modelmgr():get_u_propmgr():create(p)
			ctx:get_modelmgr():get_u_propmgr():add(prop)
		end
	end 		  

	prop:update_db()
	ctx:get_user():update_db()

	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	return ret
end    	             
	   			     
function new_friend_request:agent_request_handle(ctx, msg)
	assert(ctx and msg)
	print("agent_request_handle is called*************************")
	if msg.type == msgtype.APPLY then
		print("msgtype.APPLY is called")
		applied_idlist[tostring(msg.fromid)] = {csv_id = msg.fromid, id = msg.id}

		local t = ctx:get_modelmgr().u_new_friendmsgmgr():create(msg)
		assert(t)
		ctx:get_user().u_new_friendmsgmgr:add(msg)
		t:update_db()
	elseif msg.type == msgtype.DELETE then
		local id = friend_idlist[tostring(msg.fromid)].id
		assert(id)
		local t = ctx:get_modelmgr():get_u_new_friendmgr():get(id)
		t:set_field("isdelete", 1)
		t:update_db()

		ctx:get_modelmgr():get_u_new_friendmgr():delete(id)
		friend_idlist[tostring(msg.fromid)] = nil

	elseif msg.type == msgtype.ACCEPT then
		print("msgtype.ACCEPT is called")
		local t = ctx:get_user().u_new_friendmsgmgr:get(msg.id)
		assert(t)

		local nf = {}
		friendid = skynet.call(".game", "lua", "guid", const.FRIEND)
		assert(friendid)
		nf.id = friendid
		nf.self_csv_id = t:get_field("toid")
		nf.friend_csv_id = t:get_field("fromid")
		nf.recvtime = date
		nf.isdelete = 0
		nf.heartamount = 0
		nf.update_time = 0
		nf.ifrecved = 0
		local r = ctx:get_user().u_new_friendmgr:create(nf)
		assert(r)
		ctx:get_user().u_new_friendmgr:add(r)
		t:update_db()

		nf.id = skynet.call(".game", "lua", "guid", const.FRIEND)
		nf.self_csv_id = t:get_field("fromid")
		nf.friend_csv_id = t:get_field("toid")
		r = ctx:get_user().u_new_friendmgr:cteate(nf)
		assert(r)
		r:update_db()

		t:set_field("isread", 1)
		t:update_db()

		apply_idlist[tostring(msg.fromid)] = nil

		ctx:get_user().u_new_friendmsgmgr:delete(t:get_field("id"))
		
	elseif msg.type == msgtype.REFUSE then 
		local t = ctx:get_modelmgr():get_u_new_friendmsgmgr():get(msg.id)
		assert(t)
		t:set_field("isread", 1)
		t:update_db()
                     
		apply_idlist[tostring(msg.fromid)] = nil
		ctx:get_modelmgr():get_u_new_friendmsgmgr():delete(t:get_field("id"))

	elseif msg.type == msgtype.SENDHEART then
		local id = friend_idlist[tostring(msg.fromid)].id
		assert(id) 	
		local t = ctx:get_modelmgr():get_u_new_friendmgr():get(id)
		assert(t) 	
		t:set_field("heartamount", msg.heartamount)
		t:set_field("updatetime", msg.updatetime)
		t:update_db()
	end	
end 
	
function new_friend_request:agent_friendmsg(ctx)
	print( "get online user msg !!!!!!!!!!!!!!!!!!" )
	local r = {}
	
	local tmp = util.get_total_property( ctx:get_user(), _, _)
	assert( tmp )
	r.csv_id = ctx:get_user():get_field("csv_id")
	r.name = ctx:get_user():get_field("uname")
	r.level = ctx:get_user():get_field("level")
	r.viplevel = ctx:get_user():get_field("uviplevel")
	r.iconid = ctx:get_user():get_field("iconid")
	r.sign = ctx:get_user():get_field("sign")
	r.combat = tmp[1]
	r.online_time = os.date( "%Y%m%d%H%M%S" , ctx:get_user():get_field("onlinetime")) --user.onlinetime
	r.ifonline = true

	return r
end 

function new_friend_request.start(c, s, g, fgs, tgs, ...)
	-- body	
	print( "*********************************lilianjkh_start" )
	client_fd = c
	send_request = s
	game = g
	func_gs = fgs
	table_gs = tgs
end	

new_friend_request.REQUEST = REQUEST
new_friend_request.RESPONSE = RESPONSE
new_friend_request.SUBSCRIBE = SUBSCRIBE
    	
return new_friend_request
			
		