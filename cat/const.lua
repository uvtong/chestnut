local const = {}

-- prop id
const.DIAMOND       = 1
const.GOLD          = 2
const.EXP           = 3
const.LOVE          = 4
const.PHY_POWER     = 5
const.HONORARY_COIN = 6
const.ARA_INTEGRAL  = 7

-- achievement type
const.ACHIEVEMENT_T_SUM = 8
const.ACHIEVEMENT_T_2 = 2
const.ACHIEVEMENT_T_3 = 3
const.ACHIEVEMENT_T_4 = 4
const.ACHIEVEMENT_T_5 = 5
const.ACHIEVEMENT_T_6 = 6
const.ACHIEVEMENT_T_7 = 7
const.ACHIEVEMENT_T_8 = 8
const.ACHIEVEMENT_T_9 = 9

-- guid type
const.UENTROPY = 1
const.UEMAILENTROPY = 2
const.PUBLIC_EMAILENTROPY = 3
const.DRAW = 4
const.U_PUBLIC_EMAILENTROPY = 5

const.DB_PRIORITY_1 = 1
const.DB_PRIORITY_2 = 2
const.DB_PRIORITY_3 = 3
const.DB_DELTA      = 100 * 60

const.ARA_PTS = {}

for i=1,20 do
	if i // 2 == 0 then
		table.insert(const.ARA_PTS, i)
	end
end

return const
