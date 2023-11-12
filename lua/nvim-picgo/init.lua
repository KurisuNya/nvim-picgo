local nvim_picgo = {}

local default_config = {
	notice = "notify",
	image_name = false,
	debug = false,
}
local stop_jobs_message = {
	"%[PicGo WARN%]: can't get",
	"%[PicGo ERROR%]",
	"does not exist",
}

local function notice(state)
	if state then
		local msg = "Upload image success"
		if default_config.notice == "notify" then
			vim.notify(msg, "info", { title = "Nvim-picgo" })
		else
			vim.api.nvim_echo({ { msg, "MoreMsg" } }, true, {})
		end
	else
		local msg = "Upload image failed"
		if default_config.notice == "notify" then
			vim.notify(msg, "error", { title = "Nvim-picgo" })
		else
			vim.api.nvim_echo({ { msg, "ErrorMsg" } }, true, {})
		end
	end
end

local function callbackfn(job_id, data, _)
	if default_config.debug then
		vim.pretty_print(data)
	end
	for _, err in ipairs(stop_jobs_message) do
		if data[1]:match(err) then
			notice(false)
			vim.fn.jobstop(job_id)
			return
		end
	end
	if data[1]:match("%[PicGo SUCCESS%]:") then
		notice(true)
		local markdown_image_link
		if default_config.image_name then
			markdown_image_link = string.format("![%s](%s)", vim.fn.fnamemodify(data[2], ":t:r"), data[2])
		else
			markdown_image_link = string.format("![](%s)", data[2])
		end
		vim.fn.setreg(vim.v.register, markdown_image_link)
	end
end

function nvim_picgo.setup(conf)
	if vim.fn.executable("picgo") ~= 1 then
		vim.api.nvim_echo({ { "Missing picgo-core dependencies", "ErrorMsg" } }, true, {})
		return
	end
	default_config = vim.tbl_extend("force", default_config, conf or {})
	-- Create autocommand
	vim.api.nvim_create_user_command("PicgoUpload", nvim_picgo.upload_imagefile, { nargs = "?" })
end

function nvim_picgo.upload_imagefile(opts)
	local image_path = opts.args or ""
	if string.len(image_path) == 0 then
		image_path = vim.fn.input("Image path: ")
	end

	if string.len(image_path) == 0 then
		if default_config.notice == "notify" then
			vim.notify("The image path is empty", "error", { title = "Nvim-picgo" })
		else
			vim.api.nvim_echo({ { "The image path is empty", "ErrorMsg" } }, true, {})
		end
		return
	end

	if image_path:find("~") then
		local home_dir = vim.fn.trim(vim.fn.shellescape(vim.fn.fnamemodify("~", ":p")), "'")
		image_path = home_dir .. image_path:sub(3)
	end

	if vim.fn.filereadable(image_path) ~= 1 then
		if default_config.notice == "notify" then
			vim.notify("The image path is not valid", "error", { title = "Nvim-picgo" })
		else
			vim.api.nvim_echo({ { "Image path is not valid", "ErrorMsg" } }, true, {})
		end
		return
	end

	assert(vim.fn.filereadable(image_path) == 1, "The image path is not valid")

	if default_config.notice == "notify" then
		vim.notify("Image start uploading...", "info", { title = "Nvim-picgo" })
	else
		vim.api.nvim_echo({ { "Image start uploading...", "MoreMsg" } }, true, {})
	end

	vim.fn.jobstart({ "picgo", "u", image_path }, {
		on_stdout = callbackfn,
	})
end

return nvim_picgo
