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
  response 
  {
    ok 0 : boolean  
	
	.role { 
		.StaticBox
		{
			id 0 : integer;

			redAndBlueMax 1 : integer;

			intervalMin 2 : string;

			timeMin 3 : string;

			timeMax 4 : string;

			staticType 5 : integer;

			makeCount 6 : integer;

			with 7 : string;

			moveSpeed 8 : string;
		}
		.StaticAttr
		{
			staticTypeList 0 : *StaticBox 
		}
		
		.MoveBox
		{
			id 0 : integer;

			countMax 1 : integer;

			intervalMin 2 : string;

			timeMin 3 : string;

			timeMax 4 : string;

			moveType 5 : integer;

			makeCount 6 : integer;

			with 7 : string;

			moveSpeed 8 : string;
		}
		.MoveAttr
		{
			moveTypeList 0 : *MoveBox 
		}
		
		staticAttrLevelList 0 : *StaticAttr 
		moveAttrLevelList 1 ：*MoveAttr 
           
		title 2 : string
		path 3 ：string
		defense 4 : integer
		crit 5 : integer
		fightPower 6 : integer
		skill 7 : integer
		addPower 8 : integer
		attenuation 9 : integer 
	} 
    rolelist 1 : *role  
  }
}

foo 2 {
  response {
    ok 0 : boolean
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
