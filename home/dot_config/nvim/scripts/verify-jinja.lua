-- Run headlessly with the repository config; see README.md.
local root = vim.fn.tempname()
vim.fn.mkdir(root, "p")
root = assert(vim.uv.fs_realpath(root))
local cases = {
  { "Example.kt.jinja", "kotlin.jinja", "class Example", "kotlin" },
  { "main.py.jinja", "python.jinja", "class Example:", "python" },
  { "copier.yml.jinja", "yaml.jinja", "name: example", "yaml" },
  { "pyproject.toml.jinja", "toml.jinja", 'name = "example"', "toml" },
  { "Example.kt.j2", "kotlin.jinja", "class Example", "kotlin" },
  { "main.py.jinja2", "python.jinja", "class Example:", "python" },
  { "template.jinja", "jinja", "hello" },
  { "{{root_project}}/{% if enabled %}module{% endif %}/Example.kt.jinja", "kotlin.jinja", "class Example", "kotlin" },
  { "{{root_project}}/{% if enabled %}module{% endif %}/README.md.jinja", "markdown.jinja", "# Example", "markdown" },
}
local function group(line, col)
  return vim.fn.synIDattr(vim.fn.synID(line, col, 1), "name")
end
local ok, err = pcall(function()
  assert(vim.g.autoformat == false)
  for _, case in ipairs(cases) do
    local path = root .. "/" .. case[1]
    vim.fn.mkdir(vim.fs.dirname(path), "p")
    vim.fn.writefile(
      { case[3], "{{ package_name }}", "{% if enabled %}", "{# template comment #}", "{% endif %}" },
      path
    )
    vim.cmd.edit(vim.fn.fnameescape(path))
    vim.wait(100)
    assert(
      vim.api.nvim_buf_get_name(0) == path,
      case[1] .. ": buffer path was corrupted: " .. vim.api.nvim_buf_get_name(0) .. " (expected " .. path .. ")"
    )
    local tree = require("snacks.explorer.tree")
    tree:open(vim.api.nvim_buf_get_name(0))
    tree:walk(tree:find(root), function(node)
      if node.dir and node.open then
        assert(vim.uv.fs_stat(node.path), "Explorer would watch a nonexistent directory: " .. node.path)
      end
    end)
    assert(vim.bo.filetype == case[2], case[1] .. ": " .. vim.bo.filetype)
    assert(vim.bo.syntax ~= "", case[1] .. ": syntax disabled (ft=" .. vim.bo.filetype .. ")")
    assert(group(2, 4):match("jinja"), case[1] .. ": expression not highlighted: " .. group(2, 4))
    assert(group(3, 4):match("jinja"), case[1] .. ": statement not highlighted")
    assert(group(4, 4):match("jinja"), case[1] .. ": comment not highlighted")
    assert(#vim.lsp.get_clients({ bufnr = 0 }) == 0, case[1] .. ": unexpected LSP")
    if case[4] then
      assert(group(1, 1) ~= "", case[1] .. ": host syntax absent")
      assert(vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()], case[1] .. ": Tree-sitter inactive")
      local parser = vim.treesitter.get_parser(0, case[4])
      assert(parser:parse()[1], case[1] .. ": host parser failed")
    end
    print("PASS " .. case[1] .. " → " .. vim.bo.filetype .. " (syntax=" .. vim.bo.syntax .. ")")
    vim.cmd.bwipeout()
  end
end)
vim.fn.delete(root, "rf")
if not ok then
  vim.api.nvim_err_writeln(tostring(err))
  vim.cmd("cquit 1")
end
vim.cmd.qa()
