return {
	'nvim-telescope/telescope.nvim',
	branch = '0.1.x',
	dependencies = { 'nvim-lua/plenary.nvim' },

	init = function()
		local telescope = require("telescope")
		local builtin = require('telescope.builtin')
		vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
		vim.keymap.set('n', '<leader>fs', builtin.live_grep, { desc = 'Telescope live grep' })
		vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
		vim.keymap.set('n', '<leader>fg', builtin.git_files, { desc = 'Telescope git files' })
		vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
		telescope.setup({
			defaults = {
				layout_config = {
					horizontal = {
						preview_width = 0.55,
					},
				},
				file_ignore_patterns = {
					"node_modules",
				},
			},
			path_display = function(opts, path)
				local tail = require("telescope.utils").path_tail(path)
				local parts = vim.split(path, "/")
				local displayed_path = table.concat(parts, "/", #parts - 2)
				return string.format("%s %s", tail, displayed_path)
			end,
			layout_config = {
				horizontal = {
					preview_width = 0.55,
				},
			},
			pickers = {
				find_files = {
					theme = "dropdown",
					previewer = true,
					path_display = { "truncate" },
				},
				buffers = {
					theme = "dropdown",
					previewer = false,
					path_display = { "truncate" },
				},
			},
		})
	end
}
