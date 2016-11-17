local sd = require "sharedata"
local lst = require "list"
local table = require "table"
local  log = require "log"
local assert = assert
local cls = class("BuffGenerate")


-- Member variable
local ticktime

local bufftype = {}
bufftype.addbloodbuff = 1
bufftype.shieldbuff = 2
bufftype.addacceleratebuff = 3
bufftype.adddamagebuff = 4
bufftype.minusacceleratebuff = 5
bufftype.minusbloodbuff = 6
bufftype.minusdamagebuff = 7


function cls:InitData( sceneid , ctx )
	-- find buff id lst by scene config
	local scenekey = string.format("%s:%d","s_leveldistrictinfo",sceneid)
	log.info("scenescenescenescenexxxxxx %s",sd.query(scenekey).IncidentID )
	local buffidlst = string.split(sd.query(scenekey).IncidentID,',')               

	-- init buff data lst by buffgenerate config
	self.buffgeneratedatalist = lst.new()
	for i=1,#buffidlst,1
	do 
   	 local buffgeneratekey = string format("%s:%d","s_level_incident",buffidlst[i])
   	 local buffgenerateitem = sd.query(buffgeneratekey);
   	 lst.add(self.buffgeneratedatalist,buffgenerateitem)
	end
	-- 
	self.validbufflst = lst.new()
	self.ctx = ctx
end

function cls:TickGenerateBuff( deltaTime )
	-- add time
	ticktime = ticktime + deltaTime

	-- generate buff entity by time over
	local function func(item, ... )
		-- body
		if item.time <= ticktime then
			local tmp = {}
			tmp.id = item.id
			tmp.time = item.continuedtime
			lst.add(self.validbufflst,tmp)
			-- send msg to client create buff entity
			self.ctx:broadcast(showbuffrect,{item.id})
			lst.del(item)
		end
	end
	lst.foreach(self.buffgeneratedatalist, func)
end

--
function cls:checkrectandtimeover(entity)
	if self.validbufflst ~= nil then
		local function func(item, ... )
			if v.time - deltaTime <=0 then 
				-- send msg to client del buff entity
				self.ctx:broadcast(hidebuffrect,{item.id})
				lst.del(item)
			end
		lst.foreach(self.validbufflst, func)
		end

		local function func2(item, ... )
			local buffdatakey = string.format("%s:%d","buff",item.id)
			local buffdata = sd.query(buffdatakey);
			local pos1 = entity:get_pos()
			local pos2 = string.split(buffdata.pos,',')  
			local x1, y1, z1 = pos1:unpack()
			local x2 = tonumber(pos2[1])
			local y2 = tonumber(pos2[1])
			local z2 = tonumber(pos2[1])
			local x = x1 - x2
			local y = y1 - y2
			local z = z1 - z2
			local dis = math3d.vector3(x, y, z)
			local lenght = dis:length()
			if length < buffdata.radius then
				entity:addbuff()--createbuff(k,buffdata.type,entity)
			else

			end
		end
		lst.foreach(self.validbufflst, func2)
	end

	if entity ~= nil then
		entity:updatebuff()
	end
end


return cls