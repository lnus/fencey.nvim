local M = {}

M.copy_as_fence = function()
  local ft = vim.bo.filetype or ''
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local md = { '```' .. ft }
  for _, line in ipairs(lines) do
    table.insert(md, line)
  end
  table.insert(md, '```')
  local md_str = table.concat(md, '\n')
  vim.fn.setreg('+', md_str)
  print 'Copied as a Markdown code block!'
end

function M.setup(_)
  vim.api.nvim_create_user_command('FenceYank', function()
    M.copy_as_fence()
  end, { desc = 'Copy as a fence' })
end

return M
