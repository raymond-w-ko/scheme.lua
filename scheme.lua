-- this is the main module in sheme.lua
-- do:
-- local scheme = require 'scheme'
-- to use this

local M = {}
M._error = function(msg)
    print(msg)
    assert(false)
end

local function MakeInstantiable(t)
    t.new = function()
        return setmetatable({}, {__index = t})
    end
end

--------------------------------------------------------------------------------
-- <boolean> atom
--------------------------------------------------------------------------------
M.boolean_mt = {}
function  M.boolean_mt.__tostring(t)
    if t.value == true then
        return '#t'
    elseif t.value == false then
        return '#f'
    else
        M._error('improperly initialized <boolean>')
    end
end

M.boolean = {}
function M.boolean.new(value)
    local t = {}
    t.type = 'boolean'
    if value == 't' then t.value = true
    elseif value == 'f' then t.value = false
    end
    return setmetatable(t, M.boolean_mt)
end

--------------------------------------------------------------------------------
-- <character> atom
--------------------------------------------------------------------------------
M.character_mt = {}
function M.character_mt.__tostring(t)
    if t.value == nil then
        M._error('improperly initialized <character>')
    end
    return '#\\' .. t.value
end

M.character = {}
function M.character.new(value)
    local t = {}
    t.type = 'character'
    t.value = value
    return setmetatable(t, M.character_mt)
end

--------------------------------------------------------------------------------
-- <string> atom
--------------------------------------------------------------------------------
M.string_mt = {}
function M.string_mt.__tostring(t)
    if t.value == nil then
        M._error('improperly initialized <string>')
    end
    return '"' .. t.value .. '"'
end

M.string = {}
function M.string.new(value)
    local t = {}
    t.type = 'string'
    t.value = value
    return setmetatable(t, M.string_mt)
end

M.unspecified_value = M.string.new('unspecified')

--------------------------------------------------------------------------------
-- <symbol> atom
--------------------------------------------------------------------------------
M.symbol_mt = {}
function M.symbol_mt.__tostring(t)
    if t.value == nil then
        M._error('improperly initialized <symbol>')
    end
    return t.value
end

M.symbol = {}
-- letters
M.symbol.letters = {}
for i = string.byte('a'), string.byte('z') do
    M.symbol.letters[string.char(i)] = true
end
for i = string.byte('A'), string.byte('Z') do
    M.symbol.letters[string.char(i)] = true
end
-- digits
M.symbol.digits = {}
for i = string.byte('0'), string.byte('9') do
    M.symbol.digits[string.char(i)] = true
end
-- special initials
M.symbol.special_initials = {}
M.symbol.special_initials['!'] = true
M.symbol.special_initials['$'] = true
M.symbol.special_initials['%'] = true
M.symbol.special_initials['&'] = true
M.symbol.special_initials['*'] = true
M.symbol.special_initials['/'] = true
M.symbol.special_initials[':'] = true
M.symbol.special_initials['<'] = true
M.symbol.special_initials['='] = true
M.symbol.special_initials['>'] = true
M.symbol.special_initials['?'] = true
M.symbol.special_initials['^'] = true
M.symbol.special_initials['_'] = true
M.symbol.special_initials['~'] = true
-- special subsequents
M.symbol.special_subsequents = {}
M.symbol.special_subsequents['+'] = true
M.symbol.special_subsequents['-'] = true
M.symbol.special_subsequents['.'] = true
M.symbol.special_subsequents['@'] = true

function M.symbol.new(value)
    local t = {}
    t.type = 'symbol'
    t.value = value
    return setmetatable(t, M.symbol_mt)
end

--------------------------------------------------------------------------------
-- <number> atom
--------------------------------------------------------------------------------
M.number_mt = {}
function M.number_mt.__tostring(t)
    return tostring(t.value)
end

M.number = {}
M.number.decimal_digits = {}
M.number.decimal_digits['0'] = true
M.number.decimal_digits['1'] = true
M.number.decimal_digits['2'] = true
M.number.decimal_digits['3'] = true
M.number.decimal_digits['4'] = true
M.number.decimal_digits['5'] = true
M.number.decimal_digits['6'] = true
M.number.decimal_digits['7'] = true
M.number.decimal_digits['8'] = true
M.number.decimal_digits['9'] = true

