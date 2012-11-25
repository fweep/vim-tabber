" autoload/tabline.vim
" Author: Jim Stewart <http://github.com/fweep/>

"Checks for tab changes constantly..

" TODO {{{

" keeps losing last know number of tabs

" }}}

" Inspiration and portions of code from Powerline by
" Kim Silkebækken (https://github.com/Lokaltog/vim-powerline).

" Code Notes {{{
" The original version of this script relied on TabEnter/TabLeave events
" to identify changes in tab arrangement and adjust accordingly.
" Unfortunately, deleting a non-focused tab does not trigger any events.
" It now uses tabpage-variables to track the last known position and adjust
" labels on every refresh of tabline#TabLine().  If anyone knows of a way
" to detect the closure of a non-focused tab, please let me know!  See
" s:check_for_tab_changes().
" }}}

if exists('g:autoloaded_tabline') || &cp
  finish
endif
let g:autoloaded_tabline = '0.2.0'

" Initialization (Commands, Highlighting, Bindings) {{{

function! s:initialize_highlights() "{{{
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

  command! -nargs=+ TabLineLabel            :call tabline#TabLineLabel(<f-args>)
  command! -nargs=1 TabLineClear            :call tabline#TabLabelClear(<f-args>)
  command! -nargs=? TabLineNew              :call tabline#TabLineNew(<f-args>)
  command! -nargs=1 TabLineSelect           :call tabline#TabLineSelect(<f-args>)
  command! -nargs=? TabLineClose            :call tabline#TabLineClose(<f-args>)
  command! -nargs=0 TabLineSelectLastActive :call tabline#TabLineSelectLastActive()
endfunction "}}}

function! s:initialize_last_known_tab_numbers() "{{{
  for tab_number in range(1, s:last_tab_number())
    call s:set_last_known_tab_number(tab_number)
  endfor
endfunction "}}}

function! s:initialize_tab_properties() "{{{
  let s:tab_properties = {}
  for tab_number in range(1, s:last_tab_number())
    call s:create_properties_for_tab_number(tab_number)
  endfor
endfunction "}}}

function! s:initialize() "{{{
  let s:last_active_tab_number = 1
  let g:bufline_last_known_number_of_tabs = s:last_tab_number()
  call s:initialize_last_known_tab_numbers()
  call s:initialize_tab_properties()
  call s:initialize_commands()
  call s:initialize_highlights()
  call s:initialize_dividers()
endfunction "}}}

" }}}

" Tab Property Management {{{

function! s:create_properties_for_tab_number(new_tab_number) "{{{
  let s:tab_properties[a:new_tab_number] = { }
endfunction "}}}

function! s:remove_properties_for_tab_number(tab_number) "{{{
  unlet s:tab_properties[a:tab_number]
endfunction "}}}

function! s:shift_property_right_for_tab_number(tab_number)  "{{{
  let s:tab_properties[a:tab_number + 1] = deepcopy(s:tab_properties[a:tab_number])
endfunction "}}}

function! s:shift_properties_right_for_tab_number(new_tab_number) "{{{
  for tab_number in range(s:last_tab_number() - 1, a:new_tab_number - 1, -1)
    call s:shift_property_right_for_tab_number(tab_number)
  endfor
endfunction "}}}

function! s:shift_property_left_for_tab_number(tab_number) "{{{
  let s:tab_properties[a:tab_number - 1] = deepcopy(s:tab_properties[a:tab_number])
endfunction "}}}

function! s:shift_properties_left_for_tab_number(tab_number) "{{{
  for tab_number in range(a:tab_number, s:last_tab_number() + 1)
    call s:shift_property_left_for_tab_number(tab_number)
  endfor
endfunction "}}}

" }}}

" Script Utility Functions {{{

function! s:last_tab_number() "{{{
  return tabpagenr('$')
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

function! s:set_label(label, tab_number) "{{{
  let s:tab_properties[a:tab_number]['label'] = a:label
endfunction "}}}

function! s:label_exists_for_tab_number(tab_number) "{{{
  return has_key(s:tab_properties[a:tab_number], 'label')
endfunction "}}}

function! s:label_for_tab_number(tab_number) "{{{
  return get(s:tab_properties[a:tab_number], 'label')
endfunction "}}}

function! s:remove_label(tab_number) "{{{
  if s:label_exists_for_tab_number(a:tab_number)
    unlet s:tab_properties[a:tab_number]['label']
  endif
endfunction "}}}

function! s:close_tab(tab_number) "{{{
  execute 'tabclose ' . a:tab_number
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

function! s:create_tab(new_tab_number) "{{{
  execute a:new_tab_number . 'tabnew'
endfunction "}}}

function! s:select_tab(tab_number) "{{{
  call s:save_active_tab_number()
  execute 'tabnext ' . a:tab_number
endfunction "}}}

function! s:first_tab() "{{{
  return 1
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

function! s:last_known_tab_number(tab_number) "{{{
  return gettabvar(a:tab_number, 'tabline_last_known_tab_number')
