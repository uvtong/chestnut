-- This file will execute before every lua service start
-- See config

print("PRELOAD", ...)
package.path = "./../../lualib/?.lua;./../../service/cat/?.lua;./../../service/logind/?.lua;"..package.path
package.cpath = "./../crab/?.so;./../lua-cjson/?.so;./../lua-sharedata/?.so;./../lua-snapshot/?.so;./../lua-zset/?.so;"..package.cpath
require "functions"
require "common"
require "log"