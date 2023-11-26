local M = {}

M.error = {
	upload = { info = "Image upload failed.", level = vim.log.levels.ERROR },
	core = { info = "Picgo core error.", level = vim.log.levels.ERROR },
	path = { info = "Image path error.", level = vim.log.levels.ERROR },
}
M.success = {
	upload = { info = "Image upload success.", level = vim.log.levels.INFO },
}
M.info = {
	upload = { info = "Image start uploading...", level = vim.log.levels.INFO },
}

M.notify = function(msg, log_level)
	vim.notify(msg, log_level, { title = "nvim-picgo" })
end

return M
