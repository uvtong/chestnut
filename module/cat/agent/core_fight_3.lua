local core_fightrequest = {}
	  		
local dc = require "datacenter"
local util = require "util"
local errorcode = require "errorcode"
local const = require "const"
local socket = require "socket"
local skynet = require "skynet"
local queue = require "skynet.queue"
	  									  	
local cs
	  			  	
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
	  	
local QuanFaNum = 7
local SELF = 1
local ENEMY = 2
local START_DELAY = 3 --sec
local CERTAIN_SEQUENCE_KF = 3
local FIGHT_PLACE = 0 
	  	
local COMMON_KF = 90000
local COMBO_KF = 100000
local kf_common = {}
local kf_combo = {}
local PLACE = {GUANQIA = 1, ARENA = 2}
local KF_TYPE = {QUANFA = 1, COMBO = 2, COMMON = 3}
	  		
local Self = {  
			FightPower = 0,  --actually means presentfight power
		    MaxComboNum = 0, 
		    PresentComboNum = 0,  
		    TotalFightNum = 0,  
		    IsDead = 0,
		    IsAffectedNextTime = 0, 
		    Tmp_kf_id = 0,
			FightList = {}, 
			FightIdList = {}, 
			TmpFightIdList = {},
			Attr = {}, 
			Uid = 0,
			OnBattleList = {},
			IfArenaInit = 0,
			OnBattleSequence = 1                                           
		  }	                                                               
                                                                           
local Enemy = {                                                            
			FightPower = 0,  			--actually means presentfight power
		    MaxComboNum = 0, 			--maxcomboNum in this battle       
		    PresentComboNum = 0,        --dang qian lei ji de lian ji shu   
		    TotalFightNum = 0,  		--ziji zi dong zhan dou yi gon chu le duo shao quan
		    IsDead = 0,					--shi fou si wang                   
		    IsAffectedNextTime = 0, 	--ben ci zi dong zhan dou xuan zhong de fu jia xiao guo shi fou ying xiang xia ci xu lie
		  	Tmp_kf_id = 0,				--dang qian quanfa                 
		  	FightList = {}, 			--each role equipd positive kf list
		  	FightIdList = {}, 			--to get the element in FightList quickly, user FightIdList store ("kf_id" = index (index is the position in FightLIst))
		  	TmpFightIdList = {},		--store next automatic kf_id list sequence
		  	Attr = {}, 					--store 4 basic attrubute            
		  	Uid = 0,					--                                  
		  	OnBattleList = {},			--store chosen battle role_id 	
		  	IfArenaInit = 0,			--if Arenainited
		  	OnBattleSequence = 1 		--di ji ge shang zhen de jue se 
		  } 

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end	  	  	   	
				
function REQUEST:login(u)
	-- body
	assert( u )
	print("**********************************lilianrequest_login")
	user = u
end	    
		
--get who fight first, true user first, false robot first;	    	
local function first_fighter()		
	return ( 0 == math.random(100) % 2 )                      
end 	
		
--judeg if arise_type is true	
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
	else 
		assert(false)
	end  		
	print("judge_arise_type is *************************************", kf.arise_type , sign)
	return sign 
end 

local function get_kf_id_by_prob(kflist, prob) 	
  	assert(kflist and prob)						
    
  	local totalprob = 0												    
  	for k, v in ipairs(kflist) do
  		totalprob = totalprob + v.prob
  		if prob <= totalprob then
  			return v.kf_id 	
  		end  				
  	end 	 				
             				
  	return false 			
end 	
	
--judge if arise_count is true	
local function judge_arise_count(kf)
	assert(kf)	
	local sign = false
    print("kf.actual_fight_num and kf.arise_count in judge_arise_count is ",kf.g_csv_id, kf.actual_fight_num, kf.arise_count)
	if 0 == kf.arise_count then
		sign = true
	else 		
		if kf.actual_fight_num + 1 <= kf.arise_count then
			sign = true	
		end 	
	end 		
	print("judge_arise_count is *************************************", kf.actual_fight_num, kf.arise_count, sign)
	return sign 
end 
	
local function SortFunc(ta, tb)
	return ta.arise_probability < tb.arise_probability 
end 
	
