local sprotoparser = require "sprotoparser"

local proto = {}

proto.c2s = sprotoparser.parse [[
.package {
  type 0 : integer
  session 1 : integer
}

foobar 1 {
  request {
    what 0 : string
  }
  response {
    ok 0 : boolean 
    isBoss 1 : boolean
    endWinCount 2 : integer
	
    health_Max 3 : integer
    defense_Min 4 : integer


    redMakeStartTimeMin 5 : integer
    redMakeStartTimeMax 6 : integer
	
    bombMakePre 7 : integer
    fastMakePre 8 : integer
    groundMakePre 9 : integer
    comboMakePre 10 : integer
	
    attack1_Min 11 : integer
    attack1_Max 12 : integer
    attack1_TimeMin 13 : string
    attack1_TimeMax 14 : string
    attack1_CountMax 15 : integer 
    attack2_Min 16 : integer
    attack2_Max 17 : integer
    attack2_TimeMin 18 : string
    attack2_TimeMax 19 : string
    attack2_CountMax 20 : integer 
    attackBoxMax 21 : integer
    attack3_Max 22 : integer
 
    batter_Min 23 : integer
    batter_Max 24 : integer
 
    batter_ShowMin 25 : integer
    batter_ShowMax 26 : integer
    batter_TimeMin 27 : string
    batter_TimeMax 28 : string
    batter_CountMax 29 : integer 
 
    combo_Min 30 : integer
    combo_Max 31 : integer
    combo_ShowMax 32 : integer
    combo_CountMax 33 : integer 
	
    ground_Min 34 : integer
    ground_Max 35 : integer
    ground_TimeMin 36 : string
    ground_TimeMax 37 : string
    ground_CountMax 38 : integer
    ground_SpeedMin 39 : integer
    ground_CountClick 40 : integer
 
    fast_Min 41 : integer
    fast_Max 42 : integer
    fast_TimeMin 43 : string
    fast_TimeMax 44 : string
    fast_CountMax 45 : integer
    fast_SpeedMin 46 : integer
    fast_SpeedMax 47 : integer 
	
    bomb_Min 48 : integer
    bomb_Max 49 : integer
    bomb_TimeMin 50 : string
    bomb_TimeMax 51 : string
    bomb_CountMax 52 : integer
    bomb_SpeedMin 53 : integer
 
    red_Min 54 : integer
    red_Max 55 : integer
    red_TimeMin 56 : string
    red_TimeMax 57 : string
    red_CountMax 58 : integer
    red_SpeedMin 59 : integer
 
    comboBoxShowMin 60 : integ

  }
}

bar 3 {}

blackhole 4 {
  request {}
}

]]

proto.s2c = sprotoparser.parse [[
.package {
	type 0 : integer
	session 1 : integer
}

heartbeat 1 {}
]]

return proto
