" autoload/tabline.vim
" Author: Jim Stewart <http://github.com/fweep/>

" Inspiration and portions of code from Powerline by
" Kim Silkebækken (https://github.com/Lokaltog/vim-powerline).

if exists('g:autoloaded_tabline') || &cp
  finish
endif
let g:autoloaded_tabline = '0.4.1'

" Initialization (Commands, Highlighting, Bindings) {{{

function! s:initialize_highlights() "{{{
  if exists('g:tablist_suppress_highlights') && g:tablist_suppress_highlights
    return
  endif

  execute 'hi FweepTabLine ctermfg=244 ctermbg=235'
  execute 'hi FweepTabLineSel cterm=reverse ctermfg=239 ctermbg=187'
  execute 'hi FweepTabLineFill ctermfg=244 ctermbg=235'

  "TODO: derive these from TabLine
  execute 'hi FweepTabLineTabNumber ctermbg=235 ctermfg=33'
  execute 'hi FweepTabLineTabNumberSel ctermbg=239 ctermfg=33'
  execute 'hi FweepTabLineWindowCount ctermbg=235 ctermfg=33'
  execute 'hi FweepTabLineWindowCountSel ctermbg=239 ctermfg=33'
  execute 'hi FweepTabLineModifiedFlag ctermbg=235 ctermfg=red'
  execute 'hi FweepTabLineModifiedFlagSel ctermbg=239 ctermfg=red'
  execute 'hi FweepTabLineDivider cterm=reverse ctermfg=239 ctermbg=235'
  execute 'hi FweepTabLineDividerSel ctermbg=235 ctermfg=239'
  execute 'hi FweepTabLineUserLabel ctermfg=173 ctermbg=235'
  execute 'hi FweepTabLineUserLabelSel ctermfg=173 ctermbg=239'
endfunction "}}}

function! s:initialize_dividers() "{{{
  let s:divider_characters = [ [0x2b80], [0x2b81], [0x2b82], [0x2b83] ]
  let s:divider_character_hard = s:ParseChars(deepcopy(s:divider_characters[0]))
  let s:divider_character_soft = s:ParseChars(deepcopy(s:divider_characters[1]))
endfunction "}}}

function! s:initialize_commands() "{{{
  if exists('g:tablist_suppress_commands') && g:tablist_suppress_commands
    return
  endif

  command! -range=0 -nargs=1 TabLineLabel   :call <SID>TabLineLabel(<count>, <line1>, <f-args>)
  command! -range=0 -nargs=0 TabLineClear   :call <SID>TabLineLabel(<count>, <line1>, '')
  command! -range=0 -nargs=? TabLineNew     :call <SID>TabLineNew(<count>, <line1>, <f-args>)
  command! -nargs=0 TabLineSelectLastActive :call <SID>TabLineSelectLastActive()
endfunction "}}}

function! s:initialize() "{{{
  let s:last_active_tab_number = 1
  call s:initialize_commands()
  call s:initialize_highlights()
  call s:initialize_dividers()
endfunction "}}}

" }}}

" Script Utility Functions {{{

function! s:last_tab_number() "{{{
  return tabpagenr('$')
endfunction "}}}

function! s:active_tab_number() "{{{
  return tabpagenr()
endfunction "}}}

function! s:save_active_tab_number() "{{{
  let s:last_active_tab_number = s:active_tab_number()
endfunction "}}}

function! s:last_active_tab_number() "{{{
  return s:last_active_tab_number
endfunction "}}}

function! s:error(message) "{{{
  echohl ErrorMsg
  echomsg a:message
  echohl None
  let v:errmsg = a:message
endfunction "}}}

function! s:error_tab_does_not_exist() "{{{
  return s:error('Tab does not exist.')
endfunction "}}}

function! s:tab_exists(tab_number) "{{{
  return a:tab_number > 0 && a:tab_number <= s:last_tab_number()
endfunction "}}}

function! s:set_label_for_tab_number(tab_number, label) "{{{
  call settabvar(a:tab_number, 'tabline_label', a:label)
endfunction "}}}

function! s:label_for_tab_number(tab_number) "{{{
  return gettabvar(a:tab_number, 'tabline_label')
endfunction "}}}

function! s:create_tab(new_tab_number) "{{{
  execute a:new_tab_number . 'tabnew'
endfunction "}}}

function! s:select_tab(tab_number) "{{{
  call s:save_active_tab_number()
  execute 'tabnext ' . a:tab_number
endfunction "}}}

function! s:mouse_handle_for_tab_number(tab_number) "{{{
  return '%' . a:tab_number . 'T'
endfunction "}}}