M.number.other_valid_characters = {}
M.number.other_valid_characters['+'] = true
M.number.other_valid_characters['-'] = true
M.number.other_valid_characters['/'] = true
M.number.other_valid_characters['i'] = true
M.number.other_valid_characters['@'] = true
M.number.other_valid_characters['.'] = true

M.number.other_valid_characters['e'] = true
M.number.other_valid_characters['s'] = true
M.number.other_valid_characters['d'] = true
M.number.other_valid_characters['f'] = true
M.number.other_valid_characters['l'] = true

M.number.other_valid_characters['#'] = true
M.number.other_valid_characters['i'] = true
M.number.other_valid_characters['#'] = true
M.number.other_valid_characters['e'] = true

M.number.other_valid_characters['b'] = true
M.number.other_valid_characters['o'] = true
M.number.other_valid_characters['d'] = true
M.number.other_valid_characters['x'] = true

M.number.other_valid_characters['a'] = true
M.number.other_valid_characters['b'] = true
M.number.other_valid_characters['c'] = true
M.number.other_valid_characters['d'] = true
M.number.other_valid_characters['e'] = true
M.number.other_valid_characters['f'] = true

function M.number.new(num)
    local t = {}
    t.type = 'number'
    t.value = num
    return setmetatable(t, M.number_mt)
end

--------------------------------------------------------------------------------
-- "pair", the basis for a list
--------------------------------------------------------------------------------
M.pair_mt = {}
M.pair = {}
M.pair_mt.__index = M.pair

function M.pair_mt.__tostring(t)
    if t:empty() then
        return '()'
    end

    local str = {}
    table.insert(str, '(')
    local pair = t

    local inner = {}
    while true do
        table.insert(inner, tostring(pair.car))
        if pair.cdr.type ~= 'pair' then
            table.insert(inner, '.')
            table.insert(inner, tostring(pair.cdr))
            break
        else
            if pair.cdr:empty() then
                break
            end
            pair = pair.cdr
        end
    end
    inner = table.concat(inner, ' ')
    table.insert(str, inner)

    table.insert(str, ')')
    return table.concat(str)
end

function M.pair.empty(t)
    return t.car == nil and t.cdr == nil
end

M.pair.new = function(car, cdr)
    local t = {}
    t.type = 'pair'
    t.car = car
    t.cdr = cdr
    return setmetatable(t, M.pair_mt)
end

--------------------------------------------------------------------------------
-- secret internal <dot> atom
--------------------------------------------------------------------------------
-- dot operator for pairs
M.dot_mt = {}
M.dot = {}
function M.dot_mt.__tostring(t)
    return '__DOT__'
end

function M.dot.new()
    local t = {}
    t.type = 'dot'
    return setmetatable(t, M.dot_mt)
end

--------------------------------------------------------------------------------
-- <vector>
--------------------------------------------------------------------------------
M.vector_mt = {}
function M.vector_mt.__tostring(t)
    local str = {}
    table.insert(str, '#(')
    local inner = {}
    for _, datum in ipairs(t.value) do
        table.insert(inner, tostring(datum))
    end
    table.insert(str, table.concat(inner, ' '))
    table.insert(str, ')')
    return table.concat(str)
end

M.vector = {}
function M.vector.new(lua_list)
    local t = {}
    t.type = 'vector'
    t.value = lua_list
    return setmetatable(t, M.vector_mt)
end

--------------------------------------------------------------------------------
-- <compound_proc> atom
--------------------------------------------------------------------------------
M.compound_proc_mt = {}
function M.compound_proc_mt.__tostring(t)
    local str = {}
    table.insert(str, '(lambda (')

    local formals = {}
    local pair = t.formals
    while pair.car do
        table.insert(formals, tostring(pair.car.value))
        pair = pair.cdr
    end
    table.insert(str, table.concat(formals, ' '))

    table.insert(str, ') <body>)')
    return table.concat(str)
end

M.compound_proc = {}
function M.compound_proc.new(formals, body, env)
    local t = {}
    t.type = 'compound_proc'
    t.formals = formals
    t.body = body
    t.env = env
    return setmetatable(t, M.compound_proc_mt)
