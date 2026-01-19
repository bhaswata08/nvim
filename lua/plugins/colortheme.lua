return {
  'https://github.com/rebelot/kanagawa.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('kanagawa').setup({
        transparent = true,
        theme = 'wave',
    })
  	vim.cmd("colorscheme kanagawa-wave")

    local bg_transparent = true
    local toggle_transparency = function()
        bg_transparent = not bg_transparent
        require('kanagawa').setup({
            transparent = bg_transparent,
            theme = 'wave',
        })
        vim.cmd("colorscheme kanagawa-wave")
    end

    vim.keymap.set('n', '<leader>bg', toggle_transparency, { noremap = true, silent = true })
  end
}
