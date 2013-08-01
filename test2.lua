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
    if data == nil then
        return
    end

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
function eval(expr)
    return scheme.eval(expr, scheme.global_environment)
end

data_print(eval(read('#t')[1]))
data_print(eval(read('#\\a')[1]))
data_print(eval(read('"test string"')[1]))
data_print(eval(read('3.14159')[1]))

data_print(eval(read("'(test)")[1]))

data_print(eval(read('(set! var "hello, world")')[1]))
data_print(eval(read('(define cat "meow")')[1]))

data_print(eval(read('(if #t 3.14 "meow")')[1]))
data_print(eval(read('(if #f 3.14 "meow")')[1]))
data_print(eval(read('(if #f 3.14)')[1]))

data_print(eval(read('(if #f 3.14)')[1]))
data_print(eval(read('(lambda (arg0 arg1 arg2) (+ arg0 arg1 arg2))')[1]))
