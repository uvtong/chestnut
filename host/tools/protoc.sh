protoc -oc2s.pb c2s.proto
cp c2s.pb ../c2s.pb
protoc -os2c.pb s2c.proto
cp s2c.pb ../s2c.pb