-- Copier templates: detect the host language and overlay Jinja syntax.
return {
  {
    "HiPhish/jinja.vim",
    lazy = false, -- filetype detection must be available before opening templates
  },
}
