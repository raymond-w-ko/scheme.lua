-- this is the main module in sheme.lua
-- do:
-- local scheme = require 'scheme'
-- to use this
require 'strict'

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
M.boolean = {}
M.boolean.mt = {}
function  M.boolean.mt.__tostring(t)
    if t.value == true then
        return '#t'
    elseif t.value == false then
        return '#f'
    else
        M._error('improperly initialized <boolean>')
    end
end
function M.boolean.new(value)
    local t = {}
    t.type = 'boolean'
    if value == 't' then t.value = true
    elseif value == 'f' then t.value = false
    end
    return setmetatable(t, M.boolean.mt)
end

M.true_boolean = M.boolean.new('t')
M.false_boolean = M.boolean.new('f')

function M.create_boolean(value)
    if value == 't' then
        return M.true_boolean
    elseif value == 'f' then
        return M.false_boolean
    else
        M._error('create_boolean() only "t" or "f"')
    end
end

--------------------------------------------------------------------------------
-- <character> atom
--------------------------------------------------------------------------------
M.character = {}
M.character.chars = {}
-- TODO: add more character names
M.character.chars['newline'] = '\n'
M.character.chars['linefeed'] = '\n'
M.character.chars['return'] = '\r'
M.character.chars['space'] = ' '
M.character.chars['tab'] = '\t'
M.character.mt = {}
function M.character.mt.__tostring(t)
    if t.value == nil then
        M._error('improperly initialized <character>')
    end
    return '#\\' .. t.value
end

function M.character.new(value)
    local t = {}
    t.type = 'character'
    t.value = value
    return setmetatable(t, M.character.mt)
end

--------------------------------------------------------------------------------
-- <string> atom
--------------------------------------------------------------------------------
M.string = {}
M.string.mt = {}
function M.string.mt.__tostring(t)
    if t.value == nil then
        M._error('improperly initialized <string>')
    end
    return '"' .. t.value .. '"'
end

function M.string.new(value)
    local t = {}
    t.type = 'string'
    t.value = value
    return setmetatable(t, M.string.mt)
end

M.unspecified_value = M.string.new('unspecified')

--------------------------------------------------------------------------------
-- <symbol> atom
--------------------------------------------------------------------------------
M.symbol = {}
M.symbol.mt = {}
function M.symbol.mt.__tostring(t)
    if t.value == nil then
        M._error('improperly initialized <symbol>')
    end
    return t.value
end

M.symbol.weak_cache = {}
setmetatable(M.symbol.weak_cache, {__mode = 'v'})

function M.symbol.new(value)
    local t = {}
    t.type = 'symbol'
    t.value = value
    return setmetatable(t, M.symbol.mt)
end

function M.create_symbol(identifier)
    local symbol = M.symbol.weak_cache[identifier]
    if symbol then
        return symbol
    end

    symbol = M.symbol.new(identifier)
    M.symbol.weak_cache[identifier] = symbol
    return symbol
end

local gensym_symbol_counter = 9001
function M.gensym(prefix)
    prefix = prefix or 'G__'
    local name = prefix .. gensym_symbol_counter
    gensym_symbol_counter = gensym_symbol_counter + 1
    return M.create_symbol(name)
end

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

M.quote_symbol = M.create_symbol('quote')
M.define_symbol = M.create_symbol('define')
M.set_symbol = M.create_symbol('set!')
M.if_symbol = M.create_symbol('if')
M.lambda_symbol = M.create_symbol('lambda')
M.begin_symbol = M.create_symbol('begin')
M.cond_symbol = M.create_symbol('cond')
M.else_symbol = M.create_symbol('else')
M.let_symbol = M.create_symbol('let')
M.and_symbol = M.create_symbol('and')
M.or_symbol = M.create_symbol('or')

--------------------------------------------------------------------------------
-- <number> atom
--------------------------------------------------------------------------------
M.number = {}
M.number.mt = {}
function M.number.mt.__tostring(t)
    return tostring(t.value)
end

function M.number.new(num)
    local t = {}
    t.type = 'number'
    t.value = num
    return setmetatable(t, M.number.mt)
end

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

--------------------------------------------------------------------------------
-- "pair", the basis for a list
--------------------------------------------------------------------------------
M.pair = {}
M.pair.mt = {}
M.pair.mt.__index = M.pair

function M.pair.mt.__tostring(t)
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
    return setmetatable(t, M.pair.mt)
end

--------------------------------------------------------------------------------
-- secret internal <dot> atom
--------------------------------------------------------------------------------
-- dot operator for pairs
M.dot = {}
M.dot.mt = {}

function M.dot.mt.__tostring(t)
    return '__DOT__'
end

function M.dot.new()
    local t = {}
    t.type = 'dot'
    return setmetatable(t, M.dot.mt)
