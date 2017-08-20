local region = require "region"
local hutype = require "hutype"
local jiaotype = require "jiaotype"

local function multiple(lo, max, ... )
	-- body
	assert(lo and max)
	local mmax = max
	local m = {}
	if lo == region.Sichuan then
		m[hutype.PINGHU]          = 1
		m[hutype.DUIDUIHU]        = 2
		m[hutype.QINGYISE]        = 4
		m[hutype.DAIYAOJIU]       = 4 
		m[hutype.QIDUI]           = 4
		m[hutype.JINGOUDIAO]      = 4
		m[hutype.QINGDUIDUI]      = 8
		m[hutype.LONGQIDUI]       = 16 
		m[hutype.QINGQIDUI]       = 16 
		m[hutype.QINGYAOJIU]      = 16 
		m[hutype.JIANGJINGOUDIAO] = 16 
		m[hutype.QINGJINGOUDIAO]  = 16 
		m[hutype.TIANHU]          = 32 
		m[hutype.DIHU]            = 32 
		m[hutype.QINGLONGQIDUI]   = 32 
		m[hutype.SHIBALUOHAN]     = 64 
		m[hutype.QINGSHIBALUOHAN] = 256
	elseif lo == region.Shaanxi then
		m[hutype.PINGHU]          = 1
		m[hutype.DUIDUIHU]        = 1
		m[hutype.QINGYISE]        = 1
		m[hutype.DAIYAOJIU]       = 1 
		m[hutype.QIDUI]           = 1
		m[hutype.JINGOUDIAO]      = 1
		m[hutype.QINGDUIDUI]      = 1
		m[hutype.LONGQIDUI]       = 1
		m[hutype.QINGQIDUI]       = 1
		m[hutype.QINGYAOJIU]      = 1
		m[hutype.JIANGJINGOUDIAO] = 1
		m[hutype.QINGJINGOUDIAO]  = 1
		m[hutype.TIANHU]          = 1
		m[hutype.DIHU]            = 1
		m[hutype.QINGLONGQIDUI]   = 1
		m[hutype.SHIBALUOHAN]     = 1
		m[hutype.QINGSHIBALUOHAN] = 1
	end
	local function xx(hu, jiao, gang, ... )
		-- body
		local hm = assert(m[hu])
		if lo == region.Sichuan then
			if jiao == jiaotype.DIANGANGHUA then
				hm = hm * 2
			elseif jiao == jiaotype.GANGSHANGPAO then
				hm = hm * 2
			elseif jiao == jiaotype.QIANGGANGHU then
				hm = hm * 2
			elseif jiao == jiaotype.ZIGANGHUA then
				hm = hm * 2
			elseif jiao == jiaotype.ZIMO then
				hm = hm * 2
			end
			if hm == hutype.PINGHU then
				if gang > 0 then
					hm = hm * gang * 2
				end
			end
		end
		return hm
	end
	return xx
end

return multiple