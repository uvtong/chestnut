package.path = "../host/lualib/?.lua;" .. package.path
package.cpath = "../host/luaclib/?.so;" .. package.cpath
local protobuf = require "protobuf"

addr = io.open("../host/c2s.pb","rb")
buffer = addr:read "*a"
addr:close()

protobuf.register(buffer)

t = protobuf.decode("google.protobuf.FileDescriptorSet", buffer)

proto = t.file[1]

print(proto.name)
print(proto.package)

message = proto.message_type

for _,v in ipairs(message) do
	print(_)
	print(v.name)
	for _,v in ipairs(v.field) do
		print("\t".. v.name .. " ["..v.number.."] " .. v.label)
	end
end

package = {
	tag = 2,
	type = "REQUEST",
	session = 4,
}

code = protobuf.encode("c2s.package", package)
print("package :", #code)
-- buffer = protobuf.pack("c2s.package tag type session", 3, "REQUEST", 4 )
-- print("package :", #buffer)

decode = protobuf.decode("c2s.package" , code)

print(decode.tag)
print(decode.type)
print(decode.session)

print(message[decode.tag].name)
msg = proto.package .. "." .. message[decode.tag].name .. " account password"
print(msg)
-- msg = "c2s.req_account account password"
buffer = protobuf.pack(msg, "Alice", "123")
print(protobuf.unpack("c2s.req_account account password", buffer))
