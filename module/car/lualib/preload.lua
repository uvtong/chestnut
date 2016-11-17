-- This file will execute before every lua service start
-- See config

package.path = "./../../module/car/?.lua;./../../module/car/lualib/?.lua;./../../lualib/?.lua;"..package.path
package.cpath = "./../../module/car/luaclib/?.so;./../../luaclib/?.so;"..package.cpath

require "init"
class = cc.class
