DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_ara_leaderboards` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_ara_leaderboards`(IN in_uid int, IN in_ranking int, IN in_k int)
BEGIN 
insert into ara_leaderboards (`uid`, `ranking`, `k`) values (in_uid, in_ranking, in_k)
on duplicate key update `uid` = in_uid, `ranking` = in_ranking, `k` = in_k;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_achievement` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_achievement`(IN in_csv_id int, IN in_type int, IN in_name varchar(45), IN in_c_num int, IN in_describe varchar(255), IN in_icon_id int, IN in_reward varchar(45), IN in_star int, IN in_unlock_next_csv_id int)
BEGIN 
insert into g_achievement (`csv_id`, `type`, `name`, `c_num`, `describe`, `icon_id`, `reward`, `star`, `unlock_next_csv_id`) values (in_csv_id, in_type, in_name, in_c_num, in_describe, in_icon_id, in_reward, in_star, in_unlock_next_csv_id)
on duplicate key update `csv_id` = in_csv_id, `type` = in_type, `name` = in_name, `c_num` = in_c_num, `describe` = in_describe, `icon_id` = in_icon_id, `reward` = in_reward, `star` = in_star, `unlock_next_csv_id` = in_unlock_next_csv_id;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_ara_pts` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_ara_pts`(IN in_csv_id int, IN in_reward varchar(45))
BEGIN 
insert into g_ara_pts (`csv_id`, `reward`) values (in_csv_id, in_reward)
on duplicate key update `csv_id` = in_csv_id, `reward` = in_reward;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_ara_rnk_rwd` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_ara_rnk_rwd`(IN in_csv_id int, IN in_reward varchar(245), IN in_seri int)
BEGIN 
insert into g_ara_rnk_rwd (`csv_id`, `reward`, `seri`) values (in_csv_id, in_reward, in_seri)
on duplicate key update `csv_id` = in_csv_id, `reward` = in_reward, `seri` = in_seri;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_ara_tms` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_ara_tms`(IN in_csv_id int, IN in_purchase_cost varchar(255), IN in_list_refresh_cost varchar(255), IN in_list_cd_refresh_cost varchar(255))
BEGIN 
insert into g_ara_tms (`csv_id`, `purchase_cost`, `list_refresh_cost`, `list_cd_refresh_cost`) values (in_csv_id, in_purchase_cost, in_list_refresh_cost, in_list_cd_refresh_cost)
on duplicate key update `csv_id` = in_csv_id, `purchase_cost` = in_purchase_cost, `list_refresh_cost` = in_list_refresh_cost, `list_cd_refresh_cost` = in_list_cd_refresh_cost;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_checkin` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_checkin`(IN in_csv_id int, IN in_month int, IN in_count int, IN in_g_prop_csv_id int, IN in_g_prop_num int, IN in_vip int, IN in_vip_g_prop_csv_id int, IN in_vip_g_prop_num int)
BEGIN 
insert into g_checkin (`csv_id`, `month`, `count`, `g_prop_csv_id`, `g_prop_num`, `vip`, `vip_g_prop_csv_id`, `vip_g_prop_num`) values (in_csv_id, in_month, in_count, in_g_prop_csv_id, in_g_prop_num, in_vip, in_vip_g_prop_csv_id, in_vip_g_prop_num)
on duplicate key update `csv_id` = in_csv_id, `month` = in_month, `count` = in_count, `g_prop_csv_id` = in_g_prop_csv_id, `g_prop_num` = in_g_prop_num, `vip` = in_vip, `vip_g_prop_csv_id` = in_vip_g_prop_csv_id, `vip_g_prop_num` = in_vip_g_prop_num;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_checkin_total` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_checkin_total`(IN in_csv_id int, IN in_totalamount int, IN in_prop_id_num varchar(30))
BEGIN 
insert into g_checkin_total (`csv_id`, `totalamount`, `prop_id_num`) values (in_csv_id, in_totalamount, in_prop_id_num)
on duplicate key update `csv_id` = in_csv_id, `totalamount` = in_totalamount, `prop_id_num` = in_prop_id_num;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_checkpoint` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_checkpoint`(IN in_csv_id int, IN in_chapter int, IN in_combat int, IN in_level int, IN in_name varchar(45), IN in_checkpoint int, IN in_type int, IN in_cd int, IN in_gain_gold int, IN in_gain_exp int, IN in_drop int, IN in_reward varchar(255), IN in_monster_csv_id1 int, IN in_monster_csv_id2 int, IN in_monster_csv_id3 int, IN in_drop_cd int)
BEGIN 
insert into g_checkpoint (`csv_id`, `chapter`, `combat`, `level`, `name`, `checkpoint`, `type`, `cd`, `gain_gold`, `gain_exp`, `drop`, `reward`, `monster_csv_id1`, `monster_csv_id2`, `monster_csv_id3`, `drop_cd`) values (in_csv_id, in_chapter, in_combat, in_level, in_name, in_checkpoint, in_type, in_cd, in_gain_gold, in_gain_exp, in_drop, in_reward, in_monster_csv_id1, in_monster_csv_id2, in_monster_csv_id3, in_drop_cd)
on duplicate key update `csv_id` = in_csv_id, `chapter` = in_chapter, `combat` = in_combat, `level` = in_level, `name` = in_name, `checkpoint` = in_checkpoint, `type` = in_type, `cd` = in_cd, `gain_gold` = in_gain_gold, `gain_exp` = in_gain_exp, `drop` = in_drop, `reward` = in_reward, `monster_csv_id1` = in_monster_csv_id1, `monster_csv_id2` = in_monster_csv_id2, `monster_csv_id3` = in_monster_csv_id3, `drop_cd` = in_drop_cd;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_checkpoint_chapter` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_checkpoint_chapter`(IN in_csv_id int, IN in_level int, IN in_name varchar(45), IN in_type0_max int, IN in_type1_max int, IN in_type2_max int)
BEGIN 
insert into g_checkpoint_chapter (`csv_id`, `level`, `name`, `type0_max`, `type1_max`, `type2_max`) values (in_csv_id, in_level, in_name, in_type0_max, in_type1_max, in_type2_max)
on duplicate key update `csv_id` = in_csv_id, `level` = in_level, `name` = in_name, `type0_max` = in_type0_max, `type1_max` = in_type1_max, `type2_max` = in_type2_max;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_config` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_config`(IN in_csv_id int, IN in_user_level_max int, IN in_user_vip_max int, IN in_xilian_begain_level int, IN in_cp_chapter_max int, IN in_purch_phy_power int, IN in_diamond_per_sec int, IN in_ara_clg_tms_rst_tp int, IN in_worship_reward_id int, IN in_worship_reward_num int, IN in_ara_clg_tms_max int, IN in_ara_clg_tms_rst int, IN in_ara_integral_rst int, IN in_ara_clg_tms_pur_tms_rst int, IN in_ara_rfh_dt int)
BEGIN 
insert into g_config (`csv_id`, `user_level_max`, `user_vip_max`, `xilian_begain_level`, `cp_chapter_max`, `purch_phy_power`, `diamond_per_sec`, `ara_clg_tms_rst_tp`, `worship_reward_id`, `worship_reward_num`, `ara_clg_tms_max`, `ara_clg_tms_rst`, `ara_integral_rst`, `ara_clg_tms_pur_tms_rst`, `ara_rfh_dt`) values (in_csv_id, in_user_level_max, in_user_vip_max, in_xilian_begain_level, in_cp_chapter_max, in_purch_phy_power, in_diamond_per_sec, in_ara_clg_tms_rst_tp, in_worship_reward_id, in_worship_reward_num, in_ara_clg_tms_max, in_ara_clg_tms_rst, in_ara_integral_rst, in_ara_clg_tms_pur_tms_rst, in_ara_rfh_dt)
on duplicate key update `csv_id` = in_csv_id, `user_level_max` = in_user_level_max, `user_vip_max` = in_user_vip_max, `xilian_begain_level` = in_xilian_begain_level, `cp_chapter_max` = in_cp_chapter_max, `purch_phy_power` = in_purch_phy_power, `diamond_per_sec` = in_diamond_per_sec, `ara_clg_tms_rst_tp` = in_ara_clg_tms_rst_tp, `worship_reward_id` = in_worship_reward_id, `worship_reward_num` = in_worship_reward_num, `ara_clg_tms_max` = in_ara_clg_tms_max, `ara_clg_tms_rst` = in_ara_clg_tms_rst, `ara_integral_rst` = in_ara_integral_rst, `ara_clg_tms_pur_tms_rst` = in_ara_clg_tms_pur_tms_rst, `ara_rfh_dt` = in_ara_rfh_dt;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_daily_task` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_daily_task`(IN in_id int, IN in_update_time varchar(40), IN in_type int, IN in_task_name varchar(20), IN in_cost_amount int, IN in_iconid int, IN in_basic_reward varchar(40), IN in_levelup_reward varchar(40), IN in_level_up int, IN in_cost_id int)
BEGIN 
insert into g_daily_task (`id`, `update_time`, `type`, `task_name`, `cost_amount`, `iconid`, `basic_reward`, `levelup_reward`, `level_up`, `cost_id`) values (in_id, in_update_time, in_type, in_task_name, in_cost_amount, in_iconid, in_basic_reward, in_levelup_reward, in_level_up, in_cost_id)
on duplicate key update `id` = in_id, `update_time` = in_update_time, `type` = in_type, `task_name` = in_task_name, `cost_amount` = in_cost_amount, `iconid` = in_iconid, `basic_reward` = in_basic_reward, `levelup_reward` = in_levelup_reward, `level_up` = in_level_up, `cost_id` = in_cost_id;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_draw_role` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_draw_role`(IN in_csv_id int, IN in_num int)
BEGIN 
insert into g_draw_role (`csv_id`, `num`) values (in_csv_id, in_num)
on duplicate key update `csv_id` = in_csv_id, `num` = in_num;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_drawcost` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_drawcost`(IN in_csv_id int, IN in_cointype int, IN in_price int, IN in_cdtime int)
BEGIN 
insert into g_drawcost (`csv_id`, `cointype`, `price`, `cdtime`) values (in_csv_id, in_cointype, in_price, in_cdtime)
on duplicate key update `csv_id` = in_csv_id, `cointype` = in_cointype, `price` = in_price, `cdtime` = in_cdtime;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_equipment` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_equipment`(IN in_csv_id int, IN in_level int)
BEGIN 
insert into g_equipment (`csv_id`, `level`) values (in_csv_id, in_level)
on duplicate key update `csv_id` = in_csv_id, `level` = in_level;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_equipment_effect` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_equipment_effect`(IN in_level int, IN in_effect int)
BEGIN 
insert into g_equipment_effect (`level`, `effect`) values (in_level, in_effect)
on duplicate key update `level` = in_level, `effect` = in_effect;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_equipment_enhance` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_equipment_enhance`(IN in_g_csv_id int, IN in_csv_id int, IN in_name varchar(45), IN in_level int, IN in_combat int, IN in_defense int, IN in_critical_hit int, IN in_king int, IN in_combat_probability int, IN in_defense_probability int, IN in_critical_hit_probability int, IN in_king_probability int, IN in_enhance_success_rate int, IN in_currency_type int, IN in_currency_num int)
BEGIN 
insert into g_equipment_enhance (`g_csv_id`, `csv_id`, `name`, `level`, `combat`, `defense`, `critical_hit`, `king`, `combat_probability`, `defense_probability`, `critical_hit_probability`, `king_probability`, `enhance_success_rate`, `currency_type`, `currency_num`) values (in_g_csv_id, in_csv_id, in_name, in_level, in_combat, in_defense, in_critical_hit, in_king, in_combat_probability, in_defense_probability, in_critical_hit_probability, in_king_probability, in_enhance_success_rate, in_currency_type, in_currency_num)
on duplicate key update `g_csv_id` = in_g_csv_id, `csv_id` = in_csv_id, `name` = in_name, `level` = in_level, `combat` = in_combat, `defense` = in_defense, `critical_hit` = in_critical_hit, `king` = in_king, `combat_probability` = in_combat_probability, `defense_probability` = in_defense_probability, `critical_hit_probability` = in_critical_hit_probability, `king_probability` = in_king_probability, `enhance_success_rate` = in_enhance_success_rate, `currency_type` = in_currency_type, `currency_num` = in_currency_num;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_goods` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_goods`(IN in_csv_id int, IN in_currency_type tinyint, IN in_currency_num int, IN in_g_prop_csv_id int, IN in_g_prop_num int, IN in_inventory_init int, IN in_cd int, IN in_icon_id int)
BEGIN 
insert into g_goods (`csv_id`, `currency_type`, `currency_num`, `g_prop_csv_id`, `g_prop_num`, `inventory_init`, `cd`, `icon_id`) values (in_csv_id, in_currency_type, in_currency_num, in_g_prop_csv_id, in_g_prop_num, in_inventory_init, in_cd, in_icon_id)
on duplicate key update `csv_id` = in_csv_id, `currency_type` = in_currency_type, `currency_num` = in_currency_num, `g_prop_csv_id` = in_g_prop_csv_id, `g_prop_num` = in_g_prop_num, `inventory_init` = in_inventory_init, `cd` = in_cd, `icon_id` = in_icon_id;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_goods_refresh_cost` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_goods_refresh_cost`(IN in_csv_id int, IN in_currency_type int, IN in_currency_num int)
BEGIN 
insert into g_goods_refresh_cost (`csv_id`, `currency_type`, `currency_num`) values (in_csv_id, in_currency_type, in_currency_num)
on duplicate key update `csv_id` = in_csv_id, `currency_type` = in_currency_type, `currency_num` = in_currency_num;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_kungfu` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_kungfu`(IN in_g_csv_id int, IN in_name varchar(45), IN in_csv_id int, IN in_level tinyint, IN in_iconid int, IN in_skill_descp varchar(50), IN in_skill_effect int, IN in_type int, IN in_harm_type int, IN in_arise_probability int, IN in_arise_count int, IN in_arise_type int, IN in_arise_param int, IN in_attack_type int, IN in_effect_percent int, IN in_addition_effect_type int, IN in_addition_prog int, IN in_equip_buff_id int, IN in_buff_id int, IN in_prop_csv_id int, IN in_prop_num int, IN in_currency_type int, IN in_currency_num int)
BEGIN 
insert into g_kungfu (`g_csv_id`, `name`, `csv_id`, `level`, `iconid`, `skill_descp`, `skill_effect`, `type`, `harm_type`, `arise_probability`, `arise_count`, `arise_type`, `arise_param`, `attack_type`, `effect_percent`, `addition_effect_type`, `addition_prog`, `equip_buff_id`, `buff_id`, `prop_csv_id`, `prop_num`, `currency_type`, `currency_num`) values (in_g_csv_id, in_name, in_csv_id, in_level, in_iconid, in_skill_descp, in_skill_effect, in_type, in_harm_type, in_arise_probability, in_arise_count, in_arise_type, in_arise_param, in_attack_type, in_effect_percent, in_addition_effect_type, in_addition_prog, in_equip_buff_id, in_buff_id, in_prop_csv_id, in_prop_num, in_currency_type, in_currency_num)
on duplicate key update `g_csv_id` = in_g_csv_id, `name` = in_name, `csv_id` = in_csv_id, `level` = in_level, `iconid` = in_iconid, `skill_descp` = in_skill_descp, `skill_effect` = in_skill_effect, `type` = in_type, `harm_type` = in_harm_type, `arise_probability` = in_arise_probability, `arise_count` = in_arise_count, `arise_type` = in_arise_type, `arise_param` = in_arise_param, `attack_type` = in_attack_type, `effect_percent` = in_effect_percent, `addition_effect_type` = in_addition_effect_type, `addition_prog` = in_addition_prog, `equip_buff_id` = in_equip_buff_id, `buff_id` = in_buff_id, `prop_csv_id` = in_prop_csv_id, `prop_num` = in_prop_num, `currency_type` = in_currency_type, `currency_num` = in_currency_num;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_lilian_event` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_lilian_event`(IN in_csv_id int, IN in_cd_time int, IN in_description varchar(255), IN in_reward varchar(255))
BEGIN 
insert into g_lilian_event (`csv_id`, `cd_time`, `description`, `reward`) values (in_csv_id, in_cd_time, in_description, in_reward)
on duplicate key update `csv_id` = in_csv_id, `cd_time` = in_cd_time, `description` = in_description, `reward` = in_reward;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_lilian_invitation` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_lilian_invitation`(IN in_csv_id int, IN in_name varchar(255), IN in_reward varchar(255))
BEGIN 
insert into g_lilian_invitation (`csv_id`, `name`, `reward`) values (in_csv_id, in_name, in_reward)
on duplicate key update `csv_id` = in_csv_id, `name` = in_name, `reward` = in_reward;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_lilian_level` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_lilian_level`(IN in_csv_id int, IN in_phy_power int, IN in_experience int, IN in_queue int, IN in_dec_lilian_time int, IN in_dec_weikun_time int)
BEGIN 
insert into g_lilian_level (`csv_id`, `phy_power`, `experience`, `queue`, `dec_lilian_time`, `dec_weikun_time`) values (in_csv_id, in_phy_power, in_experience, in_queue, in_dec_lilian_time, in_dec_weikun_time)
on duplicate key update `csv_id` = in_csv_id, `phy_power` = in_phy_power, `experience` = in_experience, `queue` = in_queue, `dec_lilian_time` = in_dec_lilian_time, `dec_weikun_time` = in_dec_weikun_time;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_lilian_phy_power` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_lilian_phy_power`(IN in_csv_id int, IN in_dioment int, IN in_reset_quanguan_dioment int)
BEGIN 
insert into g_lilian_phy_power (`csv_id`, `dioment`, `reset_quanguan_dioment`) values (in_csv_id, in_dioment, in_reset_quanguan_dioment)
on duplicate key update `csv_id` = in_csv_id, `dioment` = in_dioment, `reset_quanguan_dioment` = in_reset_quanguan_dioment;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_lilian_quanguan` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_lilian_quanguan`(IN in_csv_id int, IN in_belong_zone int, IN in_open_level int, IN in_time int, IN in_reward varchar(255), IN in_day_finish_time int, IN in_need_phy_power int, IN in_reward_exp int, IN in_trigger_event_prop int, IN in_trigger_event varchar(255))
BEGIN 
insert into g_lilian_quanguan (`csv_id`, `belong_zone`, `open_level`, `time`, `reward`, `day_finish_time`, `need_phy_power`, `reward_exp`, `trigger_event_prop`, `trigger_event`) values (in_csv_id, in_belong_zone, in_open_level, in_time, in_reward, in_day_finish_time, in_need_phy_power, in_reward_exp, in_trigger_event_prop, in_trigger_event)
on duplicate key update `csv_id` = in_csv_id, `belong_zone` = in_belong_zone, `open_level` = in_open_level, `time` = in_time, `reward` = in_reward, `day_finish_time` = in_day_finish_time, `need_phy_power` = in_need_phy_power, `reward_exp` = in_reward_exp, `trigger_event_prop` = in_trigger_event_prop, `trigger_event` = in_trigger_event;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_mainreward` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_mainreward`(IN in_groupid int, IN in_csv_id int, IN in_probid int)
BEGIN 
insert into g_mainreward (`groupid`, `csv_id`, `probid`) values (in_groupid, in_csv_id, in_probid)
on duplicate key update `groupid` = in_groupid, `csv_id` = in_csv_id, `probid` = in_probid;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_monster` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_monster`(IN in_csv_id int, IN in_name varchar(45), IN in_combat int, IN in_defense int, IN in_critical_hit int, IN in_blessing int, IN in_quanfaid varchar(45))
BEGIN 
insert into g_monster (`csv_id`, `name`, `combat`, `defense`, `critical_hit`, `blessing`, `quanfaid`) values (in_csv_id, in_name, in_combat, in_defense, in_critical_hit, in_blessing, in_quanfaid)
on duplicate key update `csv_id` = in_csv_id, `name` = in_name, `combat` = in_combat, `defense` = in_defense, `critical_hit` = in_critical_hit, `blessing` = in_blessing, `quanfaid` = in_quanfaid;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_prop` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_prop`(IN in_csv_id int, IN in_name varchar(45), IN in_level int, IN in_sub_type int, IN in_pram1 varchar(255), IN in_pram2 varchar(255), IN in_icon_id int, IN in_intro int, IN in_use_type int)
BEGIN 
insert into g_prop (`csv_id`, `name`, `level`, `sub_type`, `pram1`, `pram2`, `icon_id`, `intro`, `use_type`) values (in_csv_id, in_name, in_level, in_sub_type, in_pram1, in_pram2, in_icon_id, in_intro, in_use_type)
on duplicate key update `csv_id` = in_csv_id, `name` = in_name, `level` = in_level, `sub_type` = in_sub_type, `pram1` = in_pram1, `pram2` = in_pram2, `icon_id` = in_icon_id, `intro` = in_intro, `use_type` = in_use_type;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_property_pool` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_property_pool`(IN in_csv_id int, IN in_property_pool_id int, IN in_probability int)
BEGIN 
insert into g_property_pool (`csv_id`, `property_pool_id`, `probability`) values (in_csv_id, in_property_pool_id, in_probability)
on duplicate key update `csv_id` = in_csv_id, `property_pool_id` = in_property_pool_id, `probability` = in_probability;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_property_pool_second` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_property_pool_second`(IN in_csv_id int, IN in_property_pool_id int, IN in_probability int, IN in_property_id int, IN in_value int)
BEGIN 
insert into g_property_pool_second (`csv_id`, `property_pool_id`, `probability`, `property_id`, `value`) values (in_csv_id, in_property_pool_id, in_probability, in_property_id, in_value)
on duplicate key update `csv_id` = in_csv_id, `property_pool_id` = in_property_pool_id, `probability` = in_probability, `property_id` = in_property_id, `value` = in_value;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_recharge` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_recharge`(IN in_csv_id int, IN in_icon_id int, IN in_name varchar(45), IN in_diamond int, IN in_first int, IN in_gift int, IN in_rmb int, IN in_recharge_before varchar(45), IN in_recharge_after varchar(45))
BEGIN 
insert into g_recharge (`csv_id`, `icon_id`, `name`, `diamond`, `first`, `gift`, `rmb`, `recharge_before`, `recharge_after`) values (in_csv_id, in_icon_id, in_name, in_diamond, in_first, in_gift, in_rmb, in_recharge_before, in_recharge_after)
on duplicate key update `csv_id` = in_csv_id, `icon_id` = in_icon_id, `name` = in_name, `diamond` = in_diamond, `first` = in_first, `gift` = in_gift, `rmb` = in_rmb, `recharge_before` = in_recharge_before, `recharge_after` = in_recharge_after;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_recharge_vip_reward` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_recharge_vip_reward`(IN in_vip int, IN in_diamond int, IN in_gain_gold_up_p int, IN in_gain_exp_up_p int, IN in_gold_max_up_p int, IN in_exp_max_up_p int, IN in_equipment_enhance_success_rate_up_p int, IN in_prop_refresh_reduction_p int, IN in_arena_frozen_time_reduction_p int, IN in_purchase_hp_count_max int, IN in_SCHOOL_reset_count_max int, IN in_rewared varchar(255), IN in_store_refresh_count_max int, IN in_purchasable_gift varchar(255), IN in_marked_diamond int, IN in_purchasable_diamond int)
BEGIN 
insert into g_recharge_vip_reward (`vip`, `diamond`, `gain_gold_up_p`, `gain_exp_up_p`, `gold_max_up_p`, `exp_max_up_p`, `equipment_enhance_success_rate_up_p`, `prop_refresh_reduction_p`, `arena_frozen_time_reduction_p`, `purchase_hp_count_max`, `SCHOOL_reset_count_max`, `rewared`, `store_refresh_count_max`, `purchasable_gift`, `marked_diamond`, `purchasable_diamond`) values (in_vip, in_diamond, in_gain_gold_up_p, in_gain_exp_up_p, in_gold_max_up_p, in_exp_max_up_p, in_equipment_enhance_success_rate_up_p, in_prop_refresh_reduction_p, in_arena_frozen_time_reduction_p, in_purchase_hp_count_max, in_SCHOOL_reset_count_max, in_rewared, in_store_refresh_count_max, in_purchasable_gift, in_marked_diamond, in_purchasable_diamond)
on duplicate key update `vip` = in_vip, `diamond` = in_diamond, `gain_gold_up_p` = in_gain_gold_up_p, `gain_exp_up_p` = in_gain_exp_up_p, `gold_max_up_p` = in_gold_max_up_p, `exp_max_up_p` = in_exp_max_up_p, `equipment_enhance_success_rate_up_p` = in_equipment_enhance_success_rate_up_p, `prop_refresh_reduction_p` = in_prop_refresh_reduction_p, `arena_frozen_time_reduction_p` = in_arena_frozen_time_reduction_p, `purchase_hp_count_max` = in_purchase_hp_count_max, `SCHOOL_reset_count_max` = in_SCHOOL_reset_count_max, `rewared` = in_rewared, `store_refresh_count_max` = in_store_refresh_count_max, `purchasable_gift` = in_purchasable_gift, `marked_diamond` = in_marked_diamond, `purchasable_diamond` = in_purchasable_diamond;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_role` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_role`(IN in_csv_id int, IN in_star int, IN in_name varchar(45), IN in_us_prop_csv_id int)
BEGIN 
insert into g_role (`csv_id`, `star`, `name`, `us_prop_csv_id`) values (in_csv_id, in_star, in_name, in_us_prop_csv_id)
on duplicate key update `csv_id` = in_csv_id, `star` = in_star, `name` = in_name, `us_prop_csv_id` = in_us_prop_csv_id;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_role_coppy` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_role_coppy`(IN in_us_prop_csv_id int, IN in_csv_id int, IN in_star int, IN in_name varchar(45))
BEGIN 
insert into g_role_coppy (`us_prop_csv_id`, `csv_id`, `star`, `name`) values (in_us_prop_csv_id, in_csv_id, in_star, in_name)
on duplicate key update `us_prop_csv_id` = in_us_prop_csv_id, `csv_id` = in_csv_id, `star` = in_star, `name` = in_name;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_role_effect` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_role_effect`(IN in_buffer_id int, IN in_property_id1 int, IN in_value1 int, IN in_property_id2 int, IN in_value2 int, IN in_property_id3 int, IN in_value3 int, IN in_property_id4 int, IN in_value4 int, IN in_property_id5 int, IN in_value5 int, IN in_property_id6 int, IN in_value6 int, IN in_property_id7 int, IN in_value7 int, IN in_property_id8 int, IN in_value8 int)
BEGIN 
insert into g_role_effect (`buffer_id`, `property_id1`, `value1`, `property_id2`, `value2`, `property_id3`, `value3`, `property_id4`, `value4`, `property_id5`, `value5`, `property_id6`, `value6`, `property_id7`, `value7`, `property_id8`, `value8`) values (in_buffer_id, in_property_id1, in_value1, in_property_id2, in_value2, in_property_id3, in_value3, in_property_id4, in_value4, in_property_id5, in_value5, in_property_id6, in_value6, in_property_id7, in_value7, in_property_id8, in_value8)
on duplicate key update `buffer_id` = in_buffer_id, `property_id1` = in_property_id1, `value1` = in_value1, `property_id2` = in_property_id2, `value2` = in_value2, `property_id3` = in_property_id3, `value3` = in_value3, `property_id4` = in_property_id4, `value4` = in_value4, `property_id5` = in_property_id5, `value5` = in_value5, `property_id6` = in_property_id6, `value6` = in_value6, `property_id7` = in_property_id7, `value7` = in_value7, `property_id8` = in_property_id8, `value8` = in_value8;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_role_star` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_role_star`(IN in_g_csv_id int, IN in_csv_id int, IN in_name varchar(45), IN in_star int, IN in_us_prop_csv_id int, IN in_us_prop_num int, IN in_sharp int, IN in_skill_csv_id int, IN in_gather_buffer_id int, IN in_battle_buffer_id int)
BEGIN 
insert into g_role_star (`g_csv_id`, `csv_id`, `name`, `star`, `us_prop_csv_id`, `us_prop_num`, `sharp`, `skill_csv_id`, `gather_buffer_id`, `battle_buffer_id`) values (in_g_csv_id, in_csv_id, in_name, in_star, in_us_prop_csv_id, in_us_prop_num, in_sharp, in_skill_csv_id, in_gather_buffer_id, in_battle_buffer_id)
on duplicate key update `g_csv_id` = in_g_csv_id, `csv_id` = in_csv_id, `name` = in_name, `star` = in_star, `us_prop_csv_id` = in_us_prop_csv_id, `us_prop_num` = in_us_prop_num, `sharp` = in_sharp, `skill_csv_id` = in_skill_csv_id, `gather_buffer_id` = in_gather_buffer_id, `battle_buffer_id` = in_battle_buffer_id;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_shop` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_shop`(IN in_csv_id int, IN in_type int, IN in_num int, IN in_group_id int)
BEGIN 
insert into g_shop (`csv_id`, `type`, `num`, `group_id`) values (in_csv_id, in_type, in_num, in_group_id)
on duplicate key update `csv_id` = in_csv_id, `type` = in_type, `num` = in_num, `group_id` = in_group_id;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_subreward` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_subreward`(IN in_csv_id int, IN in_propid int, IN in_propnum int, IN in_proptype int)
BEGIN 
insert into g_subreward (`csv_id`, `propid`, `propnum`, `proptype`) values (in_csv_id, in_propid, in_propnum, in_proptype)
on duplicate key update `csv_id` = in_csv_id, `propid` = in_propid, `propnum` = in_propnum, `proptype` = in_proptype;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_uid` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_uid`(IN in_csv_id int, IN in_entropy int)
BEGIN 
insert into g_uid (`csv_id`, `entropy`) values (in_csv_id, in_entropy)
on duplicate key update `csv_id` = in_csv_id, `entropy` = in_entropy;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_user_level` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_user_level`(IN in_level int, IN in_exp int, IN in_combat int, IN in_defense int, IN in_critical_hit int, IN in_skill int, IN in_gold_max int, IN in_exp_max int)
BEGIN 
insert into g_user_level (`level`, `exp`, `combat`, `defense`, `critical_hit`, `skill`, `gold_max`, `exp_max`) values (in_level, in_exp, in_combat, in_defense, in_critical_hit, in_skill, in_gold_max, in_exp_max)
on duplicate key update `level` = in_level, `exp` = in_exp, `combat` = in_combat, `defense` = in_defense, `critical_hit` = in_critical_hit, `skill` = in_skill, `gold_max` = in_gold_max, `exp_max` = in_exp_max;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_g_xilian_cost` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_g_xilian_cost`(IN in_csv_id int, IN in_cost varchar(255))
BEGIN 
insert into g_xilian_cost (`csv_id`, `cost`) values (in_csv_id, in_cost)
on duplicate key update `csv_id` = in_csv_id, `cost` = in_cost;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_logintimes` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_logintimes`(IN in_uid int, IN in_times int)
BEGIN 
insert into logintimes (`uid`, `times`) values (in_uid, in_times)
on duplicate key update `uid` = in_uid, `times` = in_times;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_public_email` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_public_email`(IN in_csv_id int, IN in_type int, IN in_title varchar(32), IN in_content varchar(32), IN in_acctime int, IN in_deltime int, IN in_isread tinyint, IN in_isdel tinyint, IN in_itemsn1 int, IN in_itemnum1 int, IN in_itemsn2 int, IN in_itemnum2 int, IN in_itemsn3 int, IN in_itemnum3 int, IN in_itemsn4 int, IN in_itemnum4 int, IN in_itemsn5 int, IN in_itemnum5 int, IN in_iconid int, IN in_isreward tinyint)
BEGIN 
insert into public_email (`csv_id`, `type`, `title`, `content`, `acctime`, `deltime`, `isread`, `isdel`, `itemsn1`, `itemnum1`, `itemsn2`, `itemnum2`, `itemsn3`, `itemnum3`, `itemsn4`, `itemnum4`, `itemsn5`, `itemnum5`, `iconid`, `isreward`) values (in_csv_id, in_type, in_title, in_content, in_acctime, in_deltime, in_isread, in_isdel, in_itemsn1, in_itemnum1, in_itemsn2, in_itemnum2, in_itemsn3, in_itemnum3, in_itemsn4, in_itemnum4, in_itemsn5, in_itemnum5, in_iconid, in_isreward)
on duplicate key update `csv_id` = in_csv_id, `type` = in_type, `title` = in_title, `content` = in_content, `acctime` = in_acctime, `deltime` = in_deltime, `isread` = in_isread, `isdel` = in_isdel, `itemsn1` = in_itemsn1, `itemnum1` = in_itemnum1, `itemsn2` = in_itemsn2, `itemnum2` = in_itemnum2, `itemsn3` = in_itemsn3, `itemnum3` = in_itemnum3, `itemsn4` = in_itemsn4, `itemnum4` = in_itemnum4, `itemsn5` = in_itemsn5, `itemnum5` = in_itemnum5, `iconid` = in_iconid, `isreward` = in_isreward;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_randomval` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_randomval`(IN in_id int, IN in_val int, IN in_step int)
BEGIN 
insert into randomval (`id`, `val`, `step`) values (in_id, in_val, in_step)
on duplicate key update `id` = in_id, `val` = in_val, `step` = in_step;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_achievement` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_achievement`(IN in_id bigint, IN in_user_id int, IN in_csv_id int, IN in_finished tinyint, IN in_type int, IN in_c_num int, IN in_unlock_next_csv_id int, IN in_is_unlock tinyint, IN in_is_valid tinyint)
BEGIN 
insert into u_achievement (`id`, `user_id`, `csv_id`, `finished`, `type`, `c_num`, `unlock_next_csv_id`, `is_unlock`, `is_valid`) values (in_id, in_user_id, in_csv_id, in_finished, in_type, in_c_num, in_unlock_next_csv_id, in_is_unlock, in_is_valid)
on duplicate key update `id` = in_id, `user_id` = in_user_id, `csv_id` = in_csv_id, `finished` = in_finished, `type` = in_type, `c_num` = in_c_num, `unlock_next_csv_id` = in_unlock_next_csv_id, `is_unlock` = in_is_unlock, `is_valid` = in_is_valid;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_achievement_rc` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_achievement_rc`(IN in_id bigint, IN in_user_id int, IN in_csv_id int, IN in_finished int, IN in_reward_collected tinyint, IN in_is_unlock tinyint)
BEGIN 
insert into u_achievement_rc (`id`, `user_id`, `csv_id`, `finished`, `reward_collected`, `is_unlock`) values (in_id, in_user_id, in_csv_id, in_finished, in_reward_collected, in_is_unlock)
on duplicate key update `id` = in_id, `user_id` = in_user_id, `csv_id` = in_csv_id, `finished` = in_finished, `reward_collected` = in_reward_collected, `is_unlock` = in_is_unlock;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_ara_bat` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_ara_bat`(IN in_id bigint, IN in_user_id int, IN in_csv_id int, IN in_start_tm int, IN in_end_tm int, IN in_over tinyint, IN in_res tinyint)
BEGIN 
insert into u_ara_bat (`id`, `user_id`, `csv_id`, `start_tm`, `end_tm`, `over`, `res`) values (in_id, in_user_id, in_csv_id, in_start_tm, in_end_tm, in_over, in_res)
on duplicate key update `id` = in_id, `user_id` = in_user_id, `csv_id` = in_csv_id, `start_tm` = in_start_tm, `end_tm` = in_end_tm, `over` = in_over, `res` = in_res;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_ara_pts` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_ara_pts`(IN in_id bigint, IN in_user_id int, IN in_csv_id int, IN in_collected tinyint)
BEGIN 
insert into u_ara_pts (`id`, `user_id`, `csv_id`, `collected`) values (in_id, in_user_id, in_csv_id, in_collected)
on duplicate key update `id` = in_id, `user_id` = in_user_id, `csv_id` = in_csv_id, `collected` = in_collected;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_ara_rnk_rwd` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_ara_rnk_rwd`(IN in_id bigint, IN in_user_id int, IN in_csv_id int, IN in_collected tinyint)
BEGIN 
insert into u_ara_rnk_rwd (`id`, `user_id`, `csv_id`, `collected`) values (in_id, in_user_id, in_csv_id, in_collected)
on duplicate key update `id` = in_id, `user_id` = in_user_id, `csv_id` = in_csv_id, `collected` = in_collected;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_ara_worship` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_ara_worship`(IN in_id bigint, IN in_user_id int, IN in_ouid int, IN in_date int, IN in_worship tinyint)
BEGIN 
insert into u_ara_worship (`id`, `user_id`, `ouid`, `date`, `worship`) values (in_id, in_user_id, in_ouid, in_date, in_worship)
on duplicate key update `id` = in_id, `user_id` = in_user_id, `ouid` = in_ouid, `date` = in_date, `worship` = in_worship;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_ara_worship_rc` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_ara_worship_rc`(IN in_id bigint, IN in_user_id int, IN in_ouid int, IN in_date int, IN in_worship tinyint)
BEGIN 
insert into u_ara_worship_rc (`id`, `user_id`, `ouid`, `date`, `worship`) values (in_id, in_user_id, in_ouid, in_date, in_worship)
on duplicate key update `id` = in_id, `user_id` = in_user_id, `ouid` = in_ouid, `date` = in_date, `worship` = in_worship;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_cgold` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_cgold`(IN in_id bigint, IN in_user_id int, IN in_cgold_time int, IN in_cgold_type int, IN in_time_length int, IN in_if_latest tinyint)
BEGIN 
insert into u_cgold (`id`, `user_id`, `cgold_time`, `cgold_type`, `time_length`, `if_latest`) values (in_id, in_user_id, in_cgold_time, in_cgold_type, in_time_length, in_if_latest)
on duplicate key update `id` = in_id, `user_id` = in_user_id, `cgold_time` = in_cgold_time, `cgold_type` = in_cgold_type, `time_length` = in_time_length, `if_latest` = in_if_latest;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_checkin` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_checkin`(IN in_id bigint, IN in_if_latest int, IN in_user_id int, IN in_u_checkin_time int, IN in_update_time int)
BEGIN 
insert into u_checkin (`id`, `if_latest`, `user_id`, `u_checkin_time`, `update_time`) values (in_id, in_if_latest, in_user_id, in_u_checkin_time, in_update_time)
on duplicate key update `id` = in_id, `if_latest` = in_if_latest, `user_id` = in_user_id, `u_checkin_time` = in_u_checkin_time, `update_time` = in_update_time;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_checkin_month` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_checkin_month`(IN in_id bigint, IN in_checkin_month int, IN in_user_id int)
BEGIN 
insert into u_checkin_month (`id`, `checkin_month`, `user_id`) values (in_id, in_checkin_month, in_user_id)
on duplicate key update `id` = in_id, `checkin_month` = in_checkin_month, `user_id` = in_user_id;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_checkpoint` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_checkpoint`(IN in_id bigint, IN in_user_id int, IN in_chapter int, IN in_chapter_type0 int, IN in_chapter_type1 int, IN in_chapter_type2 int)
BEGIN 
insert into u_checkpoint (`id`, `user_id`, `chapter`, `chapter_type0`, `chapter_type1`, `chapter_type2`) values (in_id, in_user_id, in_chapter, in_chapter_type0, in_chapter_type1, in_chapter_type2)
on duplicate key update `id` = in_id, `user_id` = in_user_id, `chapter` = in_chapter, `chapter_type0` = in_chapter_type0, `chapter_type1` = in_chapter_type1, `chapter_type2` = in_chapter_type2;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_checkpoint_rc` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_checkpoint_rc`(IN in_id bigint, IN in_user_id int, IN in_csv_id int, IN in_passed int, IN in_cd_walk int, IN in_cd_starttime int, IN in_cd_finished tinyint, IN in_hanging_starttime int, IN in_hanging_walk int, IN in_hanging_drop_starttime int, IN in_hanging_drop_walk int)
BEGIN 
insert into u_checkpoint_rc (`id`, `user_id`, `csv_id`, `passed`, `cd_walk`, `cd_starttime`, `cd_finished`, `hanging_starttime`, `hanging_walk`, `hanging_drop_starttime`, `hanging_drop_walk`) values (in_id, in_user_id, in_csv_id, in_passed, in_cd_walk, in_cd_starttime, in_cd_finished, in_hanging_starttime, in_hanging_walk, in_hanging_drop_starttime, in_hanging_drop_walk)
on duplicate key update `id` = in_id, `user_id` = in_user_id, `csv_id` = in_csv_id, `passed` = in_passed, `cd_walk` = in_cd_walk, `cd_starttime` = in_cd_starttime, `cd_finished` = in_cd_finished, `hanging_starttime` = in_hanging_starttime, `hanging_walk` = in_hanging_walk, `hanging_drop_starttime` = in_hanging_drop_starttime, `hanging_drop_walk` = in_hanging_drop_walk;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_equipment` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_equipment`(IN in_id bigint, IN in_user_id int, IN in_csv_id int, IN in_level int, IN in_combat int, IN in_defense int, IN in_critical_hit int, IN in_king int, IN in_critical_hit_probability int, IN in_combat_probability int, IN in_defense_probability int, IN in_king_probability int)
BEGIN 
insert into u_equipment (`id`, `user_id`, `csv_id`, `level`, `combat`, `defense`, `critical_hit`, `king`, `critical_hit_probability`, `combat_probability`, `defense_probability`, `king_probability`) values (in_id, in_user_id, in_csv_id, in_level, in_combat, in_defense, in_critical_hit, in_king, in_critical_hit_probability, in_combat_probability, in_defense_probability, in_king_probability)
on duplicate key update `id` = in_id, `user_id` = in_user_id, `csv_id` = in_csv_id, `level` = in_level, `combat` = in_combat, `defense` = in_defense, `critical_hit` = in_critical_hit, `king` = in_king, `critical_hit_probability` = in_critical_hit_probability, `combat_probability` = in_combat_probability, `defense_probability` = in_defense_probability, `king_probability` = in_king_probability;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_exercise` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_exercise`(IN in_id bigint, IN in_user_id int, IN in_exercise_time int, IN in_exercise_type int, IN in_time_length int, IN in_if_latest tinyint)
BEGIN 
insert into u_exercise (`id`, `user_id`, `exercise_time`, `exercise_type`, `time_length`, `if_latest`) values (in_id, in_user_id, in_exercise_time, in_exercise_type, in_time_length, in_if_latest)
on duplicate key update `id` = in_id, `user_id` = in_user_id, `exercise_time` = in_exercise_time, `exercise_type` = in_exercise_type, `time_length` = in_time_length, `if_latest` = in_if_latest;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_friend` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_friend`(IN in_id int, IN in_uid int, IN in_friendid int, IN in_isdel tinyint, IN in_recvtime bigint, IN in_heartamount int, IN in_sendtime int)
BEGIN 
insert into u_friend (`id`, `uid`, `friendid`, `isdel`, `recvtime`, `heartamount`, `sendtime`) values (in_id, in_uid, in_friendid, in_isdel, in_recvtime, in_heartamount, in_sendtime)
on duplicate key update `id` = in_id, `uid` = in_uid, `friendid` = in_friendid, `isdel` = in_isdel, `recvtime` = in_recvtime, `heartamount` = in_heartamount, `sendtime` = in_sendtime;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_friendmsg` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_friendmsg`(IN in_id int, IN in_fromid int, IN in_toid int, IN in_type int, IN in_amount int, IN in_propid int, IN in_isread tinyint, IN in_csendtime int, IN in_srecvtime int, IN in_signtime int)
BEGIN 
insert into u_friendmsg (`id`, `fromid`, `toid`, `type`, `amount`, `propid`, `isread`, `csendtime`, `srecvtime`, `signtime`) values (in_id, in_fromid, in_toid, in_type, in_amount, in_propid, in_isread, in_csendtime, in_srecvtime, in_signtime)
on duplicate key update `id` = in_id, `fromid` = in_fromid, `toid` = in_toid, `type` = in_type, `amount` = in_amount, `propid` = in_propid, `isread` = in_isread, `csendtime` = in_csendtime, `srecvtime` = in_srecvtime, `signtime` = in_signtime;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_goods` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_goods`(IN in_id bigint, IN in_user_id int, IN in_csv_id int, IN in_inventory int, IN in_countdown int, IN in_st int)
BEGIN 
insert into u_goods (`id`, `user_id`, `csv_id`, `inventory`, `countdown`, `st`) values (in_id, in_user_id, in_csv_id, in_inventory, in_countdown, in_st)
on duplicate key update `id` = in_id, `user_id` = in_user_id, `csv_id` = in_csv_id, `inventory` = in_inventory, `countdown` = in_countdown, `st` = in_st;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_journal` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_journal`(IN in_id bigint, IN in_user_id int, IN in_date int, IN in_goods_refresh_count int, IN in_goods_refresh_reset_count int, IN in_ara_rfh_tms int, IN in_ara_bat_ser int)
BEGIN 
insert into u_journal (`id`, `user_id`, `date`, `goods_refresh_count`, `goods_refresh_reset_count`, `ara_rfh_tms`, `ara_bat_ser`) values (in_id, in_user_id, in_date, in_goods_refresh_count, in_goods_refresh_reset_count, in_ara_rfh_tms, in_ara_bat_ser)
on duplicate key update `id` = in_id, `user_id` = in_user_id, `date` = in_date, `goods_refresh_count` = in_goods_refresh_count, `goods_refresh_reset_count` = in_goods_refresh_reset_count, `ara_rfh_tms` = in_ara_rfh_tms, `ara_bat_ser` = in_ara_bat_ser;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_kungfu` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_kungfu`(IN in_id bigint, IN in_user_id int, IN in_csv_id int, IN in_level int, IN in_type int, IN in_sp_id int, IN in_g_csv_id int)
BEGIN 
insert into u_kungfu (`id`, `user_id`, `csv_id`, `level`, `type`, `sp_id`, `g_csv_id`) values (in_id, in_user_id, in_csv_id, in_level, in_type, in_sp_id, in_g_csv_id)
on duplicate key update `id` = in_id, `user_id` = in_user_id, `csv_id` = in_csv_id, `level` = in_level, `type` = in_type, `sp_id` = in_sp_id, `g_csv_id` = in_g_csv_id;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_lilian_main` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_lilian_main`(IN in_id int, IN in_csv_id int, IN in_user_id int, IN in_quanguan_id int, IN in_start_time int, IN in_end_time int, IN in_if_trigger_event int, IN in_iffinished int, IN in_invitation_id int, IN in_iflevel_up int, IN in_event_start_time int, IN in_event_end_time int, IN in_if_lilian_finished int, IN in_eventid int, IN in_if_canceled int, IN in_if_event_canceled int, IN in_if_lilian_reward int, IN in_if_event_reward int, IN in_event_reward varchar(256), IN in_lilian_reward varchar(256))
BEGIN 
insert into u_lilian_main (`id`, `csv_id`, `user_id`, `quanguan_id`, `start_time`, `end_time`, `if_trigger_event`, `iffinished`, `invitation_id`, `iflevel_up`, `event_start_time`, `event_end_time`, `if_lilian_finished`, `eventid`, `if_canceled`, `if_event_canceled`, `if_lilian_reward`, `if_event_reward`, `event_reward`, `lilian_reward`) values (in_id, in_csv_id, in_user_id, in_quanguan_id, in_start_time, in_end_time, in_if_trigger_event, in_iffinished, in_invitation_id, in_iflevel_up, in_event_start_time, in_event_end_time, in_if_lilian_finished, in_eventid, in_if_canceled, in_if_event_canceled, in_if_lilian_reward, in_if_event_reward, in_event_reward, in_lilian_reward)
on duplicate key update `id` = in_id, `csv_id` = in_csv_id, `user_id` = in_user_id, `quanguan_id` = in_quanguan_id, `start_time` = in_start_time, `end_time` = in_end_time, `if_trigger_event` = in_if_trigger_event, `iffinished` = in_iffinished, `invitation_id` = in_invitation_id, `iflevel_up` = in_iflevel_up, `event_start_time` = in_event_start_time, `event_end_time` = in_event_end_time, `if_lilian_finished` = in_if_lilian_finished, `eventid` = in_eventid, `if_canceled` = in_if_canceled, `if_event_canceled` = in_if_event_canceled, `if_lilian_reward` = in_if_lilian_reward, `if_event_reward` = in_if_event_reward, `event_reward` = in_event_reward, `lilian_reward` = in_lilian_reward;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_lilian_phy_power` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_lilian_phy_power`(IN in_id bigint, IN in_user_id int, IN in_csv_id int, IN in_start_time int, IN in_end_time int, IN in_purch_time int, IN in_num int)
BEGIN 
insert into u_lilian_phy_power (`id`, `user_id`, `csv_id`, `start_time`, `end_time`, `purch_time`, `num`) values (in_id, in_user_id, in_csv_id, in_start_time, in_end_time, in_purch_time, in_num)
on duplicate key update `id` = in_id, `user_id` = in_user_id, `csv_id` = in_csv_id, `start_time` = in_start_time, `end_time` = in_end_time, `purch_time` = in_purch_time, `num` = in_num;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_lilian_qg_num` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_lilian_qg_num`(IN in_id int, IN in_csv_id int, IN in_user_id int, IN in_start_time int, IN in_end_time int, IN in_num int, IN in_quanguan_id int, IN in_reset_num int)
BEGIN 
insert into u_lilian_qg_num (`id`, `csv_id`, `user_id`, `start_time`, `end_time`, `num`, `quanguan_id`, `reset_num`) values (in_id, in_csv_id, in_user_id, in_start_time, in_end_time, in_num, in_quanguan_id, in_reset_num)
on duplicate key update `id` = in_id, `csv_id` = in_csv_id, `user_id` = in_user_id, `start_time` = in_start_time, `end_time` = in_end_time, `num` = in_num, `quanguan_id` = in_quanguan_id, `reset_num` = in_reset_num;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_lilian_sub` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_lilian_sub`(IN in_id int, IN in_csv_id int, IN in_first_lilian_time int, IN in_start_time int, IN in_update_time int, IN in_used_queue_num int, IN in_end_lilian_time int)
BEGIN 
insert into u_lilian_sub (`id`, `csv_id`, `first_lilian_time`, `start_time`, `update_time`, `used_queue_num`, `end_lilian_time`) values (in_id, in_csv_id, in_first_lilian_time, in_start_time, in_update_time, in_used_queue_num, in_end_lilian_time)
on duplicate key update `id` = in_id, `csv_id` = in_csv_id, `first_lilian_time` = in_first_lilian_time, `start_time` = in_start_time, `update_time` = in_update_time, `used_queue_num` = in_used_queue_num, `end_lilian_time` = in_end_lilian_time;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_new_draw` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_new_draw`(IN in_id int, IN in_uid int, IN in_drawtype int, IN in_srecvtime int, IN in_propid int, IN in_amount int, IN in_iffree tinyint, IN in_updatetime int, IN in_is_latest tinyint)
BEGIN 
insert into u_new_draw (`id`, `uid`, `drawtype`, `srecvtime`, `propid`, `amount`, `iffree`, `updatetime`, `is_latest`) values (in_id, in_uid, in_drawtype, in_srecvtime, in_propid, in_amount, in_iffree, in_updatetime, in_is_latest)
on duplicate key update `id` = in_id, `uid` = in_uid, `drawtype` = in_drawtype, `srecvtime` = in_srecvtime, `propid` = in_propid, `amount` = in_amount, `iffree` = in_iffree, `updatetime` = in_updatetime, `is_latest` = in_is_latest;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_new_email` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_new_email`(IN in_id bigint, IN in_csv_id int, IN in_uid int, IN in_type int, IN in_title varchar(32), IN in_content varchar(32), IN in_acctime int, IN in_deltime int, IN in_isread tinyint, IN in_isdel tinyint, IN in_itemsn1 int, IN in_itemnum1 int, IN in_itemsn2 int, IN in_itemnum2 int, IN in_itemsn3 int, IN in_itemnum3 int, IN in_itemsn4 int, IN in_itemnum4 int, IN in_itemsn5 int, IN in_itemnum5 int, IN in_isreward tinyint)
BEGIN 
insert into u_new_email (`id`, `csv_id`, `uid`, `type`, `title`, `content`, `acctime`, `deltime`, `isread`, `isdel`, `itemsn1`, `itemnum1`, `itemsn2`, `itemnum2`, `itemsn3`, `itemnum3`, `itemsn4`, `itemnum4`, `itemsn5`, `itemnum5`, `isreward`) values (in_id, in_csv_id, in_uid, in_type, in_title, in_content, in_acctime, in_deltime, in_isread, in_isdel, in_itemsn1, in_itemnum1, in_itemsn2, in_itemnum2, in_itemsn3, in_itemnum3, in_itemsn4, in_itemnum4, in_itemsn5, in_itemnum5, in_isreward)
on duplicate key update `id` = in_id, `csv_id` = in_csv_id, `uid` = in_uid, `type` = in_type, `title` = in_title, `content` = in_content, `acctime` = in_acctime, `deltime` = in_deltime, `isread` = in_isread, `isdel` = in_isdel, `itemsn1` = in_itemsn1, `itemnum1` = in_itemnum1, `itemsn2` = in_itemsn2, `itemnum2` = in_itemnum2, `itemsn3` = in_itemsn3, `itemnum3` = in_itemnum3, `itemsn4` = in_itemsn4, `itemnum4` = in_itemnum4, `itemsn5` = in_itemsn5, `itemnum5` = in_itemnum5, `isreward` = in_isreward;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_new_friend` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_new_friend`(IN in_id bigint, IN in_self_csv_id int, IN in_friend_csv_id int, IN in_isdelete tinyint, IN in_recvtime int, IN in_heartamount int, IN in_update_time int, IN in_ifrecved tinyint, IN in_ifsent tinyint)
BEGIN 
insert into u_new_friend (`id`, `self_csv_id`, `friend_csv_id`, `isdelete`, `recvtime`, `heartamount`, `update_time`, `ifrecved`, `ifsent`) values (in_id, in_self_csv_id, in_friend_csv_id, in_isdelete, in_recvtime, in_heartamount, in_update_time, in_ifrecved, in_ifsent)
on duplicate key update `id` = in_id, `self_csv_id` = in_self_csv_id, `friend_csv_id` = in_friend_csv_id, `isdelete` = in_isdelete, `recvtime` = in_recvtime, `heartamount` = in_heartamount, `update_time` = in_update_time, `ifrecved` = in_ifrecved, `ifsent` = in_ifsent;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_new_friendmsg` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_new_friendmsg`(IN in_id bigint, IN in_fromid int, IN in_toid int, IN in_type int, IN in_amount int, IN in_isread tinyint, IN in_srecvtime int, IN in_updatetime int)
BEGIN 
insert into u_new_friendmsg (`id`, `fromid`, `toid`, `type`, `amount`, `isread`, `srecvtime`, `updatetime`) values (in_id, in_fromid, in_toid, in_type, in_amount, in_isread, in_srecvtime, in_updatetime)
on duplicate key update `id` = in_id, `fromid` = in_fromid, `toid` = in_toid, `type` = in_type, `amount` = in_amount, `isread` = in_isread, `srecvtime` = in_srecvtime, `updatetime` = in_updatetime;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_prop` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_prop`(IN in_id bigint, IN in_user_id int, IN in_csv_id int, IN in_num int, IN in_sub_type int, IN in_level int, IN in_pram1 varchar(255), IN in_pram2 varchar(255), IN in_name varchar(45), IN in_use_type int)
BEGIN 
insert into u_prop (`id`, `user_id`, `csv_id`, `num`, `sub_type`, `level`, `pram1`, `pram2`, `name`, `use_type`) values (in_id, in_user_id, in_csv_id, in_num, in_sub_type, in_level, in_pram1, in_pram2, in_name, in_use_type)
on duplicate key update `id` = in_id, `user_id` = in_user_id, `csv_id` = in_csv_id, `num` = in_num, `sub_type` = in_sub_type, `level` = in_level, `pram1` = in_pram1, `pram2` = in_pram2, `name` = in_name, `use_type` = in_use_type;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_purchase_goods` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_purchase_goods`(IN in_id bigint, IN in_user_id int, IN in_csv_id int, IN in_num int, IN in_currency_type int, IN in_currency_num int, IN in_purchase_time int)
BEGIN 
insert into u_purchase_goods (`id`, `user_id`, `csv_id`, `num`, `currency_type`, `currency_num`, `purchase_time`) values (in_id, in_user_id, in_csv_id, in_num, in_currency_type, in_currency_num, in_purchase_time)
on duplicate key update `id` = in_id, `user_id` = in_user_id, `csv_id` = in_csv_id, `num` = in_num, `currency_type` = in_currency_type, `currency_num` = in_currency_num, `purchase_time` = in_purchase_time;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_purchase_reward` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_purchase_reward`(IN in_id bigint, IN in_user_id int, IN in_csv_id int, IN in_g_goods_csv_id int, IN in_g_goods_num int, IN in_c_type tinyint, IN in_c_recharge_vip int, IN in_c_vip int, IN in_collected tinyint, IN in_prop_id int, IN in_u_purchase_rewardcol varchar(45), IN in_distribute_time int)
BEGIN 
insert into u_purchase_reward (`id`, `user_id`, `csv_id`, `g_goods_csv_id`, `g_goods_num`, `c_type`, `c_recharge_vip`, `c_vip`, `collected`, `prop_id`, `u_purchase_rewardcol`, `distribute_time`) values (in_id, in_user_id, in_csv_id, in_g_goods_csv_id, in_g_goods_num, in_c_type, in_c_recharge_vip, in_c_vip, in_collected, in_prop_id, in_u_purchase_rewardcol, in_distribute_time)
on duplicate key update `id` = in_id, `user_id` = in_user_id, `csv_id` = in_csv_id, `g_goods_csv_id` = in_g_goods_csv_id, `g_goods_num` = in_g_goods_num, `c_type` = in_c_type, `c_recharge_vip` = in_c_recharge_vip, `c_vip` = in_c_vip, `collected` = in_collected, `prop_id` = in_prop_id, `u_purchase_rewardcol` = in_u_purchase_rewardcol, `distribute_time` = in_distribute_time;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_recharge_count` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_recharge_count`(IN in_id bigint, IN in_user_id int, IN in_csv_id int, IN in_count int)
BEGIN 
insert into u_recharge_count (`id`, `user_id`, `csv_id`, `count`) values (in_id, in_user_id, in_csv_id, in_count)
on duplicate key update `id` = in_id, `user_id` = in_user_id, `csv_id` = in_csv_id, `count` = in_count;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_recharge_record` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_recharge_record`(IN in_id bigint, IN in_user_id int, IN in_csv_id int, IN in_num int, IN in_dt bigint)
BEGIN 
insert into u_recharge_record (`id`, `user_id`, `csv_id`, `num`, `dt`) values (in_id, in_user_id, in_csv_id, in_num, in_dt)
on duplicate key update `id` = in_id, `user_id` = in_user_id, `csv_id` = in_csv_id, `num` = in_num, `dt` = in_dt;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_recharge_vip_reward` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_recharge_vip_reward`(IN in_id bigint, IN in_user_id int, IN in_vip int, IN in_collected tinyint, IN in_purchased tinyint)
BEGIN 
insert into u_recharge_vip_reward (`id`, `user_id`, `vip`, `collected`, `purchased`) values (in_id, in_user_id, in_vip, in_collected, in_purchased)
on duplicate key update `id` = in_id, `user_id` = in_user_id, `vip` = in_vip, `collected` = in_collected, `purchased` = in_purchased;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_u_role` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_u_role`(IN in_id bigint, IN in_user_id int, IN in_csv_id int, IN in_name varchar(45), IN in_star int, IN in_us_prop_csv_id int, IN in_us_prop_num int, IN in_sharp int, IN in_skill_csv_id int, IN in_gather_buffer_id int, IN in_battle_buffer_id int, IN in_k_csv_id1 int, IN in_k_csv_id2 int, IN in_k_csv_id3 int, IN in_k_csv_id4 int, IN in_k_csv_id5 int, IN in_k_csv_id6 int, IN in_k_csv_id7 int, IN in_property_id1 int, IN in_value1 int, IN in_property_id2 int, IN in_value2 int, IN in_property_id3 int, IN in_value3 int, IN in_property_id4 int, IN in_value4 int, IN in_property_id5 int, IN in_value5 int)
BEGIN 
insert into u_role (`id`, `user_id`, `csv_id`, `name`, `star`, `us_prop_csv_id`, `us_prop_num`, `sharp`, `skill_csv_id`, `gather_buffer_id`, `battle_buffer_id`, `k_csv_id1`, `k_csv_id2`, `k_csv_id3`, `k_csv_id4`, `k_csv_id5`, `k_csv_id6`, `k_csv_id7`, `property_id1`, `value1`, `property_id2`, `value2`, `property_id3`, `value3`, `property_id4`, `value4`, `property_id5`, `value5`) values (in_id, in_user_id, in_csv_id, in_name, in_star, in_us_prop_csv_id, in_us_prop_num, in_sharp, in_skill_csv_id, in_gather_buffer_id, in_battle_buffer_id, in_k_csv_id1, in_k_csv_id2, in_k_csv_id3, in_k_csv_id4, in_k_csv_id5, in_k_csv_id6, in_k_csv_id7, in_property_id1, in_value1, in_property_id2, in_value2, in_property_id3, in_value3, in_property_id4, in_value4, in_property_id5, in_value5)
on duplicate key update `id` = in_id, `user_id` = in_user_id, `csv_id` = in_csv_id, `name` = in_name, `star` = in_star, `us_prop_csv_id` = in_us_prop_csv_id, `us_prop_num` = in_us_prop_num, `sharp` = in_sharp, `skill_csv_id` = in_skill_csv_id, `gather_buffer_id` = in_gather_buffer_id, `battle_buffer_id` = in_battle_buffer_id, `k_csv_id1` = in_k_csv_id1, `k_csv_id2` = in_k_csv_id2, `k_csv_id3` = in_k_csv_id3, `k_csv_id4` = in_k_csv_id4, `k_csv_id5` = in_k_csv_id5, `k_csv_id6` = in_k_csv_id6, `k_csv_id7` = in_k_csv_id7, `property_id1` = in_property_id1, `value1` = in_value1, `property_id2` = in_property_id2, `value2` = in_value2, `property_id3` = in_property_id3, `value3` = in_value3, `property_id4` = in_property_id4, `value4` = in_value4, `property_id5` = in_property_id5, `value5` = in_value5;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_users` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_users`(IN in_csv_id int, IN in_uname varchar(32), IN in_uviplevel int, IN in_config_sound tinyint, IN in_config_music tinyint, IN in_avatar int, IN in_sign varchar(255), IN in_c_role_id int, IN in_ifonline tinyint, IN in_level int, IN in_combat int, IN in_defense int, IN in_critical_hit int, IN in_blessing int, IN in_permission tinyint, IN in_modify_uname_count tinyint, IN in_onlinetime int, IN in_iconid int, IN in_is_valid tinyint, IN in_recharge_rmb int, IN in_recharge_diamond int, IN in_uvip_progress int, IN in_checkin_num int, IN in_checkin_reward_num int, IN in_exercise_level int, IN in_cgold_level int, IN in_gold_max int, IN in_exp_max int, IN in_equipment_enhance_success_rate_up_p int, IN in_store_refresh_count_max int, IN in_prop_refresh int, IN in_arena_frozen_time int, IN in_purchase_hp_count int, IN in_gain_gold_up_p int, IN in_gain_exp_up_p int, IN in_purchase_hp_count_max int, IN in_SCHOOL_reset_count_max int, IN in_SCHOOL_reset_count int, IN in_signup_time int, IN in_pemail_csv_id int, IN in_take_diamonds int, IN in_draw_number int, IN in_ifxilian int, IN in_cp_chapter int, IN in_cp_type int, IN in_cp_checkpoint int, IN in_cp_id int, IN in_cp_drop_id1 int, IN in_cp_drop_id2 int, IN in_cp_drop_id3 int, IN in_cp_fighting tinyint, IN in_lilian_level int, IN in_lilian_exp int, IN in_lilian_phy_power int, IN in_purch_lilian_phy_power int, IN in_ara_role_id1 int, IN in_ara_role_id2 int, IN in_ara_role_id3 int, IN in_ara_win_tms int, IN in_ara_lose_tms int, IN in_ara_tie_tms int, IN in_ara_clg_tms int, IN in_ara_clg_cost_tms int, IN in_ara_integral int, IN in_ara_fighting tinyint, IN in_ara_interface tinyint, IN in_ara_rfh_cost_tms int, IN in_ara_r1_sum_combat int, IN in_ara_r1_sum_defense int, IN in_ara_r1_sum_critical_hit int, IN in_ara_r1_sum_king int, IN in_ara_rfh_st int, IN in_ara_rfh_cd int, IN in_ara_rfh_cd_cost_tms int, IN in_ara_clg_tms_rsttm int, IN in_ara_clg_cost_rsttm int, IN in_ara_integral_rsttm int, IN in_draw_num int, IN in_ara_r2_sum_combat int, IN in_ara_r2_sum_defense int, IN in_ara_r2_sum_critical_hit int, IN in_ara_r2_sum_king int, IN in_ara_r3_sum_combat int, IN in_ara_r3_sum_defense int, IN in_ara_r3_sum_critical_hit int, IN in_ara_r3_sum_king int, IN in_daily_recv_heart int, IN in_friend_update_time int)
BEGIN 
insert into users (`csv_id`, `uname`, `uviplevel`, `config_sound`, `config_music`, `avatar`, `sign`, `c_role_id`, `ifonline`, `level`, `combat`, `defense`, `critical_hit`, `blessing`, `permission`, `modify_uname_count`, `onlinetime`, `iconid`, `is_valid`, `recharge_rmb`, `recharge_diamond`, `uvip_progress`, `checkin_num`, `checkin_reward_num`, `exercise_level`, `cgold_level`, `gold_max`, `exp_max`, `equipment_enhance_success_rate_up_p`, `store_refresh_count_max`, `prop_refresh`, `arena_frozen_time`, `purchase_hp_count`, `gain_gold_up_p`, `gain_exp_up_p`, `purchase_hp_count_max`, `SCHOOL_reset_count_max`, `SCHOOL_reset_count`, `signup_time`, `pemail_csv_id`, `take_diamonds`, `draw_number`, `ifxilian`, `cp_chapter`, `cp_type`, `cp_checkpoint`, `cp_id`, `cp_drop_id1`, `cp_drop_id2`, `cp_drop_id3`, `cp_fighting`, `lilian_level`, `lilian_exp`, `lilian_phy_power`, `purch_lilian_phy_power`, `ara_role_id1`, `ara_role_id2`, `ara_role_id3`, `ara_win_tms`, `ara_lose_tms`, `ara_tie_tms`, `ara_clg_tms`, `ara_clg_cost_tms`, `ara_integral`, `ara_fighting`, `ara_interface`, `ara_rfh_cost_tms`, `ara_r1_sum_combat`, `ara_r1_sum_defense`, `ara_r1_sum_critical_hit`, `ara_r1_sum_king`, `ara_rfh_st`, `ara_rfh_cd`, `ara_rfh_cd_cost_tms`, `ara_clg_tms_rsttm`, `ara_clg_cost_rsttm`, `ara_integral_rsttm`, `draw_num`, `ara_r2_sum_combat`, `ara_r2_sum_defense`, `ara_r2_sum_critical_hit`, `ara_r2_sum_king`, `ara_r3_sum_combat`, `ara_r3_sum_defense`, `ara_r3_sum_critical_hit`, `ara_r3_sum_king`, `daily_recv_heart`, `friend_update_time`) values (in_csv_id, in_uname, in_uviplevel, in_config_sound, in_config_music, in_avatar, in_sign, in_c_role_id, in_ifonline, in_level, in_combat, in_defense, in_critical_hit, in_blessing, in_permission, in_modify_uname_count, in_onlinetime, in_iconid, in_is_valid, in_recharge_rmb, in_recharge_diamond, in_uvip_progress, in_checkin_num, in_checkin_reward_num, in_exercise_level, in_cgold_level, in_gold_max, in_exp_max, in_equipment_enhance_success_rate_up_p, in_store_refresh_count_max, in_prop_refresh, in_arena_frozen_time, in_purchase_hp_count, in_gain_gold_up_p, in_gain_exp_up_p, in_purchase_hp_count_max, in_SCHOOL_reset_count_max, in_SCHOOL_reset_count, in_signup_time, in_pemail_csv_id, in_take_diamonds, in_draw_number, in_ifxilian, in_cp_chapter, in_cp_type, in_cp_checkpoint, in_cp_id, in_cp_drop_id1, in_cp_drop_id2, in_cp_drop_id3, in_cp_fighting, in_lilian_level, in_lilian_exp, in_lilian_phy_power, in_purch_lilian_phy_power, in_ara_role_id1, in_ara_role_id2, in_ara_role_id3, in_ara_win_tms, in_ara_lose_tms, in_ara_tie_tms, in_ara_clg_tms, in_ara_clg_cost_tms, in_ara_integral, in_ara_fighting, in_ara_interface, in_ara_rfh_cost_tms, in_ara_r1_sum_combat, in_ara_r1_sum_defense, in_ara_r1_sum_critical_hit, in_ara_r1_sum_king, in_ara_rfh_st, in_ara_rfh_cd, in_ara_rfh_cd_cost_tms, in_ara_clg_tms_rsttm, in_ara_clg_cost_rsttm, in_ara_integral_rsttm, in_draw_num, in_ara_r2_sum_combat, in_ara_r2_sum_defense, in_ara_r2_sum_critical_hit, in_ara_r2_sum_king, in_ara_r3_sum_combat, in_ara_r3_sum_defense, in_ara_r3_sum_critical_hit, in_ara_r3_sum_king, in_daily_recv_heart, in_friend_update_time)
on duplicate key update `csv_id` = in_csv_id, `uname` = in_uname, `uviplevel` = in_uviplevel, `config_sound` = in_config_sound, `config_music` = in_config_music, `avatar` = in_avatar, `sign` = in_sign, `c_role_id` = in_c_role_id, `ifonline` = in_ifonline, `level` = in_level, `combat` = in_combat, `defense` = in_defense, `critical_hit` = in_critical_hit, `blessing` = in_blessing, `permission` = in_permission, `modify_uname_count` = in_modify_uname_count, `onlinetime` = in_onlinetime, `iconid` = in_iconid, `is_valid` = in_is_valid, `recharge_rmb` = in_recharge_rmb, `recharge_diamond` = in_recharge_diamond, `uvip_progress` = in_uvip_progress, `checkin_num` = in_checkin_num, `checkin_reward_num` = in_checkin_reward_num, `exercise_level` = in_exercise_level, `cgold_level` = in_cgold_level, `gold_max` = in_gold_max, `exp_max` = in_exp_max, `equipment_enhance_success_rate_up_p` = in_equipment_enhance_success_rate_up_p, `store_refresh_count_max` = in_store_refresh_count_max, `prop_refresh` = in_prop_refresh, `arena_frozen_time` = in_arena_frozen_time, `purchase_hp_count` = in_purchase_hp_count, `gain_gold_up_p` = in_gain_gold_up_p, `gain_exp_up_p` = in_gain_exp_up_p, `purchase_hp_count_max` = in_purchase_hp_count_max, `SCHOOL_reset_count_max` = in_SCHOOL_reset_count_max, `SCHOOL_reset_count` = in_SCHOOL_reset_count, `signup_time` = in_signup_time, `pemail_csv_id` = in_pemail_csv_id, `take_diamonds` = in_take_diamonds, `draw_number` = in_draw_number, `ifxilian` = in_ifxilian, `cp_chapter` = in_cp_chapter, `cp_type` = in_cp_type, `cp_checkpoint` = in_cp_checkpoint, `cp_id` = in_cp_id, `cp_drop_id1` = in_cp_drop_id1, `cp_drop_id2` = in_cp_drop_id2, `cp_drop_id3` = in_cp_drop_id3, `cp_fighting` = in_cp_fighting, `lilian_level` = in_lilian_level, `lilian_exp` = in_lilian_exp, `lilian_phy_power` = in_lilian_phy_power, `purch_lilian_phy_power` = in_purch_lilian_phy_power, `ara_role_id1` = in_ara_role_id1, `ara_role_id2` = in_ara_role_id2, `ara_role_id3` = in_ara_role_id3, `ara_win_tms` = in_ara_win_tms, `ara_lose_tms` = in_ara_lose_tms, `ara_tie_tms` = in_ara_tie_tms, `ara_clg_tms` = in_ara_clg_tms, `ara_clg_cost_tms` = in_ara_clg_cost_tms, `ara_integral` = in_ara_integral, `ara_fighting` = in_ara_fighting, `ara_interface` = in_ara_interface, `ara_rfh_cost_tms` = in_ara_rfh_cost_tms, `ara_r1_sum_combat` = in_ara_r1_sum_combat, `ara_r1_sum_defense` = in_ara_r1_sum_defense, `ara_r1_sum_critical_hit` = in_ara_r1_sum_critical_hit, `ara_r1_sum_king` = in_ara_r1_sum_king, `ara_rfh_st` = in_ara_rfh_st, `ara_rfh_cd` = in_ara_rfh_cd, `ara_rfh_cd_cost_tms` = in_ara_rfh_cd_cost_tms, `ara_clg_tms_rsttm` = in_ara_clg_tms_rsttm, `ara_clg_cost_rsttm` = in_ara_clg_cost_rsttm, `ara_integral_rsttm` = in_ara_integral_rsttm, `draw_num` = in_draw_num, `ara_r2_sum_combat` = in_ara_r2_sum_combat, `ara_r2_sum_defense` = in_ara_r2_sum_defense, `ara_r2_sum_critical_hit` = in_ara_r2_sum_critical_hit, `ara_r2_sum_king` = in_ara_r2_sum_king, `ara_r3_sum_combat` = in_ara_r3_sum_combat, `ara_r3_sum_defense` = in_ara_r3_sum_defense, `ara_r3_sum_critical_hit` = in_ara_r3_sum_critical_hit, `ara_r3_sum_king` = in_ara_r3_sum_king, `daily_recv_heart` = in_daily_recv_heart, `friend_update_time` = in_friend_update_time;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_users_ara_bat` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_users_ara_bat`(IN in_csv_id int, IN in_ser int, IN in_start_tm int, IN in_end_tm int, IN in_over tinyint, IN in_res int)
BEGIN 
insert into users_ara_bat (`csv_id`, `ser`, `start_tm`, `end_tm`, `over`, `res`) values (in_csv_id, in_ser, in_start_tm, in_end_tm, in_over, in_res)
on duplicate key update `csv_id` = in_csv_id, `ser` = in_ser, `start_tm` = in_start_tm, `end_tm` = in_end_tm, `over` = in_over, `res` = in_res;
END$$ 
DELIMITER ;
DELIMITER $$
DROP PROCEDURE IF EXISTS `qy_insert_users_i` $$
 CREATE DEFINER=`root`@`%` PROCEDURE `qy_insert_users_i`(IN in_csv_id int)
BEGIN 
insert into users_i (`csv_id`) values (in_csv_id)
on duplicate key update `csv_id` = in_csv_id;
END$$ 
DELIMITER ;
