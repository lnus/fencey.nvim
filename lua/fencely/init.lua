local M = {}

M.fence_yank_pending = false
M.config = {
  highlight = false, -- TODO: Implement
}

local function fence_yank_handler(event)
  if not M.fence_yank_pending then
    return
  end

  M.fence_yank_pending = false

  local ft = vim.bo.filetype or ''
  local reg = event.regname ~= '' and event.regname or '"'
  local yank_text = vim.fn.getreg(reg)
  local trimmed_yank_text = yank_text:gsub('%s+$', '') -- Remove trailing whitespace/newlines
  local lines = vim.split(trimmed_yank_text, '\n', { plain = true })

  local md = { '```' .. ft }
  for _, line in ipairs(lines) do
    table.insert(md, line)
  end
  table.insert(md, '```')
  local md_str = table.concat(md, '\n')

  -- TODO: Lookup if I handle this correctly
  -- It works on my machine™️
  vim.fn.setreg('+', md_str)
  print 'Fence-yank applied to current yank.'

  if M.config.highlight then
    vim.hl.on_yank() -- TODO: Allow config?
  end
end

function M.setup(config)
  M.config = vim.tbl_deep_extend('force', M.config, config or {})

  vim.api.nvim_create_augroup('FenceYank', { clear = true })

  vim.api.nvim_create_autocmd('TextYankPost', {
    group = 'FenceYank',
    callback = fence_yank_handler,
  })

  vim.api.nvim_create_user_command('FenceYank', function()
    M.fence_yank_pending = true
    print 'Entered into fence yank mode'
  end, { desc = 'Copy as a fence' })
end

return M
