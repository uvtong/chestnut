local errorcode = {}

errorcode[1] = { code = 1, msg = "success"}
errorcode[2] = { code = 2, msg = "offline"}
errorcode[3] = { code = 3, msg = "not enough role prop number"}
errorcode[4] = { code = 4, msg = "prop don't user"}
errorcode[5] = { code = 5, msg = "goods refresh count more then store refersh count max."}
errorcode[6] = { code = 6, msg = "not enough diamond."}
errorcode[7] = { code = 7, msg = "countdown has been changed."}
errorcode[8] = { code = 8, msg = "goods don't need refresh"}
errorcode[9] = { code = 9, msg = "not enough gold."}
errorcode[10] = { code = 10, msg = "goods is a frozen state."}
errorcode[11] = { code = 11, msg = "not enough goods"}
errorcode[12] = { code = 12, msg = "password must be greater then 8"}
errorcode[13] = { code = 13, msg = "account already exists"}
errorcode[14] = { code = 14, msg = "account already login"}
errorcode[15] = { code = 15, msg = "account no exists"}
errorcode[16] = { code = 16, msg = "not enough prop"}
errorcode[17] = { code = 17, msg = "modify uname count more than 1"}
errorcode[18] = { code = 18, msg = "you only have a time to change your name, or you can take money."}
errorcode[19] = { code = 19, msg = "user upgrade, not enough exp."}
errorcode[20] = { code = 20, msg = "vip reward non-existent."}
errorcode[21] = { code = 21, msg = "vip more then your vip "}
errorcode[22] = { code = 22, msg = "your vip reward has been collected."}
errorcode[23] = { code = 23, msg = "equipment enhance, do not exceed the level of the player."}
errorcode[24] = { code = 24, msg = "equipment enhance failture."}
errorcode[25] = { code = 25, msg = "your vip gift has purchased"}
errorcode[26] = { code = 26, msg = "your achievement reward don't collected"}
errorcode[27] = { code = 27, msg = "from the client data is wrong."}
errorcode[28] = { code = 28, msg = "props unavailable."}
errorcode[29] = { code = 29, msg = "exception"}
errorcode[30] = { code = 30, msg = "more then user level max value."}
errorcode[31] = { code = 31, msg = "not enough money"}
errorcode[32] = { code = 32, msg = "first xilian"}
errorcode[33] = { code = 33, msg = "failture"}
errorcode[34] = { code = 34, msg = "no passed checkpoint"}
errorcode[35] = { code = 35, msg = "checkpoint id error"}
errorcode[36] = { code = 36, msg = "nothing from client"}
errorcode[37] = { code = 37, msg = "data from client is wrong."}
errorcode[38] = { code = 38, msg = "rnk rwd has collected"}
errorcode[39] = { code = 39, msg = "no exists protocol"}
errorcode[40] = { code = 40, msg = "not enough chllenge times."}


--email
errorcode[41] = { code = 41 , msg = "not email in maillist" }

--kungfu

errorcode[51] = { code = 51 , msg = "kongfu not exist" }
errorcode[52] = { code = 52 , msg = "kungfu level not match" }

--friend
errorcode[60] = {code = 60, msg = "to many friends"}
errorcode[ 61 ] = { code = 61 , msg = "you wai gua" }
errorcode[ 62 ] = { code = 62 , msg = "checkin already" } 
errorcode[ 63 ] = { code = 63 , msg = "can not apply yourself" }
errorcode[ 64 ] = { code = 64 , msg = "no such user" }
errorcode[ 65 ] = { code = 65 , msg = "can not add yourself" }
errorcode[ 66 ] = { code = 66 , msg = "already friend" }
errorcode[ 67 ] = { code = 67 , msg = "in the appliedlist" }
errorcode[ 68 ] = { code = 68 , msg = "not enough heart" }
errorcode[ 69 ] = { code = 69 , msg = "too much heart" }
errorcode[ 70 ] = { code = 70 , msg = "can not add this one" }

--checkin
errorcode[ 71 ] = { code = 71 , msg = "donot match the server totalmount" }
errorcode[ 72 ] = { code = 72 , msg = "can not checkin_reward" }

--lilian
errorcode[81] = { code = 81 , msg = "lilian not finished yet" }
errorcode[82] = { code = 82 , msg = "condition not meet" }
errorcode[83] = { code = 83 , msg = "can not lilian anymore in this quanguan" }
errorcode[84] = { code = 84 , msg = "not enough queue" }
errorcode[85] = { code = 85 , msg = "event not finished yet" }
errorcode[86] = { code = 86 , msg = "already get lilian reward" }
errorcode[87] = { code = 87 , msg = "already get event reward" }
errorcode[88] = { code = 88 , msg = "wrong reward type" }
errorcode[89] = { code = 89 , msg = "limit purchase num" }
errorcode[90] = { code = 90 , msg = "can not reset" }
errorcode[91] = { code = 91 , msg = "speed over time"}

--corefight
errorcode[110] = {code = 110, msg = "game is over"}
errorcode[111] = {code = 111, msg = "continue fight"}
errorcode[112] = {code = 112, msg = "wrong data"}


errorcode[150] = {code = 150, msg = "not enough role"}
errorcode[151] = {code = 151, msg = "last ara not finished"}
errorcode[152] = {code = 152, msg = "arena ranking reward has collected"}
errorcode[153] = {code = 153, msg = "no exitence role id"}
return errorcode