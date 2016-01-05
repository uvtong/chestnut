local csvreader = require "csvReader"
local csvreader = require "skynet"

local csvcont = {}

csvcont = csvreader.getcont( "../csvfiles/data.csv" )
for i, v in ipair( csvcont ) do
	print( i, v )
end

