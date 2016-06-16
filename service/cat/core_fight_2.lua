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
local kf_common 
local kf_combo  
local PLACE = {GUANQIA = 1, ARENA = 2}
local myctx   	
		  	  	
local Self = {  
		  	FightPower = 0,  --actually means presentfight power
		    MaxComboNum = 0, 
		    PresentComboNum = 0,  
		    TotalFightNum = 0,  
		    IsDead = 0,
		    IsAffectedNextTime = 0, 
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
	
function REQUEST:login(u, ctx)
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
				 	
local function get_fight_list(user, roledid, roletype)			
	assert(user and roledid and roletype)

	local ret = {}															
	local r = {}															
	local TmpSelf 																			

	if roletype == SELF then
		TmpSelf = Self
	else
		TmpSelf = Enemy
	end	

	r = user.u_rolemgr:get_by_csv_id(roleid)
	assert(r)

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
			
local function init_attribute(user, inittype)
	assert(user and inittype)
	--assert(uid and roleid and inittype)
	local TmpSelf 
	local t = {}
	
	if inittype == SELF then
		TmpSelf = Self
	else
		TmpSelf = Enemy
	end 

	t = util.get_total_property(user, _, _)
	assert(t)

	TmpSelf.Attr.combat = t[1] or 0
	TmpSelf.Attr.defence = t[2] or 0
	TmpSelf.Attr.critical_hit = t[3] or 0
	TmpSelf.Attr.king = t[4] or 0
			
	TmpSelf.FightPower = t[1] or 0
		
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

end 		
			
local function reset_arena(t)
	reset(t)  
          	
	t.Uid = 0
	t.OnBattleList = {}
	t.IfArenaInit = 0
	t.OnBattleSequence = 1
end 					  	
						  
local function get_monster_battle_list(guanqiaid)
	assert(guanqiaid)	  
	local r = skynet.call(".game", "lua", "query_g_checkpoint", guanqiaid)
	assert(r)			  

	local index = 1
	while index < FIXED_MONSTER_NUM do
		local monster_csvid = "monster_csvid" .. index
		if 0 ~= r[monster_csvid] then
			table.insert(Enemy.OnBattleList, r[monster_csvid])
		end 

		index = index + 1
	end 
end		
		  	
local function get_on_battle_list(user, type)
	assert(user and type)	

	local TmpSelf 		

	if type == SELF then
		TmpSelf = Self  
	else 			    
		TmpSelf = Enemy 
	end 	

	local idx = 1 
	while idx <= ON_BATTLE_ROLE_NUM do
	  	local ara_role_id = "ara_role_id" .. idx
	  	local value = user[ara_role_id]
	  	if 0 == value then 
	  		return false 
	  	else 										
	  		table.insert(TmpSelf.OnBattleList, value)
	  	end 										
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
  		print("attacheffect is 6 *******************", math.floor(TmpEnemy.FightPower * (kf.addition_prog / 100)) )
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
local KF_TYPE = {QUANFA = 1, COMBO = 2, COMMON = 3}
  							
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
				kf = TmpSelf.FightList[TmpSelf.FightIdList[tostring(v.kf_id)]]
				assert(kf)
				print("kf_g_csv_id ****************************************", kf.g_csv_id)
			elseif v.kf_type == KF_TYPE.COMMON then
				print("commom attack***********************************************")
				kf = kf_common
			else 			
			   	assert(false)
			end 			

			if 0 == TmpSelf.IsAffectedNextTime then
				TmpSelf.TmpFightIdList = {}
				get_ordered_fight_list_to_client(TmpSelf.FightList, TmpSelf.TmpFightIdList, TmpSelf.TotalFightNum)
			else 			
				TmpSelf.IsAffectedNextTime = 0
			end 				
			
			if 0 == TmpEnemy.IsAffectedNextTime then
				TmpEnemy.TmpFightIdList = {}
				get_ordered_fight_list_to_client(TmpEnemy.FightList, TmpEnemy.TmpFightIdList, TmpEnemy.TotalFightNum)
			else 				 
				TmpEnemy.IsAffectedNextTime = 0 
			end 				 
            				
			for k, v in pairs(TmpSelf.TmpFightIdList) do 
				print("TmpSELE.TmpFightIdList is ", k, v) 
				for sk, sv in pairs(v) do 
					print(sk, sv) 
				end 			 	
			end 				 
			
			local tmp_kf_id = get_kf_id_by_prob(TmpSelf.TmpFightIdList, v.kf_prob) 
			print("tmp_kf_id is ****************************************", tmp_kf_id) 
			if not tmp_kf_id then 
				return false 	 
			else  				 	
				if tmp_kf_id == v.kf_id then 
					totalattack = get_attack(kf, TmpSelf, TmpEnemy) 		
				else 			  	
					return false   
				end 			  	
			end 				  		
		else 					 
			print("already in 2**************************")								--if MANUAL ATTACK 							
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
        assert(totalattack == v.attack) 
		if totalattack == v.attack then	
			local left = TmpEnemy.FightPower - totalattack 
			print("left is ****************", left, left > 0 ) 
			if left > 0 then 
				TmpEnemy.FightPower = TmpEnemy.FightPower - totalattack 
				print("TmpEnemy.FightPower - totalattack > 0", TmpEnemy.FightPower, totalattack)                 
				local effect = get_attacheffect(kf, TmpSelf, TmpEnemy, totalattack)
				if effect ~= v.attach_effect then
					assert(effect == v.attach_effect)
					return false
				end
            
				if 1 == TmpSelf.IsDead then                                            
			   	 	isdead = (TmpSelf == Self) and SELF or ENEMY
				elseif 1 == TmpEnemy.IsDead then 
				 	isdead = (TmpEnemy == Enemy) and ENEMY or SELF                                                      
				end 
            
				if v.attcktype == 1 and v.kf_type == KF_TYPE.QUANFA then
					kf.actual_fight_num = kf.actual_fight_num + 1
					TmpSelf.TotalFightNum = TmpSelf.TotalFightNum + 1
				end
			else 
				TmpEnemy.IsDead = 1 
				isdead = (TmpEnemy == Enemy) and ENEMY or SELF		
			end 	

			print("isdead is ", isdead)
			print("v.isdead is ", v.isdead)
			print("Selffightpower is **********************", TmpSelf.FightPower)
			print("Enemyfightpower is *************************", TmpEnemy.FightPower)
			if v.isdead ~= 0 then
				if isdead == v.isdead then
				 	return true					
				else 
				 	return false
				end	 
			else 	 
				return true
			end	     
		else 	 	 
			return false	
		end 	 	 
	else 		 	 
		return false 
	end 		 	 
end 				 
	
function REQUEST:BeginGUQNQIACoreFight(ctx)
	assert(self.monsterid and ctx)
    
	print("BeginGUANQIACoreFight is called *******************************", self.monsterid)

	FIGHT_PLACE = PLACE.GUANQIA
    			
	reset_arena(Self)
	reset_arena(Enemy)
   			
	local ret = {}	
				
	if not kf_common or not kf_combo then							
		get_kf_common_and_combo()
	end 	

	assert(ctx.me.cp_chapter ~= 0)
	get_monster_battle_list(ctx.user.cp_chapter)

	get_monster_fight_list(Enemy.OnBattleList[Enemy.OnBattleSequence])

	init_attribute(ctx.me, SELF)
	get_fight_list(ctx.me, ctx.me.c_role_id, SELF)

	--huo de wan jia zi ji de lin shi quan fa dui lie
	get_ordered_fight_list_to_client(Self.FightList, Self.TmpFightIdList, Self.TotalFightNum)
	local rdm = math.random(100)
	--sheng cheng xian zai de quan fa
	local kf_id = get_kf_id_by_prob(Self.TmpFightIdList, rdm)
	ret.self = SELF
	ret.self_kfid = kf_id

	get_ordered_fight_list_to_client(Enemy.FightList, Enemy.TmpFightIdList, Enemy.TotalFightNum)
	local rdm = math.random(100)
	--sheng cheng xian zai de 
	local kf_id = get_kf_id_by_prob(Enemy.TmpFightIdList, rdm)
	ret.self = Enemy
	ret.self_kfid = kf_id
 				
	ret.errorcode = errorcode[1].code
	ret.delay_time = START_DELAY
    		
	if first_fighter() then
		ret.firstfighter = SELF
	else   	
		ret.firstfighter = ENEMY
	end   	
          	
	return ret
end 	  	
			
function REQUEST:GuanQia_OnPrepareNextMonster(ctx)
	assert(ctx)
	local ret = {} 
			
	if 1 == Self.IsDead then
		ret.errorcode = errorcode[110].code 
	elseif 0 == Enemy.IsDead then
		ret.errorcode = errorcode[110].code
	else 	
		Enemy.IsDead = 0
		reset(Enemy)
		Enemy.OnBattleSequence = Enemy.OnBattleSequence + 1
		get_monster_fight_list(Enemy.OnBattleList[Enemy.OnBattleSequence])
			
		if first_fighter() then 	
			ret.firstfighter = SELF 
		else 						
			ret.firstfighter = ENEMY
		end 						
			   							
		ret.errorcode = errorcode[1].code
		ret.delay_time = START_DELAY
	end  					 
		 	
	return ret
end		 	
		 	
function REQUEST:GuanQiaBattleList(ctx)
	print("BattleList is called ****************************", #self.fightlist)
	assert(self.fightlist)
	local ret = {}   
		                 
	for k , v in ipairs(self.fightlist) do
		for sk , sv in pairs(v) do
		 	print("value ",sk, sv)
		end          
        	
		if not do_verify(v, user.c_role_id) then
		 	ret.errorcode = errorcode[112].code
		 	return ret
		end 
	end  	
		 	
	ret.errorcode = errorcode[1].code
	return ret
end 	 			
		 	
function REQUEST:BeginArenaCoreFight(ctx)
	assert(self.uid and self.roleid and ctx)
	print("BeginArenaCoreFight is called **********************************", self.uid, self.roleid)
		 	
	FIGHT_PLACE = PLACE.ARENA
		 	
	reset_arena(Self)		
	reset_arena(Enemy)		
		 	
    local ret = {}								
    	 											
    --init common and combo special kf 
    if not kf_combo or not kf_combo then			
    	get_kf_common_and_combo()         			
    end 		

    --init user and enemy on_battlerole_info_list
    if not get_on_battle_list(ctx.me, SELF) then   	
    	ret.errorcode = errorcode[110].code 	  	
    end 				 				  		  	
    											  					
    if not get_on_battle_list(ctx.enemy, ENEMY) then
    	ret.errorcode = errorcode[110],code 	  	 
    end                                			  
    											  
    --get role fight_list             			  	
	get_fight_list(ctx.me, Self.OnBattleList[1] , SELF) 
	get_fight_list(ctx.enemy, Enemy.OnBattleList[1], ENEMY) 
	--init basic attribute             			  	
	init_attribute(_, Self.OnBattleList[1], SELF) 
	init_attribute(self.uid, Enemy.OnBattleList[1], ENEMY) 
						 						  
	if first_fighter() then 					  
		ret.firstfighter = SELF 				  
	else 										  
		ret.firstfighter = ENEMY
	end 						
			   							
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
	end 				
	
	TmpSelf.IsDead = 0 
	reset(TmpSelf) 
	TmpSelf.OnBattleSequence = TmpSelf.OnBattleSequence + 1 
	

	ret.errorcode = errorcode[110].code 
	
	return ret
end 	    			
						
function REQUEST:ArenaBattleList()
	print("ArenaBattleList is called**********************************", #self.fightlist)
	assert(self.fightlist)
	local ret = {}   	
		 					
	for k , v in ipairs(self.fightlist) do
		for sk , sv in pairs(v) do
			print("value ",sk, sv)
		end          
                     
		if not do_verify(v, Self.OnBattleList[Self.OnBattleSequence]) then
			ret.errorcode = errorcode[112].code
			return ret
		end
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
