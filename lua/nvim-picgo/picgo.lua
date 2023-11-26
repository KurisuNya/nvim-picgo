local error_messages = {
	"%[PicGo WARN%]: can't get",
	"%[PicGo ERROR%]",
	"does not exist",
}

local success_messages = {
	"%[PicGo SUCCESS%]:",
}

local M = {}

M.check_error = function(data)
	for _, msg in ipairs(error_messages) do
		if data[1]:match(msg) then
			return true
		end
	end
	return false
end

M.check_success = function(data)
	for _, msg in ipairs(success_messages) do
		if data[1]:match(msg) then
			return true
		end
	end
	return false
end

M.get_markdown_link = function(data, add_image_name)
	local markdown_image_link
	if add_image_name then
		markdown_image_link = string.format("![%s](%s)", vim.fn.fnamemodify(data[2], ":t:r"), data[2])
	else
		markdown_image_link = string.format("![](%s)", data[2])
	end
	return markdown_image_link
end

return M
