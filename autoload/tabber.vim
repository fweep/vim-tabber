" autoload/tabber.vim
" Author: Jim Stewart <http://github.com/fweep/>

" Inspiration and portions of code from Powerline by
" Kim Silkebækken (https://github.com/Lokaltog/vim-powerline).

if exists('g:autoloaded_tabber') || &cp
  finish
endif
let g:autoloaded_tabber = '0.5.4'

" Initialization (Commands, Highlighting, Bindings) {{{

function! s:initialize_highlights() "{{{
  if exists('g:tabber_suppress_highlights') && g:tabber_suppress_highlights
    return
  endif

  execute 'highlight TabLine cterm=NONE ctermfg=244 ctermbg=235'
  execute 'highlight TabLineSel cterm=reverse ctermfg=239 ctermbg=187'
  execute 'highlight TabLineFill cterm=NONE ctermfg=244 ctermbg=235'

  "TODO: derive these from TabLine
  execute 'highlight TabLineTabNumber ctermbg=235 ctermfg=33'
  execute 'highlight TabLineTabNumberSel ctermbg=239 ctermfg=33'
  execute 'highlight TabLineWindowCount ctermbg=235 ctermfg=33'
  execute 'highlight TabLineWindowCountSel ctermbg=239 ctermfg=33'
  execute 'highlight TabLineModifiedFlag ctermbg=235 ctermfg=red'
  execute 'highlight TabLineModifiedFlagSel ctermbg=239 ctermfg=red'
  execute 'highlight TabLineDivider cterm=reverse ctermfg=239 ctermbg=235'
  execute 'highlight TabLineDividerSel ctermbg=235 ctermfg=239'
  execute 'highlight TabLineUserLabel ctermfg=173 ctermbg=235'
  execute 'highlight TabLineUserLabelSel ctermfg=173 ctermbg=239'
  execute 'highlight TabLineDefaultLabel ctermfg=143 ctermbg=235'
  execute 'highlight TabLineDefaultLabelSel ctermfg=143 ctermbg=239'
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

function! s:initialize_dividers() "{{{
  let s:divider_characters = [ [0x2b80], [0x2b81], [0x2b82], [0x2b83] ]
  let s:divider_character_hard = s:ParseChars(deepcopy(s:divider_characters[0]))
  let s:divider_character_soft = s:ParseChars(deepcopy(s:divider_characters[1]))
endfunction "}}}

function! s:initialize_commands() "{{{
  if exists('g:tabber_suppress_commands') && g:tabber_suppress_commands
    return
  endif

  command! -range=0 -nargs=1 TabberLabel   :call <SID>TabberLabel(<count>, <line1>, <f-args>)
  command! -range=0 -nargs=0 TabberClear   :call <SID>TabberLabel(<count>, <line1>, '')
  command! -range=0 -nargs=? TabberNew     :call <SID>TabberNew(<count>, <line1>, <f-args>)
  command! -nargs=0 TabberSelectLastActive :call <SID>TabberSelectLastActive()
endfunction "}}}

function! s:initialize() "{{{
  let s:last_active_tab = 1
  call s:initialize_commands()
  call s:initialize_highlights()
  call s:initialize_dividers()
endfunction "}}}

" }}}

" Exported Functions {{{

