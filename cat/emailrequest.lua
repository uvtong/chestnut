local emailrequest = {}

local user

local emailbox 

function emailrequest:mails()
	local ret = {}
	ret.mail_list = {}
	local hasemail

   	 	for i , v in pairs( emailbox._data ) do
   	 		print("no value\n")
    		hasemail = true

    		local tmp = {}
    		tmp.attachs = {}
    			
    		tmp.emailid = v.id
    		tmp.type = v.type
    		tmp.acctime = os.date("%Y-%m-%d" , v.acctime)
    		tmp.isread = v.isread
    		tmp.isreward = v.isreward
    		tmp.title = v.title
    		tmp.content = v.content
    		
			tmp.attachs = v:getallitem()
			tmp.iconid = v.iconid
			
			--[[for i = 1 , 5 do
				local id = "itemsn" .. i
				local num = "itemnum" .. i
				print(v[id])
				print( string.format( "rid is %d" , v[id]) )
				if 0 ~= v[id] then
					local ni = itemtable._new()
					print("an attach is add in to the ret")
					ni.itemid = v[id]
					ni.itemnum = v[num]
					table.insert( tmp.attachs , ni )	
					print("insert succe in to a ret email\n")
				end
			end--]]

			table.insert( ret.mail_list , tmp )
    	end	

    	if hasemail then
    		ret.ok = true
    	else
    		ret.ok = false
    	end		
    	print("mails is called already\n")
    return  ret
end	
	
function emailrequest:mail_read()
	print( "reademail is called\n" )
	for k , v in pairs( emailbox._data ) do
		print( k ,v , type( v.id ) , v.id )
	end
	emailbox:reademail( user.id , self.mail_id )
end	
	
function emailrequest:mail_delete() 
	print("mail_delete is called\n")

	emailbox:deleteemail( user.id , self.mail_id )
end	
	
function emailrequest:mail_getreward()
	print("mail_getreward is called\n")

	emailbox:getreward( user.id , self.mail_id )
end

function emailrequest:mail_newemail( newemail )
end

function emailrequest.getvalue( u )
	user = u
	emailbox = user.emailbox
end

return emailrequest
