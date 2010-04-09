awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    {
        rule = { class = "MPlayer" },
        properties = { floating = true }
    },
    {
        rule = { class = "gimp" },
        properties = { floating = true }
    },
    {
        rule = { class = "Swiftfox" },
        properties = { tag = tags[1][2] }
    },
    {
        rule = { class = "Swiftfox", instance = 'Places' },
        properties = { tag = tags[1][2], geometry = { width = 900, height = 650, x = 175, y = 75 }, centered = true }
    },
    {
        rule = { class = "Swiftfox", name = 'Save a Bookmark' },
        properties = { geometry = { width = 920, height = 500, x = 220, y = 145 }, centered = true }
    },
    {
        rule = { class = "Swiftfox", instance = 'Dialog' },
        properties = { tag = tags[1][2], geometry = { width = 460, height = 350, x = 350, y = 200 }, centered = true }
    },
    {
        rule = { class = "Uzbl" },
        properties = { geometry = { width = 1100, height = 700 }, centered = true }
    },
    {
        rule = { class = "Gpick" },
        properties = { geometry = { width = 680, height = 432 }, centered = true, floating = true }
    },
    {
        rule = { class = "VirtualBox" },
        properties = { centered = true, floating = true }
    },
    {
        rule = { class = "Skype", instance = 'skype' },
        properties = { geometry = { width = 320, height = 500, x = 25, y = 40 }, tag = tags[1][4], floating = true, }
    },
    {
        rule = { class = "Skype", instance = 'skype', name = 'Chat' },
        properties = { geometry = { width = 600, height = 530, x = 400, y = 30 }, tag = tags[1][4] }
    },
}
