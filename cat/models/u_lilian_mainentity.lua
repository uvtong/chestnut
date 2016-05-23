local entitycpp = require "entitycpp"

local cls = class("u_lilian_mainentity", entitycpp)

function cls:ctor(mgr, P, ... )
	-- body
	self.__head  = mgr.__head
	self.__head_ord = mgr.__head_ord
	self.__tname = mgr.__tname
	self.__pk    = mgr.__pk
	self.__fk    = mgr.__fk
	self.__rdb   = mgr.__rdb
	self.__wdb   = mgr.__wdb
	self.__stm   = mgr.__stm
	self.__col_updated=0
	self.__fields = {
			id = 0,
			csv_id = 0,
			user_id = 0,
			quanguan_id = 0,
			start_time = 0,
			end_time = 0,
			if_trigger_event = 0,
			iffinished = 0,
			invitation_id = 0,
			iflevel_up = 0,
			event_start_time = 0,
			event_end_time = 0,
			if_lilian_finished = 0,
			eventid = 0,
			if_canceled = 0,
			if_event_canceled = 0,
			if_lilian_reward = 0,
			if_event_reward = 0,
			event_reward = 0,
			lilian_reward = 0,
		}

	self.__ecol_updated = {
			id = 0,
			csv_id = 0,
			user_id = 0,
			quanguan_id = 0,
			start_time = 0,
			end_time = 0,
			if_trigger_event = 0,
			iffinished = 0,
			invitation_id = 0,
			iflevel_up = 0,
			event_start_time = 0,
			event_end_time = 0,
			if_lilian_finished = 0,
			eventid = 0,
			if_canceled = 0,
			if_event_canceled = 0,
			if_lilian_reward = 0,
			if_event_reward = 0,
			event_reward = 0,
			lilian_reward = 0,
		}

	for k,v in pairs(self.__head) do
		self.__fields[k] = assert(P[k], string.format("no exist %s", k))
	end
	return self
end

function cls:set_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["id"] = self.__ecol_updated["id"] + 1
	if self.__ecol_updated["id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.id = v
end

function cls:get_id( ... )
	-- body
	return self.__fields.id
end

function cls:set_csv_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["csv_id"] = self.__ecol_updated["csv_id"] + 1
	if self.__ecol_updated["csv_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.csv_id = v
end

function cls:get_csv_id( ... )
	-- body
	return self.__fields.csv_id
end

function cls:set_user_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["user_id"] = self.__ecol_updated["user_id"] + 1
	if self.__ecol_updated["user_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.user_id = v
end

function cls:get_user_id( ... )
	-- body
	return self.__fields.user_id
end

function cls:set_quanguan_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["quanguan_id"] = self.__ecol_updated["quanguan_id"] + 1
	if self.__ecol_updated["quanguan_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.quanguan_id = v
end

function cls:get_quanguan_id( ... )
	-- body
	return self.__fields.quanguan_id
end

function cls:set_start_time(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["start_time"] = self.__ecol_updated["start_time"] + 1
	if self.__ecol_updated["start_time"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.start_time = v
end

function cls:get_start_time( ... )
	-- body
	return self.__fields.start_time
end

function cls:set_end_time(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["end_time"] = self.__ecol_updated["end_time"] + 1
	if self.__ecol_updated["end_time"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.end_time = v
end

function cls:get_end_time( ... )
	-- body
	return self.__fields.end_time
end

function cls:set_if_trigger_event(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["if_trigger_event"] = self.__ecol_updated["if_trigger_event"] + 1
	if self.__ecol_updated["if_trigger_event"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.if_trigger_event = v
end

function cls:get_if_trigger_event( ... )
	-- body
	return self.__fields.if_trigger_event
end

function cls:set_iffinished(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["iffinished"] = self.__ecol_updated["iffinished"] + 1
	if self.__ecol_updated["iffinished"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.iffinished = v
end

function cls:get_iffinished( ... )
	-- body
	return self.__fields.iffinished
end

function cls:set_invitation_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["invitation_id"] = self.__ecol_updated["invitation_id"] + 1
	if self.__ecol_updated["invitation_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.invitation_id = v
end

function cls:get_invitation_id( ... )
	-- body
	return self.__fields.invitation_id
end

function cls:set_iflevel_up(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["iflevel_up"] = self.__ecol_updated["iflevel_up"] + 1
	if self.__ecol_updated["iflevel_up"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.iflevel_up = v
end

function cls:get_iflevel_up( ... )
	-- body
	return self.__fields.iflevel_up
end

function cls:set_event_start_time(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["event_start_time"] = self.__ecol_updated["event_start_time"] + 1
	if self.__ecol_updated["event_start_time"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.event_start_time = v
end

function cls:get_event_start_time( ... )
	-- body
	return self.__fields.event_start_time
end

function cls:set_event_end_time(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["event_end_time"] = self.__ecol_updated["event_end_time"] + 1
	if self.__ecol_updated["event_end_time"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.event_end_time = v
end

function cls:get_event_end_time( ... )
	-- body
	return self.__fields.event_end_time
end

function cls:set_if_lilian_finished(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["if_lilian_finished"] = self.__ecol_updated["if_lilian_finished"] + 1
	if self.__ecol_updated["if_lilian_finished"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.if_lilian_finished = v
end

function cls:get_if_lilian_finished( ... )
	-- body
	return self.__fields.if_lilian_finished
end

function cls:set_eventid(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["eventid"] = self.__ecol_updated["eventid"] + 1
	if self.__ecol_updated["eventid"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.eventid = v
end

function cls:get_eventid( ... )
	-- body
	return self.__fields.eventid
end

function cls:set_if_canceled(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["if_canceled"] = self.__ecol_updated["if_canceled"] + 1
	if self.__ecol_updated["if_canceled"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.if_canceled = v
end

function cls:get_if_canceled( ... )
	-- body
	return self.__fields.if_canceled
end

function cls:set_if_event_canceled(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["if_event_canceled"] = self.__ecol_updated["if_event_canceled"] + 1
	if self.__ecol_updated["if_event_canceled"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.if_event_canceled = v
end

function cls:get_if_event_canceled( ... )
	-- body
	return self.__fields.if_event_canceled
end

function cls:set_if_lilian_reward(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["if_lilian_reward"] = self.__ecol_updated["if_lilian_reward"] + 1
	if self.__ecol_updated["if_lilian_reward"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.if_lilian_reward = v
end

function cls:get_if_lilian_reward( ... )
	-- body
	return self.__fields.if_lilian_reward
end

function cls:set_if_event_reward(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["if_event_reward"] = self.__ecol_updated["if_event_reward"] + 1
	if self.__ecol_updated["if_event_reward"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.if_event_reward = v
end

function cls:get_if_event_reward( ... )
	-- body
	return self.__fields.if_event_reward
end

function cls:set_event_reward(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["event_reward"] = self.__ecol_updated["event_reward"] + 1
	if self.__ecol_updated["event_reward"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.event_reward = v
end

function cls:get_event_reward( ... )
	-- body
	return self.__fields.event_reward
end

function cls:set_lilian_reward(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["lilian_reward"] = self.__ecol_updated["lilian_reward"] + 1
	if self.__ecol_updated["lilian_reward"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.lilian_reward = v
end

function cls:get_lilian_reward( ... )
	-- body
	return self.__fields.lilian_reward
end


return cls
