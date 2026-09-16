return {
	{
		"mfussenegger/nvim-jdtls",
		ft = "java",
		config = function()
			local jdtls = require("jdtls")
			local mason = vim.fn.stdpath("data") .. "/mason"

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "java",
				callback = function()
					if vim.fn.executable(mason .. "/bin/jdtls") == 0 then
						vim.notify("Install jdtls with :Mason", vim.log.levels.WARN)
						return
					end
					local root = jdtls.setup.find_root({ "pom.xml", "build.gradle", ".git" })
					if not root then return end
					jdtls.start_or_attach({
						cmd = { mason .. "/bin/jdtls" },
						root_dir = root,
						settings = {
							java = {
								runtimes = {
									{ name = "JavaSE-17", path = "/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home" },
								},
							},
						},
					})
				end,
			})
		end,
	},
}
