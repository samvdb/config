-- -----------------------------------------------------------------------------
-- SIMPLE TEXT CLOCK
-- -----------------------------------------------------------------------------
--
--  A clock that can be colored and have it's format changed.
--
--  Usage:
--    require("widget.clock")
--    clock = widget.clock({ }, 60, "%H:%M", "#bfff00")
--
--  In your wibox use the widget like this:
--    clock.widget
--
--  You can call methods on the clock object
--    clock:set_color("#990000") changes the color
--    clock:set_format("%m") changes the format
--
-- -----------------------------------------------------------------------------

local setmetatable = setmetatable
local os = os
local ipairs = ipairs

local beautiful = require("beautiful")

local capi = {
    widget = widget,
    timer = timer
}

module("widget.clock") 

local properties = { "color", "format", }

local function update (clock)
    clock.widget.text = "<span color='" .. clock.color .. "'>" .. os.date(clock.format) .. "</span>"
end

-- Build properties function
for _, prop in ipairs(properties) do
    if not _M["set_" .. prop] then
        _M["set_" .. prop] = function(clock, value)
            clock[prop] = value
            update(clock)
            return clock
        end
    end
end

--- Create a textclock widget. It draws the time it is in a textbox.
-- @param args Standard arguments for textbox widget.
-- @param format The time format. Default is " %a %b %d, %H:%M ".
-- @param timeout How often update the time. Default is 60.
-- @param color The color to draw the clock foreground in
-- @return A textbox widget showing a clock
function new(args, timeout, format, color)
    local args = args or {}
    local theme = beautiful.get()

    local timeout = timeout or 60
    local format = format or " %a %b %d, %H:%M "
    local color = color or theme.fg_normal or "#ffffff"

    args.type = "textbox"

    local clock = { color = color, format = format }
    local timer = capi.timer { timeout = timeout }

    clock.widget = capi.widget(args)

    -- Set methods
    for _, prop in ipairs(properties) do
        clock["set_" .. prop] = _M["set_" .. prop]
    end

    timer:add_signal("timeout", function() update(clock) end)
    timer:start()
    update(clock)

    return clock
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
