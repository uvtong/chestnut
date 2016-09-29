-- This file will execute before every lua service start
-- See config

package.path = "./../../lualib/?.lua;"..package.path
package.cpath = "./../crab/?.so;./../lua-cjson/?.so;./../lua-sharedata/?.so;./../lua-snapshot/?.so;./../lua-zset/?.so;./../../luaclib/?.so;"..package.cpath

require "init"
class = cc.class
-- print = function ( ... )
	-- body
	-- assert("please skynet.error instead of print.")
-- end