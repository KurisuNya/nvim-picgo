local message = require("nvim-picgo.message")
local picgo = require("nvim-picgo.picgo")

local default_opts = {
	add_image_name = false,
	auto_paste = false,
	debug = false,
}

local function callbackfn(job_id, data, _)
	if default_opts.debug then
		vim.pretty_print(data)
	end
	-- check error
	if picgo.check_data_error(data) then
		vim.fn.jobstop(job_id)
		message.notify(message.error.upload.info, message.error.upload.level)
	end
	-- check success
	if picgo.check_data_success(data) then
		local markdown_link = picgo.get_markdown_link(data, default_opts.add_image_name)
		if default_opts.auto_paste then
			vim.api.nvim_put({ markdown_link }, "l", true, false)
		else
			vim.fn.setreg(vim.v.register, markdown_link .. "\n")
		end
		message.notify(message.success.upload.info, message.success.upload.level)
	end
end

local M = {}

function M.upload_imagefile(opts)
	-- get image path
	local image_path = opts.args or opts.path or ""
	if string.len(image_path) == 0 then
		image_path = vim.fn.input("Image path: ")
	end
	if string.len(image_path) == 0 then
		message.notify(message.error.path.info, message.error.path.level)
		return
	end
	if image_path:find("~") then -- replace ~ with $HOME
		local home_dir = vim.fn.trim(vim.fn.shellescape(vim.fn.fnamemodify("~", ":p")), "'")
		image_path = home_dir .. image_path:sub(3)
	end
	if vim.fn.filereadable(image_path) ~= 1 then
		message.notify(message.error.path.info, message.error.path.level)
		return
	end
	-- start upload
	message.notify(message.info.upload.info, message.info.upload.level)
	vim.fn.jobstart({ "picgo", "u", image_path }, { on_stdout = callbackfn })
end

function M.setup(opts)
	if not picgo.check_core_ready() then
		message.notify(message.error.core.info, message.error.core.level)
		return
	end
	default_opts = vim.tbl_extend("force", default_opts, opts or {})
	vim.api.nvim_create_user_command("PicgoUpload", M.upload_imagefile, { nargs = "?" })
end

return M
