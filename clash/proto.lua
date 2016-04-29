local sprotoparser = require "sprotoparser"

local proto = {}

proto.c2s = sprotoparser.parse [[
.package {
	type 0 : integer
	session 1 : integer
}

.role {
    csv_id 0 : integer
    is_possessed 1 : boolean
    star 2 : integer
    u_us_prop_num 3 : integer
    property_id1 4 : integer
    value1 5 : integer
    property_id2 6 : integer
    value2 7 : integer
    property_id3 8 : integer
    value3 9 : integer
    property_id4 10 : integer
    value4 11 : integer
    property_id5 12 : integer
    value5 13 : integer
}

.prop {
    csv_id 0 : integer
    num 1 : integer
}

.achi {
    csv_id 0 : integer
    finished 1 : integer
    reward_collected 2 : boolean
    is_unlock 3 : boolean
}

.attach {
    itemsn 0 : integer
    itemnum 1 : integer
}

.mail {	
	emailid 0 : integer
	type 1 : integer
	iconid 2 : integer
	acctime 3 : string
	isread 4 : boolean
	isreward 5 : boolean
	title 6 : string
	content 7 : string
	errorcode 8 : integer
	attachs 9 : *attach
}

.idlist {
    id 0 : integer
}

.friendidlist {
    signtime 0 : integer
    friendid 1 : integer
    type 2 : integer
}

.subuser {
	id 0 : integer
	name 1 : string
	level 2 : integer
	viplevel 3 : integer
	iconid 4 : integer
	sign 5 : string
	fightpower 6  : integer
	uid  7 :string
	online_time 8 : string
	heart 9 : boolean 
	apply 10 : boolean 
	receive 11 : boolean 
	type 12 : integer
    signtime 13 : integer
    heartamount 14 : integer
}

.apply {
	signtime 0 : integer
	friendid 1 : integer
	type 2 : integer
}

.heartlist {   
    signtime 0 : integer
    amount 1 : integer
    friendid 2 : integer
    type 3 : integer    
    csendtime 4 : string 
}   

.goods {
    csv_id 0 : integer
    currency_type 1 : integer
    currency_num 2 : integer
    g_prop_csv_id 3 : integer
    g_prop_num 4 : integer
    inventory 5 : integer
    countdown 6 : integer
}
 
.goodsbuy {
    goods_id 0 : integer
    goods_num 1 : integer
}

.recharge_item {
	csv_id 0 : integer
	icon_id 1 : integer
	name 2 : string
	diamond 3 : integer
	first 4 : integer
	gift 5 : integer
	rmb 6 : integer
}

.recharge_buy {
	csv_id 0 : integer
	num 1 : integer
}

.recharge_reward_item {
	id 0 : integer
	distribute_dt 1 : string
	icon_id 2 : integer
}

.drawlist {  
    drawtype 0 : integer
    lefttime 1 : integer
    drawnum 2 : integer
}
 
.drawrewardlist {
    propid 0 : integer
    propnum 1 : integer
    proptype 2 : integer
}  

.recharge_vip_reward {
    vip 0 : integer
    props 1 : *prop
    collected 2 : boolean
    purchased 3 : boolean
}

.equipment {
    csv_id 0 : integer
    level 1 : integer
    combat 2 : integer
    defense 3 : integer
    critical_hit 4 : integer
    king 5 : integer
    critical_hit_probability 6 : integer
    combat_probability 7 : integer
    defense_probability 8 : integer
    king_probability 9 : integer
    enhance_success_rate 10 : integer
}

.kungfu_content {
    csv_id 1 : integer
    k_level 2 : integer
    k_type 3 : integer
    k_sp_num 4 : integer 
}
 
.kungfu_pos_and_id {
    position 0 : integer
    k_csv_id 1 : integer
}

.kungfu_role_list {
    r_csv_id 0 : integer    
    pos_list 1 : *kungfu_pos_and_id
} 

.user {
    uname 0 : string 
    uviplevel 1 : integer
    config_sound 2 : boolean
    config_music 3 : boolean
    avatar 4 : integer
    sign 5 : string
    c_role_id 6 : integer
    level 7 : integer
    recharge_rmb 8 : integer
    recharge_diamond 9 : integer
    uvip_progress 10 : integer
    cp_hanging_id 11 : integer
    uexp 12 : integer
    gold 13 : integer
    diamond 14 : integer
    love 15 : integer
    equipment_list 16 : *equipment
    kungfu_list 17 : *kungfu_content
    rolelist 18 : *role
    cp_chapter 19 : integer
    lilian_level 20 : integer
}

.checkpoint_chapter {
	chapter 0 : integer
	chapter_type0 1 : integer
	chapter_type1 2 : integer
	chapter_type2 3 : integer		
}

.lilian_idlist {
    id 0 : integer
}       
        
.quanguan_basic_info {
    quanguan_id 0 : integer
    lilian_num 1 : integer
    left_cd_time 2 : integer
    errorcode 3 : integer
    msg 4 : string
    if_trigger_event 5 : integer
    invitation_id 6 : integer
    iflevel_up 7 : integer
    delay_type 8 : integer
    if_event_reward 9 : integer
    if_lilian_reward 10 : integer
    eventid 11 : integer
    reward 12 : *lilian_reward_info
}   
    
.lilian_reward_info {
    propid 1 : integer
    propnum 2 : integer
}   

.quanguan_lilian_num {
    quanguan_id 0 : integer
    num 1 : integer
    reset_num 2 : integer
}   

handshake 1 {
    request {
        secret 0 : string
    }
    response {
    	errorcode 0 : integer
        msg 1 : string
    }
}

role_info 2 {
    request {
        role_id 0 : integer
    }
    response {
        errorcode 0 : integer
        msg 1 : string
        r 2 : role
    }
}

mails 3 {
    response {
        errorcode 0 : integer
	   msg 1 : string 
	   mail_list 2 : *mail	
    }
}

signup 4 {
	request {
		account 0 : string
		password 1 : string
	}
    response {
        errorcode 0 : integer
        msg 1 : string
    }
}

login 5 {
    request {
        account 0 : string
        password 1 : string
    }
    response {
        errorcode 0 : integer
        msg 1 : string
        u 2 : user
    }
}

role_upgrade_star 6 {
    request {
        role_csv_id 0 : integer
    }
	response {
		errorcode 0 :integer
		msg 1 : string
        r 2 : role
	}
}

choose_role 7 {
    request {
        role_id 0 : integer
    }
    response {
        errorcode 0 : integer
        msg 1 : string
    }
}

wake 8 {
    request {
        role_id 0 : integer
    }
    response {
        errorcode 0 :integer
        msg 1 : string
        r 2 : role
    }
}

props 9 {
    response {
        l 0 : *prop
    }
}

use_prop 10 {
    request {
        role_id 0 : integer
        props 1 : *prop
    }
    response {
        errorcode 0 : integer
        msg 1 : string
        r 2 : role
        props 3 : *prop
    }
}

achievement 11 {
    response {
        errorcode 0 : integer
        msg 1 : string  
        achis 2 : *achi
    }
} 	 

mail_read 12 {
	request {
        mail_id 0 : *idlist
    }
    response {
        errorcode 0 : integer
        msg 1 : string
    }
}

mail_delete 13 {
	request { 
		mail_id 0 : *idlist
	}
    response {
        errorcode 0 : integer
        msg 1 : string
    }
}

mail_getreward 14 {
	request { 
		mail_id 0 : *idlist
		type 1 : integer
	}
    response {
        errorcode 0 : integer
        msg 1 : string
    }
} 

friend_list 15 {
	response {
		ok 0 : boolean
		errorcode 1 : integer
		msg 2 : string
		friendlist  3 : *subuser
        today_left_heart 4 : integer
	}
}

applied_list 16 {
	response {
		ok 0 : boolean
		errorcode 1 : integer
		msg 2 : string
		friendlist  3 : *subuser
	}
}

otherfriend_list  17 {
	response {
		ok 0 : boolean
		errorcode 1 : integer
		msg 2 : string
		friendlist  3 : *subuser
	}
}

findfriend 18 {
	request {
		id 0 : integer
	}
	response {
		ok 0 : boolean
		errorcode 1 : integer
		msg 2 : string
		friend 3 : *subuser
	}
}

applyfriend 19 {
	request {
		friendlist 0 : *friendidlist
	}
}
 
recvfriend 20 {
	request {
		friendlist 0 : *friendidlist
	}
}

refusefriend 21 {
	request {
		friendlist 0 : *friendidlist
	}
}

deletefriend 22 {
	request {
        signtime 0 : integer
        friendid 1 : integer
        type 2 : integer
    }
    response {
        errorcode 0 : integer
        msg 1 : string
    }
}	 
	
recvheart 23 {
	 request {
        hl 0 : *heartlist
        totalamount 1 : integer
    }   
    response {
        errorcode 0 : integer
        msg 1 : string
    } 
}		
		
sendheart 24 {
	request {
        hl 0 : *heartlist
	   totalamount 1 : integer
    }   
    response {
       errorcode 0 : integer
       msg 1 : string
    }	
}

user_can_modify_name 25 {
    response {
        errorcode 0 : integer
        msg 1 : string
    }
}

user_modify_name 26 {
    request {
        name 0 : string
    }   
    response {
        errorcode 0 : integer
        msg 1 : string
    }
}

user_upgrade 27 {
    response {
        errorcode 0 : integer
        msg 1 : string
    }
}

user 28 {
    response {
        errorcode 0 : integer
        msg 1 : string
        user 2 : user
    }
}

shop_all 29 {
    response {
        errorcode 0 : integer
        msg 1 : string
        l 2 : *goods
        goods_refresh_count 3 : integer
        store_refresh_count_max 4 : integer
    }
}

shop_purchase 30 {
    request {
        g 0 : *goodsbuy
    }
    response {
        errorcode 0 : integer
        msg 1 : string
        l 2 : *prop
        ll 3 : *goods
        goods_refresh_count 4 : integer
        store_refresh_count_max 5 : integer
    }
}

shop_refresh 31 {
    request {
        goods_id 0 : integer
    }
    response {
        errorcode 0 : integer
        msg 1 : string
        l 2 : *goods
        goods_refresh_count 3 : integer
        store_refresh_count_max 4 : integer
    }
}

raffle 32 {
    request {
        raffle_type 0 : integer
    }
    response {
        errorcode 0 : integer
        msg 1 : string
        l 2 : *prop
    }
}

logout 33 {
    response {
        errorcode 0 : integer
        msg 1 : string
    }
}

recharge_all 34 {
    response {
        errorcode 0 : integer
        msg 1 : string
        l 2 : *recharge_item
    }
}

recharge_purchase 35 {
    request {
        g 0 : *recharge_buy  
    }
    response {
        errorcode 0 : integer
        msg 1 : string
        u 2 : user
    }
}

recharge_collect 36 {
}

recharge_reward 37 {
}

draw 38 { 
    response {
        list 0 : *drawlist
    }
}  

applydraw 39 {
    request {
        drawtype 0 : integer
        iffree 1 : boolean  
    }
    response {
        errorcode 0 : integer
        msg 1 : string
        list 2 : *drawrewardlist
        lefttime 3 : integer
    }
}
 
achievement_reward_collect 40 {
    request {
        csv_id 0 : integer
    }
    response {
        errorcode 0 : integer
        msg 1 : string
        next 2 : achi
    }
}

recharge_vip_reward_all 41 {
    response {
        errorcode 0 : integer
        msg 1 : string
        reward 2 : *recharge_vip_reward
    }
}

recharge_vip_reward_collect 42 {
    request {
        vip 0 : integer
    }
    response {
        errorcode 0 : integer
        msg 1 : string
        vip 2 : integer
        collected 3 : boolean
    }
}

checkin 43 {
    response {
        totalamount 0 : integer
        monthamount 1 : integer
        ifcheckin_t 2 : boolean
        rewardnum 3 : integer
    }
}

checkin_aday 44
{
    response {
        errorcode 0 : integer
        msg 1 : string  
    }
}
 

checkin_reward 45 {
    request {
        totalamount 0 : integer
        rewardnum 1 : integer
    }
    response {
        errorcode 0 : integer
        msg 1 : string      
    }
}

exercise 46 {
    response {
        ifexercise 0 : boolean
        lefttime 1 : integer
        exercise_level 2 : integer
    }
}
 
exercise_once 47 {
    request {
        daily_type 0 : integer
        exercise_type 1 : integer
        exercise_level 2 : integer
    }
    response {
        errorcode 0 : integer
        msg 1 : string
        lefttime 2 : integer
    }
}
 
c_gold 48 {
    response {
        ifc_gold 0 : boolean
        lefttime 1 : integer
        c_gold_level 2 :  integer
    }
}
 
c_gold_once 49 {
    request {
        daily_type 0 : integer
        c_gold_type 1 : integer
        c_gold_level 2 : integer
    }
    response {
        errorcode 0 : integer
        msg 1 : string
        lefttime 2 : integer
    }
}

equipment_enhance 50 {
    request {
        csv_id 0 : integer
    }
    response {
        errorcode 0 : integer
        msg 1 : string
        e 2 : equipment
        is_valid 3 : boolean
        effect 4 : integer
    }
}

equipment_all 51 {
    response {
        errorcode 0 : integer
        msg 1 : string
        l 2 : *equipment
    }
}

role_all 52 {
    response {
        errorcode 0 : integer
        msg 1 : string
        l 2 : *role
        combat 3 : integer
        defense 4 : integer
        critical_hit 5 : integer
        blessing 6 : integer
    }
}

role_recruit 53 {
    request {
        csv_id 0 : integer
    }
    response {
        errorcode 0 : integer
        msg 1 : string
        r 2 : role
    }
}

role_battle 54 {
    request {
        csv_id 0 : integer
    }
    response {
        errorcode 0 : integer
        msg 1 : string
    }
}

kungfu 55 {
	response
	{
		k_list 0 : *kungfu_content
        role_kid_list 1 : *kungfu_role_list
	}
}
 
kungfu_levelup 56 {
	request
	{
		csv_id 0 : integer
		k_level 1 : integer
		k_type 2 : integer
        amount 3 : integer
	}
	response
	{
		errorcode 0 : integer
		msg 1 : string
        amount 2 : integer
	}
}
 
kungfu_chose 57 {
	request
	{
		r_csv_id 0 : integer
		idlist 1 : *kungfu_pos_and_id
	}
    response {
        errorcode 0 : integer
        msg 1 : string
    }
}

user_sign 58 {
	request {	
		sign 0 : string
	}
	response {
		errorcode 0 : integer
		msg 1 : string
	}
}

user_random_name 59 {
	response {
		errorcode 0 : integer
		msg 1 : string
		name 2 : string
	}
}

recharge_vip_reward_purchase 60 {
    request {
        vip 0 : integer
    }
    response {
        errorcode 0 : integer
        msg 1 : string
        l 2 : *prop
    }
}

xilian 61 {
    request {
        role_id 0 : integer
        is_locked1 1 : boolean
        is_locked2 2 : boolean
        is_locked3 3 : boolean
        is_locked4 4 : boolean
        is_locked5 5 : boolean
    }
    response {
        errorcode 0 : integer
        msg 1 : string
        property_id1 2 : integer
        value1 3 : integer
        property_id2 4 : integer
        value2 5 : integer
        property_id3 6 : integer
        value3 7 : integer
        property_id4 8 : integer
        value4 9 : integer
        property_id5 10 : integer
        value5 11 : integer
    }
}

xilian_ok 62 {
    request {
        role_id 0 : integer
        ok 1 : boolean
    }
    response {
        errorcode 0 : integer
        msg 1 : string
    }
}

checkpoint_chapter 63 {
	response {
		errorcode 0 : integer
		msg 1 : string
		l 2 : *checkpoint_chapter
	}
}

checkpoint_hanging 64 {
	response {
		errorcode 0 : integer
		msg 1 : string
        props 2 : *prop
	}
}

checkpoint_battle_exit 65 {
    request {
        chapter 0 : integer
        type 1 : integer
        checkpoint 2 : integer
        csv_id 3 : integer
        result 4 : integer
    }
    response {
        errorcode 0 : integer
        msg 1 : string
        reward 2 : *prop
    }
}

checkpoint_hanging_choose 66 {
    request {
        chapter 0 : integer
        type 1 : integer
        checkpoint 2 : integer
        csv_id 3 : integer
    }  
    response {
        errorcode 0 : integer
        msg 1 : string
        passed 2 : integer
    }
}

checkpoint_battle_enter 67 {
    request {
        chapter 0 : integer
        type 1 : integer
        checkpoint 2 : integer
        csv_id 3 : integer
    }
    response { 
        errorcode 0 : integer
        msg 1 : string
        cd 2 : integer
    }
}

get_lilian_info 68 {
    response {
        errorcode 0 : integer
        msg 1 : string
        level 2 : integer
        phy_power 3 : integer
        invitation_idlist 4 : *lilian_idlist
        basic_info 5 : *quanguan_basic_info
        lilian_exp 6 : integer
        lilian_num_list 7 : *quanguan_lilian_num
        purch_phy_power_num 8 : integer
        phy_power_left_cd_time 9 : integer
        present_phy_power_num 10 : integer
    }    
}       

start_lilian 69 {
    request {
        quanguan_id 0 : integer
        invitation_id 1 : integer
    }
    response {
        errorcode 0: integer
        msg 1 : string
        left_cd_time 2 : integer
    }
}   
    
lilian_get_phy_power 70 {
    response {
        errorcode 0 : integer
        msg 1 : string
        phy_power 2 : integer
        left_cd_time 3 : integer
    }
}

lilian_get_reward_list 71 {
    request {
        quanguan_id 0 : integer
        reward_type 1 : integer
    }
    response {
        iffinished 0 : integer
        if_trigger_event 1 : integer
        left_cd_time 2 : integer
        invitation_id 3 : integer
        lilian_level 4 : integer
        errorcode 5 : integer
        if_lilian_reward 6 : integer
        if_event_reward 7 : integer

        if_lilian_finished 8 : integer
        lilian_exp 9 : integer
        eventid 10 : integer
        reward 11 : *lilian_reward_info
    }
}

checkpoint_exit 72 {
    response {
        errorcode 0 : integer
        msg 1 : string
    }
}

lilian_purch_phy_power 73 {
    response {
        errorcode 0 : integer
        msg 1 : string
        phy_power 2 : integer
        left_cd_time 3 : integer
    }
}

app_resume 74 {
    response {
        errorcode 0 : integer
        msg 1 : string
    }
}

app_backgroud 75 {
    response {
        errorcode 0 : integer
        msg 1 : string
    }
}

lilian_inc 76 {
    request {
        quanguan_id 0 : integer 
        inc_type 1 : integer
    }
    response {
        errorcode 0 : integer
        msg 1 : string
        inc_num 2 : integer
        diamond_num 3 : integer
        iffinished 4 : integer
        if_trigger_event 5 : integer
        left_cd_time 6 : integer
        invitation_id 7 : integer
        lilian_level 8 : integer
        if_lilian_reward 9 : integer
        if_event_reward 10 : integer
        lilian_exp 11 : integer
        eventid 12 : integer
        reward 13 : *lilian_reward_info
    }
}

lilian_reset_quanguan 77 {
    request {
        quanguan_id 0 : integer
    }
    response {
        errorcode 0 : integer
        msg 1 : string
        diamond_num 2 : integer
    }
}

lilian_rewared_list 78 {
    request {
        quanguan_id 0 : integer
        rtype 1 : integer
    }
    response {
        errorcode 0 : integer
        reward 1 : *lilian_reward_info
        invitation_id 2 : integer
        left_cd_time 3 : integer
    }
}


]]

proto.s2c = sprotoparser.parse [[
.package {
	type 0 : integer
	session 1 : integer
}

.achi {
    csv_id 0 : integer
    finished 1 : integer
}

heartbeat 1 {}

mail 2 {
    request {
        from 0 : integer
        to 1 : integer
        head 2 : string
        msg 3 : string   
    }
    response {
        errorcode 0 : integer
        msg 1 : string
    }
}

finish_achi 3 {
    request {
        which 0 : achi
    }
    response {
        errorcode 0 : integer
        msg 1 : string
    }
}

lilian_update 4 {
    response {
        errorcode 0 : integer
        msg 1 : string
    }
}

]]

return proto