end

--------------------------------------------------------------------------------
-- environment
--
-- Basically a linked list of linked lists. You check the tail linked list
-- first for the symbol name, and if you can't find it traverse backwards.
-- If you reach the head and still can't find the value, then the symbol
-- is not bound.
--
-- Since we are in Lua, we can easily use dictionaries instead of linear search.
--
-- This is not an explicit Scheme atom, but something that is implicit, so
-- capitalize
--------------------------------------------------------------------------------
M.Environment_mt = {}
function M.Environment_mt.lookup_symbol(t, symbol)
    if t.vars[symbol.value] ~= nil then
        return t.vars[symbol.value]
    elseif t.previous_env ~= nil then
        return M.Environment_mt.lookup_symbol(t.previous_env, symbol.value)
    else
        M._error('unbound symbol: ' .. symbol.value)
    end
end

function M.Environment_mt.define_symbol(t, symbol, value)
    if t.vars[symbol.value] ~= nil and t.previous_env ~= nil then
        M._error('symbol already bound in a non top level environment: ' .. symbol.name)
    else
        t.vars[symbol.value] = value
        return M.unspecified_value
    end
end

function M.Environment_mt.set_symbol(t, symbol, value)
    if t.vars[symbol.value] == nil and t.previous_env ~= nil then
        if t.previous_env then
            return M.Environment_mt.set_symbol(t.previous_env, symbol, value)
        else
            M._error('set! could not find bound symbol: ' .. symbol.value)
        end
    end

    t.vars[symbol.value] = value
    return M.unspecified_value
end

M.Environment = {}
function M.Environment.new(previous_env)
    local t = {}
    t.previous_env = previous_env
    t.vars = {}
    return setmetatable(t, {__index = M.Environment_mt})
end

-- the default outermost environment containing core functions and etc.
M.global_environment = M.Environment.new(nil)

--------------------------------------------------------------------------------
-- read
--------------------------------------------------------------------------------
local function SearchTillWhitespace(text, begin_index)
    while true do
        if (begin_index + 1) > #text then
            return begin_index
        end
        local ch = text:sub(begin_index + 1, begin_index + 1)
        if ch == '\t'  or ch == '\n' or ch == '\r' then
            return begin_index
        end
        if ch == ' ' then
            return begin_index + 1
        end
        begin_index = begin_index + 1
    end
end

function SearchTillNumberEnd(text, begin_index)
    while true do
        if (begin_index + 1) > #text then
            return begin_index
        end
        local ch = text:sub(begin_index + 1, begin_index + 1)
        if not M.number.decimal_digits[ch]
            and not M.number.other_valid_characters[ch] then
            return begin_index
        end
        begin_index = begin_index + 1
    end
end

local function SearchTillStringEnd(text, begin_index)
    local i = begin_index
    local str = {}
    while true do
        if i > #text then
            M._error('EOF reached when trying to find end string quote')
        end
        local ch = text:sub(i, i)
        if ch == '"' then
            break
        end
        if ch == '\\' then
            local nextch = text:sub(i + 1, i + 1)
            if nextch == '"' or nextch == '\\' then
                table.insert(str, nextch)
            else
                M._error('invalid character after backslash in string')
            end
            i = i + 2
        else
            table.insert(str, ch)
            i = i + 1
        end
    end

    return table.concat(str, ''), i
end

local whitespace_chars = {}
whitespace_chars[' '] = true
whitespace_chars['\t'] = true
whitespace_chars['\n'] = true
whitespace_chars['\r'] = true
local function IsWhitespace(ch)
    return whitespace_chars[ch]
end

local function IsSymbolInitial(ch)
    return M.symbol.letters[ch] or M.symbol.special_initials[ch]
end

local function ExtractSymbol(text, begin_index)
    local i = begin_index
    local name = {}
    table.insert(name, text:sub(i, i))
    i = i + 1
    while i <= #text do
        local ch = text:sub(i, i)
        if M.symbol.letters[ch]
            or M.symbol.special_initials[ch]
            or M.symbol.special_subsequents[ch]
            or M.symbol.digits[ch] then
            table.insert(name, ch)
        else
            break
        end
        i = i + 1
    end
    return table.concat(name), i - 1
