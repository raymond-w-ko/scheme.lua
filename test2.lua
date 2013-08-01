local scheme = require 'scheme'

function datum_print(datum)
    io.write('---\n')
    for _, data in ipairs(datum) do
        io.write('type: ' .. data.type)
        io.write(' , ')
        io.write('value: ' .. tostring(data.value))
        io.write(' , ')
        io.write('tostring: ' .. tostring(data))
        io.write('\n')
    end
end

function data_print(data)
    io.write('---\n')
    io.write('type: ' .. data.type)
    io.write(' , ')
    io.write('value: ' .. tostring(data.value))
    io.write(' , ')
    io.write('tostring: ' .. tostring(data))
    io.write('\n')
end

local datum

local read = scheme.read
local eval = scheme.eval

data_print(eval(read('#t')[1]))
data_print(eval(read('#\\a')[1]))
data_print(eval(read('"test string"')[1]))
data_print(eval(read('3.14159')[1]))
