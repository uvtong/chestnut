local skynet = require "skynet"
local skynet_queue = require "skynet.queue"
local snax = require "snax"
local sd = require "sharedata"
local log = require "log"
local list = require "list"
local gs = require "room.gamestate"
local region_mgr = require "room.region_mgr"
local food_mgr = require "room.food_mgr"
local player = require "room.player"
local car = require "room.car"
local pos80_80 = require "room.pos80_80"
local queue = require "queue"
local leadboard = require "room.leadboard"

local gametype = {}
gametype.NONE   = 0
gametype.LIMIT  = 1
gametype.CIRCLE = 2

local cls = class("rcontext")

cls.type = type

function cls:ctor(id, ... )
	-- body
	self._id = id
	self._sceneid = 1000001
	self._gate = nil
	self._room_mgr = nil
	self._max_number = 2
	self._number = 0
	self._ainumber = 0
	
	self._session_players = {}
	self._players_sz = 0
	self._player_cs = skynet_queue()

	self._ais = {}
	self._ai_sz = 0
	self._aics = skynet_queue()
	
	self._state = gs.NONE
	self._type = gametype.NONE
	self._times = {}

	self._list = list.new()
	for i=1,35 do
		local tmp = player.new()
		list.insert_tail(self._list, tmp)
	end
	self._csfree = skynet_queue()

	self._region_mgr = nil
	self._food_mgr = food_mgr.new(self, self._sceneid)

	self._q1 = queue()
	self._q2 = queue()

	for i,v in ipairs(pos80_80.a) do
		self._q1:enqueue(v)
	end

	for i,v in ipairs(pos80_80.b) do
		-- self._q2:enqueue(v)
		self._q1:enqueue(v)
	end

	self._leadboard = leadboard.new(10)
end

function cls:get_buff_mgr( ... )
	-- body
	return self._buff_mgr
end

function cls:get_food_mgr( ... )
	-- body
	return self._food_mgr
end

function cls:get_id( ... )
	-- body
	return self._id
end

function cls:get_gate( ... )
	-- body
	return self._gate
end

function cls:set_gate(v, ... )
	-- body
	self._gate = v	
end

function cls:get_number( ... )
	-- body
	return self._number
end

function cls:get_ainumber( ... )
	-- body
	return self._ainumber
end

function cls:get_room_mgr( ... )
	-- body
	return self._room_mgr
end

function cls:set_room_mgr(value, ... )
	-- body
	self._room_mgr = value
end

function cls:get_q1( ... )
	-- body
	return self._q1
end

function cls:get_q2( ... )
	-- body
	return self._q2
end

function cls:get_leadboard( ... )
	-- body
	return self._leadboard
end

function cls:add(uid, p, ... )
	-- body
	self._session_players[uid] = p
	local function func( ... )
		-- body
		self._players_sz = self._players_sz + 1
	end
	self._player_cs(func)
	self._leadboard:push_back(p, player.comp_score)
end

function cls:remove(uid, ... )
	-- body
	local player = self._session_players[uid]
	assert(player)
	self._session_players[uid] = nil
	local function func1( ... )
		-- body
		self._players_sz = self._players_sz - 1
	end
	self._player_cs(func1)
	local function func2( ... )
		-- body
		list.insert_tail(self._list, player)
	end
	self._csfree(func2)
end

function cls:get_player(uid, ... )
	-- body
	local player = self._session_players[uid]
	if player then
		return player
	else
		log.error("uid: %d, player is no existen", uid)
	end
end

function cls:get_players( ... )
	-- body
	return self._session_players
end

function cls:get_players_sz( ... )
	-- body
	return self._players_sz
end

function cls:alloc_ai(hp, ... )
	-- body
	local uid = skynet.call(".AI_MGR", "lua", "enter")
	local player = self:get_freeplayer()
	player:set_uid(uid)
	player:set_ai(true)

	local car = car.new(1, uid)
	car:set_player(player)
	car:set_hp(hp)

	player:set_car(car)
	
	return player
end

function cls:free_ai(player, ... )
	-- body
	local function func( ... )
		-- body
		list.insert_tail(self._list, player)
	end
	self._csfree(func)
	skynet.call(".AI_MGR", "lua", "exit", player:get_id())
end

function cls:add_ai(id, p, ... )
	-- body
	assert(id and p)
	self._ais[id] = p
	local function func( ... )
		-- body
		self._ai_sz = self._ai_sz + 1
	end
	self._aics(func)
	self._leadboard:push_back(p, player.comp_score)
end

function cls:remove_ai(id, ... )
	-- body
	assert(id)
	local player = assert(self._ais[id])
	self._ais[id] = nil
	local function func( ... )
		-- body
		self._ai_sz = self._ai_sz - 1
	end
	self._aics(func)
	return player
end

function cls:get_ai(id, ... )
	-- body
	return self._ais[id]
end

function cls:get_ais( ... )
	-- body
	return self._ais
end

function cls:get_ai_sz( ... )
	-- body
	return self._ai_sz
end

function cls:get_maxnum( ... )
	-- body
	return self._max_number
end

function cls:start(t, total, num, ainum, ... )
	-- body
	log.info("total:%d, num:%d, ainum:%d", total, num, ainum)
	self._state = gs.STATE
	self._type = t
	self._region_mgr = region_mgr.new(self, self._sceneid)
	self._food_mgr:start()
	self._max_number = total
	self._number = num
	self._ainumber = ainum

	local key = string.format("%s:%d", "s_attribute", 1)
	local row = sd.query(key)

	-- local num = self._ainumber
	-- for i=1,num do
	-- 	local player = self:alloc_ai(row.baseHP)
	-- 	self:add_ai(player:get_id(), player)
	-- end


	if self._type == gametype.CIRCLE then
		local handler = cc.handler(self, cls.close)
		skynet.timeout(600 * 60 * 15, handler)
	end

	local handler = cc.handler(self, cls.leadboard_cd) 
	skynet.timeout(100 * 3, handler)
end

function cls:close( ... )
	-- body
	self._state = gs.CLOSE
	if self._type == gametype.CIRCLE then
		self:start(self._type, self._max_number, self._number, self._ainumber)
	else
		for k,player in pairs(self._session_players) do
			local agent = player:get_agent()
			agent.post.limit_close()
		end
	end
end

function cls:get_state( ... )
	-- body
	return self._state
end

function cls:set_state(value, ... )
	-- body
	self._state = value
end

function cls:get_freeplayer( ... )
	-- body
	local function func(li, ... )
		-- body
		if list.size(li) > 0 then
			local player = list.head(self._list)
			list.remove_head(self._list)
			return player
		else
			local tmp = player.new()
			return tmp
		end
	end
	return self._csfree(func, self._list)
end

function cls:leadboard_cd( ... )
	-- body
	if self._state == gs.CLOSE then
	else
		local handler = cc.handler(self, cls.leadboard_cd) 
		skynet.timeout(100 * 3, handler)
	end
	local arr = {}
	local function tick(p, ... )
		-- body
		local tmp = {}
		tmp.userid = p:get_uid()
		tmp.socre = p:get_score()
		table.insert(arr, tmp)
	end
	self._leadboard:foreach(tick)
	for k,v in pairs(self._session_players) do
		local agent = v:get_agent()
		agent.post.rank({ r=arr })
	end
end

return cls