function! tabber#TabLine() "{{{

  let tabline = ''

  for tab in range(1, s:last_tab())

    let is_active_tab = tab == s:active_tab()
    let tab_highlight = s:highlighted_text('TabLine', '', is_active_tab)

    let tabline .= tab_highlight
    let tabline .= s:mouse_handle_for_tab(tab)
    let tabline .= s:highlighted_text('TabLineTabNumber', ' ' . tab, is_active_tab) . tab_highlight
    let tabline .= s:window_count_for_tab(tab, is_active_tab) . tab_highlight

    if s:tab_contains_modified_buffers(tab)
      let tabline .= ' ' . s:highlighted_text('TabLineModifiedFlag', '+', is_active_tab) . tab_highlight
    endif

    let properties = s:properties_for_tab(tab)
    if !empty(properties['label'])
      if properties['tab_of_predefined_label'] > 0
        let highlight = 'TabLineDefaultLabel'
      else
        let highlight = 'TabLineUserLabel'
      endif
      let tab_label = s:highlighted_text(highlight, properties['label'], is_active_tab) . tab_highlight
    else
      let tab_label = s:normal_label_for_tab(tab)
    endif

    let tabline .= ' ' . tab_label . ' '

    if ((s:active_tab() == tab) || (s:active_tab() == (tab + 1)))
      let tabline .= s:highlighted_text('TabLineDivider', s:divider_character_hard, is_active_tab)
    elseif tab != s:last_tab()
      let tabline .= s:divider_character_soft
    endif

  endfor

  let tabline .= '%#TabLineFill#%T'

  if s:last_tab() > 1
    let tabline .= '%='
    let tabline .= '%#TabLine#%999Xclose'
  endif

  return tabline

endfunction "}}}

" }}}

" Script Utility Functions {{{

" Tab Settings {{{

function! s:set_label_for_tab(tab, label) "{{{
  let properties = s:properties_for_tab(a:tab)
  let properties.label = a:label
  let properties.tab_of_predefined_label = 0
  call s:save_properties_for_tab(a:tab, properties)
endfunction "}}}

function! s:tab_of_predefined_label_for_tab(tab) "{{{
  let settings = gettabvar(a:tab, 'tabber_properties')
  if empty(settings)
    return 0
  endif
  return settings.tab_of_predefined_label
endfunction "}}}

function! s:predefined_label_in_use_for_tab(tab) "{{{
  let in_use = 0
  for tab in range(1, s:last_tab())
    if s:tab_of_predefined_label_for_tab(tab) == a:tab
      let in_use = 1
      break
    endif
  endfor
  return in_use
endfunction "}}}

function! s:properties_for_tab(tab) "{{{
  let properties = gettabvar(a:tab, 'tabber_properties')
  if empty(properties)
    return s:create_properties_for_tab(a:tab)
  endif
  return properties
endfunction "}}}

function! s:save_properties_for_tab(tab, properties) "{{{
  call settabvar(a:tab, 'tabber_properties', a:properties)
endfunction "}}}

function! s:create_properties_for_tab(tab) "{{{
  let properties = { 'label': '', 'tab_of_predefined_label': 0 }
  if has_key(g:tabber_predefined_labels, a:tab) && !s:predefined_label_in_use_for_tab(a:tab)
    let properties.label = g:tabber_predefined_labels[a:tab]
    let properties.tab_of_predefined_label = a:tab
  elseif exists('g:tabber_default_unknown_label')
    let properties.label = g:tabber_default_unknown_label
  endif
  call s:save_properties_for_tab(a:tab, properties)
  return properties
endfunction "}}}

function! s:label_for_tab(tab) "{{{
  return s:properties_for_tab(a:tab).label
endfunction "}}}

" }}}

" Error Handling {{{

function! s:error(message) "{{{
  echohl ErrorMsg
  echomsg a:message
  echohl None
  let v:errmsg = a:message
endfunction "}}}

function! s:error_tab_does_not_exist() "{{{
  return s:error('Tab does not exist.')
endfunction "}}}

" }}}

" Tab Arrangement {{{

function! s:last_tab() "{{{
  return tabpagenr('$')
endfunction "}}}

function! s:active_tab() "{{{
  return tabpagenr()
endfunction "}}}

function! s:tab_exists(tab) "{{{
  return a:tab > 0 && a:tab <= s:last_tab()
endfunction "}}}

function! s:save_active_tab() "{{{
  let s:last_active_tab = s:active_tab()
endfunction "}}}