function! s:ParseChars(arg) "{{{
  "Copied from Powerline.
  let arg = a:arg
  if type(arg) == type([])
    call map(arg, 'nr2char(v:val)')
    return join(arg, '')
  endif
  return arg
endfunction "}}}

function! s:highlighted_text(highlight_name, text, is_active_tab) "{{{
  return '%#' . a:highlight_name . (a:is_active_tab ? 'Sel' : '') . '#' . a:text
endfunction "}}}

function! s:window_count_for_tab_number(tab_number, is_active_tab) "{{{
  let number_of_windows_in_tab = tabpagewinnr(a:tab_number, '$')
  if number_of_windows_in_tab > 1
    let text = ':' . s:highlighted_text('FweepTabLineWindowCount', number_of_windows_in_tab, a:is_active_tab)
  else
    let text = ''
  endif
  return text
endfunction "}}}

function! s:tab_contains_modified_buffers(tab_number) "{{{
  let tab_contains_modified_buffers = 0
  let tab_buffer_list = tabpagebuflist(a:tab_number)
  for buffer_number in tab_buffer_list
    let buffer_modified = getbufvar(buffer_number, '&modified')
    if buffer_modified
      let tab_contains_modified_buffers = 1
      break
    endif
  endfor
  return tab_contains_modified_buffers
endfunction "}}}

function! s:default_label_for_tab_number(tab_number)
  let tab_buffer_list = tabpagebuflist(a:tab_number)
  let window_number = tabpagewinnr(a:tab_number)
  let active_window_buffer_name = bufname(tab_buffer_list[window_number - 1])
  if !empty(active_window_buffer_name)
    let label = pathshorten(active_window_buffer_name)
  else
    let label = '[No Name]'
  endif
  return label
endfunction

" }}}

" Exported Functions {{{

function! tabline#TabLine() "{{{

  let tabline = ''

  for tab_number in range(1, s:last_tab_number())

    let is_active_tab = tab_number == s:active_tab_number()
    let tab_highlight = s:highlighted_text('FweepTabLine', '', is_active_tab)

    let tabline .= tab_highlight
    let tabline .= s:mouse_handle_for_tab_number(tab_number)
    let tabline .= s:highlighted_text('FweepTabLineTabNumber', ' ' . tab_number, is_active_tab) . tab_highlight
    let tabline .= s:window_count_for_tab_number(tab_number, is_active_tab) . tab_highlight

    if s:tab_contains_modified_buffers(tab_number)
      let tabline .= ' ' . s:highlighted_text('FweepTabLineModifiedFlag', '+', is_active_tab) . tab_highlight
    endif

    let user_label = s:label_for_tab_number(tab_number)

    if !empty(user_label)
      let tab_label = s:highlighted_text('FweepTabLineUserLabel', user_label, is_active_tab) . tab_highlight
    else
      let tab_label = s:default_label_for_tab_number(tab_number)
    endif

    let tabline .= ' ' . tab_label . ' '

    if ((s:active_tab_number() == tab_number) || (s:active_tab_number() == (tab_number + 1)))
      let tabline .= s:highlighted_text('FweepTabLineDivider', s:divider_character_hard, is_active_tab)
    elseif tab_number != s:last_tab_number()
      let tabline .= s:divider_character_soft
    endif

  endfor

  let tabline .= '%#FweepTabLineFill#%T'

  if s:last_tab_number() > 1
    let tabline .= '%='
    let tabline .= '%#FweepTabLine#%999Xclose'
  endif

  return tabline

endfunction "}}}

function! s:TabLineSelectLastActive() "{{{
  if s:tab_exists(s:last_active_tab_number())
    call s:select_tab(s:last_active_tab_number())
  else
    call s:select_tab(1)
  endif
endfunction "}}}

function! s:command_count(count, line1)
  let command_count = ''
  if a:count == a:line1
    if a:count == 0
      let command_count = '0'
    else
      let command_count = a:line1
    endif
  endif
  return command_count
endfunction

function! s:TabLineNew(count, line1, ...) "{{{
  execute s:command_count(a:count, a:line1) . 'tabnew'
  if a:0 == 1
    call s:set_label_for_tab_number(s:active_tab_number(), a:1)
  endif
  redraw!
endfunction "}}}

function! s:TabLineLabel(count, line1, label) "{{{
  let command_count = s:command_count(a:count, a:line1)
  let tab_number = empty(command_count) ? s:active_tab_number() : command_count
  if !s:tab_exists(tab_number)
    call s:error_tab_does_not_exist()
  else
    call s:set_label_for_tab_number(tab_number, a:label)
    redraw!
  endif
endfunction "}}}

" }}}

call s:initialize()
