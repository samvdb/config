-- -----------------------------------------------------------------------------
-- EASY LOGGING IN AWESOME'S RC
-- -----------------------------------------------------------------------------
--
-- This library makes it quite trivial to log data to stderr from your rc.lua or
-- other awesome library.
-- Simply include it with:
-- log = require("lib.logging")
--
-- To log data just use the main object:
-- log("this will be printed to stderr")
--
-- There is also a helper to print the contents of tables:
-- log(log.table_print(some_table))
--
-- To use effectively you need easy access to awesomes stderr. By default this
-- is the TTY where you started X from, but depending on your setup it could be
-- several places. If your awesome is started from .xinitrc i suggest piping
-- at least stderr to a logfile:
--    exec awesome > /var/log/xsession.log 2>&1
-- note, that for this to work the user you start X as must have write access to
-- the file in question (/var/log/xsession.log)
--
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- TODO/MAYBE/SUGGESTIONS
-- -----------------------------------------------------------------------------
--
-- - Better table_print?
-- - Specify an output file on instantiation?
-- - Find out how to require the lib without "lib.logging"
--
-- -----------------------------------------------------------------------------

local setmetatable = setmetatable
local pairs = pairs
local tostring = tostring
local type = type
local table = table
local io = io
local string = string

module("lib.logging")

local function to_string (tbl)
    if "nil" == type(tbl) then
        return tostring(nil)
    elseif "table" == type(tbl) then
        return table_print(tbl)
    elseif "string" == type(tbl) then
        return tbl
    else
        return tostring(tbl)
    end
end

function table_print (tt, indent, done)
    done = done or {}
    indent = indent or 0
    if type(tt) == "table" then
        local sb = {}
        for key, value in pairs (tt) do
            table.insert(sb, string.rep (" ", indent)) -- indent it
            if type (value) == "table" and not done [value] then
                done [value] = true
                table.insert(sb, "{\n");
                table.insert(sb, table_print (value, indent + 2, done))
                table.insert(sb, string.rep (" ", indent)) -- indent it
                table.insert(sb, "}\n");
            elseif "number" == type(key) then
                table.insert(sb, string.format("\"%s\"\n", tostring(value)))
            else
                table.insert(sb, string.format(
                "%s = \"%s\"\n", tostring (key), tostring(value)))
            end
        end
        return table.concat(sb)
    else
        return tt .. "\n"
    end
end

function log (...)
    local args = {...}
    local str = ""
    for k = 1, #args do
        str = str .. to_string(args[k])
        if k ~= #args then str = str .. " " end
    end

    str = str .. "\n"
    io.stderr:write(str)
end

setmetatable(_M, { __call = function(_, ...) return log(...) end })

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