end

local function BuildList(lua_list)
    local list = M.pair.new(nil, nil)
    local previous_pair = nil
    local current_pair = list
    local found_dot = false
    for i = 1, #lua_list do
        local datum = lua_list[i]
        if datum.type == 'dot' then
            found_dot = true
        else
            if found_dot then
                previous_pair.cdr = datum
                if i ~= #lua_list then
                    M._error('more <datum> found after dot in list')
                end

                break
            else
                current_pair.car = datum
                current_pair.cdr = M.pair.new(nil, nil)
                previous_pair = current_pair
                current_pair = current_pair.cdr
            end
        end
    end
    return list
end

local function DatumInsert(datum, data, prefix_stack)
    while #prefix_stack > 0 do
        local prefix = table.remove(prefix_stack)
        local meta_data = {}
        local expanded_abbrev
        if prefix == '\'' then
            expanded_abbrev = M.symbol.new('quote')
        elseif prefix == '`' then
            expanded_abbrev = M.symbol.new('quasiquote')
        elseif prefix == ',' then
            expanded_abbrev = M.symbol.new('unquote')
        elseif prefix == ',@' then
            expanded_abbrev = M.symbol.new('unquote-splicing')
        end
        table.insert(meta_data, expanded_abbrev)
        table.insert(meta_data, data)
        data = BuildList(meta_data)
    end
    table.insert(datum, data)
end

local function ParseSchemeNumber(text, i)
    local end_index = SearchTillNumberEnd(text, i)
    local number_string = text:sub(i, end_index)
    -- TODO: determine if this can be used
    local exactness = false
    local base = 10
    while number_string:sub(1, 1) == '#' do
        local prefix = number_string:sub(2, 2)
        assert(prefix)
        if prefix == 'i' then exactness = false
        elseif prefix == 'e' then exactness = true
        elseif prefix == 'b' then base = 2
        elseif prefix == 'o' then base = 8
        elseif prefix == 'd' then base = 10
        elseif prefix == 'x' then base = 16
        end
        number_string = number_string:sub(3)
    end

    local num = tonumber(number_string, base)
    if num == nil then
        M._error('failed to parse ' .. number_string .. ' as base ' .. base)
    end

    return num, end_index
end

