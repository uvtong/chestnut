local hutype = require "hutype"

local function check_qidui(cards, ... )
	-- body
	assert(cards and #cards > 0)
	local res = hutype.NONE
	local ctype = cards[1]:tof()
	local qing = true
	local jiang = 0
	local gang = 0

	local len = #cards
	local idx = 1

	local a = cards[idx]
	idx = idx + 1
	while idx <= len do
		local b = cards[idx]
		idx = idx + 1

		if a:eq(b) then
			jiang = jiang + 1

			if idx <= len then
				local c = cards[idx]
				idx = idx + 1
				if a:eq(c) then
					if idx <= len then
						local d = cards[idx]
						idx = idx + 1
						if a:eq(d) then
							jiang = jiang + 1
							gang = gang + 1
							if idx <= len then
								local e = cards[idx]
								idx = idx + 1
								if e:tof() ~= a:tof() then
									qing = false
								end
								a = e
							else
								break
							end
						else
							break
						end
					else
						break
					end
				elseif a:tof() ~= c:tof() then
					qing = false
				end
				a = c
			else
				break
			end	
		else
			break
		end
	end

	if jiang == 7 and qing and gang >= 1 then
		return hutype.QINGLONGQIDUI
	elseif jiang == 7 and qing then
		return hutype.QINGQIDUI
	elseif jiang == 7 and gang >= 1 then
		return hutype.LONGQIDUI
	elseif jiang == 7 then
		return hutype.QIDUI
	else
		return hutype.NONE
	end
end

local function check_put(putcards, ... )
	-- body
	assert(putcards)
	local gang = 0
	local qing = true
	local ctype
	local len = putcards
	if len > 0 then
		local idx = 1
		local cards = putcards[idx]
		idx = idx + 1
		ctype = cards[1]:tof()
		if #cards == 4 then
			gang = gang + 1
		end
		while idx <= len do
			local cards = putcards[idx]
			idx = idx + 1
			if #cards == 4 then
				gang = gang + 1
			end
			if cards[1]:tof() ~= ctype then
				qing = false
			end
		end
		if qing then
			return gang, qing, ctype
		else
			return gang, qing
		end
	else
		qing = false
		return gang, qing
	end
end

local _M = {}

function _M.check_sichuan(cards, putcards, ... )
	-- body
	assert(cards and putcards)
	local res = hutype.NONE

	local qing = true

	local jiang = 0
	local tong3 = 0
	local lian3 = 0
	local gang = 0

	local x = 1

	local len = cards
	local idx = 1
	local a = cards[idx]
	idx = idx + 1
	while idx <= len do
		local b = cards[idx]
		idx = idx + 1
		if b:eq(a) then
			if idx > len then
				break
			end
			local c = cards[idx]
			idx = idx + 1
			if c:eq(b) then
				if idx > len then
					tong3 = tong3 + 1
					break
				end
				local d = cards[idx]
				idx = idx + 1
				if d:eq(a) then
					if idx > len then
						break
					end
					local e = cards[idx]
					idx = idx + 1
					if e:tof() == a:tof() then
						if e:nof() == a:nof() + 1 then
							if idx > len then
								break
							end
							local f = cards[idx]
							idx = idx + 1
							if f:eq(e) then
								if idx > len then
									break
								end
								local g = cards[idx]
								idx = idx + 1
								if g:tof() == f:tof() then
									if g:nof() == f:nof() + 1 then
										if idx > len  then
											break
										end
										local h = cards[idx]
										idx = idx + 1
										if h:eq(g) then
											lian3 = lian3 + 2
											jiang = jiang + 1
											if idx <= len then
												local i = cards[idx]
												idx = idx + 1
												if i:tof() ~= a:tof() then
													qing = false
												end
												a = i
											else
												break
											end
										else
											break
										end
									else
										break
									end
								else
									break
								end
							elseif f:tof() == e:tof() then
								if f:nof() == e:nof() + 1 then
									tong3 = tong3 + 1
									lian3 = lian3 + 1
									gang = gang + 1
									if idx <= len then
										local g = cards[idx]
										idx = idx + 1
										if g:tof() ~= a:tof() then
											qing = false
										end
										a = g
									else
										break
									end
								else
									break
								end
							else
								break
							end
						else
							break
						end
					else
						break
					end
				elseif d:tof() == a:tof() then
					if d:nof() == a:nof() + 1 then
						if idx > len then
							break
						end
						local e = cards[idx]
						idx = idx + 1
						if e:tof() == d:tof() then
							if e:nof() == d:nof() + 1 then
								lian3 = lian3 + 1
								jiang = jiang + 1
								if idx <= len then
									local f = cards[idx]
									if f:tof() ~= a:tof() then
										qing = false
									end
									a = f
								else
									break
								end
							else
								break
							end
						else
							break
						end
					else
						tong3 = tong3 + 1
						a = d
					end
				else
					qing = false
					tong3 = tong3 + 1
					a = d
				end
			elseif c:tof() == a:tof() then
				if c:nof() == a:nof() + 1 then
					local d = cards[idx]
					idx = idx + 1
					if c:eq(d) then
						jiang = jiang + 1
						local e = cards[idx]
						idx = idx + 1
						if c:eq(e) then
							jiang = jiang - 1
							tong3 = tong3 + 1
							local f = cards[idx]
							idx = idx + 1
							if c:eq(f) then
								jiang = jiang + 2
								tong3 = tong3 - 1
								local g = cards[idx]
								idx = idx + 1
								if c:tof() == g:tof() then
									if c:nof() + 1 == g:nof() then
										local h = cards[idx]
										idx = idx + 1
										if g:eq(h) then
											jiang = jiang - 3
											jiang = jiang + 1
											lian3 = lian3 + 2
										else
											ok = false
											break
										end
									else
										ok = false
										break
									end
								else
									ok = false
									break
								end
							else
							end
						elseif c:tof() == e:tof() then
							if c:nof() + 1 == e:nof() then
								if idx < len then
									ok = false
									break
								end
								local f = cards[idx]
								idx = idx + 1
								if f:eq(e) then
								else
									ok = false
									break
								end
							else
								ok = false
								break
							end
						else
							ok = false
							break
						end
					else
						ok = false
						break
					end
				else
					a = c
					idx = idx - 1
				end
			else
				jiang = jiang + 1
				qing = false
				a = cards[idx]
				idx = idx + 1
			end
		elseif b:tof() == a:tof() then
			if b:nof() == a:nof() + 1 then
				if idx > len then
					break
				end
				local c = cards[idx]
				idx = idx + 1
				if c:eq(b) then
					if idx <= len then
						local d = cards[idx]
						if d:eq(c) then
							if idx <= len then
								local e = cards[idx]
								if e:eq(d) then
									if idx <= len then
										local f = cards[idx]
										if f:tof() == e:tof() then
											if f:nof() == e:nof() + 1 then
												tong3 = tong3 + 1
												lian3 = lian3 + 1
												if idx <= len then
													local g = cards[idx]
													if g:tof() ~= a:tof() then
														qing = false
													end
													a = g
												else
													break
												end
											else
												break
											end
										else
											break
										end
									else
										break
									end
								elseif e:tof() == d:tof() then
									if e:nof() == d:nof() + 1 then
										lian3 = lian3 + 1
										jiang = jiang + 1
										if idx <= len then
											local f = cards[idx]
											if f:tof() ~= e:tof() then
												qing = false
											end
											a = f 
										else
											break
										end
									else
										break
									end
								else
									break
								end
							else
								break
							end
						else
							break
						end
					else
						break
					end
				elseif c:tof() == b:tof() then
					if c:nof() == b:nof() + 1 then
						if idx <= len then
							local d = cards[idx]
							idx = idx + 1
							if d:eq(c) then
								if idx <= len then
									local e = cards[idx]
									idx = idx + 1
									if e:eq(d) then
										if idx <= len then
											local f = cards[idx]
											idx = idx + 1
											if f:eq(e) then
												lian3 = lian3 + 1
												tong3 = tong3 + 1
												gang = gang + 1
												if idx <= len then
													local g = cards[idx]
													if g:tof() ~= a:tof() then
														qing = false
													end
													a = g
												else
													break
												end
											else
												lian3 = lian3 + 1
												jiang = jiang + 1
												if f:tof() ~= a:tof() then
													qing = false
												end
												a = f
											end
										else
											lian3 = lian3 + 1
											jiang = jiang + 1
											break
										end
									else
										break
									end
								else
									break
								end
							else
								lian3 = lian3 + 1
								if d:tof() ~= c:tof() then
									qing = false
								end
								a = d
							end
						else
							lian3 = lian3 + 1
							break
						end
					else
						break
					end
				else
					break
				end
			else
				break
			end
		else
			break
		end
	end

	local pgang, pqing, pctype = check_put(putcards)
	if pqing and qing then
		if a:tof() == pctype then
		else
			qing = false
		end
	else
		qing = false
	end
	gang = gang + pgang


	if jiang * 2 + tong3 * 3 + lian3 * 3 == len then
		if len == 2 and jiang == 1 then
			if qing and gang == 4 then
				res = hutype.QINGSHIBALUOHAN
			elseif gang == 4 then
				res = hutype.SHIBALUOHAN
			elseif qing then
				res = hutype.QINGJINGOUDIAO
			else
				res = hutype.JINGOUDIAO
			end
		elseif jiang == 1 and lian3 == 0 then
			if qing then
				res = hutype.QINGDUIDUI
			else
				res = hutype.DUIDUIHU
			end
		else
			res = hutype.PINGHU
		end
	end
	return res
end

return _M