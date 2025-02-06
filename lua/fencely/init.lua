local M = {}

M.config = {
  highlight = false, -- TODO: Implement
}

M.copy_as_fence = function(start_line, end_line)
  local ft = vim.bo.filetype or ''
  local buf = vim.api.nvim_get_current_buf()

  if not start_line or not end_line then
    start_line = 0
    end_line = vim.api.nvim_buf_line_count(buf)
  end

  -- Adjust for 1-indexing
  start_line = start_line - 1

  local lines = vim.api.nvim_buf_get_lines(buf, start_line, end_line, false)
  local md = { '```' .. ft }
  for _, line in ipairs(lines) do
    table.insert(md, line)
  end
  table.insert(md, '```')
  local md_str = table.concat(md, '\n')
  vim.fn.setreg('+', md_str)

  if #lines > 1 then
    print(#lines .. ' lines fence yanked')
  end
end

function M.setup(config)
  M.config = vim.tbl_deep_extend('force', M.config, config or {})

  vim.api.nvim_create_user_command('FenceYank', function(opts)
    M.copy_as_fence(opts.line1, opts.line2)
  end, { desc = 'Copy as a fence', range = true })
end

return M
