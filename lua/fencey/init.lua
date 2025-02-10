local M = {}

local config = require('fencey.config').config
local utils = require 'fencey.utils'

M.fence_yank_mode = false

local original_escape_map = vim.fn.maparg('<Esc>', 'n', false, true)
local extmark_ns = vim.api.nvim_create_namespace 'FenceYank'

local function set_virtual_text()
  vim.api.nvim_buf_clear_namespace(0, extmark_ns, 0, -1)

  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local row = cursor_pos[1] - 1

  vim.api.nvim_buf_set_extmark(0, extmark_ns, row, 0, {
    virt_text = {
      { config.virtual_text.content, config.virtual_text.hl_group },
    },
    virt_text_pos = 'eol',
  })
end

local function clear_virtual_text()
  vim.api.nvim_buf_clear_namespace(0, extmark_ns, 0, -1)
end

local function exit_fence_yank_mode()
  M.fence_yank_mode = false
  clear_virtual_text()

  local ok, err = pcall(function()
    if original_escape_map then
      vim.api.nvim_set_keymap('n', '<Esc>', original_escape_map.rhs, {
        noremap = original_escape_map.noremap,
        silent = original_escape_map.silent,
      })
    else
      vim.api.nvim_del_keymap('n', '<Esc>')
    end
  end)

  if not ok then
    utils.error('Failed to restore <Esc> keymap: ' .. err)
  end

  vim.api.nvim_del_augroup_by_name 'FenceYankCursor'
  utils.debug 'Exited fence yank mode'
end

local function format_markdown(ft, yank_text)
  local trimmed_yank_text = yank_text:gsub('%s+$', '') -- Remove trailing whitespace/newlines
  local lines = vim.split(trimmed_yank_text, '\n', { plain = true })

  local md = { '```' .. ft }
  for _, line in ipairs(lines) do
    table.insert(md, line)
  end
  table.insert(md, '```')
  return table.concat(md, '\n')
end

local function apply_fence_yank(event)
  local ft = vim.bo.filetype or ''
  local reg = event.regname ~= '' and event.regname or '"'
  local yank_text = vim.fn.getreg(reg)
  local md_str = format_markdown(ft, yank_text)

  vim.fn.setreg(config.register, md_str)
  utils.debug 'Fence-yank applied to current yank.'
end

local function fence_yank_handler(event)
  if not M.fence_yank_mode then
    return
  end

  -- Prevent conflict with other autocommands
  vim.schedule(function()
    apply_fence_yank(event)
    exit_fence_yank_mode()
  end)
end

function M.setup(opts)
  require('fencey.config').setup(opts)

  vim.api.nvim_create_augroup('FenceYank', { clear = true })

  vim.api.nvim_create_autocmd('TextYankPost', {
    group = 'FenceYank',
    callback = fence_yank_handler,
  })

  vim.api.nvim_create_user_command('FenceYank', function()
    M.fence_yank_mode = true
    set_virtual_text()
    utils.debug 'Entered into fence yank mode'

    vim.api.nvim_set_keymap('n', '<Esc>', '', {
      callback = exit_fence_yank_mode,
      noremap = true,
      silent = true,
    })

    vim.api.nvim_create_augroup('FenceYankCursor', { clear = true })
    vim.api.nvim_create_autocmd('CursorMoved', {
      group = 'FenceYankCursor',
      callback = set_virtual_text,
    })
  end, { desc = 'Enter fence yank mode' })
end

return M