--huo de wan jia shang zhen jue se de sou you zhu dong quan fa , bing an zhao chu fa gai lv pai xu
local function get_ordered_fight_list(tfightlist, reserved_fight_list, reserved_fightid_list)
	assert(tfightlist and reserved_fight_list)
	print("sizeof tfightlist is :", #tfightlist, #reserved_fight_list)

	for k, v in pairs(tfightlist) do
		local kf = skynet.call(".game", "lua", "query_g_kungfu", v)
		assert(kf)					
		if 1 == kf.type then                                        -- only insert posirive skill
			kf.actual_fight_num = 0
			table.insert(reserved_fight_list, kf)
		end
	end 
		
	print("reserved_fight_list is ***************************", #reserved_fight_list)
							
	table.sort(reserved_fight_list, SortFunc)

	for k , v in ipairs(reserved_fight_list) do
		print("reserved idlist is ", v.g_csv_id)		 	
		reserved_fightid_list[tostring(v.g_csv_id)] = k
	end 										 	
end 		 
	
--huo de mei ci zi dong zhan dou de quan fa xu lie
local function get_ordered_fight_list_to_client(sordered_fight_list, tmp_fightid_list, totalfightnum)
	assert(sordered_fight_list and tmp_fightid_list)
             
	local total_raise_prob = 0    --the sum of all kf trigger prob
	local sign = false            --to indicate if if first time to get bigger than sign
	print("sizeof sordered_fight_list is ", #sordered_fight_list)
    	 
	--when get next fight_list , need to get if there is a special kf that need to generate in a certain squence
	local if_has_certain_kfid = false

	--shou xian pan duan ,shi fou you di ji ci bi xu chu fa de quan fa
	for k, v in ipairs(sordered_fight_list) do
		if CERTAIN_SEQUENCE_KF == v.arise_type then
			if totalfightnum + 1 == v.arise_param then
				print("find the certain_sequence_kf*************************")
				if_has_certain_kfid = true
				table.insert(tmp_fightid_list, {kf_id = v.g_csv_id, prob = 100})
				assert(false)
			end
		end
	end 

	--ruo mei you ,zou zheng chang de liu cheng 
	if not if_has_certain_kfid then
		for k , v in ipairs(sordered_fight_list) do
			if judge_arise_count(v) and judge_arise_type(v, totalfightnum) then
				total_raise_prob = total_raise_prob + v.arise_probability
				if total_raise_prob < 100 then																										
					table.insert(tmp_fightid_list, {kf_id = v.g_csv_id, prob = v.arise_probability})
				elseif sign == false then 
					table.insert(tmp_fightid_list, {kf_id = v.g_csv_id, prob = v.arise_probability})
					break				  		
				end 	 					
			end    		 				
		end 	

		print("totalattack in get_ordered_fight_list is", total_raise_prob)
			
	-- if total_raise_prob < 100% , then add a common fight
		if total_raise_prob < 100 then             
			table.insert(tmp_fightid_list, {kf_id = COMMON_KF, prob = 100 - total_raise_prob}) --tmp					
			--table.insert(reserved_fight_list, )
			--reserved_fightid_list[tostring()] = #reserved_fight_list + 1
		end 				
	end	
end 	
		
--huo de guai de 		
local function get_monster_fight_list(monsterid)
	assert(monsterid)
	local fight_id_list = {}
			
	local r = skynet.call(".game", "lua", "query_g_monster", monsterid)
	assert(r)
		
	Enemy.Attr.combat = r.combat  
	Enemy.Attr.defence = r.defense
	Enemy.Attr.critical_hit = r.critical_hit
	Enemy.Attr.king = r.blessing  
    	
	Enemy.FightPower = r.combat 
	print("r.quanfaid is ********************************************", r.quanfaid)
	local t = util.parse_text(r.quanfaid, "(%d+%*?)", 1)
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
	local TmpSelf 																			
	print("get_fight_list is ******************************", roletype, SELF)
	
	if roletype == SELF then
		r = user.u_rolemgr:get_by_csv_id(roleid)
		assert(r)
		TmpSelf = Self
		print("fucking tempself == self")
	else 																						
		local sql = string.format("select * from u_role where user_id = %s and csv_id = %s" , uid, roleid)
		r = skynet.call(util.random_db(), "lua", "command", "query", sql)
		assert(r)
		TmpSelf = Enemy
		print("fucking tempself == Enemy")
	end 	

	local idx = 1
	local tmp = {}

	while idx <= QuanFaNum do
		local k_csv_id = "k_csv_id" .. idx
		local kfid = r[k_csv_id]
		print(k_csv_id, kfid)
		if 0 ~= kfid then
			table.insert(tmp, kfid)
		end
		idx = idx + 1
	end 

	--assert(Self.FightList == Enemy.FightLIst)
	for k, v in ipairs(TmpSelf.FightList) do
		print(k, v.g_csv_id)
	end 
			  
	--assert(TmpSelf.FightList == {})		
	ret = get_ordered_fight_list(tmp, TmpSelf.FightList, TmpSelf.FightIdList)
	print("TmpSelf.Fight in get_fight_list is ****************************")
			  	
	return ret
end 		  	
		
local function init_attribute(uid, roleid, inittype)
	print("uid, roleid, inittype", uid, roleid, inittype)
	--assert(uid and roleid and inittype)
	local t = {}
		
	if inittype == SELF then
		t = util.get_total_property(user, _, _)
		assert(t)
				
		Self.Attr.combat = t[1] or 0
		Self.Attr.defence = t[2] or 0
		Self.Attr.critical_hit = t[3] or 0
		Self.Attr.king = t[4] or 0
			
		Self.FightPower = t[1] or 0
	else     
		t = util.get_total_property(_, uid, roleid)
		assert(t)
		
		Enemy.Attr.combat = t[1] or 0
		Enemy.Attr.defence = t[2] or 0
		Enemy.Attr.critical_hit = t[3] or 0
		Enemy.Attr.king = t[4] or 0
		
		Enemy.FightPower = t[1] or 0
	end	
		
	print("basic property is************************************", t[1], t[2], t[3], t[4])
end	
	
local function TmpPrintContent(t)
	assert(t)
	for k , v in pairs(t) do
		if type(v) == "table" then
			print(k .. ":")
			for sk, sv in pairs(v) do
				print(sk, sv)
			end
		else
			print(k, v)
		end
	end

	print("sizeof tmpself.FightList is***************************** ", #(t.FightList))
end	
	
local function get_kf_common_and_combo()
	local r = skynet.call(".game", "lua", "query_g_kungfu", COMMON_KF)
	assert(r)
	kf_common = r
	
	local t = skynet.call(".game", "lua", "query_g_kungfu", COMBO_KF)
	assert(t)
	kf_combo = t
end	
	
local function reset(t) 
	assert(t) 

	t.FightPower = 0	  	
	t.TmpFightIdList = {} 	
	t.FightIdList = {}	  
	t.FightList = {}
	t.Attr = {}			  	 
	t.IsDead = 0 		 
	t.IsAffectedNextTime = 0
	t.MaxComboNum = 0	 
	t.PresentComboNum = 0
	t.TotalFightNum = 0  
	t.Tmp_kf_id = 0
	
end      
		 	
local function reset_arena(t)
	reset(t)
		 
	t.Uid = 0
	t.OnBattleList = {}
	t.IfArenaInit = 0
	t.OnBattleSequence = 1
end 	 	
		 	
function REQUEST:TMP_BeginGUQNQIACoreFight()
	assert(self.monsterid)
	print("BeginGUANQIACoreFight is called *******************************", self.monsterid)
		 			
	FIGHT_PLACE = PLACE.GUANQIA
		 
	reset(Self)
	reset(Enemy)
           	
	local ret = {}
	if not kf_common or not kf_combo then
		get_kf_common_and_combo()
	end  
		 	
	get_monster_fight_list(self.monsterid)

	init_attribute(_, user.c_role_id, SELF)
	get_fight_list(_, user.c_role_id, SELF)
    	 	
    -- who fight first
    local TmpSelf
    if first_fighter() then
		ret.firstfighter = user.c_role_id
		TmpSelf = Self
	else   	
		ret.firstfighter = self.monsterid
		TmpSelf = Enemy
	end  

	--get first fighter kf_id 
	get_ordered_fight_list_to_client(TmpSelf.FightList, TmpSelf.TmpFightIdList, TmpSelf.TotalFightNum)
	local rdm = math.random(100)
	local kf_id = get_kf_id_by_prob(TmpSelf.TmpFightIdList, rdm)
	assert(kf_id)
	print("self kf_id is ************************************", kf_id)
	TmpSelf.Tmp_kf_id = kf_id
    ret.kf_id = kf_id  
	
	ret.errorcode = errorcode[1].code
	ret.delay_time = START_DELAY
                 	

	return ret
end 	  	
		  	
local function get_on_battle_list(uid, type)	 		
	assert(uid and type and TmpSelf)	 	
	if type == SELF then 
		local idx = 1 
		while idx <= ON_BATTLE_ROLE_NUM do
		  	local ara_role_id = "ara_role_id" .. idx
		  	local value = user[ara_role_id]
		  	if 0 == value then 
		  		return false 
		  	else 
		  		table.insert(Self.OnBattleList, value)
		  	end 
		end	                 
	elseif type == ENEMY then
		local sql = string.format("select ara_role_id1, ara_role_id2, ara_role_id3 from users where csv_id = %s", uid)
		local r = skynet.call(util.random_db(), "lua", "command", "query", sql)
		assert(#r == 3)       
                             
		local idx = 1        
		while idx <= ON_BATTLE_ROLE_NUM do
		  	local ara_role_id = "ara_role_id" .. idx
		  	local value = r[1][ara_role_id]
		  	if 0 == value then 
		  		return false 
		  	else 			 
		  		table.insert(Enemy.OnBattleList, value)
		  	end              
		end                  
	else                      
		assert(false)         
	end   
   	
	return true
end 	  
		  
local function get_attack(kf, TmpSelf, TmpEnemy)
	assert(kf and TmpSelf and TmpEnemy)
    
	local totalattack = 0
          			
	local defenceprob = TmpEnemy.Attr.defence / (TmpEnemy.Attr.defence + 100)                	--enemy defenceprob
	local critical_heartprob = 	TmpSelf.Attr.critical_hit / (TmpSelf.Attr.critical_hit + 100) 	-- self critical_hitprob
	local kingprob = TmpSelf.Attr.king / (TmpSelf.Attr.king + 100) 								--self kingprob
	print("kingprobis ",kingprob, kf.attack_type) 
	
	for k, v in pairs(kf) do
		print(k, v)
	end
	
	if 1 == kf.attack_type then --common attack
		totalattack = math.floor((TmpSelf.Attr.combat * 0.2 + TmpSelf.FightPower * 0.1) * (kf.effect_percent / 100) * (1 - defenceprob) * (1 + kingprob ))
		print("all value in get_attack is1 ", TmpSelf.Attr.combat, TmpSelf.FightPower, kf.effect_percent, defenceprob,kingprob)
		print(TmpSelf.Attr.combat * 0.2, TmpSelf.FightPower * 0.1, kf.effect_percent / 100, 1 - defenceprob, 1 + kingprob)
	elseif 2 == kf.attack_type then    --critical attack
		totalattack = math.floor((TmpSelf.Attr.combat * 0.2 + TmpSelf.FightPower * 0.1) * (kf.effect_percent / 100) * (1 - defenceprob) * (1 + critical_heartprob))
		print("all value in get_attack is 2", TmpSelf.Attr.combat, TmpSelf.FightPower, kf.effect_percent, defenceprob, critical_heartprob)
	elseif 3 == kf.attack_type then 
          
	elseif 4 == kf.attack_type then    --combo attack
		totalattack = math.floor((TmpSelf.Attr.combat * 0.2 + TmpSelf.FightPower * 0.1) * (1 + TmpSelf.PresentComboNum * 0.1 + kingprob + critical_heartprob))
		print("all value in get_attack is 4", TmpSelf.Attr.combat, TmpSelf.FightPower, kf.effect_percent, defenceprob, TmpSelf.PresentComboNum, kingprob)
	else  		
		--TODO	
	end   		
         
	print(" totalattack******************************* ", totalattack)
	return totalattack
end 	 					
	
local function get_attacheffect(kf, TmpSelf, TmpEnemy, totalattack)
	print("in get_attacheffect**********************************", kf.addition_effect_type)
	assert(kf and TmpSelf and TmpEnemy and totalattack) 
	local tmp = {}
	local effect = 0
	if 1 == kf.addition_effect_type then
		for k , v in ipairs(TmpEnemy.FightList) do
		 	if v.addition_prog <= kf.addition_prog then
		 		table.insert(tmp, v)
		 	else
		 		break
		 	end 
		end 	
         
		TmpEnemy.TmpFightIdList = {}
		get_ordered_fight_list_to_client(TmpEnemy.FightList, TmpEnemy.TmpFightIdList, TmpEnemy.TotalFightNum)
		TmpEnemy.IsAffectedNextTime = 1
         	
		print("attacheffect is 1")
		for k, v in ipairs(TmpEnemy.TmpFightIdList) do
		 	print(k, v )
		end 
	elseif 2 == kf.addition_effect_type then
		effect = math.floor(totalattack * (kf.addition_prog / 100) )
		TmpSelf.FightPower = TmpSelf.FightPower + effect
		if TmpSelf.FightPower > TmpSelf.Attr.combat then
		 	TmpSelf.FightPower = TmpSelf.Attr.combat
		end 
		print("attacheffect is 2 *******************", math.floor(totalattack * (kf.addition_prog / 100) )) 																							
	elseif 3 == kf.addition_effect_type then
		effect = math.floor(TmpSelf.Attr.combat * (kf.addition_prog / 100) )
		TmpSelf.FightPower = TmpSelf.FightPower + effect
		if TmpSelf.FightPower > TmpSelf.Attr.combat then
		 	TmpSelf.FightPower = TmpSelf.Attr.combat
		end 	
		print("attacheffect is 3 *******************", math.floor(TmpSelf.Attr.combat * (kf.addition_prog / 100) ))
	elseif 4 == kf.addition_effect_type then
		effect = math.floor(totalattack * (kf.addition_prog / 100) )
		TmpSelf.FightPower = TmpSelf.FightPower - effect
		if TmpSelf.FightPower <= 0 then
		 	TmpSelf.FightPower = 0
		 	TmpSelf.IsDead = 1
		end  			  
		print("attacheffect is 4 *******************", math.floor(totalattack * (kf.addition_prog / 100) ))
	elseif 5 == kf.addition_effect_type then
		effect = math.floor((TmpEnemy.Attr.combat - TmpEnemy.FightPower) * (kf.addition_prog / 100))
		TmpEnemy.FightPower = TmpEnemy.FightPower - effect
		if TmpEnemy.FightPower <= 0 then
		 	TmpEnemy.FightPower = 0
		 	TmpEnemy.IsDead = 1
		end  					
		print("attacheffect is 5 *******************", math.floor((TmpEnemy.Attr.combat - TmpEnemy.FightPower) * (kf.addition_prog / 100)))																																																								 			
	elseif 6 == kf.addition_effect_type then
		effect = math.floor(TmpEnemy.FightPower * (kf.addition_prog / 100))
		if TmpEnemy.FightPower - effect <= 0 then
		 	TmpEnemy.FightPower = 0
		 	TmpEnemy.IsDead = 1
		else 			  																				  	
		 	TmpEnemy.FightPower = TmpEnemy.FightPower - effect
		 	TmpSelf.FightPower = TmpSelf.FightPower + effect
		 	if TmpSelf.FightPower > TmpSelf.Attr.combat then
		 	 	TmpSelf.FightPower = TmpSelf.Attr.combat
		 	end 		  	
  		end  				
  		print("attacheffect is 5 *******************", math.floor(TmpEnemy.FightPower * (kf.addition_prog / 100)) )
  	else    
  		--TODO deal 0 type 	
  	end  	 				
  	print("get attach_effect is over***************************************", effect)
  	return effect 			
end		   	 	 		  	
             	 			
--gen ju ke hu duan chuan lai de kf_prob lai xulie zhong zhao dao duiying de kf_id			
local function get_kf_id_by_prob(kflist, prob) 	
  	assert(kflist and prob)						
              	 			
  	local totalprob = 0												    
  	for k, v in ipairs(kflist) do
  		totalprob = totalprob + v.prob
  		if prob <= totalprob then
  			return v.kf_id 	
  		end  				
  	end 	 				
             				
  	return false 			
end 							
  							
--yan zheng ke hu duan chuan lai de shuju shi fou zheng que, 
--								
--1. testify if client and server generate the same kf_id 
--2. if 1. testify if client and server generage the same heart
--3. if 2. testify if attach-effect is the same
--4. if 3. testify who dead , if user 1, enemy 2 . if it is the same as server .then 
--   this battle is correct.
local function do_verify(v, userroleid)
  	print("do_verify is called********************************", userroleid)
  	assert(v)
  			
  	local TmpSelf = {}
  	local TmpEnemy = {}
  				
  	if v.fighterid == userroleid then --
  		TmpSelf = Self
  		TmpEnemy = Enemy	
  	else 			
  		TmpSelf = Enemy
  		TmpEnemy = Self
  	end 			
  					
  	local kf = {}	
  	local totalattack = 0	
  				
  	if 0 == TmpSelf.IsDead and 0 == TmpEnemy.IsDead then
  		if 1 == v.attcktype then
		assert(1 == v.attcktype)
			print("already in 1**************************")					-- if AUTOMATIC ATTACK
			if v.kf_type == KF_TYPE.QUANFA then
				kf = TmpSelf.FightList[TmpSelf.FightIdList[tostring(TmpSelf.Tmp_kf_id)]]
				assert(kf)
				print("kf_g_csv_id ****************************************", kf.g_csv_id)
			elseif v.kf_type == KF_TYPE.COMMON then
				print("commom attack***********************************************")
				kf = kf_common
			else 			
			   	assert(false)
			end 			

			-- if 0 == TmpSelf.IsAffectedNextTime then
			-- 	TmpSelf.TmpFightIdList = {}
			-- 	get_ordered_fight_list_to_client(TmpSelf.FightList, TmpSelf.TmpFightIdList, TmpSelf.TotalFightNum)
			-- else 	
			-- 	TmpSelf.IsAffectedNextTime = 0
			-- end 				
				
			-- if 0 == TmpEnemy.IsAffectedNextTime then
			-- 	TmpEnemy.TmpFightIdList = {}
			-- 	get_ordered_fight_list_to_client(TmpEnemy.FightList, TmpEnemy.TmpFightIdList, TmpEnemy.TotalFightNum)
			-- else 				 
			-- 	TmpEnemy.IsAffectedNextTime = 0 
			-- end 				 
            	
			for k, v in pairs(TmpSelf.TmpFightIdList) do 
				print("TmpSELE.TmpFightIdList is ", k, v) 
				for sk, sv in pairs(v) do 
				   	print(sk, sv) 
				end 			 	
			end    	 			 
                     
			-- local tmp_kf_id = get_kf_id_by_prob(TmpSelf.TmpFightIdList, v.kf_prob) 
			-- print("tmp_kf_id is ****************************************", tmp_kf_id) 
			-- assert(tmp_kf_id)
			-- if not tmp_kf_id then 
			-- 	return false 	 
			-- else  				 	
			--end  
			totalattack = get_attack(kf, TmpSelf, TmpEnemy) 		 				  		
		else 	   				 
			print("already in 2**************************")				  					--if MANUAL ATTACK 							
			if v.kf_type == 1 then 
			 	if TmpSelf.PresentComboNum >= v.random_combo_num then 
			 	 	totalattack = get_attack(kf_common, TmpSelf, TmpEnemy) 
			 	 	print("totalattack is ********************************", totalattack) 
			 	else 			 			
			 	 	return false  
			 	end 
			elseif v.kf_type == 2 then 
			 	totalattack = get_attack(kf_combo, TmpSelf, TmpEnemy) 
			 	TmpSelf.PresentComboNum = TmpSelf.PresentComboNum + 1 
			else 	
			 	assert(false) 
			end  		
				 	 
			TmpEnemy.PresentComboNum = 0 
		end      			
        
		local isdead = 0 
		print("totalattack is ********************************", totalattack, v.attack) 
        		            	
		local left = TmpEnemy.FightPower - totalattack 
		local effect = 0
		local kf_id = 0		
		if left > 0 then 
			TmpEnemy.FightPower = TmpEnemy.FightPower - totalattack 
			print("TmpEnemy.FightPower - totalattack > 0", TmpEnemy.FightPower, totalattack)                 
			effect = get_attacheffect(kf, TmpSelf, TmpEnemy, totalattack)  
        			        	
			if v.attcktype == 1 then 
				if v.kf_type == KF_TYPE.QUANFA then
			   		kf.actual_fight_num = kf.actual_fight_num + 1
			   		TmpSelf.TotalFightNum = TmpSelf.TotalFightNum + 1
			   	end 	
        					    	        	
			   	if 0 == TmpSelf.IsDead and 0 == TmpEnemy.IsDead then 
			   		if 0 == TmpEnemy.IsAffectedNextTime then
						TmpEnemy.TmpFightIdList = {}
						get_ordered_fight_list_to_client(TmpEnemy.FightList, TmpEnemy.TmpFightIdList, TmpEnemy.TotalFightNum)
					else   				 
						TmpEnemy.IsAffectedNextTime = 0 
					end    						
					--get enemy tmpkf_id 		
					local rdm = math.random(100)
					kf_id = get_kf_id_by_prob(TmpEnemy.TmpFightIdList, rdm)
					TmpEnemy.Tmp_kf_id = kf_id  
				end 	   						
			end 	       						
		else    	       						
			TmpEnemy.IsDead = 1 					
		end    		       						
    				       						
		print("Selffightpower is **********************", TmpSelf.FightPower)
		print("Enemyfightpower is *************************", TmpEnemy.FightPower)
		return true, totalattack, effect, kf_id;
	else 	   	    	   						
		return false 	   						
	end 	 	 		   							
end  		 		 	   
						   
--  function REQUEST:GuanQia_OnPrepareNextMonster()
--  assert(self.monsterid) 
--  print("GuanQia_OnPrepareNextMonster*****************")
--  end  	 			   
		     			   
function REQUEST:TMP_GuanQiaBattleList()
	--print("BattleList is called ****************************", #self.fightlist)
	assert(self.fightinfo)
	local ret = {}   	
		                 
	for sk , sv in pairs(self.fightinfo) do
		print("value ",sk, sv)
	end          	       
    						
	local sign , totalattack, effect, kf_id = do_verify(self.fightinfo, user.c_role_id)
	                           
	if not sign then       
		ret.errorcode = errorcode[112].code
		return ret 		   
	else 				    	
		if 1 == Self.IsDead	then
			ret.loser = SELF		
		elseif 1 == Enemy.IsDead then			   	
			ret.loser = ENEMY    
		else
			ret.loser = 0
		end

		-- if 1 == fightinfo.attack_type then
		-- 	ret.kf_id = 
		-- else

		-- end

		ret.totalattack = totalattack
		ret.effect = effect
		ret.kf_id = kf_id
		assert(self.fightinfo.fighttype == 1 and kf_id == 0)
		print("ret.kf_id is ********************************************************", kf_id)
	end 			       				
                           
	ret.errorcode = errorcode[1].code
	return ret 			    
end 	
		
function REQUEST:BeginArenaCoreFight()
	assert(self.uid and self.roleid)
	print("BeginArenaCoreFight is called **********************************", self.uid, self.roleid)

	FIGHT_PLACE = PLACE.ARENA
	
	reset_arena(Self)		
	reset_arena(Enemy)		

    local ret = {}								
    
    --init common and combo special kf 			
    get_kf_common_and_combo()         			
    --init user and enemy on_battlerole_info_list
    if not get_on_battle_list(_, SELF) then 	
    	ret.errorcode = errorcode[110].code 		
    end 				 				  		
    					
    if not get_on_battle_list(self.uid, ENEMY) then
    	ret.errorcode = errorcode[110],code
    end                                
	Self.Uid = user.csv_id
	Enemy.Uid = self.uid    			
	
    --get role fight_list             
	get_fight_list(_, Self.OnBattleList[1] , SELF) 
	get_fight_list(self.uid, Enemy.OnBattleList[1], ENEMY) 
	--init basic attribute             
	init_attribute(_, Self.OnBattleList[1], SELF) 
	init_attribute(self.uid, Enemy.OnBattleList[1], ENEMY) 				
    					
    -- who fight first  
    local TmpSelf  	   	
    if first_fighter() then  
		ret.firstfighter = SELF  
		TmpSelf = Self  
	else               
		ret.firstfighter = ENEMY  
		TmpSelf = Enemy  
	end  
	
	--get first fighter kf_id  
	get_ordered_fight_list_to_client(TmpSelf.FightList, TmpSelf.TmpFightIdList, TmpSelf.TotalFightNum)  
	local rdm = math.random(100)  
	local kf_id = get_kf_id_by_prob(TmpSelf.TmpFightIdList, rdm)  
	assert(kf_id)  					
	print("self kf_id is ************************************", kf_id)  
	TmpSelf.Tmp_kf_id = kf_id  		
    ret.kf_id = kf_id  				
	
	ret.errorcode = errorcode[1].code
	ret.delay_time = START_DELAY	
     							                  				
	return ret 	  	   				
end   								   		  	   			
        
function REQUEST:Arena_OnPrepareNextRole()
	--assert(self.loserid)				
	local ret = {} 	   				
      			                   					
	local TmpSelf = {}  			
	if 1 == Self.IsDead then		
	   	TmpSelf = Self 				
	elseif 1 == Enemy.IsDead then	
	  	TmpSelf = Enemy 
	else
		ret.errorcode = errorcode[110].code
	end  	  	  	   	
      		           
    if TmpSelf.OnBattleSequence < 3 then              
	   	reset(TmpSelf)    
	   	TmpSelf.OnBattleSequence = TmpSelf.OnBattleSequence + 1 
       			  
	   	if TmpSelf == Self then
	   	 	get_fight_list(_, Self.OnBattleList[Self.OnBattleSequence] , SELF)  
	   		init_attribute(_, Self.OnBattleList[Self.OnBattleSequence], SELF) 
	   	else 
	   		get_fight_list(Enemy.Uid, Enemy.OnBattleList[Enemy.OnBattleSequence], ENEMY)
	   		init_attribute(Enemy.Uid, Enemy.OnBattleList[Enemy.OnBattleSequence], ENEMY)
	 	end   						  	
	    	
	 	if firstfighter() then
	 		ret.firstfighter = SELF
	 		TmpSelf = Self
	 	else 
	 		ret.firstfighter = ENEMY
	 		TmpSelf = Enemy
	 	end 
        
    	get_ordered_fight_list_to_client(TmpSelf.FightList, TmpSelf.TmpFightIdList, TmpSelf.TotalFightNum)  
		local rdm = math.random(100)  
		local kf_id = get_kf_id_by_prob(TmpSelf.TmpFightIdList, rdm)  
		assert(kf_id)  					
		print("self kf_id is ************************************", kf_id)  
        
		TmpSelf.Tmp_kf_id = kf_id  		
   	 	ret.kf_id = kf_id  				
	    
		ret.errorcode = errorcode[1].code
		ret.delay_time = START_DELAY
	else                              
		ret.errorcode = errorcode[110].code
	end    	             
     		                    
	return ret 			
end 
	
function REQUEST:ArenaBattleList()
	print("ArenaBattleList is called**********************************", #self.fightlist)
	assert(self.fightinfo)
	local ret = {}    	
    		          
	for sk , sv in pairs(self.fightinfo) do
		print("value ",sk, sv)
	end          	       
    		                        
	local sign , totalattack, effect, kf_id = do_verify(self.fightinfo, user.c_role_id) 
    	                       
	if not sign then        
		ret.errorcode = errorcode[112].code 
		return ret 		   
	else 				    	
		if 1 == Self.IsDead	then 
			ret.loser = SELF 		
		elseif 1 == Enemy.IsDead then  			   	
			ret.loser = ENEMY     
		else 
			ret.loser = 0 
		end 
        
		ret.totalattack = totalattack
		ret.effect = effect
		ret.kf_id = kf_id
	end 

	ret.errorcode = errorcode[1].code
	return ret	
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
	
	-- if not NormalExistTime then
	-- 	assert(false)		   	
	-- 	ret.errorcode[110].code
	-- else 					   	
	-- 	if date - NormalExistTime >= MAX_EXIT_TIME then
	-- 		--TODO Tell client user failed
                                
	-- 		--user.is_in_core_fight = 0
                                
	-- 		ret.errorcode = errorcode[110].code
	-- 		ret.loserid = user.csv_id
	-- 	else                    
	-- 		ret.errorcode = errorcode[1].code  --tell client continue play effect
	-- 	end                    
	-- end 	

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