end

--------------------------------------------------------------------------------
-- <vector>
--------------------------------------------------------------------------------
M.vector = {}
M.vector.mt = {}

function M.vector.mt.__tostring(t)
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

function M.vector.new(lua_list)
    local t = {}
    t.type = 'vector'
    t.value = lua_list
    return setmetatable(t, M.vector.mt)
end

--------------------------------------------------------------------------------
-- <primitive_proc> atom
--------------------------------------------------------------------------------
M.primitive_proc = {}
M.primitive_proc.mt = {}
function M.primitive_proc.mt__tostring(t)
    return tostring(t.fn)
end

function M.primitive_proc.new(fn)
    local t = {}
    t.type = 'primitive_proc'
    t.fn = fn
    return setmetatable(t, M.primitive_proc.mt)
end

--------------------------------------------------------------------------------
-- <compound_proc> atom
--------------------------------------------------------------------------------
M.compound_proc = {}
M.compound_proc.mt = {}
function M.compound_proc.mt.__tostring(t)
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

function M.compound_proc.new(formals, body, env)
    local t = {}
    t.type = 'compound_proc'
    t.formals = formals
    t.body = body
    t.env = env
    return setmetatable(t, M.compound_proc.mt)
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
M.Environment = {}
M.Environment.mt = {}
function M.Environment.mt.lookup_symbol(t, symbol)
    if t.vars[symbol.value] ~= nil then
        return t.vars[symbol.value]
    elseif t.previous_env ~= nil then
        return M.Environment.mt.lookup_symbol(t.previous_env, symbol)
    else
        M._error('unbound symbol: ' .. symbol.value)
    end
end

function M.Environment.mt.define_symbol(t, symbol, value)
    if t.vars[symbol.value] ~= nil and t.previous_env ~= nil then
        M._error('symbol already bound in a non top level environment: ' .. symbol.name)
    else
        t.vars[symbol.value] = value
        return M.unspecified_value
    end
end

function M.Environment.mt.set_symbol(t, symbol, value)
    if t.vars[symbol.value] == nil and t.previous_env ~= nil then
        if t.previous_env then
            return M.Environment.mt.set_symbol(t.previous_env, symbol, value)
        else
            M._error('set! could not find bound symbol: ' .. symbol.value)
        end
    end

    t.vars[symbol.value] = value
    return M.unspecified_value
end

function M.Environment.__tostring(t)
    local str = {}
    for symbol_name, object in pairs(t.vars) do
        table.insert(str, symbol_name .. ' -> ' .. tostring(object))
    end
    return table.concat(str, '\n')
end

function M.Environment.debug_print(t)
end

function M.Environment.new(previous_env)
    local t = {}
    t.previous_env = previous_env
    t.vars = {}
    return setmetatable(t, {__index = M.Environment.mt, __tostring = M.Environment.__tostring})
end

-- the default outermost environment containing core functions and etc.
M.global_environment = M.Environment.new(nil)

--------------------------------------------------------------------------------
-- read
--------------------------------------------------------------------------------
local function SearchTillNonLetter(text, begin_index)
    while true do
        -- EOF
        if (begin_index + 1) > #text then
            return begin_index
        end
        local ch = text:sub(begin_index + 1, begin_index + 1)
        if not M.symbol.letters[ch] then
            return begin_index
        end
        begin_index = begin_index + 1
    end
end

function SearchTillNumberEnd(text, begin_index)
    while true do
        -- EOF
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

function M.BuildList(lua_list)
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
            expanded_abbrev = M.create_symbol('quote')
        elseif prefix == '`' then
            expanded_abbrev = M.create_symbol('quasiquote')
        elseif prefix == ',' then
            expanded_abbrev = M.create_symbol('unquote')
        elseif prefix == ',@' then
            expanded_abbrev = M.create_symbol('unquote-splicing')
        end
        table.insert(meta_data, expanded_abbrev)
        table.insert(meta_data, data)
        data = M.BuildList(meta_data)
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
                local data = M.create_boolean(m)
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
                local end_index = SearchTillNonLetter(text, i + 2)
                local ch = text:sub(i + 2, end_index)
                if ch:len() > 1 then
                    local single_ch = M.character.chars[ch]
                    if single_ch then
                        ch = single_ch
                    end
                end
                local data = M.character.new(ch)
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
                local data = M.create_symbol(ch)
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
                local data = M.create_symbol('...')
                DatumInsert(datum, data, prefix_stack)
                prefix_stack = {}
                i = i + 4
            end
        elseif ch == '@' then
            M._error('symbols cannot start with "@"')
        elseif M.symbol.letters[ch] or M.symbol.special_initials[ch] then
            local symbol, end_index = ExtractSymbol(text, i)
            local data = M.create_symbol(symbol)
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
                local scheme_list = M.BuildList(prelist)
                DatumInsert(datum, scheme_list, prefix_stack_of_list[prelist])
                prefix_stack_of_list[prelist] = nil
            end
            i = i + 1

            paren_balance = paren_balance - 1
        else
            print('read() encountered unexpected character')
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

