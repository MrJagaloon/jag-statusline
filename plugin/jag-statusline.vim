
if exists("g:loaded_jagstl") && g:loaded_jagstl
    finish
endif
let g:loaded_jagstl = 1

let s:default_sections = [
  \ jagstl#sections#mode,
  \ { 'fnc': " jagstl#sections#get_cwd() ", 'fg': 07, 'bg': 08 },
  \ { 'fmt': " %t ", 'fg': 02, 'bg': 00 },
  \ { 'fmt': "%=" },
  \ { 'fmt': " %(%m%r%h%w) ", 'fg': 07, 'bg': 00 },
  \ { 'fmt': " %c : %l/%L %p%% ", 'fg': 07, 'bg': 08 },
  \ { 'fmt': " %y ", 'fg': 00, 'bg': 02 }
  \ ]
lockvar s:default_sections

" Script Func: init {{{
" Initialize the status line by setting all sections and their highlights.
let s:initialized = 0
function! s:init()
    if s:initialized
        return
    endif
    let s:initialized = 1

    call s:refresh_sections()
    call s:refresh_highlights()

    autocmd! ColorScheme * call s:refresh_highlights() | 
      \ call jagstl#sections#refresh_highlights()

    command! JagstlRefresh call s:refresh_sections() | 
      \ call s:refresh_highlights() 
      \ call jagstl#sections#refresh_highlights()

endfunction
" }}}
" Script Func: refresh_sections {{{
" Rebuilds the status line using the defined sections.
function! s:refresh_sections()
    let s:stl = ""
    let l:idx = 0
    while s:is_section(l:idx)
        let s:stl .= s:get_section_string(idx) 
        let l:idx += 1
    endwhile
    let &statusline=s:stl
endfunction
" }}}
" Group: Status Line Sections {{{ ----------------------------------------------
" Script Func: is_section {{{
" Returns a flag indicating if there exists a section at the given index in
" g:jagstl#sections. If g:jagstl#sections does not exist, checks 
" s:default_sections.
function! s:is_section(idx)
    return type(s:get_section(a:idx)) == v:t_dict
endfunction
" }}}
" Script Func: get_section {{{
" If g:jagstl#sections exists, and a section exists at the given index within 
" g:jagstl#sections, return the section. Else, if a section exists at the index 
" in s:default_sections, return the section. Otherwise return null.
function! s:get_section(idx)
    let l:sec = v:null
    if exists("g:jagstl#sections")
        if exists("g:jagstl#sections[a:idx]")
            let l:sec = g:jagstl#sections[a:idx]
        endif
    elseif exists("s:default_sections[a:idx]")
        let l:sec s:default_sections[a:idx]
    endif
    return l:sec
endfunction
" }}}
" Script Func: get_section_string {{{
" Returns the string to be used in the status line for the given section.
" The string includes the section's highlight group and format string.
function! s:get_section_string(idx)
    let l:section_str = ""

    if s:section_has_highlight(a:idx)
        let l:section_str .= "%#" . s:get_section_highlight_group(a:idx) . "#"
    endif

    let l:sec = s:get_section(a:idx)
    if exists("l:sec['fnc']")
        let l:section_str .= eval(l:sec['fnc'])
    elseif exists("l:sec['fmt']")
        let l:section_str .= l:sec['fmt']
    endif

    return l:section_str
endfunction
" }}}
" }}}
" Group: Section Highlights {{{ ------------------------------------------------
" Script Func: refresh_highlights {{{
" Reset highlights for all sections
function! s:refresh_highlights()
    let l:idx = 0
    while s:is_section(l:idx)
        call s:refresh_section_highlight(l:idx)
        let l:idx += 1
    endwhile
endfunction
" }}}
" Script Func: refresh_section_highlight {{{
" Update highlights for the section at the given index.
function! s:refresh_section_highlight(idx)
    if s:section_has_highlight(a:idx) != 1
        return
    endif
    let l:sec = s:get_section(a:idx)

    let l:cmd = "hi " . s:get_section_highlight_group(a:idx)
    if exists("l:sec['fg']")
        let l:cmd .= ' ctermfg=' . l:sec['fg']
    endif
    if exists("l:sec['bg']")
        let l:cmd .= ' ctermbg=' . l:sec['bg']
    endif
    if exists("l:sec['guifg']")
        let l:cmd .= ' guifg=' . l:sec['guifg']
    endif
    if exists("l:sec['guibg']")
        let l:cmd .= ' guibg=' . l:sec['guibg']
    endif
    if exists("l:sec['attr']")
        let l:cmd .= ' cterm=' . l:sec['attr']
    endif

    execute l:cmd
endfunction
" }}}
" Script Func: section_has_highlight {{{
" Returns an int indicating if the section at idx has any highlight attributes.
" Returns 2 if the section specifies the highlight group (hi). Returns 1 if the
" Section specifies any specific highlight attributes (fg, bg, guifg, guibg, 
" attr). Returns 0 otherwise.
function! s:section_has_highlight(idx)
    let l:sec = s:get_section(a:idx)
    if exists("l:sec['hi']")
        return 2
    elseif exists("l:sec['fg']") || exists("l:sec['bg']") || 
         \ exists("l:sec['guifg']") || exists("l:sec['guibg']") || 
         \ exists("l:sec['attr']")
        return 1
    else 
        return 0
    endif
endfunction
" }}}
" Script Func: get_section_highlight_group {{{
" Returns the name of the section's highlight group. If the section has no 
" highlight group, returns "".
function! s:get_section_highlight_group(idx)
    let l:has_hi = s:section_has_highlight(a:idx)
    if l:has_hi == 2
        return s:get_section(a:idx)['hi']
    elseif l:has_hi == 1
        return 'jagstl_section_' . a:idx
    else
        return ""
    endif
endfunction
" }}}
" }}}

if exists("g:jagstl#enabled") && g:jagstl#enabled
    call s:init()
endif

" vim:foldmethod=marker
