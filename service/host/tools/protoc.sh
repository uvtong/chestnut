protoc -oc2s.pb --cpp_out=./ c2s.proto
cp c2s.pb ../c2s.pb
protoc -os2c.pb --cpp_out=./ s2c.proto
cp s2c.pb ../s2c.pb