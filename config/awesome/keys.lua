-- show infomation about current client in a naughty notification
-- bind 'naughty_info.func' to a keybind to trigger
-- when the notification is visible, trigger it again to clear it
local naughty_info = {}
naughty_info.current = nil
naughty_info.func = function ()
    if naughty_info.current then
        naughty.destroy(naughty_info.current)
        naughty_info.current = nil
    else
        local c = client.focus
        if not c then return end
        local geom = c:geometry()
        local t = ""
        if c.class      then t = t .. "<b>Class:</b>\t\t" .. c.class .. "\n" end
        if c.instance   then t = t .. "<b>Instance:</b>\t\t" .. c.instance .. "\n" end
        if c.role       then t = t .. "<b>Role:</b>\t\t" .. c.role .. "\n" end
        if c.name       then t = t .. "<b>Name:</b>\t\t" .. c.name .. "\n" end
        if c.type       then t = t .. "<b>Type:</b>\t\t" .. c.type .. "\n" end
        t = t .. "<b>Dimensions:</b>\t" .. "x:" .. (geom.x or "") .. " y:" .. (geom.y or "") .. " w:" .. (geom.width or "") .. " h:" .. (geom.height or "")

        naughty_info.current = naughty.notify({
            text = t,
            timeout = 30,
            width = 500,
        })
    end
end

globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(apps.terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Prompt
    awful.key({ modkey },           "r",    function ()
        awful.prompt.run({
            bg_cursor   = beautiful.prompt.bg_color,
            fg_cursor   = beautiful.prompt.fg_color,
            font        = beautiful.prompt.font,
            ul_cursor   = beautiful.prompt.underline,
            selectall   = beautiful.prompt.selectall,
            prompt      = beautiful.prompt.text,
        },
        tools.prompt[mouse.screen].widget,
        function (...) tools.prompt[mouse.screen].widget.text = awful.util.spawn(...) end,
        awful.completion.shell,
        awful.util.getdir("cache") .. "/history")
    end),

    -- Lua Prompt
    awful.key({ modkey },           "x",    function ()
        awful.prompt.run({ prompt = "Run Lua code: " },
        tools.prompt[mouse.screen].widget,
        awful.util.eval, nil,
        awful.util.getdir("cache") .. "/history_eval")
    end),

    -- print info on current client
    awful.key({ modkey },           "i",   naughty_info.func ),

    -- clear irc notifications
    awful.key({ modkey },           ".",   tools.irc.clear_notifications )
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,           }, "s",      function (c) state.sloppy_focus = not state.sloppy_focus end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
