# fencey.nvim

![Fencey Demo](https://github.com/user-attachments/assets/57900642-e61f-4ffd-a6d3-0507547942d5)

## Features

- Yank text as a code block
- Do it again, _if you want to_

> Couldn't this just have been a gist with an autocommand?!

Yes, but this is cooler.

Feel free to repurpose the code as an autocommand if you want,
but I have added some _niceties_ that make this easier to use.

## Usage

`fencey.nvim` provides one command:

- `:FenceYank` puts you into fence yank mode

I recommend keybinding this to something reasonable, see [example config](#example-configuration).

## Installation

1. Install via your favorite package manager

```lua
-- lazy.nvim
{
    'lnus/fencey.nvim',
    opts = {},
},
```

2. Setup the plugin in your `init.lua`

**NOT** needed with `lazy.nvim` if `opts` is set, like above

```lua
require('fencey').setup()
```

## Configuration

The default configuration is very barebones.

```lua
{
    verbose = false, -- Log more often
    virtual_text = {
        content = '[FY]', -- Virtual text content
        hl_group = 'DiagnosticVirtualTextInfo', -- Which highlight group to use
    },
}
```

### Example configuration

> Make sure to understand `cmd` and `keys` from [lazy.nvim](https://lazy.folke.io/spec/examples)

With `lazy.nvim` a config might look like this:

```lua
{
    'lnus/fencey.nvim',
    opts = {
        verbose = false,
        virtual_text = {
            content = '[FenceY]',
            hl_group = 'Comment',
        },
    },
    cmd = { 'FenceYank' },
    keys = {
      { '<leader>fy', '<cmd>FenceYank<cr>', desc = '[F]ence [Y]ank' },
    },
},
```

Or a more explicit, not lazy loaded configuration:

```lua
{
    'lnus/fencey.nvim',
    config = function()
        vim.api.nvim_set_hl(0, 'AwesomeHighlight', { fg = '#FF0FF0', italic = true })
        vim.keymap.set('n', '<leader>yf', '<cmd>FenceYank<cr>', { desc = '[Y]ank [F]ence' })

        require('fencey').setup {
            verbose = false,
            virtual_text = {
                content = '[Yanking Fence]',
                hl_group = 'AwesomeHighlight',
            },
        }
    end,
},
```

## License

MIT
