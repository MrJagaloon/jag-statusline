
function! jagstl#sections#refresh_highlights()
    if exists('s:mode_in_use') && s:mode_in_use
        call s:update_mode_highlight()
    endif
endfunction

" Section: Mode {{{ ---------------------------------------------------------------------
" To be use as an entire section in jagstl to enable dynamic colors.
if !exists('jagstl#sections#mode')
    let jagstl#sections#mode = { 
      \ 'fmt': " %{jagstl#sections#get_mode()} ", 
      \ 'hi': "jagstl_section_mode" 
      \ }
    lockvar jagstl#sections#mode
endif

if !exists('s:default_modes')
    let s:default_modes = { 
      \ 'normal':       { 'str': 'N',  'fg': 00, 'bg': 02 }, 
      \ 'insert':       { 'str': 'I',  'fg': 00, 'bg': 04 }, 
      \ 'replace':      { 'str': 'R',  'fg': 00, 'bg': 01 }, 
      \ 'visual':       { 'str': 'V',  'fg': 00, 'bg': 05 },
      \ 'visual_line':  { 'str': 'VL', 'fg': 00, 'bg': 05 },
      \ 'visual_block': { 'str': 'VB', 'fg': 00, 'bg': 05 }
      \ }
    lockvar s:default_modes
endif

let s:curr_mode_key = ""

" Returns a status line section with a format and color indicating the user's
" current mode. 
function! jagstl#sections#get_mode()
    let s:mode_in_use = 1
    call s:update_curr_mode()
    return s:curr_mode['str']
endfunction

" Returns the key of the user's current mode. 
function! s:update_curr_mode()
    let l:new_mode_key = 'normal'

    let l:code = mode()

    if l:code ==# 'i'
        let l:new_mode_key = 'insert'
    elseif l:code ==# 'R'
        let l:new_mode_key = 'replace'
    elseif l:code ==# 'v'
        let l:new_mode_key = 'visual'
    elseif l:code ==# 'V'
        let l:new_mode_key = 'visual_line'
    elseif mode(1) ==# ''
        let l:new_mode_key = 'visual_block'
    endif

    if s:curr_mode_key != l:new_mode_key
        let s:curr_mode_key = l:new_mode_key
        let s:curr_mode = s:get_mode(s:curr_mode_key)
        call s:update_mode_highlight()
    endif
endfunction

" Update the mode section highlighting
function! s:update_mode_highlight()
    let l:cmd = ""
    if exists("s:curr_mode['fg']")
        let l:cmd .= ' ctermfg=' . s:curr_mode['fg']
    else
    endif
    if exists("s:curr_mode['bg']")
        let l:cmd .= ' ctermbg=' . s:curr_mode['bg']
    endif
    if exists("s:curr_mode['attr']")
        let l:cmd .= ' cterm='   . s:curr_mode['attr']
    endif

    if l:cmd != ""
        exec 'hi jagstl_section_mode' . l:cmd
    endif
endfunction

" If the given key exists in g:jagstl#sections#modes, return is value. Else if 
" it exists in s:default_modes, return its value. Otherwise, return null.
function! s:get_mode(mode_key)
    let l:mode = v:null
    if exists("g:jagstl#sections#modes") && exists("g:jagstl#sections#modes[a:mode_key]")
        let l:mode = g:jagstl#sections#modes[a:mode_key]
    elseif exists("s:default_modes[a:mode_key]")
        let l:mode = s:default_modes[a:mode_key]
    endif
    return l:mode
endfunction
" }}}
" Section: CWD {{{ -------------------------------------------------------------
" Return the CWD with $HOME replaced by ~. If an argument is passed and is 
" evaluated as true, include a '/' at the end of the CWD.
function! jagstl#sections#get_cwd(...)
    let l:cwd = getcwd()
    let l:fmtd_cwd = substitute(getcwd(), $HOME, "~", "")
    if exists("a:0") && a:0
        let l:fmtd_cwd .= '/'
    endif
    return l:fmtd_cwd
endfunction
" }}}

" vim:foldmethod=marker
