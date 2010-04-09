-- ----------------------------------------------------------------------------
-- A widget layout that centers it contents
-- ----------------------------------------------------------------------------

local ipairs = ipairs
local type = type
local table = table
local math = math
local util = require("awful.util")
local capi = {
    screen = screen,
}

module("widget.layout.center")

function center(bounds, widgets, screen)
    local geometries = {
        free = util.table.clone(bounds)
    }
    -- at the moment we assume this layout is wrapped in a flex,
    -- so we want to leave the full screen width available
    geometries.free.width = capi.screen[screen].geometry.width

    local width = 0

    -- loop once over widgets and tables with widgets and sum up
    -- their width
    for _, k in ipairs(util.table.keys_filter(widgets, "table", "widget")) do
        local w = widgets[k]
        if type(w) == "table" then
            local layout = w.layout or default
            local g = layout(bounds, w, screen)
            for _, w in ipairs(g) do
                width = width + w.width
            end
        elseif type(w) == "widget" then
            local extents = w:extents(screen)
            width = width + extents.width
        end
    end

    local x = math.floor((geometries.free.width / 2) - (width / 2))

    -- calculate the horizontal position of all the widgets
    for _, k in ipairs(util.table.keys(widgets)) do
        local v = widgets[k]
        if type(v) == "table" then
            local layout = v.layout or default
            local g = layout(bounds, v, screen)
            for _, v in ipairs(g) do
                v.x = v.x + x
                table.insert(geometries, v)
            end
            bounds = g.free
        elseif type(v) == "widget" then
            local g = v:extents(screen)
            g.resize = v.resize

            if g.resize and g.width > 0 and g.height > 0 then
                g.width = bounds.height
                g.height = bounds.height
                g.x = x
                g.y = bounds.y
                x = x + g.width
            elseif g.width > 0 and g.height > 0 then
                g.x = x
                g.y = bounds.y
                g.height = bounds.height
                x = x + g.width
            else
                g.x = 0
                g.y = 0
                g.width = 0
                g.height = 0
            end
            table.insert(geometries, g)
        end
    end

    return geometries
end

-- just an alias
function absolute(...)
    return center(...)
end

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
