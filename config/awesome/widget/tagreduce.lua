-- ----------------------------------------------------------------------------
-- MINIMALISTIC TAG HANDLING
-- ----------------------------------------------------------------------------
--
-- The tagreduce library by default shows only the current tag, but expands to
-- show all tags on mouseover. When unexpanded it displays any urgent tags in
-- their own area so no notifications will be missed. If expanded, urgent tags
-- are collapsed into the normal view. It can be manipulated at runtime, so
-- you can set a keybind to expand/unexpand the view if you want.
--
-- At the moment the only thing that is missing compared to the normal setup is
-- special treatment of tags with clients on them. So, no coloring or marking
-- of those tags is done. Additionally the display is text only, so there are no
-- images or anything included.
--
-- By default tagreduce will use your beautiful color setup.
--
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- USAGE
-- ----------------------------------------------------------------------------
--
-- Use it like you would the normal awesome tag function
--
-- require library
--   require('widget.tagreduce')
-- create a container
--   tags = { }
-- add any mouse handlers you want 
--   tags.buttons = awful.button({ }, 1, awful.tag.viewonly)
-- add any args you would like, eg:
--   tags.args = {
--      fg_normal = "#990000", -- red tags, just because
--   }
--
-- Inside your wibox setup, use it like this:
--   tags[s] = widget.tagreduce(screen, tags.buttons, tags.args)
--
-- and in the wibox itself you use `widget' parameter to get the widget itself
--   tags.widget
--
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- OPTIONS
-- ----------------------------------------------------------------------------
--
-- Options that can be used to customize the display.
-- Pass them to the tagreduce function to have them set permanently, or use them
-- with a `set_' prefix to set options at runtime.
--
-- Colors: hexadecimal color values, eg: "#333333" or "#999"
--    fg_normal
--    bg_normal
--    fg_focus
--    bg_focus
--    fg_urgent
--    bg_urgent
--
-- expand: boolean
--    if `true', show all tags always
--    if `false', show only selected, except on mouseover
--
-- hide_urgent: boolean
--    this controls whether urgent tags will be shown in their
--    own area when appropriate.
--    if `false' don't show separate urgent tags
--    if `true' show urgent tags in their own area
--
-- Margins: numeric, pixels
-- margin_left
-- margin_right
--
-- --------------------------
-- Setting options at runtime
-- --------------------------
-- All of the above options can be set at runtime by calling a function on the
-- tagreduce object, named as the option prefixed by 'set_'.
-- As an example, using the setup from above, one can do
--    echo "tags:set_fg_focus = '#990000'" | awesome-client
-- to change the fg_focus color at any time.
-- These options can also be bound to keys, so you can show/hide tags easily
--
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- TODO/MAYBE/SUGGESTIONS:
-- ----------------------------------------------------------------------------
--
-- - Nicer default colours. 
-- - Distinguish tags with clients on them?
-- - Change syntax to be more in line with other widgets of this kind
--   - Don't use args, but props
--   - Have own table in beautiful for colour configuration?
--
-- ----------------------------------------------------------------------------


-- Grab environment
local setmetatable = setmetatable
local pairs = pairs
local ipairs = ipairs
local table = table

local util = require("awful.util")
local layout = require("awful.widget.layout")
local tag = require("awful.tag")
local beautiful = require("beautiful")

local capi = {
    client = client,
    screen = screen,
    widget = widget,
    button = button
}

module("widget.tagreduce")

local properties = {
    "fg_normal", "bg_normal", "fg_focus", "bg_focus",
    "fg_urgent", "bg_urgent", "expand", "hide_urgent",
    "margin_left", "margin_right",
}

local function tagwidgets(data, tags, widgets)
    for i = 1, #tags do
        local t = tags[i]

        -- add buttons
        if data.buttons then
            if not data.proxy_buttons[t] then
                data.proxy_buttons[t] = {}
                for kb, b in ipairs(data.buttons) do
                    -- Proxy to the users button handlers with the tag as argument
                    local btn = capi.button({ modifiers = b.modifiers, button = b.button })
                    btn:add_signal("press", function () b:emit_signal("press", t) end)
                    btn:add_signal("release", function () b:emit_signal("release", t) end)
                    table.insert(data.proxy_buttons[t], btn)
                end
            end
            widgets[i]:buttons(data.proxy_buttons[t])
        end

        local text, bg, fg = nil

        -- if t.selected then
        if t.selected then
            fg = data.fg_focus
            bg = data.bg_focus
            text = util.escape(t.name)
        else
            fg = data.fg_normal
            bg = data.bg_normal
            for _, c in pairs(t:clients()) do
                if c.urgent then
                    fg = data.fg_urgent
                    bg = data.bg_urgent
                    break
                end
            end
            text = util.escape(t.name)
        end

        if fg and text then
            text = "<span color='" .. fg .. "'> " .. text .. " </span>"
        end

        if text then
            widgets[i].text = text
            if bg then
                widgets[i].bg = bg
            end
        else
            widgets[i].visible = false
        end
    end
end