function M.last_expr(expr)
    return expr.cdr:empty()
end

function M.sequence_to_expr(seq)
    if seq.type ~= 'pair' then
        return seq
    elseif seq:empty() then
        return seq
    elseif M.last_expr(seq) then
        return seq.car
    else
        local pair = M.pair.new(M.create_symbol('begin'), seq)
        return pair
    end
end

function M.make_if(predicate, consequent, alternate)
    local expr = {}
    table.insert(expr, M.create_symbol('if'))
    table.insert(expr, predicate)
    table.insert(expr, consequent)
    if not (alternate.type == 'pair' and alternate:empty()) then
        table.insert(expr, alternate)
    end
    return M.BuildList(expr)
end

-- TODO implement (condition => expression) form
function M.cond_to_if(expr)
    local function cond_clauses(expr) return expr.cdr end
    local function cond_predicate(clause) return clause.car end
    local function cond_actions(clause)
        return clause.cdr
    end

    local function cond_else_clause(expr)
        return cond_predicate(expr) == M.else_symbol
    end
    local function expand_clauses(clauses)
        assert(clauses.type == 'pair')
        if clauses:empty() then
            return M.unspecified_value
        else
            local first = clauses.car
            local rest = clauses.cdr
            if cond_else_clause(first) then
                if rest:empty() then
                    return M.sequence_to_expr(cond_actions(first))
                else
                    M._error('ELSE clause is not last in (cond ...)')
                end
            else
                local bindings = {}
                local predicate = cond_predicate(first)
                local consequent = cond_actions(first)
                if consequent:empty() then
                    -- check if expr is missing in clause
                    -- e.g. (cond (test)) instead of (cond (test expr))
                    local binding = {}
                    local symbol = M.gensym()
                    table.insert(binding, symbol)
                    table.insert(binding, predicate)
                    binding = M.BuildList(binding)
                    table.insert(bindings, binding)
                    consequent = symbol
                    predicate = symbol
                elseif consequent.type == 'pair'
                    -- check if using special => form
                    -- e.g. (cond (test => expr)) instead of (cond (test expr))
                    and consequent.car.type == 'symbol'
                    and consequent.car.value == '=>' then
                    local binding = {}
                    local symbol = M.gensym()
                    table.insert(binding, symbol)
                    table.insert(binding, predicate)
                    binding = M.BuildList(binding)
                    table.insert(bindings, binding)

                    predicate = symbol
                    local application = M.pair.new(symbol, M.pair.new())
                    application = M.pair.new(consequent.cdr.car, application)
                    consequent = M.BuildList({application})
                end

                local transformed_expr = M.make_if(
                    predicate,
                    M.sequence_to_expr(consequent),
                    expand_clauses(rest))

                if #bindings > 0 then
                    local let_wrapper = {}
                    table.insert(let_wrapper, M.create_symbol('let'))
                    table.insert(let_wrapper, M.BuildList(bindings))
                    table.insert(let_wrapper, transformed_expr)
                    return M.BuildList(let_wrapper)
                else
                    return transformed_expr
                end
            end
        end
    end

    return expand_clauses(cond_clauses(expr))
end

function M.list_of_values(expr, env)
    if expr:empty() then
        return M.pair.new(nil, nil)
    else
        return M.pair.new(
            M.eval(expr.car, env),
            M.list_of_values(expr.cdr, env))
    end
end

function M.prepare_apply_operands(arguments)
    if arguments.cdr:empty() then
        return arguments.car
    else
        return M.pair.new(
            arguments.car,
            M.prepare_apply_operands(arguments.cdr))
    end
end

function M.make_begin(seq)
    return M.pair.new(M.create_symbol('begin'), seq)
end

function M.extend_environment(formals, arguments, previous_env)
    local env = M.Environment.new(previous_env)
    while formals.car do
        env:define_symbol(formals.car, arguments.car)
        -- advance
        formals = formals.cdr
        arguments = arguments.cdr
    end
    return env
end

