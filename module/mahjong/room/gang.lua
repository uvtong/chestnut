local opcode = require "opcode"

local function gang(idx, curidx, card, cards, putcards, ... )
	-- body
	assert(idx and curidx and card and cards and putcards)
	assert(idx > 0 and curidx > 0)
	local res = opcode.none
	if curidx == idx then

		if #putcards > 0 then
			for i,v in ipairs(putcards) do
				if #v.cards == 3 then
					if v.cards[1]:eq(card) then
						res = opcode.bugang
						return res, card
					end
				end
			end
		end

		-- an for card
		local len = #cards
		local first = cards[1]
		local count = 1
		for i=2,len do
			if cards[i]:eq(first) then
				count = count + 1
			elseif count == 3 then
				if first:eq(card) then					
					res = opcode.angang
					return res, card
				else
					first = cards[i]
					count = 1
				end
			else
				first = cards[i]
				count = 1
			end
		end
		if count == 3 then
			if first:eq(card) then
				res = opcode.angang
				return res, card
			end
		end

		-- an for had
		first = cards[1]
		count = 1
		for i=2,len do
			if cards[i]:eq(first) then
				count = count + 1
			elseif count == 4 then
				res = opcode.angang
				return res, first
			else
				first = cards[i]
				count = 1
			end
		end
		if count == 4 then
			res = opcode.angang
			return res, first
		end

		-- bu for had
		if #putcards > 0 then
			for i,v in ipairs(putcards) do
				if #v.cards == 3 then
					for j,card in ipairs(cards) do
						if v.cards[1]:eq(card) then
							res = opcode.bugang
							return res, card
						end
					end
				end
			end
		end

		return res
	else
		local len = #cards
		local first = cards[1]
		local count = 1
		for i=2,len do
			if cards[i]:eq(first) then
				count = count + 1
			elseif count == 3 then
				if first:eq(card) then
					res = opcode.zhigang
					return res, card
				else
					first = cards[i]
					count = 1
				end
			else
				first = cards[i]
				count = 1
			end
		end
		if count == 3 then
			if first:eq(card) then
				res = opcode.zhigang
				return res, card
			end
		end
		return res
	end
end

return gang