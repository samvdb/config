-- -----------------------------------------------------------------------------
-- MINIMAL BORDERS PLEASE
-- -----------------------------------------------------------------------------
--
-- Only draw borders when absolutely necessary to distinguish a window.
--
-- Just require the file and it does it's work
--
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- TODO/MAYBE/SUGESTIONS:
-- -----------------------------------------------------------------------------
-- - Needs a cleanup
-- - Perhaps don't use layout == "max"?
-- - Perhaps look at these todo's again and find out what they are about?
-- -----------------------------------------------------------------------------

local pairs = pairs
local beautiful = require("beautiful")
local awful = require("awful")
local capi = {
    client = client,
}

module("bordercontrol")

local function bordercontrol (c)
    -- get visible clients on screen
    if c ~= nil then
        local visible_clients = awful.client.visible(c.screen)
        local tiled_clients = awful.client.tiled(c.screen)
        local layout = awful.layout.getname(awful.layout.get(c.screen))

        -- I am still not getting this right
        -- If I have one floating window, and a single tiled fullscreen in the
        -- background, the floating is correctly bordered, and while unfocused,
        -- the tiled in the bg is not bordered, but when the tiled is selected
        -- it gets a border...
        if #visible_clients > 0 then
            for _, c in pairs(visible_clients) do

                -- floating clients have border
                -- if awful.client.floating.get(c) or layout == 'floating' then
                -- floating client has border
                if awful.client.floating.get(c) or (layout == 'floating') then
                    c.border_width = beautiful.border_width
                    -- max layout, or only one client => no border
                elseif #visible_clients == 1 or layout == 'max' or tiled_clients == 1 then
                    c.border_width = 0
                else
                    c.border_width = beautiful.border_width
                end
            end
        end
    end
end

-- -- Border or no border signals
capi.client.add_signal("focus", bordercontrol)
capi.client.add_signal("unfocus", bordercontrol)
capi.client.add_signal("list", bordercontrol)
capi.client.add_signal("manage", bordercontrol)
capi.client.add_signal("unmanage", bordercontrol)
awful.tag.attached_add_signal(nil, "property::selected", bordercontrol)
awful.tag.attached_add_signal(nil, "property::layout", bordercontrol)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
