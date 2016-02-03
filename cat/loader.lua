local skynet = require "skynet"
local util = require "util"

local loader = {}
local user 
local game

local function load_g_achievement()
	-- body
	assert(game.g_achievementmgr == nil)
	local g_achievementmgr = require "g_achievementmgr"
	local r = skynet.call(util.random_db(), "lua", "command", "select", "g_achievement")
	for i,v in ipairs(r) do
		local t = g_achievementmgr.create(v)
		g_achievementmgr:add(t)
	end
	game.g_achievementmgr = g_achievementmgr
end


function loader.load_all()
	-- body
	load_g_achievement()
	return game, user
end

return loader