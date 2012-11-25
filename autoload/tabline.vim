" autoload/tabline.vim
" Author: Jim Stewart <http://github.com/fweep/>

" Inspiration and portions of code from Powerline by
" Kim Silkebækken (https://github.com/Lokaltog/vim-powerline).

if exists('g:autoloaded_tabline') || &cp
  finish
endif
let g:autoloaded_tabline = '0.2.0'

function! s:initialize_highlights()
  if exists('g:tablist_suppress_highlights') && g:tablist_suppress_highlights
    return
  endif

  exec 'hi FweepTabLineTabNumber ctermbg=235 ctermfg=33'
  exec 'hi FweepTabLineTabNumberSel ctermbg=239 ctermfg=33'
  exec 'hi FweepTabLineWindowCount ctermbg=235 ctermfg=33'
  exec 'hi FweepTabLineWindowCountSel ctermbg=239 ctermfg=33'
  exec 'hi FweepTabLineModifiedFlag ctermbg=235 ctermfg=red'
  exec 'hi FweepTabLineModifiedFlagSel ctermbg=239 ctermfg=red'
  exec 'hi FweepTabLine ctermfg=244 ctermbg=235'
  exec 'hi FweepTabLineSel cterm=reverse ctermfg=239 ctermbg=187'
  exec 'hi FweepTabLineFill ctermfg=244 ctermbg=235'
  exec 'hi FweepTabLineDivider cterm=reverse ctermfg=239 ctermbg=235'
  exec 'hi FweepTabLineDividerSel ctermbg=235 ctermfg=239'
  exec 'hi FweepTabLineUserLabel ctermfg=173 ctermbg=235'
  exec 'hi FweepTabLineUserLabelSel ctermfg=173 ctermbg=239'
endfunction

function! s:ParseChars(arg)
  "Copied from Powerline.
  let arg = a:arg
  if type(arg) == type([])
    call map(arg, 'nr2char(v:val)')
    return join(arg, '')
  endif
  return arg
endfunction

function! s:initialize_dividers()
  let s:divider_characters = [ [0x2b80], [0x2b81], [0x2b82], [0x2b83] ]
  let s:divider_character_hard = s:ParseChars(deepcopy(s:divider_characters[0]))
  let s:divider_character_soft = s:ParseChars(deepcopy(s:divider_characters[1]))
endfunction

function! s:initialize_commands()
  if exists('g:tablist_suppress_commands') && g:tablist_suppress_commands
    return
  endif

  command! -nargs=+ TabLineLabel            :call tabline#TabLineLabel(<f-args>)
  command! -nargs=1 TabLineClear            :call tabline#TabLabelClear(<f-args>)
  command! -nargs=? TabLineNew              :call tabline#TabLineNew(<f-args>)
  command! -nargs=1 TabLineSelect           :call tabline#TabLineSelect(<f-args>)
  command! -nargs=? TabLineClose            :call tabline#TabLineClose(<f-args>)
  command! -nargs=0 TabLineSelectLastActive :call tabline#TabLineSelectLastActive()
endfunction

function! s:initialize()
  let s:last_active_tab_number = 1
  let s:tab_labels = {}
  call s:initialize_commands()
  call s:initialize_highlights()
  call s:initialize_dividers()
endfunction

call s:initialize()

"-----

function! s:error(message)
  echohl ErrorMsg
  echomsg a:message
  echohl None
  let v:errmsg = a:message
endfunction

function! s:error_tab_does_not_exist()
  return s:error('Tab does not exist.')
endfunction

function! s:number_of_open_tabs()
  return tabpagenr('$')
endfunction

function! s:tab_exists(tab_number)
  return a:tab_number > 0 && a:tab_number <= s:number_of_open_tabs()
endfunction

function! s:set_label(label, tab_number)
  let s:tab_labels[a:tab_number] = a:label
endfunction

function! s:label_exists_for_tab_number(tab_number)
  return exists('s:tab_labels') && has_key(s:tab_labels, a:tab_number)
endfunction

function! s:label_for_tab_number(tab_number)
  return get(s:tab_labels, a:tab_number)
endfunction

function! s:remove_label(tab_number)
  if s:label_exists_for_tab_number(a:tab_number)
    unlet s:tab_labels[a:tab_number]
  endif
endfunction

function! s:close_tab(tab_number)
  "FIXME: shift labels left
  "FIXME: honor g:tabline_sticky_labels
  call s:remove_label(a:tab_number)
  execute 'tabclose ' . a:tab_number
endfunction

function! s:active_tab_number()
  return tabpagenr()
endfunction

