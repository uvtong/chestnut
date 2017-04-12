-- This file will execute before every lua service start
-- See config

package.path = "./../../module/ball/?.lua;./../../module/ball/lualib/?.lua;./../../lualib/?.lua;"..package.path
package.cpath = "./../../module/ball/luaclib/?.so;./../../luaclib/?.so;"..package.cpath

require "init"
class = cc.class
-- print = function ( ... )
	-- body
	-- assert("please skynet.error instead of print.")
-- end