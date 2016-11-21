local skynet = require "skynet"
local sd = require "sharedata"
local food = require "room.food"
local log = require "log"
local cls = class("food_mgr")

function cls:ctor(ctx, id, ... )
	-- body
	self._ctx = ctx
	self._id = id
	self._foodid = 0
	self._foods = {}
	self._foods_sz = 0
	self._genstibes = {}
	self._refresh = nil
	local key = string.format("%s:%d", "s_leveldistrictinfo", id)
	local row = sd.query(key)
	local arr = string.split(row.gemstones, ";")
	for i,v in ipairs(arr) do
		local q = string.split(v, ",")
		self._genstibes[q[1]] = q[2]
	end
	self._refresh = row.Refresh * 100
end

function cls:start( ... )
	-- body
	self:gen()
end

function cls:gen( ... )
	-- body
	local li = {}
	for k,v in pairs(self._genstibes) do
		local key = string.format("%s:%d", "s_gemstone", tonumber(k))
		log.info(key)
		local row = sd.query(key)
		for i=1,tonumber(v) do
			self._foodid = self._foodid + 1	
			local x = math.random(1, 100)
			local y = math.random(1, 100)
			local z = math.random(1, 100)
			local tmp = food.new(self._foodid, tonumber(k), row.Blood)
			tmp:set_x(x)
			tmp:set_y(y)
			tmp:set_z(z)
			self._foods[self._foodid] = tmp

			local i = {}
			i.id = self._foodid
			i.resid = tonumber(k)
			i.x = x
			i.y = 0
			i.z = z
			table.insert(li, i)
			self._foods_sz = self._foods_sz + 1
			if self._foods_sz > 40 then
				break
			end
		end	
	end
	local players = self._ctx:get_players()
	for k,v in pairs(players) do
		local agent = v:get_agent()
		agent.post.generatebloodentity({ bloodentitylst=li })
	end
	local callback = cc.handler(self, cls.gen)
	skynet.timeout(self._refresh, callback)
end

function cls:add( ... )
	-- body
end

function cls:remove(id, ... )
	-- body
	if self._foods[id] then
		self._foods[id] = nil
		self._foods_sz = self._foods_sz - 1
	end
end

function cls:get_food(id, ... )
	-- body
	log.info("%d", id)
	if self._foods[id] then
		return self._foods[id]
	else
		log.error("multi ")
	end
end

return cls