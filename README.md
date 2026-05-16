# jen.nvim

Neovim plugin that wraps the `jen` encryption tool.

## Install

```lua
{
  "path/to/jen.nvim",
}
```

## Commands

- `:Jen e` encrypts the current file to `filename.ext.enc` using a password prompt.
- `:Jen d` decrypts the current `.enc` file and opens the result in a new buffer.

## Notes

- Set `vim.g.jen_bin` if `jen` is not on your PATH.
