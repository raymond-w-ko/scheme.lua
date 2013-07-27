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

local datum

--datum = scheme.read('#t')
--datum_print(datum)
--datum = scheme.read(' #t')
--datum_print(datum)
--datum = scheme.read(' #t ')
--datum_print(datum)
--datum = scheme.read(' #t #t')
--datum_print(datum)

--datum = scheme.read('#f')
--datum_print(datum)
--datum = scheme.read(' #f')
--datum_print(datum)
--datum = scheme.read(' #f #f #f')
--datum_print(datum)

--datum = scheme.read('#\\a')
--datum_print(datum)
--datum = scheme.read('#\\newline')
--datum_print(datum)
--datum = scheme.read('#\\space')
--datum_print(datum)
--datum = scheme.read('#\\ ')
--datum_print(datum)

datum = scheme.read('"test"')
datum_print(datum)
datum = scheme.read('"t\\\\est"')
datum_print(datum)
datum = scheme.read('"t\\"est"')
datum_print(datum)
datum = scheme.read('"test\\\\"')
datum_print(datum)
datum = scheme.read('"test\\""')
datum_print(datum)
