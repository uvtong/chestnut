local core_fightrequest = {}
	  		
local dc = require "datacenter"
local util = require "util"
local errorcode = requi re "errorcode"
local const = require "const"
local socket = require "socket"
local skynet = require "skynet"
local queue = require "skynet.queue"
										  	
local cs
local FIXED_STEP = 60 --sec, used for lilian_phy_power
local ADAY = 24 * 60 * 60
local IF_TRIGGER_EVENT = 0
	  			  	
local send_package
local send_request

local REQUEST = {}
local RESPONSE = {}
local SUBSCRIBE = {}
local client_fd
local func_gs
local table_gs = {}
	  	
local game 
local user 
local dc 
local record_date = {} 
        
local _Meta = { 
			FightPower = 0,  --actually means presentfight power
		    MaxComboNum = 0, 
		    PresentComboNum = 0,  
		    TotalFightNum = 0,  
		    IsDead = 0,
		    IsAffectedNextTime = 0, 
			FightList = {}, 
			FightIdList = {}, 
			TmpFightIdList = {},
			Attr = {} 
		  } 

local function New()
	local t = {}
 	setmetatable( t, { __index = _Meta } )
 	return t
end

local QuanFaNum = 7
local FIGHT_TYPE = {GUANQIA = 1, ARENA = 2}
local INIT_TYPE = {SELF = 1, ENEMY = 2}
local ATTACK_TYPE = {AUTOMATIC = 1, MANUAL = 2}
local SELF = 1
local ENEMY = 2
local START_DELAY = 3 --sec
local COMMON_KF = 100001
local COMBO_KF = 100002

local Self = New()
local Enemy = New()

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
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
	  	
local function update()
	print( "timeout update is called **************************************" )
	local session = func_gs()
	table_gs[tostring(session)] = "lilian_update"
	send_package( send_request( "lilian_update" , nil, session , _) )
end   		
	  	
local function daily_update()
	print( "daily update is called" )
	local date = os.time()
	local settime = getsettime()
    	    
	skynet.timeout( ( settime + ADAY - date ) * 100, update )
end 	
			
function REQUEST:login(u)
	-- body
	assert( u )
	print("**********************************lilianrequest_login")
	user = u
end	    
	    	
local function first_fighter()		
	return ( 0 == math.random(100) % 2 )                      -- true user first, false robot first;
end 	
				
local function SortFunc(ta, tb)
	return ta.arise_probability > tb.arise_probability 
end 	
	
local function get_ordered_fight_list(tfightlist, reserved_fight_list, reserved_fightid_list)
	assert(tfightlist and reserved_fight_list)

	for k, v in pairs(tfightlist) do
		local kf = skynet.call(".game", "lua", "query_g_kungfu", v)
		assert(kf)
		if 1 == kf.type then                                        -- only insert posirive skill
			table.insert(reserved_fight_list, kf)
		end
	end 

	table.sort(reserved_fight_list, SortFunc)

	for k , v in ipairs(reserved_fight_list) do
		reserved_fightid_list[tostring(v.g_csv_id)] = k
	end 				
end 					
							
local function get_ordered_fight_list_to_client(sordered_fight_list, tmp_fightid_list)
	assert(sordered_fight_list and tmp_fightid_list)

	local total_raise_prob = 0    --the sum of all kf trigger prob
	local sign = false            --to indicate if if first time to get bigger than sign

	for k , v in ipairs(sordered_fight_list) do
		total_raise_prob = total_raise_prob + v.arise_probability
				     		
		if judge_arise_count(kf) and judge_arise_type(kf, totalfightnum) then
			if total_raise_prob < 100 then																										
				table.insert(tmp_fightid_list, {kf_id = v.g_csv_id, prob = v.arise_probability})
			elseif sign == false then              
				table.insert(tmp_fightid_list, {kf_id = v.g_csv_id, prob = v.arise_probability})
				break						
			end 	 					
		end    		 				
	end 			 				
					 				
	-- if total_raise_prob < 100% , then add a common fight
	if total_raise_prob < 100 then             
		table.insert(tmp_fightid_list, {kf_id = COMMON_KF, prob = 100 - total_raise_prob}) --tmp					
		--table.insert(reserved_fight_list, )
		--reserved_fightid_list[tostring()] = #reserved_fight_list + 1
	end 					
		
	return ret
end 	
		
