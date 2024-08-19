local notify = require("notify")

vim.notify = notify;

notify.setup({
	render = "default",
	stages = "slide",
})
