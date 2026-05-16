local M = {}

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "jen.nvim" })
end

local function jen_bin()
  return vim.g.jen_bin or "jen"
end

local function get_current_path()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    notify("buffer has no file path", vim.log.levels.ERROR)
    return nil
  end
  return path
end

local function ensure_saved()
  if vim.bo.modified then
    vim.cmd("write")
  end
end

local function run_jen(args, password, on_success)
  local cmd = { jen_bin() }
  vim.list_extend(cmd, args)
  local input = (password or "") .. "\n"

  if vim.system then
    vim.system(cmd, { stdin = input, text = true }, function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          local message = result.stderr and result.stderr ~= "" and result.stderr or "jen failed"
          notify(message, vim.log.levels.ERROR)
          return
        end
        on_success(result.stdout or "")
      end)
    end)
    return
  end

  local output = vim.fn.system(cmd, input)
  if vim.v.shell_error ~= 0 then
    local message = output ~= "" and output or "jen failed"
    notify(message, vim.log.levels.ERROR)
    return
  end
  on_success(output)
end

local function prompt_password()
  local password = vim.fn.inputsecret("password: ")
  if password == "" then
    notify("password is required", vim.log.levels.ERROR)
    return nil
  end
  return password
end

function M.encrypt_current()
  local path = get_current_path()
  if not path then
    return
  end
  ensure_saved()
  local password = prompt_password()
  if not password then
    return
  end
  local output_path = path .. ".enc"

  run_jen({ "encrypt", path, output_path }, password, function()
    notify("encrypted to " .. output_path)
  end)
end

local function decrypt_output_name(path)
  if path:sub(-4) == ".enc" then
    return path:sub(1, -5) .. ".dec"
  end
  return path .. ".dec"
end

function M.decrypt_current()
  local path = get_current_path()
  if not path then
    return
  end
  local password = prompt_password()
  if not password then
    return
  end

  run_jen({ "decrypt", path }, password, function(output)
    local buf = vim.api.nvim_create_buf(true, false)
    local name = decrypt_output_name(path)
    vim.api.nvim_buf_set_name(buf, name)
    local lines = vim.split(output, "\n", { plain = true })
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_set_current_buf(buf)
  end)
end

function M.command(opts)
  local action = (opts.fargs[1] or ""):lower()
  if action == "e" then
    M.encrypt_current()
    return
  end
  if action == "d" then
    M.decrypt_current()
    return
  end
  notify("unknown action: use e or d", vim.log.levels.ERROR)
end

return M
