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
M.boolean_mt = {
    __tostring = function(t)
        if t.value == true then
            return '#t'
        elseif t.value == false then
            return '#f'
        else
            M._error('improperly initialized <boolean>')
        end
    end
}
M.boolean = {
    new = function(value)
        local t = {}
        t.type = 'boolean'
        if value == 't' then t.value = true
        elseif value == 'f' then t.value = false
        end
        return setmetatable(t, M.boolean_mt)
    end
}

--------------------------------------------------------------------------------
-- <character> atom
--------------------------------------------------------------------------------
M.character_mt = {
    __tostring = function(t)
        if t.value == nil then
            M._error('improperly initialized <character>')
        end
        return '#\\' .. t.value
    end
}

M.character = {
    new = function(value)
        local t = {}
        t.type = 'character'
        t.value = value
        return setmetatable(t, M.character_mt)
    end
}

--------------------------------------------------------------------------------
-- <string> atom
--------------------------------------------------------------------------------
M.string_mt = {
    __tostring = function(t)
        if t.value == nil then
            M._error('improperly initialized <string>')
        end
        return '"' .. t.value .. '"'
    end
}

M.string = {
    new = function(value)
        local t = {}
        t.type = 'string'
        t.value = value
        return setmetatable(t, M.string_mt)
    end
}

--------------------------------------------------------------------------------
-- <identifier> atom
--------------------------------------------------------------------------------
M.identifer_mt = {
    __tostring = function(t)
        if t.value == nil then
            M._error('improperly initialized <identifier>')
        end
        return t.value
    end
}

M.identifier = {
    letters = {},
    special_initials = {},
    special_subsequents = {},
    digits = {},
    new = function(value)
        local t = {}
        t.type = 'identifier'
        t.value = value
        return setmetatable(t, M.identifer_mt)
    end
}
-- letters
for i = string.byte('a'), string.byte('z') do
    M.identifier.letters[string.char(i)] = true
end
for i = string.byte('A'), string.byte('Z') do
    M.identifier.letters[string.char(i)] = true
end
-- digits
for i = string.byte('0'), string.byte('9') do
    M.identifier.digits[string.char(i)] = true
end
-- special initials
M.identifier.special_initials['!'] = true
M.identifier.special_initials['$'] = true
M.identifier.special_initials['%'] = true
M.identifier.special_initials['&'] = true
M.identifier.special_initials['*'] = true
M.identifier.special_initials['/'] = true
M.identifier.special_initials[':'] = true
M.identifier.special_initials['<'] = true
M.identifier.special_initials['='] = true
M.identifier.special_initials['>'] = true
M.identifier.special_initials['?'] = true
M.identifier.special_initials['^'] = true
M.identifier.special_initials['_'] = true
M.identifier.special_initials['~'] = true
-- special subsequents
M.identifier.special_subsequents['+'] = true
M.identifier.special_subsequents['-'] = true
M.identifier.special_subsequents['.'] = true
M.identifier.special_subsequents['@'] = true

-- "pair", the basis for a list
M.pair_mt = {
    --[[
    __tostring = function(t)
        if t:empty() then
            return '()'
        end

        local str = {}
        table.insert(str, '(')
        if t.car then
            table.insert(str, tostring(t.car))
        end
        table.insert(str, ' . ')
        if t.cdr then
            table.insert(str, tostring(t.cdr))
        else
            table.insert(str, '()')
        end
        table.insert(str, ')')
        return table.concat(str)
    end
    --]]
    __tostring = function(t)
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
}
M.pair = {
    empty = function(t)
        return t.car == nil and t.cdr == nil
    end
    ,
    new = function(car, cdr)
        local t = {}
        t.type = 'pair'
        t.car = car
        t.cdr = cdr
        return setmetatable(t, M.pair_mt)
    end
}
M.pair_mt.__index = M.pair

-- dot operator for pairs
M.dot_mt = {
    __tostring = function(t)
        return '__DOT__'
    end
}
M.dot = {
    new = function()
        local t = {}
        t.type = 'dot'
        return setmetatable(t, M.dot_mt)
    end
}

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

local function IsIdentifierInitial(ch)
    return M.identifier.letters[ch] or M.identifier.special_initials[ch]
end

local function ExtractIdentifier(text, begin_index)
    local i = begin_index
    local name = {}
    table.insert(name, text:sub(i, i))
    i = i + 1
    while i <= #text do
        local ch = text:sub(i, i)
        if M.identifier.letters[ch]
            or M.identifier.special_initials[ch]
            or M.identifier.special_subsequents[ch]
            or M.identifier.digits[ch] then
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

function M.read(text)
    local line_number = 1
    local master_datum = {}
    local datum = master_datum
    local parent_datum_of = {}
    local i = 1
    local len = #text
    local paren_balance = 0

    while i <= len do
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
            if i + 1 > len then
                M._error('expected more input after #')
            end

            local m = text:sub(i + 1, i + 1)

            if m == 't' or m == 'f' then
                -- boolean true
                local data = M.boolean.new(m)
                table.insert(datum, data)
                i = i + 2
            elseif m == '\\' then
                -- characters
                if i + 2 > len then
                    M._error('expected more input after #\\')
                end
                local end_index = SearchTillWhitespace(text, i + 2)
                local character = text:sub(i + 2, end_index)
                if character:lower() == 'space' then
                    character = ' '
                elseif character:lower() == 'newline' then
                    character = '\n'
                end
                assert(character)
                local data = M.character.new(character)
                table.insert(datum, data)
                i = end_index + 1
            end
        elseif ch == '"' then
            -- string
            local str, end_index = SearchTillStringEnd(text, i + 1)
            local data = M.string.new(str)
            table.insert(datum, data)
            i = end_index + 1
        elseif ch == '+' or ch == '-' then
            -- peculiar identifier '+' and '-'
            if (i + 1) > #text or IsWhitespace(text:sub(i + 1, i + 1)) then
                local data = M.identifier.new(ch)
                table.insert(datum, data)
                i = i + 1
            else
                M._error('whitespace or EOF must follow peculiar identifier: ' .. ch)
            end
        elseif ch == '.' then
            -- dot notation for Scheme pairs
            if IsWhitespace(text:sub(i + 1, i + 1)) then
                local data = M.dot.new()
                table.insert(datum, data)
                i = i + 1
            else
                -- peculiar identifier '...'
                if (i + 2) > #text then
                    M._error('"..." is the only valid identifier with prefix "."')
                end
                if text:sub(i, i + 2) ~= '...' then
                    M._error('"..." is the only valid identifier with prefix "."')
                end
                if not ((i + 4) > #text) and not IsWhitespace(text:sub(i + 4, i + 4)) then
                    M._error('"..." must be followed by whitespace or EOF')
                end
                local data = M.identifier.new('...')
                table.insert(datum, data)
                i = i + 4
            end
        elseif ch == '@' then
            M._error('identifiers cannot start with "@"')
        elseif M.identifier.letters[ch] or M.identifier.special_initials[ch] then
            local identifier, end_index = ExtractIdentifier(text, i)
            local data = M.identifier.new(identifier)
            table.insert(datum, data)
            i = end_index + 1
        elseif ch == '(' then
            local new_datum = {}
            parent_datum_of[new_datum] = datum
            datum = new_datum
            i = i + 1
            paren_balance = paren_balance + 1
        elseif ch == ')' then
            if paren_balance <= 0 then
                M._error('one or more ")" detected')
            end
            local prelist = datum
            datum = parent_datum_of[datum]
            table.insert(datum, BuildList(prelist))
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

return M
