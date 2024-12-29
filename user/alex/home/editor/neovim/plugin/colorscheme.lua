local function setup_vity()
	local plugin_name = "vity"

	local status, vity = pcall(require, plugin_name)
	if not status then
		vim.notify(plugin_name ..
			" not found\t(check trace with :Notifications)",
			vim.log.levels.ERROR, { title = plugin_name })
		vim.notify(vity, vim.log.levels.TRACE, { title = plugin_name })
		return
	end

	local status, err = pcall(vity.setup)
	if not status then
		vim.notify(plugin_name ..
			".setup() failed\t(check trace with :Notifications)",
			vim.log.levels.ERROR, { title = plugin_name })
		vim.notify(err, vim.log.levels.TRACE, { title = plugin_name })
		return
	end
end

setup_vity()
