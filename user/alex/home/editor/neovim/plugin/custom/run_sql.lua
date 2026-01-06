local function run_sql()
	local db_url = os.getenv("NVIM_DATABASE_URL") or os.getenv("DATABASE_URL")
	if not db_url then
		vim.notify(
			"No database URL found in NVIM_DATABASE_URL or DATABASE_URL",
			"error"
		)
		return
	end

	-- for now with dadbod
	vim.cmd("%DB " .. db_url)
end

vim.api.nvim_create_user_command("RunSql", run_sql, {});