function M.eval(expr, env)
    assert(expr and env)

    local operator
    if expr.type == 'pair' and expr.car and expr.car.type == 'symbol' then
        operator = expr.car
    end

    if M.is_self_evaluating(expr) then
        return expr
    elseif M.is_variable(expr) then
        return M.lookup_variable_value(expr, env)
    elseif operator == M.quote_symbol then
        return expr.cdr.car
    elseif operator == M.set_symbol then
        local symbol = expr.cdr.car
        local value = M.eval(expr.cdr.cdr.car, env)
        return env:set_symbol(symbol, value)
    elseif operator == M.define_symbol then
        local arg0 = expr.cdr.car
        local arg1 = expr.cdr.cdr.car
        if arg0.type == 'symbol' then
            return env:define_symbol(arg0, M.eval(arg1, env))
        elseif symbol.type == 'pair' then
            -- TODO (define ...) for functions
        end
    elseif operator == M.if_symbol then
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
    elseif operator == M.lambda_symbol then
        local formals = expr.cdr.car
        local body = expr.cdr.cdr
        return M.compound_proc.new(formals, body, env)
    elseif operator == M.begin_symbol then
        local pair = expr.cdr
        while not pair.cdr:empty() do
            M.eval(pair.car, env)
            pair = pair.cdr
        end
        return M.eval(pair.car, env)
    elseif operator == M.cond_symbol then
        local transformed_expr = M.cond_to_if(expr)
        --print(transformed_expr)
        return M.eval(transformed_expr, env)
    elseif operator == M.let_symbol then
        local vars = expr.cdr.car
        local body = expr.cdr.cdr.car

        local var_list = {}
        local exp_list = {}
        local pair = vars
        while pair.car do
            local var = pair.car.car
            local expr = pair.car.cdr.car
            table.insert(var_list, var)
            table.insert(exp_list, expr)
            pair = pair.cdr
        end

        local lambda_expr = {}
        table.insert(lambda_expr, M.create_symbol('lambda'))
        table.insert(lambda_expr, M.BuildList(var_list))
        table.insert(lambda_expr, body)

        local transformed_expr = {}
        table.insert(transformed_expr, M.BuildList(lambda_expr))
        for _, exp in ipairs(exp_list) do
            table.insert(transformed_expr, exp)
        end

        transformed_expr = M.BuildList(transformed_expr)
        --print(transformed_expr)
        return M.eval(transformed_expr, env)
    elseif operator == M.and_symbol then
        local test = expr.cdr
        if test:empty() then
            return M.true_boolean
        end
        while not test.cdr:empty() do
            local result = M.eval(test.car, env)
            if result == M.false_boolean then
                return result
            end
            test = test.cdr
        end
        return M.eval(test.car, env)
    elseif operator == M.or_symbol then
        local test = expr.cdr
        if test:empty() then
            return M.false_boolean
        end
        while not test.cdr:empty() do
            local result = M.eval(test.car, env)
            if result ~= M.false_boolean then
                return result
            end
            test = test.cdr
        end
        return M.eval(test.car, env)
    elseif expr.type == 'pair' then
        -- (function ...)
        local procedure = M.eval(expr.car, env)
        local arguments = M.list_of_values(expr.cdr, env)

        if procedure.type == 'primitive_proc'
            and procedure.fn == M.eval then
            return M.eval(arguments.car, arguments.cdr.car)
        end

        if procedure.type == 'primitive_proc'
            and procedure.fn == M.apply then
            procedure = arguments.car
            arguments = M.prepare_apply_operands(arguments.cdr)
        end

        if procedure.type == 'primitive_proc' then
            return procedure.fn(arguments)
        elseif procedure.type == 'compound_proc' then
            local new_expr = M.make_begin(procedure.body)
            local new_env = M.extend_environment(
                procedure.formals,
                arguments,
                procedure.env)
            return M.eval(new_expr, new_env)
        else
            M._error('could not evaluate procedure of type: ' .. procedure.type)
        end
    else
        M._error('unable to eval expresson of type: ' .. expr.type .. ' and value: ' .. tostring(expr.value))
    end
end

function M.apply()
end

--------------------------------------------------------------------------------
-- primitive functions
--------------------------------------------------------------------------------
M.primitive_symbols = {}
local function register_primitive(symbol_name, fn)
    local symbol = M.create_symbol(symbol_name)
    local primitive_proc = M.primitive_proc.new(fn)
    M.global_environment:define_symbol(symbol, primitive_proc)
    M.primitive_symbols[symbol] = primitive_proc
end

-- (eval)
register_primitive('eval', M.eval)

local function prim_apply()
    M._error('apply primitive should never be directly called')
    assert(false)
end
register_primitive('apply', M.apply)

-- (print)
local function prim_print(args)
    local str = {}
    while args.car do
        table.insert(str, args.car.value)
        args = args.cdr
    end

    print(table.concat(str, ' '))

    return M.unspecified_value
end
register_primitive('print', prim_print)

-- (+)
local function prim_add(args)
    local sum = 0
    while args.car do
        sum = sum + args.car.value
        args = args.cdr
    end

    return M.number.new(sum)
end
register_primitive('+', prim_add)

return M
