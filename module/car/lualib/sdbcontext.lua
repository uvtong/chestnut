local s_buff_set = require "s_buff_set"
local s_leveldistrictinfo_set = require "s_leveldistrictinfo_set"
local s_level_incident_set = require "s_level_incident_set"
local s_attribute_set = require "s_attribute_set"
local s_gemstone_set = require "s_gemstone_set"
local log = require "log"
local dbcontext = require "dbcontext"
local cls = class("sdbcontext", dbcontext)

function cls:ctor(env, rdb, wdb, ... )
	-- body
	cls.super.ctor(self, env, rdb, wdb)
	self._s_buf_set = s_buff_set.new(env, self, rdb, wdb)
	self._s_leveldistrictinfo_set = s_leveldistrictinfo_set.new(env, self, rdb, wdb)
	self._s_level_incident_set = s_level_incident_set.new(env, self, rdb, wdb)
	self._s_attribute_set = s_attribute_set.new(env, self, rdb, wdb)
	self._s_gemstone_set = s_gemstone_set.new(env, self, rdb, wdb)
	return self
end

function cls:load_db_to_data( ... )
	-- body
	self._s_buf_set:load_db_to_data()
	self._s_leveldistrictinfo_set:load_db_to_data()
	self._s_level_incident_set:load_db_to_data()
	self._s_attribute_set:load_db_to_data()
	self._s_gemstone_set:load_db_to_data()
end

function cls:load_data_to_sd( ... )
	-- body
	self._s_buf_set:load_data_to_sd()
	self._s_leveldistrictinfo_set:load_data_to_sd()
	self._s_level_incident_set:load_data_to_sd()
	self._s_attribute_set:load_data_to_sd()
	self._s_gemstone_set:load_data_to_sd()
end

return cls