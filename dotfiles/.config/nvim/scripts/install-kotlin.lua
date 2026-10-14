local success, err = pcall(function()
  require("lazy").load({ plugins = { "mason.nvim" } })
  local registry = require("mason-registry")
  local ready = false
  registry.refresh(function()
    ready = true
  end)
  assert(vim.wait(60000, function()
    return ready
  end, 100))
  local package = registry.get_package("kotlin-lsp")
  -- The public host issues the signed CDN redirect; the registry's direct CDN URL returns 403.
  for _, download in ipairs(package.spec.source.download) do
    for name, url in pairs(download.files) do
      download.files[name] = url:gsub("https://download%-cdn%.jetbrains%.com/", "https://download.jetbrains.com/")
    end
  end
  if not package:is_installed() and not package:is_installing() then
    package:install()
  end
  assert(
    vim.wait(360000, function()
      return not package:is_installing()
    end, 200),
    "Kotlin LSP installation timeout"
  )
  assert(package:is_installed(), "Kotlin LSP installation failed; see Mason logs")
  print("Official Kotlin LSP installed")
end)
if success then
  vim.cmd("qa!")
else
  io.stderr:write(tostring(err) .. "\n")
  vim.cmd("cquit")
end
