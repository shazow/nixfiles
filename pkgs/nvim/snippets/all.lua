local ls = require("luasnip")
local snip = ls.snippet
local func = ls.function_node

ls.add_snippets(nil, {
    all = {
        snip(
            { trig = "date", namr = "Date", dscr = "Current date as YYYY-MM-DD", },
            { func(function() return { os.date("%Y-%m-%d") } end, {}) }
        ),
        snip(
            { trig = "datetime", namr = "Date and time", dscr = "Current timestamp as YYYY-MM-DD HH:DD:SS", },
            { func(function() return { os.date("%Y-%m-%d %H:%M:%S") } end, {}) }
        ),
    },
})
