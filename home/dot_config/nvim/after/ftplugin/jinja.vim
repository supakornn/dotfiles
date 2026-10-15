" Keep the Jinja syntax overlay when Tree-sitter highlights the host language.
" get_lang('jinja') returns a name even without a parser on newer Neovim.
if !get(b:, 'jinja_syntax_autocmd_loaded', v:false)
    autocmd FileType <buffer> if !empty(&ft) | setlocal syntax=on | endif
    let b:jinja_syntax_autocmd_loaded = v:true
endif