local function update(data)
    -- find out which list of tags we are dealing with
    local tags = {}
    local urgenttags = {}
    tags = capi.screen[data.screen]:tags()

    -- find urgent tags if required
    if not hide_urgent then
        for k, t in ipairs(tags) do
            if not t.selected then
                for _, c in pairs(t:clients()) do
                    if c.urgent then
                        table.insert(urgenttags, t)
                    end
                end
            end
        end
    end

    if not data.expand and not data.expanded then
        tags = tag.selectedlist(data.screen)
    end

    -- filter out hidden tags (XXX: wtf are hidden tags?)
    local showntags = {}
    for k, t in ipairs(tags) do
        if not tag.getproperty(t, "hide") then
            table.insert(showntags, t)
        end
    end

    -- add or remove normal tag widgets
    local len = #util.table.keys_filter(data.widget.normal, "widget")
    if len < #showntags then
        for i = len + 1, #showntags do
            local tb = capi.widget({ type ="textbox", align = "right" })
            tb:margin({ left = data.margin_left, right = data.margin_right })

            -- handle mouseover
            if not data.expand then
                tb:add_signal("mouse::enter", function () if not data.expanded then data.expanded = true; update(data) end end)
                tb:add_signal("mouse::leave", function () if data.expanded then data.expanded = false; update(data) end end)
            end

            data.widget.normal[i] = tb
        end
    elseif len > #showntags then
        for i = #showntags + 1, len do
            data.widget.normal[i] = nil
        end
    end

    -- generate the normal widgets
    tagwidgets(data, showntags, data.widget.normal)

    -- add or remove urgent tag widgets
    if not data.expand and not data.expanded then
        local len = #util.table.keys_filter(data.widget.urgent, "widget")
        if len < #urgenttags then
            for i, t in ipairs(urgenttags) do
                if not tag.getproperty(t, "hide") then
                    local tb = capi.widget({ type ="textbox", align = "right" })
                    tb:margin({ left = data.margin_left, right = data.margin_right })
                    data.widget.urgent[i] = tb
                end
            end
        elseif len > #urgenttags then
            for k, w in ipairs(data.widget.urgent) do
                local found = false
                for i, t in ipairs(urgenttags) do
                    if t.name == w.text then
                        found = true
                    end
                end
                if not found then
                    data.widget.urgent[k] = nil
                end
            end
        end
        -- generate the urgent widgets
        tagwidgets(data, urgenttags, data.widget.urgent)
    else
        data.widget.urgent = {
            layout = layout.horizontal.leftright
        }
    end
end

-- build properties function
for _, prop in ipairs(properties) do
    if not _M["set_" .. prop] then
        _M["set_" .. prop] = function(data, value)
            data[prop] = value
            update(data)
            return data
        end
    end
end

-- @param screen The screen to draw tag list for.
-- @param buttons A table with buttons binding to set.
-- @param args The arguments table
-- fg_normal Normal tag color
-- bg_normal Normal tag background color
-- fg_focus Selected tag color
-- bg_focus Selected tag background color
-- fg_urgent Urgent tag color
-- bg_urgent Urgent tag background color
-- expand Boolean, show all tags or only current
-- hide_urgent Boolean, hide urgent tags
-- margin_left left margin of each tag
-- margin_right right margin of each tag
function new(screen, buttons, args)
    if not args then args = {} end
    local theme = beautiful.get()

    args.fg_normal      = args.fg_normal    or theme.fg_normal  or "#888888"
    args.bg_normal      = args.bg_normal    or theme.bg_normal  or "#000000"
    args.fg_focus       = args.fg_focus     or theme.fg_focus   or "#ffffff"
    args.bg_focus       = args.bg_focus     or theme.bg_focus   or "#000000"
    args.fg_urgent      = args.fg_urgent    or theme.fg_urgent  or "#ff669d"
    args.bg_urgent      = args.bg_urgent    or theme.bg_urgent  or "#000000"
    args.expand         = args.expand       or false
    args.hide_urgent    = args.hide_urgent  or false
    args.margin_left    = args.margin_left  or 0
    args.margin_right   = args.margin_right or 0

    local widget = {
        normal = {
            layout = layout.horizontal.leftright
        },
        urgent = {
            layout = layout.horizontal.leftright
        },
        layout = layout.horizontal.leftright
    }

    local data = {
        widget = widget,
        screen = screen,
        buttons = buttons or {},
        proxy_buttons = {},
    }
    data = util.table.join(data, args)

    -- Set methods
    for _, prop in ipairs(properties) do
        data["set_" .. prop] = _M["set_" .. prop]
    end

    local u = function (s)
        if s == screen then
            update(data)
        end
    end
    local uc = function (c) return u(c.screen) end

    -- register signals for updating tagdata
    capi.client.add_signal("focus", uc)
    capi.client.add_signal("unfocus", uc)
    tag.attached_add_signal(screen, "property::selected", uc)
    tag.attached_add_signal(screen, "property::icon", uc)
    tag.attached_add_signal(screen, "property::hide", uc)
    tag.attached_add_signal(screen, "property::name", uc)
    capi.screen[screen]:add_signal("tag::attach", function(screen, tag)
        u(screen.index)
    end)
    capi.screen[screen]:add_signal("tag::detach", function(screen, tag)
        u(screen.index)
    end)
    capi.client.add_signal("new", function(c)
        c:add_signal("property::urgent", uc)
        c:add_signal("property::screen", function(c)
            -- If client change screen, refresh it anyway since we don't from
            -- which screen it was coming :-)
            u(screen)
        end)
        c:add_signal("tagged", uc)
        c:add_signal("untagged", uc)
    end)
    capi.client.add_signal("unmanage", uc)

    -- update and return
    u(screen)
    return data
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
