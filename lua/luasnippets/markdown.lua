local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
    s("blogstart", {
        t({
            "---",
            "layout: post",
            "title: ",
        }),
    }),
}