function! s:save_active_tab_number()
  let s:last_active_tab_number = s:active_tab_number()
endfunction

function! s:last_active_tab_number()
  return s:last_active_tab_number
endfunction

function! s:create_tab(new_tab_number)
  execute a:new_tab_number . 'tabnew'
endfunction

function! s:select_tab(tab_number)
  call s:save_active_tab_number()
  execute 'tabnext ' . a:tab_number
endfunction

function! s:first_tab()
  return 1
endfunction

function! s:mouse_handle_for_tab_number(tab_number)
  return '%' . a:tab_number . 'T'
endfunction

"-----

function! tabline#TabLineSelectLastActive()
  if s:tab_exists(s:last_active_tab_number())
    call s:select_tab(s:last_active_tab_number())
  else
    call s:error('Last active tab no longer exists; selecting tab 1.')
    call s:select_tab(s:first_tab())
  endif
endfunction

function! tabline#TabLineClose(...)
  if a:0
    let tab_number = a:1
  else
    let tab_number = s:active_tab_number()
  endif

  if tab_number == 1 && s:number_of_open_tabs() == 1
    call s:error("Cannot close the last tab.")
  elseif !s:tab_exists(tab_number)
    call s:error_tab_does_not_exist()
  else
    call s:close_tab(tab_number)
  endif
endfunction

function! tabline#TabLineSelect(tab_number)
  if !s:tab_exists(tab_number)
    call s:error_tab_does_not_exist()
  else
    call s:select_tab(a:tab_number)
  endif
endfunction

function! tabline#TabLineNew(...)
  let new_tab_number = s:number_of_open_tabs() + 1
  if a:0 == 1
    call s:set_label(a:1, new_tab_number)
  endif
  call s:create_tab(new_tab_number)
  redraw!
endfunction

function! tabline#TabLineLabel(label, ...)
  let tab_number = a:0 == 1 ? a:1 : s:active_tab_number()
  if !s:tab_exists(tab_number)
    call s:error_tab_does_not_exist()
  else
    call s:set_label(a:label, tab_number)
    redraw!
  endif
endfunction

function! tabline#TabLabelClear(tab_number)
  if !s:tab_exists(tab_number)
    call s:error_tab_does_not_exist()
  else
    call s:remove_label(a:tab_number)
    redraw!
  endif
endfunction

function! tabline#TabLine()
  let s = ''

  for tab_index in range(s:number_of_open_tabs())

    let tab_number = tab_index + 1
    let window_number = tabpagewinnr(tab_number)
    let number_of_windows_in_tab = tabpagewinnr(tab_number, '$')

    let sel = tab_number == s:active_tab_number() ? 'Sel' : ''
    let tab_highlight = '%#FweepTabLine' . sel . '#'

    let s .= tab_highlight . ' '
    let s .= s:mouse_handle_for_tab_number(tab_number)
    let s .= '%#FweepTabLineTabNumber' . sel . '#' .tab_number . tab_highlight

    if number_of_windows_in_tab > 1
      let s .= ':' . '%#FweepTabLineWindowCount' . sel . '#' . number_of_windows_in_tab . tab_highlight
    endif

    let tab_contains_modified_buffers = 0
    let tab_buffer_list = tabpagebuflist(tab_number)
    for buffer_number in tab_buffer_list
      let buffer_modified = getbufvar(buffer_number, '&modified')
      if buffer_modified
        let tab_contains_modified_buffers = 1
      endif
    endfor

    if tab_contains_modified_buffers
      let s .= ' ' . '%#FweepTabLineModifiedFlag' . sel . '#+' . tab_highlight
    endif

    let active_window_buffer_name = bufname(tab_buffer_list[window_number - 1])
    if active_window_buffer_name != ''
      let default_tab_label = pathshorten(active_window_buffer_name)
    else
      let default_tab_label = '[No Name]'
    endif

    if s:label_exists_for_tab_number(tab_number)
      let tab_label = '%#FweepTabLineUserLabel' . sel . '#' . s:label_for_tab_number(tab_number) . tab_highlight
    else
      let tab_label = default_tab_label
    endif

    let s .= ' ' . tab_label

    let s .= '%T '

    if ((s:active_tab_number() == tab_number) || (s:active_tab_number() == (tab_number + 1)))
      let s .= '%#FweepTabLineDivider' . sel . '#' . s:divider_character_hard . tab_highlight
    elseif tab_number != s:number_of_open_tabs()
      let s .= s:divider_character_soft
    endif

  endfor

  let s .= '%#FweepTabLineFill#%=%999XX'

  return s
endfunction