function M.read(text)
    local k_number_prefixes = {}
    k_number_prefixes['i'] = true
    k_number_prefixes['e'] = true
    k_number_prefixes['b'] = true
    k_number_prefixes['o'] = true
    k_number_prefixes['d'] = true
    k_number_prefixes['x'] = true

    local line_number = 1

    local master_datum = {}
    local datum = master_datum
    local parent_datum_of = {}

    -- 0 indicates that parentheses are perfectly balanced,
    -- >0 mean there are too many '('s
    -- <0 mean there are too many ')'s
    local paren_balance = 0

    -- when making the next list, it should be a vector instead
    local is_next_list_a_vector = false
    local is_vector = {}

    -- ' or ` or , or ,@ was found, and the next datum will consume all of the
    -- prefixes in the stack, expanding to the unabbreviated prefix
    local prefix_stack = {}
    -- since we are aren't recursively parsing, this map is used to indicate
    -- the prefixes that a list or vector has consumed
    local prefix_stack_of_list = {}

    local i = 1
    while i <= #text do
        local ch = text:sub(i, i)

        if ch == '\t' or ch == ' ' or ch == '\r' then
            -- whitespace
            i = i + 1
        elseif ch == '\n' then
            -- whitespace
            i = i + 1
            line_number = line_number + 1
        elseif ch == '#' then
            -- '#' can be followed by a multitude of things
            if i + 1 > #text then
                M._error('expected more input after #')
            end

            local m = text:sub(i + 1, i + 1)
            if m == 't' or m == 'f' then
                -- boolean true
                local data = M.boolean.new(m)
                DatumInsert(datum, data, prefix_stack)
                prefix_stack = {}
                i = i + 2
            elseif k_number_prefixes[m] then
                local number, end_index = ParseSchemeNumber(text, i)
                local data = M.number.new(number)
                DatumInsert(datum, data, prefix_stack)
                i = end_index + 1
            elseif m == '\\' then
                -- characters
                if i + 2 > #text then
                    M._error('expected more input after #\\')
                end
                -- TODO: doesn't work in all cases, like where a paren follows,
                -- need to revise to be more robost
                local end_index = SearchTillWhitespace(text, i + 2)
                local character = text:sub(i + 2, end_index)
                if character:lower() == 'space' then
                    character = ' '
                elseif character:lower() == 'newline' then
                    character = '\n'
                end
                local data = M.character.new(character)
                DatumInsert(datum, data, prefix_stack)
                prefix_stack = {}
                i = end_index + 1
            elseif m == '(' then
                -- prefix to make next 'list' a 'vector'
                is_next_list_a_vector = true
                i = i + 1
            end
        elseif ch == '"' then
            -- string
            local str, end_index = SearchTillStringEnd(text, i + 1)
            local data = M.string.new(str)
            DatumInsert(datum, data, prefix_stack)
            prefix_stack = {}
            i = end_index + 1
        elseif ch == '+' or ch == '-' then
            -- peculiar symbol '+' and '-'
            if (i + 1) > #text or IsWhitespace(text:sub(i + 1, i + 1)) then
                local data = M.symbol.new(ch)
                DatumInsert(datum, data, prefix_stack)
                prefix_stack = {}
                i = i + 1
            elseif (i + 1) <= #text and M.number.decimal_digits[text:sub(i + 1, i + 1)] then
                local number, end_index = ParseSchemeNumber(text, i)
                local data = M.number.new(number)
                DatumInsert(datum, data, prefix_stack)
                i = end_index + 1
            else
                M._error('whitespace, EOF, or decimal digits must follow peculiar symbol: ' .. ch)
            end
        elseif M.number.decimal_digits[ch] then
            local number, end_index = ParseSchemeNumber(text, i)
            local data = M.number.new(number)
            DatumInsert(datum, data, prefix_stack)
            i = end_index + 1
        elseif ch == '.' then
            -- dot notation for Scheme pairs
            if IsWhitespace(text:sub(i + 1, i + 1)) then
                if is_vector[datum] then
                    M._error('dot operator meaningless in vector')
                end
                local data = M.dot.new()
                table.insert(datum, data)
                i = i + 1
            else
                -- peculiar symbol '...'
                if (i + 2) > #text then
                    M._error('"..." is the only valid symbol with prefix "."')
                end
                if text:sub(i, i + 2) ~= '...' then
                    M._error('"..." is the only valid symbol with prefix "."')
                end
                if not ((i + 4) > #text) and not IsWhitespace(text:sub(i + 4, i + 4)) then
                    M._error('"..." must be followed by whitespace or EOF')
                end
                local data = M.symbol.new('...')
                table.insert(datum, data)
                DatumInsert(datum, data, prefix_stack)
                prefix_stack = {}
                i = i + 4
            end
        elseif ch == '@' then
            M._error('symbols cannot start with "@"')
        elseif M.symbol.letters[ch] or M.symbol.special_initials[ch] then
            local symbol, end_index = ExtractSymbol(text, i)
            local data = M.symbol.new(symbol)
            DatumInsert(datum, data, prefix_stack)
            prefix_stack = {}
            i = end_index + 1
        elseif ch == '\'' or ch == '`' or ch == ',' then
            if (i + 1) > #text then
                M._error('expected more input after ' .. ch)
            end
            local m = text:sub(i + 1, i + 1)
            local prefix
            if ch == ',' and m == '@' then
                if (i + 2) > #text then
                    M._error('expected more input after ,@')
                end
                prefix = ',@'
                i = i + 2
            else
                prefix = ch
                i = i + 1
            end
            table.insert(prefix_stack, prefix)
        elseif ch == '(' then
            local new_datum = {}
            parent_datum_of[new_datum] = datum
            datum = new_datum

            -- check to see if this should be a vector instead
            is_vector[datum] = is_next_list_a_vector
            is_next_list_a_vector = false

            -- consume prefix_stack
            prefix_stack_of_list[datum] = prefix_stack
            prefix_stack = {}

            i = i + 1
            paren_balance = paren_balance + 1
        elseif ch == ')' then
            if paren_balance <= 0 then
                M._error('one or more ")" detected')
            end
            local prelist = datum
            -- restore previous datum
            datum = parent_datum_of[datum]

            -- decide whether to build a vector or a list
            if is_vector[prelist] then
                is_vector[prelist] = nil
                local scheme_vector = M.vector.new(prelist)
                DatumInsert(datum, scheme_vector, prefix_stack_of_list[prelist])
                prefix_stack_of_list[prelist] = nil
            else
                local scheme_list = BuildList(prelist)
                DatumInsert(datum, scheme_list, prefix_stack_of_list[prelist])
                prefix_stack_of_list[prelist] = nil
            end
            i = i + 1

            paren_balance = paren_balance - 1
        else
            print(tostring(ch))
            assert(false)
        end
    end

    if paren_balance ~= 0 then
        M._error('unclosed "(" detected')
    end

    return datum
end

--------------------------------------------------------------------------------
-- eval
--
-- adapted from
-- metacircular evaluator in SICP
-- http://mitpress.mit.edu/sicp/full-text/sicp/book/node77.html
-- and
-- https://github.com/petermichaux/bootstrap-scheme/blob/v0.21/scheme.c
--------------------------------------------------------------------------------

local self_evaluating_types = {}
self_evaluating_types['boolean'] = true
self_evaluating_types['character'] = true
self_evaluating_types['string'] = true
self_evaluating_types['number'] = true
function M.is_self_evaluating(expr)
    return self_evaluating_types[expr.type]
end

function M.is_variable(expr)
    return expr.type == 'symbol'
end

function M.lookup_variable_value(expr, env)
    return env:lookup_symbol(expr)
end

function M.is_symbol_named(expr, name)
    if expr.type == 'pair' and expr.car and expr.car.type == 'symbol' then
        if expr.car.value == name then
            return true
        end
    end

    return false
end

function M.is_quoted(expr) return M.is_symbol_named(expr, 'quote') end
function M.is_assignment(expr) return M.is_symbol_named(expr, 'set!') end
function M.is_definition(expr) return M.is_symbol_named(expr, 'define') end
function M.is_if(expr) return M.is_symbol_named(expr, 'if') end
function M.is_lambda(expr) return M.is_symbol_named(expr, 'lambda') end
function M.is_begin(expr) return M.is_symbol_named(expr, 'begin') end

function M.eval(expr, env, proc, arguments, result)
    assert(expr)
    assert(env)

    if M.is_self_evaluating(expr) then
        return expr
    elseif M.is_variable(expr) then
        return M.lookup_variable_value(expr, env)
    elseif M.is_quoted(expr) then
        return expr.cdr.car
    elseif M.is_assignment(expr) then
        local symbol = expr.cdr.car
        local value = M.eval(expr.cdr.cdr.car, env)
        return env:set_symbol(symbol, value)
    elseif M.is_definition(expr) then
        local arg0 = expr.cdr.car
        local arg1 = expr.cdr.cdr.car
        if arg0.type == 'symbol' then
            return env:define_symbol(arg0, M.eval(arg1, env))
        elseif symbol.type == 'pair' then
            -- TODO (define ...) for functions
        end
    elseif M.is_if(expr) then
        local test = expr.cdr.car
        local consequent = expr.cdr.cdr.car
        local alternate = nil
        if not expr.cdr.cdr.cdr:empty() then
            alternate = expr.cdr.cdr.cdr.car
        end

        local result = M.eval(test, env)
        if result.type == 'boolean' and result.value == false then
            if alternate then
                return M.eval(alternate, env)
            else
                return M.unspecified_value
            end
        else
            return M.eval(consequent, env)
        end
    elseif M.is_lambda(expr) then
        local formals = expr.cdr.car
        local body = expr.cdr.cdr.car
        return M.compound_proc.new(formals, body, env)
    elseif M.is_begin(expr) then
        local pair = expr.cdr
        while not pair.cdr:empty() do
            M.eval(pair.car, env)
            pair = pair.cdr
        end
        return M.eval(pair.car, env)
    else
        M._error('unable to eval expr of type: ' .. expr.type)
    end
end

return M
