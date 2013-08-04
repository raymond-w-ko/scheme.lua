local scheme = require 'scheme'

local function test(input, output)
    local datum = scheme.read(input)[1]
    local result = tostring(scheme.eval(datum, scheme.global_environment))
    if result ~= output then
        print('input:\n' .. tostring(datum))
        print('got:\n' .. result)
        print('expected:\n' .. output)
        assert(false)
    else
        return true
    end
end

-- type test

test('(boolean? #t)', '#t')
test('(boolean? #f)', '#t')
test('(boolean? 1234)', '#f')
test('(boolean? #\\a)', '#f')
test("(boolean? '())", '#f')

test("(symbol? 'asdf)", '#t')
test("(symbol? 'cat)", '#t')
test("(symbol? '())", '#f')
test("(symbol? 1234)", '#f')
test("(symbol? symbol?)", '#f')

test('(char? #\\a)', '#t')
test('(char? "cat")', '#f')
test('(char? #f)', '#f')
test("(char? '())", '#f')

test("(vector? #())", '#t')
test("(vector? '())", '#f')
test('(vector? "test")', '#f')

test("(pair? '())", '#t')
test("(pair? #())", '#f')
test('(pair? "test")', '#f')

test('(define proc1 (lambda (x) (+ 1 x)))', '"unspecified"')
test("(procedure? +)", '#t')
test("(procedure? proc1)", '#t')
test("(procedure? 1234)", '#f')

test("(number? 1234)", '#t')
test('(number? "1234")', '#f')

test('(string? "1234")', '#t')
test("(string? 1234)", '#f')

-- TODO: add other type checking as it is pretty hard to mess up
