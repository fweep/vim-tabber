" autoload/tabline.vim
" Author: Jim Stewart <http://github.com/fweep/>

" Inspiration and portions of code from Powerline by
" Kim Silkebækken (https://github.com/Lokaltog/vim-powerline).

if exists('g:autoloaded_tabline') || &cp
  finish
endif
let g:autoloaded_tabline = '0.5.3'

" Initialization (Commands, Highlighting, Bindings) {{{

function! s:initialize_highlights() "{{{
  if exists('g:tablist_suppress_highlights') && g:tablist_suppress_highlights
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

" Exported Functions {{{

function! tabline#TabLine() "{{{

  let tabline = ''

  for tab_number in range(1, s:last_tab_number())

    let is_active_tab = tab_number == s:active_tab_number()
    let tab_highlight = s:highlighted_text('TabLine', '', is_active_tab)

    let tabline .= tab_highlight
    let tabline .= s:mouse_handle_for_tab_number(tab_number)
    let tabline .= s:highlighted_text('TabLineTabNumber', ' ' . tab_number, is_active_tab) . tab_highlight
    let tabline .= s:window_count_for_tab_number(tab_number, is_active_tab) . tab_highlight

    if s:tab_contains_modified_buffers(tab_number)
      let tabline .= ' ' . s:highlighted_text('TabLineModifiedFlag', '+', is_active_tab) . tab_highlight
    endif

    let tabline_settings = s:tabline_settings_for_tab_number(tab_number)
    if !empty(tabline_settings['label'])
      if tabline_settings['tab_number_of_default_label'] > 0
        let highlight = 'TabLineDefaultLabel'
      else
        let highlight = 'TabLineUserLabel'
      endif
      let tab_label = s:highlighted_text(highlight, tabline_settings['label'], is_active_tab) . tab_highlight
    else
      let tab_label = s:normal_label_for_tab_number(tab_number)
    endif

    let tabline .= ' ' . tab_label . ' '

    if ((s:active_tab_number() == tab_number) || (s:active_tab_number() == (tab_number + 1)))
      let tabline .= s:highlighted_text('TabLineDivider', s:divider_character_hard, is_active_tab)
    elseif tab_number != s:last_tab_number()
      let tabline .= s:divider_character_soft
    endif

  endfor

  let tabline .= '%#TabLineFill#%T'

  if s:last_tab_number() > 1
    let tabline .= '%='
    let tabline .= '%#TabLine#%999Xclose'
  endif

  return tabline

endfunction "}}}

" }}}

" Script Utility Functions {{{

" Tab Settings {{{

function! s:set_label_for_tab_number(tab_number, label) "{{{
  let tabline_settings = s:tabline_settings_for_tab_number(a:tab_number)
  let tabline_settings.label = a:label
  let tabline_settings.tab_number_of_default_label = 0
  call s:save_tabline_settings_for_tab_number(a:tab_number, tabline_settings)
endfunction "}}}

function! s:tab_number_of_default_label_for_tab_number(tab_number) "{{{
  let settings = gettabvar(a:tab_number, 'tabline_settings')
  if empty(settings)
    return 0
  endif
  return settings.tab_number_of_default_label
endfunction "}}}

function! s:default_label_in_use_for_tab_number(tab_number) "{{{
  let in_use = 0
  for tab_number in range(1, s:last_tab_number())
    if s:tab_number_of_default_label_for_tab_number(tab_number) == a:tab_number
      let in_use = 1
      break
    endif
  endfor
  return in_use
endfunction "}}}

function! s:tabline_settings_for_tab_number(tab_number) "{{{
  let tabline_settings = gettabvar(a:tab_number, 'tabline_settings')
  if empty(tabline_settings)
    return s:create_tabline_settings_for_tab_number(a:tab_number)
  endif
  return tabline_settings
endfunction "}}}

function! s:save_tabline_settings_for_tab_number(tab_number, tabline_settings) "{{{
  call settabvar(a:tab_number, 'tabline_settings', a:tabline_settings)
endfunction "}}}

function! s:create_tabline_settings_for_tab_number(tab_number) "{{{
  let tabline_settings = { 'label': '', 'tab_number_of_default_label': 0 }
  if has_key(g:tabline_default_labels, a:tab_number) && !s:default_label_in_use_for_tab_number(a:tab_number)
    let tabline_settings['label'] = g:tabline_default_labels[a:tab_number]
    let tabline_settings['tab_number_of_default_label'] = a:tab_number
  elseif exists('g:tabline_default_unknown_label')
    let tabline_settings.label = g:tabline_default_unknown_label
  endif
  call s:save_tabline_settings_for_tab_number(a:tab_number, tabline_settings)
  return tabline_settings
endfunction "}}}

function! s:label_for_tab_number(tab_number) "{{{
  return s:tabline_settings_for_tab_number(a:tab_number)['label']
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

function! s:last_tab_number() "{{{
  return tabpagenr('$')
endfunction "}}}

function! s:active_tab_number() "{{{
  return tabpagenr()
endfunction "}}}

function! s:tab_exists(tab_number) "{{{
  return a:tab_number > 0 && a:tab_number <= s:last_tab_number()
endfunction "}}}

function! s:save_active_tab_number() "{{{
  let s:last_active_tab_number = s:active_tab_number()
endfunction "}}}

function! s:last_active_tab_number() "{{{
  return s:last_active_tab_number
endfunction "}}}

" }}}

" Tabline() Helpers {{{

function! s:mouse_handle_for_tab_number(tab_number) "{{{
  return '%' . a:tab_number . 'T'
endfunction "}}}

function! s:highlighted_text(highlight_name, text, is_active_tab) "{{{
  return '%#' . a:highlight_name . (a:is_active_tab ? 'Sel' : '') . '#' . a:text
endfunction "}}}

function! s:window_count_for_tab_number(tab_number, is_active_tab) "{{{
  let number_of_windows_in_tab = tabpagewinnr(a:tab_number, '$')
  if number_of_windows_in_tab > 1
    let text = ':' . s:highlighted_text('TabLineWindowCount', number_of_windows_in_tab, a:is_active_tab)
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

function! s:normal_label_for_tab_number(tab_number) "{{{
  let tab_buffer_list = tabpagebuflist(a:tab_number)
  let window_number = tabpagewinnr(a:tab_number)
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

function! s:create_tab(new_tab_number) "{{{
  execute a:new_tab_number . 'tabnew'
endfunction "}}}

function! s:select_tab(tab_number) "{{{
  call s:save_active_tab_number()
  execute 'tabnext ' . a:tab_number
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

function! s:TabLineSelectLastActive() "{{{
  if s:tab_exists(s:last_active_tab_number())
    call s:select_tab(s:last_active_tab_number())
  else
    call s:select_tab(1)
  endif
endfunction "}}}

function! s:TabLineNew(count, line1, ...) "{{{
  execute s:command_count(a:count, a:line1) . 'tabnew'
  let tab_number = s:active_tab_number()
  call s:create_tabline_settings_for_tab_number(tab_number)
  if a:0 == 1
    call s:set_label_for_tab_number(tab_number, a:1)
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

" }}}

call s:initialize()
