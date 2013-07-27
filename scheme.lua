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
        t.value = value
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

function M.read(text)
    local line_number = 1
    local datum = {}
    local i = 1
    local len = #text

    while i <= len do
        local ch = text:sub(i, i)

        if ch == '\t' or ch == ' ' or ch == '\r' then
            i = i + 1
        elseif ch == '\n' then
            i = i + 1
            line_number = line_number + 1
        elseif ch == '#' then
            if i + 1 > len then
                M._error('expected more input after #')
            end

            -- '#' can be followed by a multitude of things
            local m = text:sub(i + 1, i + 1)

            -- booleans
            if m == 't' then
                local data = M.boolean.new(true)
                table.insert(datum, data)
                i = i + 2
            elseif m == 'f' then
                local data = M.boolean.new(false)
                table.insert(datum, data)
                i = i + 2
            elseif m == '\\' then
                -- characters
                if i + 2 > len then
                    M._error('expected more input after #')
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
            local str, end_index = SearchTillStringEnd(text, i + 1)
            local data = M.string.new(str)
            table.insert(datum, data)
            i = end_index + 1
        end
    end

    return datum
end

return M
