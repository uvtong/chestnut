-- This file will execute before every lua service start
-- See config

print("PRELOAD", ...)
package.path = "./../lualib/?.lua;"..package.path
package.cpath = "./../lua-cjson/?.so;"..package.cpath
require "functions"
require "common"