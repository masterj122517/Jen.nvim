local jen = require("jen")

vim.api.nvim_create_user_command("Jen", function(opts)
  jen.command(opts)
end, {
  nargs = "?",
  complete = function()
    return { "e", "d", "es", "ds" }
  end,
})
