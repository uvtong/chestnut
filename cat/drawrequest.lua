package.path = "./../cat/?.lua;" .. package.path
    
local drawrequest = {}
local user
local drawmgr    	
local game
		
function drawrequest:draw()
	print( "applydraw is called ........................." )
    local ret = {}
    ret = drawmgr:applydraw( user , game )
    print( ret )
    return ret
end		
		
function drawrequest:applydraw( )
	print( "mydraw is called" )
	local ret = {}
	local t = {}
	t.drawtype = self.drawtype
	t.iffree = self.iffree
 	print( "drawtype is ..........." , self.drawtype )
	if 1 == self.drawtype then
		print( "frienddraw is called" )
		ret = drawmgr:frienddraw( t )
	elseif 2 == self.drawtype then
		print( "onetimedraw is called" )
		ret = drawmgr:onetimedraw( t )
	elseif 3 == self.drawtype then
		print( "tentimedraw is called" )
		ret = drawmgr:tentimedraw( t )
	else

	end
	print( "applydraw is called" )
	return ret
end	
	
function drawrequest.getvalue( u , g )
	assert( u )
	user = u 
	game = g
	drawmgr = user.drawmgr
	print( "load user successfully in drawrequest" )
end	
	
return drawrequest