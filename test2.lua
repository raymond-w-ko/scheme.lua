local scheme = require 'scheme'

function datum_print(datum)
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

function self_evaluating_test()
    data_print(eval(read('#t')[1]))
    data_print(eval(read('#\\a')[1]))
    data_print(eval(read('"test string"')[1]))
    data_print(eval(read('3.14159')[1]))
end

function quote_test()
    data_print(eval(read("'(test)")[1]))
end

function create_symbol_test()
    data_print(eval(read('(set! var "hello, world")')[1]))
    data_print(eval(read('(define cat "meow")')[1]))
end

function if_test()
    data_print(eval(read('(if #t 3.14 "meow")')[1]))
    data_print(eval(read('(if #f 3.14 "meow")')[1]))
    data_print(eval(read('(if #f 3.14)')[1]))
end

function lambda_test()
    data_print(eval(read('(lambda (arg0 arg1 arg2) (+ arg0 arg1 arg2))')[1]))
end

function begin_test()
    data_print(eval(read('(begin "cat")')[1]))
    data_print(eval(read('(begin "cat" "meow")')[1]))
end

function cond_test()
data_print(eval(read([[
(cond (else "cheeseburger"))
]])[1]))

data_print(eval(read([[
(cond (#t "cat")
      (else "cheeseburger"))
]])[1]))

data_print(eval(read([[
(cond (#f "cat")
      (else "cheeseburger"))
]])[1]))

data_print(eval(read([[
(cond (#f "cat")
      (#t "meow")
      (else "cheeseburger"))
]])[1]))

data_print(eval(read([[
(cond (#f "cat")
      (#t "meow"))
]])[1]))

data_print(eval(read([[
(cond (#f "cat")
      (#f "meow"))
]])[1]))

data_print(eval(read([[
(cond (#t "cat" "purr")
      (#t "meow" "purr")
      (#t "meow" "purr")
      (#t "meow" "purr")
      (#t "meow"))
]])[1]))

    data_print(eval(read([[
(cond (#f)
      ((+ 1 1))
      (#t "meow"))
    ]])[1]))

    data_print(eval(read([[
(cond (#f)
      ((+ 1 1) => (lambda (x) (+ 1000 x)))
      (else "pizza"))
    ]])[1]))

end

function let_test()
    data_print(eval(read([[
(let ((var0 "meow")
      (var1 "cat")
      (var2 "purr"))
  (print var0 var1 var2))
    ]])[1]))
end

function application_test()
    data_print(eval(read([[
(+ 1 2 3)
    ]])[1]))
end

self_evaluating_test()
quote_test()
create_symbol_test()
if_test()
lambda_test()
begin_test()
cond_test()
let_test()
application_test()

datum = nil
print('')
print('weak table test - nothing should appear except core symbols')
scheme.symbol.weak_cache['meow'] = {'test'}
collectgarbage('collect')
for k, v in pairs(scheme.symbol.weak_cache) do print(k .. ' -> ' .. tostring(v)) end
