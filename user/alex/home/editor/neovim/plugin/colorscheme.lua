local function setup_vity()
	local status, vity = pcall(require, "vity")
	if not status then
		vim.notify("vity not found", vim.log.levels.ERROR, { title = "vity" })
		vim.notify(vity, vim.log.levels.TRACE, { title = "vity" })
		return
	end

	local status, _ = pcall(vity.setup)
	if not status then
		vim.notify("vity setup failed", vim.log.levels.ERROR, { title = "vity" })
		return
	end
end
setup_vity()