function! s:last_active_tab() "{{{
  return s:last_active_tab
endfunction "}}}

" }}}

" TabLine() Helpers {{{

function! s:mouse_handle_for_tab(tab) "{{{
  return '%' . a:tab . 'T'
endfunction "}}}

function! s:highlighted_text(highlight_name, text, is_active_tab) "{{{
  return '%#' . a:highlight_name . (a:is_active_tab ? 'Sel' : '') . '#' . a:text
endfunction "}}}

function! s:window_count_for_tab(tab, is_active_tab) "{{{
  let number_of_windows_in_tab = tabpagewinnr(a:tab, '$')
  if number_of_windows_in_tab > 1
    let text = ':' . s:highlighted_text('TabLineWindowCount', number_of_windows_in_tab, a:is_active_tab)
  else
    let text = ''
  endif
  return text
endfunction "}}}

function! s:tab_contains_modified_buffers(tab) "{{{
  let tab_contains_modified_buffers = 0
  let tab_buffer_list = tabpagebuflist(a:tab)
  for buffer_number in tab_buffer_list
    let buffer_modified = getbufvar(buffer_number, '&modified')
    if buffer_modified
      let tab_contains_modified_buffers = 1
      break
    endif
  endfor
  return tab_contains_modified_buffers
endfunction "}}}

function! s:normal_label_for_tab(tab) "{{{
  let tab_buffer_list = tabpagebuflist(a:tab)
  let window_number = tabpagewinnr(a:tab)
  let active_window_buffer_name = bufname(tab_buffer_list[window_number - 1])
  if !empty(active_window_buffer_name)
    let label = pathshorten(active_window_buffer_name)
  else
    let label = '[No Name]'
  endif
  return label
endfunction "}}}

" }}}

" Command Handlers {{{

function! s:create_tab(new_tab) "{{{
  execute a:new_tab . 'tabnew'
endfunction "}}}

function! s:select_tab(tab) "{{{
  call s:save_active_tab()
  execute 'tabnext ' . a:tab
endfunction "}}}

function! s:command_count(count, line1) "{{{
  let command_count = ''
  if a:count == a:line1
    if a:count == 0
      let command_count = '0'
    else
      let command_count = a:line1
    endif
  endif
  return command_count
endfunction "}}}

function! s:TabberSelectLastActive() "{{{
  if s:tab_exists(s:last_active_tab())
    call s:select_tab(s:last_active_tab())
  else
    call s:select_tab(1)
  endif
endfunction "}}}

function! s:prompt_user_for_label(tab) "{{{
  let new_tab_label = ''
  if g:tabber_prompt_for_new_label
    call inputsave()
    let new_tab_label = input('Label for tab ' . a:tab . ': ')
    call inputrestore()
  endif
  return new_tab_label
endfunction "}}}

function! s:TabberNew(count, line1, ...) "{{{
  execute s:command_count(a:count, a:line1) . 'tabnew'
  let tab = s:active_tab()
  let properties = s:create_properties_for_tab(tab)
  let new_tab_label = ''
  if a:0 == 1
    let new_tab_label = a:1
  elseif properties.tab_of_predefined_label != tab
    if exists('g:tabber_default_user_label')
      let new_tab_label = g:tabber_default_user_label
    else
      let new_tab_label = s:prompt_user_for_label(tab)
    endif
  endif
  if !empty(new_tab_label)
    call s:set_label_for_tab(tab, new_tab_label)
  endif
  redraw!
endfunction "}}}

function! s:TabberLabel(count, line1, label) "{{{
  let command_count = s:command_count(a:count, a:line1)
  let tab = empty(command_count) ? s:active_tab() : command_count
  if !s:tab_exists(tab)
    call s:error_tab_does_not_exist()
  else
    call s:set_label_for_tab(tab, a:label)
    redraw!
  endif
endfunction "}}}

" }}}

" }}}

call s:initialize()