local function get_monster_fight_list(monsterid)
	assert(monsterid)
	local fight_id_list = {}
		
	local r = skynet.call(".game", "lua", "query_g_monster", monsterid)
	assert(r)
		
	Enemy.Attr.combat = r.combat
	Enemy.Attr.defence = r.defence
	Enemy.Attr.critical_hit = r.critical_hit
	Enemy.Attr.king = r.blessing
	
	local t = util.parse_text(r.quanfaid, "", 1)
	local tmp = {}
	for k, v in ipairs(t) do
		tmp[k] = v[1]
	end 
	
	assert(#tmp > 0)
	
	fight_id_list = get_ordered_fight_list(tmp, Enemy.FightList, Enemy.FightIdList)
	
	return fight_id_list
end 
										
local function get_fight_list(uid, roleid, roletype)
	local ret = {}
	local r = {}
	local TmpSelf = {}
	
	if roletype == SELF then
		r = user.u_rolemgr:get_by_csv_id(roleid)
		assert(r)
		TmpSelf = Self
	else
		local sql = string.format("select * from u_role where user_id = %s and csv_id = %s" , uid , roleid)
		r = skynet.call(util.random_db(), "lua", "command", "query", sql)
		assert(r)
		TmpSelf = Enemy
	end
	
	local inx = 1
	local tmp = {}

	while idx <= QuanFaNum do
		local k_csv_id = "k_csv_id" .. idx
		local kfid = r[k_csv_id]

		if 0 ~= kfid then
			table.insert(tmp, kfid)
		end
		idx = idx + 1
	end 
	
	ret = get_ordered_fight_list(tmp, TmpSelf.FightList, TmpSelf.FightIdList)
		
	return ret
end 	
	
local function init_attribute(uid, roleid, inittype)
	assert(uid and roleid and inittype)

	if (inittype == SELF) then
		local t = util.get_total_property(user, _, roleid)
		assert(t)

		Self.Attr.combat = t[1]
		Self.Attr.defence = t[2]
		Self.Attr.critical_hit = t[3]
		Self.Attr.king = t[4]
	else     
		local t = util.get_total_property(_, uid, roleid)
		assert(t)

		Enemy.Attr.combat = t[1]
		Enemy.Attr.defence = t[2]
		Enemy.Attr.critical_hit = t[3]
		Enemy.Attr.king = t[4]
	end			
end			
										
function REQUEST:BeginGUQNQIACoreFight()
	assert(self.monsterid)
	print("BeginGUANQIACoreFight is called *******************************", self.monsterid)

	local ret = {}
		
	get_monster_fight_list(self.monsterid)
	init_attribute(_, user.c_role_id, SELF)

	ret.errorcode = errorcode[1].code
	ret.delay_time = START_DELAY
	if first_fighter() then
		ret.firstfighter = SELF
	else
		ret.firstfighter = ENEMY
	end

	return ret
end 
	
function REQUEST:BeginArenaCoreFight()
	assert(self.uid and self.roleid)
	print("BeginArenaCoreFight is called **********************************", )

    local ret = {}

	get_fight_list(_, user.c_role_id, SELF)
	get_fight_list(self.uid, self.roleid, ENEMY)
	init_attribute(_, user.c_role_id, SELF)
	init_attribute(self.uid, self.roleid, ENEMY)

	ret.errorcode = errorcode[1].code
	ret.delay_time = START_DELAY
	if first_fighter() then
		ret.firstfighter = SELF
	else
		ret.firstfighter = ENEMY
	end 

	return ret
end 		
	
local function judge_arise_type(kf, totalfightnum)
	assert(kf and totalfightnum)
	local sign = false

	if 0 == kf.arise_type then
		sign = true
	elseif 1 == kf.arise_type then
		sign = Self.FightPower < math.floor(Self.Attr.combat * (kf.arise_param / 100))
	elseif 2 == kf.arise_type then
		sign =  Enemy.FightPower < math.floor(Enemy.Attr.combat * (kf.arise_param / 100))
	elseif 3 == kf.arise_type then
		sign = (totalfightnum + 1) == kf.arise_param
	elseif 
		assert(false)
	end 		

	return sign 
end 			
		
local function judge_arise_count(kf)
	assert(kf)	
	local sign = false
    
	if 0 == kf.arise_count then
		sign = true
	else 		
		if kf.actual_fight_num + 1 <= kf.arise_count then
			sign = true	
		end 	
	end 		

	return sign
end 		
					
local function get_attack(kf, TmpSelf, TmpEnemy)
	assert(kf and TmpSelf and TmpEnemy)

	local totalattack = 0

	local defenceprob = TmpEnemy.Attr.defence / (TmpEnemy.Attr.defence + 100)               	--enemy defenceprob
	local critical_heartprob = 	TmpSelf.Attr.critical_hit / (TmpSelf.Attr.critical_hit + 100)	-- self critical_hitprob
	local kingprob = TmpSelf.Attr.king / (TmpSelf.Attr.king + 100) 								--self kingprob

	if 1 == kf.attack_type then --common attack
		totalattack = math.floor((TmpSelf.Attr.combat * 0.2 + TmpSelf.FightPower * 0.1) * (kf.effect_pre / 100) * (1 - defenceprob))
	elseif 2 == kf.attack_type then --critical attack
		totalattack = math.floor((TmpSelf.Attr.combat * 0.2 + TmpSelf.FightPower * 0.1) * (kf.effect_pre / 100) * (1 - defenceprob) * (1 + critical_heartprob))
	elseif 3 == kf.attack_type then 

	elseif 4 == kf.attack_type then -- combo attack
		totalattack = math.floor((TmpSelf.Attr.combat * 0.2 + TmpSelf.FightPower * 0.1) * (1 + TmpSelf.combonum * 0.1 + kingprob + critical_heartprob))
	else 		
		--TODO	
	end 		

	print(" totalattack******************************* ", totalattack)
	return totalattack
end 						
			
local function get_attacheffect(kf, TmpSelf, TmpEnemy)
	assert(kf and TmpSelf and TmpEnemy) 
	local tmp = {}
	if 1 == kf.attach_type then
		for k , v in ipairs(TmpEnemy.FightList) do
			if v.arise_param <= kf.arise_param then
				table.insert(tmp, v)
			else
				break
			end
		end

		TmpEnemy.TmpFightIdList = {}
		get_ordered_fight_list_to_client(TmpEnemy.FightList, TmpEnemy.TmpFightIdList)
		TmpEnemy.IsAffectedNextTime = 1

	elseif 2 == kf.attach_type then
		TmpSelf.FightPower = TmpSelf.FightPower + math.floor(totalattack * (kf.attch_state / 100) )
		if TmpSelf.FightPower > TmpSelf.Attr.combat then
			TmpSelf.FightPower = TmpSelf.Attr.combat
		end 																							
	elseif 3 == kf.attach_type then
		TmpSelf.FightPower = TmpSelf.FightPower + math.floor(TmpSelf.Attr.combat * (kf.attch_state / 100) )
		if TmpSelf.FightPower > TmpSelf.Attr.combat then
			TmpSelf.FightPower = TmpSelf.Attr.combat
		end 
	elseif 4 == kf.attach_type then
		TmpSelf.FightPower = TmpSelf.FightPower - math.floor(totalattack * (kf.attch_state / 100) )
		if TmpSelf.FightPower <= 0 then
			TmpSelf.FightPower = 0
			TmpSelf.IsDead = 1
		end 
	elseif 5 == kf.attach_type then
		TmpEnemy.FightPower = TmpEnemy.FightPower - math.floor((TmpEnemy.Attr.combat - TmpEnemy.FightPower) * (kf.attach_state / 100))
		if TmpEnemy.FightPower <= 0 then
			TmpEnemy.FightPower = 0
			TmpEnemy.IsDead = 1
		end 																							
	elseif 6 == kf.attach_type then
		local effectheart= TmpEnemy.FightPower - math.floor(TmpEnemy.FightPower * (kf.attach_state / 100))
		if TmpEnemy.FightPower - effectheart <= 0 then
			TmpEnemy.FightPower = 0
			TmpEnemy.IsDead = 1
		else 
			TmpEnemy.FightPower = TmpEnemy.FightPower - effectheart
			TmpSelf.FightPower = TmpSelf.FightPower + effectheart
			if TmpSelf.FightPower > TmpSelf.Attr.combat then
				TmpSelf.FightPower = TmpSelf.Attr.combat
			end
		end  
	else 		
		--TODO deal 0 type 
	end 		
end				
							
local function get_kf_id_by_prob(kflist, prob)
	assert(kflist and prob)

	local totalprob = 0
	for k, v in ipairs(kflist) do
		totalprob = totalprob + v.prob
		if prob < totalprob then
			return v.kf_id
		end 	
	end 			

	return false 		
end					
	
local KF_TYPE = {QUANFA = 1, COMBO = 2, COMMON = 3}
local function do_verify(v, userroleid)
	print("do_verify is called********************************")
	assert(v) 	

	local TmpSelf = {}
	local TmpEnemy = {}

	if v.fighterid == userroleid then
		TmpSelf = Self
		TmpEnemy = Enemy	
	else 			
		TmpSelf = Enemy
		TmpEnemy = Self
	end 			

	local kf = {}	
	local totalattack = 0

	if 0 == TmpSelf.IsDead and 0 == TmpEnemy.IsDead then
		kf = TmpSelf.FightList[TmpSelf.FightIdList[tostring(v.kf_id)]]
		assert(kf)	

		if 1 == v.attacktype then 					-- if AUTOMATIC ATTACK
			if 0 == TmpSelf.IsAffectedNextTime then
				get_ordered_fight_list_to_client(TmpSelf.FightList, TmpSelf.TmpFightIdList)
			else
				TmpSelf.IsAffectedNextTime = 0
			end
			if 0 == TmpEnemy.IsAffectedNextTime then
				get_ordered_fight_list_to_client(TmpEnemy.FightList, TmpEnemy.TmpFightIdList)
			else
				TmpEnemy.IsAffectedNextTime = 0
			end

			local tmp_kf_id = get_kf_id_by_prob(TmpSelf.TmpFightIdList, v.prob)
			if not tmp_kf_id then 
				return false	  
			else 				  	
				if tmp_kf_id == v.kf_id then
					totalattack = get_attack(kf, TmpSelf, TmpEnemy) 		
				else 			  	
					return false   
				end 			  	
			end 				  		
		else 					  					--if MANUAL ATTACK								
			if v.kf_type == KF_TYPE.COMBO then
				if TmpSelf.PresentComboNum >= v.random_combo_num then
					totalattack = get_attack(kf, TmpSelf, TmpEnemy)
					print("totalattack is ********************************", totalattack)
				else 						
					return false
				end 								
			elseif v.kf_type == KF_TYPE.COMMON then
				totalattack = get_attack(kf, TmpSelf, TmpEnemy)
				TmpSelf.PresentComboNum = TmpSelf.PresentComboNum + 1
			else 	
				assert(false)
			end 				

			TmpEnemy.PresentComboNum = 0
		end 		

		local isdead

		if totalattack == v.attack then	
			if TmpEnemy.FightPower - totalattack > 0 then
				TmpEnemy.FightPower = TmpEnemy.FightPower - totalattack
				get_attacheffect(kf, TmpSelf, TmpEnemy)
				isdead = false
			else 	
				isdead = true		
			end 	

			if isdead == v.IsDead then
				return true						
			else 	
				return false
			end		
		else 		
			return false	
		end 		
	else 			
		return false
	end 			
end 				
								
function REQUEST:GuanQiaBattleList()
	print("BattleList is called ****************************")
	assert(self.fightlist)
	local ret = {}		

	for k , v in ipairs(self.fightlist) do
		if not do_verify(v, user.c_role_id) then
			ret.errorcode = errorcode[].code
			return ret
		end
	end 	

	ret.errorcode = errorcode[1].code
	return ret
end 		
		
function REQUEST:ArenaBattleList()
	print("ArenaBattleList is called**********************************")
	assert(self.fightlist)

	for k , v in ipairs(self.fightlist) do

	end 	
end 		
			
local NormalExistTime	
local MAX_EXIT_TIME = 5 --sec
			
function REQUEST:OnNormalExitCoreFight()
	print( "OnNormalExitCoreFight is called *****************************" )		
	NormalExistTime = os.time()
end 		
	
function REQUEST:OnReEnterCoreFight()	
	print( "OnReEnterCoreFight is called**************************************" )
	local date = os.time()
	local ret = {}

	if date - NormalExistTime >= MAX_EXIT_TIME then
		--TODO Tell client user failed

		user.is_in_core_fight = 0

		ret.errorcode = errorcode[110].code
	else
		ret.errorcode = errorcode[111].code  --tell client continue play effect
	end 

	return ret
end 
	
function REQUEST:EndCoreFight()

end 
	
function core_fightrequest.start(c, s, g, fgs, tgs, ...)
	-- body	
	print( "*********************************lilian_start" )
	client_fd = c
	send_request = s
	game = g
	func_gs = fgs
	table_gs = tgs
end		 	
			
function core_fightrequest.disconnect()
	-- body	
end			

core_fightrequest.REQUEST = REQUEST
core_fightrequest.RESPONSE = RESPONSE
core_fightrequest.SUBSCRIBE = SUBSCRIBE
			
return core_fightrequest