local skynet = require "skynet"
local dc = require "datacenter"
local sd = require "sharedata"
local errorcode = require "errorcode"
local const = require "const"
local util = require "util"
local super = require "module"
local cls = class("shopmodule", super)

function cls:ctor(env, ... )
	-- body
	self._env = env
end

return cls