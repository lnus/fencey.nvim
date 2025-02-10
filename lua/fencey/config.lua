local M = {}

M.config = {
  verbose = false,
  register = '+',
  virtual_text = {
    content = '[FY]',
    hl_group = 'DiagnosticVirtualTextInfo',
  },
}

function M.setup(opts)
  for option, value in pairs(opts) do
    if type(value) == 'table' then
      if type(M.config[option]) ~= 'table' then
        M.config[option] = {}
      end
      for k, v in pairs(value) do
        M.config[option][k] = v
      end
    else
      M.config[option] = value
    end
  end
end

return M
