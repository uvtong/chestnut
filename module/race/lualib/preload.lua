-- This file will execute before every lua service start
-- See config

package.path  = "./../../lualib/?.lua;"..package.path
package.cpath = "./../../luaclib/?.so;"..package.cpath
package.path  = "./../../module/mahjong/lualib/?.lua;"..package.path
require "init"
class = cc.class


-- print = function ( ... )
	-- body
	-- assert("please skynet.error instead of print.")
-- end