endfunction "}}}

function! s:set_last_known_tab_number(tab_number) "{{{
  call settabvar(a:tab_number, "tabline_last_known_tab_number", a:tab_number)
endfunction "}}}

function! s:check_for_renumbered_tabs(new_tab_number) "{{{
  for tab_number in range(1, s:last_tab_number())
    let last_known_tab_number = s:last_known_tab_number(tab_number)
    if !empty(last_known_tab_number) && last_known_tab_number == a:new_tab_number
      call s:shift_properties_right_for_tab_number(tab_number)
      break
    endif
  endfor
endfunction "}}}

function! s:process_new_tab_number(new_tab_number) "{{{
  if a:new_tab_number != s:last_tab_number()
    call s:check_for_renumbered_tabs(a:new_tab_number)
  end
  call s:create_properties_for_tab_number(a:new_tab_number)
  call s:set_last_known_tab_number(a:new_tab_number)
endfunction " }}}

function! s:check_for_new_tabs() "{{{
  for tab_number in range(1, s:last_tab_number())
    let last_known_tab_number = s:last_known_tab_number(tab_number)
    if empty(last_known_tab_number)
      call s:process_new_tab_number(tab_number)
      return 1
    endif
  endfor
  return 0
endfunction "}}}

function! s:process_closed_tab_number(old_tab_number) "{{{
  call s:shift_properties_left_for_tab_number(a:old_tab_number)
  call s:remove_properties_for_tab_number(s:last_tab_number() + 1)
endfunction "}}}

function! s:check_for_closed_tabs() "{{{
  for tab_number in sort(copy(keys(s:tab_properties))) "FIXME: copy required?
    let last_known_tab_number = s:last_known_tab_number(tab_number)
    if !empty(last_known_tab_number) && tab_number != last_known_tab_number "FIXME: empty required?
      call s:process_closed_tab_number(last_known_tab_number)
      return 1
    endif
  endfor
  return 0
endfunction "}}}

function! s:check_for_tab_changes() "{{{
  if g:bufline_last_known_number_of_tabs != s:last_tab_number()
    call s:error('tab change detected from ' . g:bufline_last_known_number_of_tabs . ' to ' . s:last_tab_number())
    if !s:check_for_new_tabs()
      if s:check_for_closed_tabs()
        call s:initialize_last_known_tab_numbers()
      endif
    endif
  endif
  "FIXME: why doesn't this work after the last call?
  let g:bufline_last_known_number_of_tabs = s:last_tab_number()
endfunction " }}}

" }}}

" Exported Functions {{{

function! tabline#TabLine() "{{{

  call s:check_for_tab_changes()

  let s = ''

  for tab_number in range(1, s:last_tab_number())

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
    elseif tab_number != s:last_tab_number()
      let s .= s:divider_character_soft
    endif

  endfor

  let s .= '%#FweepTabLineFill#%=%999XX'

  return s

endfunction "}}}

function! tabline#TabLineSelectLastActive() "{{{
  if s:tab_exists(s:last_active_tab_number())
    call s:select_tab(s:last_active_tab_number())
  else
    call s:error('Last active tab no longer exists; selecting tab 1.')
    call s:select_tab(s:first_tab())
  endif
endfunction "}}}

function! tabline#TabLineClose(...) "{{{
  if a:0
    let tab_number = a:1
  else
    let tab_number = s:active_tab_number()
  endif

  if tab_number == 1 && s:last_tab_number() == 1
    call s:error("Cannot close the last tab.")
  elseif !s:tab_exists(tab_number)
    call s:error_tab_does_not_exist()
  else
    call s:close_tab(tab_number)
  endif
endfunction "}}}

function! tabline#TabLineSelect(tab_number) "{{{
  if !s:tab_exists(a:tab_number)
    call s:error_tab_does_not_exist()
  else
    call s:select_tab(a:tab_number)
  endif
endfunction "}}}

function! tabline#TabLineNew(...) "{{{
  "TODO: figure out how to pass the varargs on to create_tab
  let new_tab_number = s:last_tab_number() + 1
  call s:create_properties_for_tab_number(new_tab_number)
  if a:0 == 1
    call s:set_label(a:1, new_tab_number)
  endif
  call s:create_tab(new_tab_number)
  redraw!
endfunction "}}}

function! tabline#TabLineLabel(label, ...) "{{{
  let tab_number = a:0 == 1 ? a:1 : s:active_tab_number()
  if !s:tab_exists(tab_number)
    call s:error_tab_does_not_exist()
  else
    call s:set_label(a:label, tab_number)
    redraw!
  endif
endfunction "}}}

function! tabline#TabLabelClear(tab_number) "{{{
  if !s:tab_exists(tab_number)
    call s:error_tab_does_not_exist()
  else
    call s:remove_label(a:tab_number)
    redraw!
  endif
endfunction "}}}

" }}}

call s:initialize()
