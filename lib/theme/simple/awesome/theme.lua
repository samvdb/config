------------------
-- Simple Theme --
------------------

theme = {}

theme.wallpaper_cmd = { " " }

-- theme.font              = "sans 8"
theme.font              = "Dejavu Sans 8"
theme.mono              = "Dejavu Sans Mono 8"
theme.mono_small        = "Dejavu Sans Mono 6"

theme.bg_normal         = "#000000cc"
theme.bg_focus          = "#535d6c00"
theme.bg_urgent         = "#ff0000"

theme.fg_normal         = "#aaaaaa"
theme.fg_focus          = "#ffffff"
theme.fg_urgent         = "#ffffff"

theme.border_width      = "1"
theme.border_normal     = "#222222"
theme.border_focus      = "#990000"
theme.border_marked     = "#91231c"

theme.tag = {}
theme.tag.bg_normal     = "#22222200"
theme.tag.fg_normal     = "#555555"
theme.tag.bg_focus      = "#999999"
theme.tag.fg_focus      = "#999999"
theme.tag.bg_urgent     = "#990000"
theme.tag.fg_urgent     = "#990000"

theme.prompt = {}
theme.prompt.bg_color   = "#22222200"
theme.prompt.fg_color   = "#00ffff"
theme.prompt.underline  = "single"
theme.prompt.text       = ":"

theme.clock = {}
theme.clock.fg_normal   = "#990000"

theme.volume = {}
theme.volume.fg_on      = "#009900"
theme.volume.fg_off     = "#990000"

-- IRC
theme.irc = {}
theme.irc.fg_normal     = "#999999"
theme.irc.fg_highlight  = "#ff669d"
theme.irc.fg_offline    = "#444444"
theme.irc.fg_active     = "#bfff00"

-- Battery
theme.battery = {}
theme.battery.color_normal      = "#aaaaaa"
theme.battery.color_warning     = "#ff669d"
theme.battery.color_high        = "#ff669d"
theme.battery.color_medium      = "#444444"
theme.battery.color_low         = "#bfff00"

return theme
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
