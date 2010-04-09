require("awful")
require("awful.autofocus")
require("awful.rules")
require("beautiful")
require("naughty")

require("lib/bordercontrol")

log = require("lib.logging")

log("test");
-- Setup Theme
home = os.getenv("HOME")
beautiful.init(home .. "/lib/theme/current/awesome/theme.lua")

-- Variables
apps = {}
apps.terminal = "urxvt"
apps.editor = apps.terminal .. " -e vim"

modkey = "Mod4"
state = {
    sloppy_focus = true
}

layouts = {
    awful.layout.suit.max,
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.floating,
}

-- Tags
tags = {}
for s = 1, screen.count() do
    tags[s] = awful.tag({ "work", "surf", "misc", "chat" }, s, layouts[1])
end

-- Widgets
tools = {}

-- -- Clock
require('widget.clock')
tools.clock = widget.clock({ }, 60, "%A %e %B %H:%M", "#bfff00")

-- -- Tags (only show current tag and urgent tags, except on mouseover)
require('widget.tagreduce')
tools.tags = { }
tools.tags.buttons = awful.button({ }, 1, awful.tag.viewonly)
tools.tags.args = { }

-- -- Prompt
tools.prompt = { }

-- -- Volume
require('widget.volume')
tools.volume = widget.volume({ }, {
    text = "<span font_desc='Dejavu Sans 12'>&#x266c;</span>", -- BEAMED SIXTEENTH NOTES
    colormute = "#444444",
    channel = "PCM",
})
awful.widget.layout.margins[tools.volume.widget] = { left = 2, right = 2 }

-- Layoutbox
require("widget.layoutbox")
tools.layoutbox = { }
tools.layoutbox.layouts = {
    max         = "<span font_desc='Dejavu Sans 12'>&#x1d306;</span>", -- TETRAGRAM FOR CENTRE
    tile        = "<span font_desc='Dejavu Sans 12'>&#x1d32e;</span>", -- TETRAGRAM FOR RESPONSE
    tilebottom  = "<span font_desc='Dejavu Sans 12'>&#x1d34e;</span>", -- TETRAGRAM FOR COMPLETION
    floating    = "<span font_desc='Dejavu Sans 12'>&#x1d356;</span>", -- TETRAGRAM FOR FOSTERING
}

-- IRC
require("widget.irc")
tools.irc = widget.irc({ }, {
    text = "<span font_desc='Dejavu Sans 11'>&#x2318;</span>", -- PLACE OF INTEREST SIGN
})
tools.irc:set_highlights({ "alterecco", "otherecco" })
tools.irc:set_clientname("weechat-curses")
awful.widget.layout.margins[tools.irc.widget] = { left = 1, right = 2, top = 1 }

-- Battery
require("widget.battery")
tools.battery = widget.battery({ }, {
    text = "<span font_desc='Dejavu Sans 12'>&#x26a1;</span>", -- HIGH VOLTAGE SIGN"
    batID = "BAT1",
})
awful.widget.layout.margins[tools.battery.widget] = { left = 0, right = 0 }

-- Wibox
tools.wibox = { }

-- we need our special widget layouts
require("widget.layout.center")

for s = 1, screen.count() do
    -- create widgets for each screen
    tools.tags[s] = widget.tagreduce(s, tools.tags.buttons, tools.tags.args)

    tools.prompt[s] = awful.widget.prompt()
    awful.widget.layout.margins[tools.prompt[s]] = { left = 5 }

    tools.layoutbox[s] = widget.layoutbox(s, { }, tools.layoutbox.layouts)
    awful.widget.layout.margins[tools.layoutbox[s].widget] = { left = 2, right = 2 }

    tools.wibox[s] = awful.wibox({ position = "top", screen = s })
    tools.wibox[s].widgets = {
        {
            tools.tags[s].widget,
            tools.prompt[s],
            layout = awful.widget.layout.horizontal.leftright,
        },
        {
            tools.clock.widget,
            layout = widget.layout.center.absolute,
        },
        {
            tools.layoutbox[s].widget,
            tools.irc.widget,
            tools.volume.widget,
            tools.battery.widget,
            layout = awful.widget.layout.horizontal.rightleft,
        },
        layout = awful.widget.layout.horizontal.flex,
    }
end

-- Key bindings
require("keys")

-- Rules
require("rules")

-- Signals
client.add_signal("manage", function (c, startup)

    c:add_signal("mouse::enter", function(c)
        if state.sloppy_focus and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    c.size_hints_honor = false
    if not startup then
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
