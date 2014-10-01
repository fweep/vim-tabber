" autoload/tabber.vim
" Author: Jim Stewart <http://github.com/fweep/>

" Inspiration and portions of code from Powerline by
" Kim Silkebækken (https://github.com/Lokaltog/vim-powerline).

if exists('g:autoloaded_tabber') || &cp
  finish
endif
let g:autoloaded_tabber = '0.6.0'

" Initialization (Commands, Highlighting, Bindings) {{{1

function! s:initialize_highlights() "{{{2
  if exists('g:tabber_suppress_highlights') && g:tabber_suppress_highlights
    return
  endif

  execute 'highlight TabLine cterm=NONE ctermfg=244 ctermbg=235 gui=NONE guifg=#808080 guibg=#262626'
  execute 'highlight TabLineSel cterm=reverse ctermfg=239 ctermbg=187 gui=reverse guifg=#4e4e4e guibg=#d7d7af'
  execute 'highlight TabLineFill cterm=NONE ctermfg=244 ctermbg=235 gui=NONE guifg=#808080 guibg=#262626'

  "TODO: derive these from TabLine
  execute 'highlight TabLineTabNumber ctermbg=235 ctermfg=33 guibg=#262626 guifg=#0087ff'
  execute 'highlight TabLineTabNumberSel ctermbg=239 ctermfg=33 guibg=#4e4e4e guifg=#0087ff'
  execute 'highlight TabLineWindowCount ctermbg=235 ctermfg=33 guibg=#262626 guifg=#0087ff'
  execute 'highlight TabLineWindowCountSel ctermbg=239 ctermfg=33 guibg=#4e4e4e guifg=#0087ff'
  execute 'highlight TabLineModifiedFlag ctermbg=235 ctermfg=red guibg=#262626 guifg=red'
  execute 'highlight TabLineModifiedFlagSel ctermbg=239 ctermfg=red guibg=#4e4e4e guifg=red'
  execute 'highlight TabLineDivider cterm=reverse ctermfg=239 ctermbg=235 guibg=#4e4e4e guifg=#262626'
  execute 'highlight TabLineDividerSel ctermbg=235 ctermfg=239 guibg=#262626 guifg=#4e4e4e'
  execute 'highlight TabLineUserLabel ctermfg=173 ctermbg=235 guifg=#d7875f guibg=#262626'
  execute 'highlight TabLineUserLabelSel ctermfg=173 ctermbg=239 guifg=#d7875f guibg=#4e4e4e'
  execute 'highlight TabLineDefaultLabel ctermfg=143 ctermbg=235 guifg=#afaf5f guibg=#262626'
  execute 'highlight TabLineDefaultLabelSel ctermfg=143 ctermbg=239 guifg=#afaf5f guibg=#4e4e4e'
endfunction

function! s:ParseChars(arg) "{{{22
  "Copied from Powerline.
  let arg = a:arg
  if type(arg) == type([])
    call map(arg, 'nr2char(v:val)')
    return join(arg, '')
  endif
  return arg
endfunction

function! s:initialize_dividers() "{{{2
  " Dividers from Powerline.
  let s:divider_symbols = {
        \ 'compatible': { 'dividers': [ '', [0x2502], '', [0x2502] ] },
        \ 'unicode': { 'dividers': [[0x25b6], [0x276f], [0x25c0], [0x276e]] },
        \ 'fancy': { 'dividers': [[0xe0b0], [0xe0b1], [0xe0b2], [0xe0b3]] }
        \ }
  let s:divider_characters = s:divider_symbols[g:tabber_divider_style].dividers
  let s:divider_character_hard = s:ParseChars(deepcopy(s:divider_characters[0]))
  let s:divider_character_soft = s:ParseChars(deepcopy(s:divider_characters[1]))
endfunction

function! s:initialize_commands() "{{{2
  if exists('g:tabber_suppress_commands') && g:tabber_suppress_commands
    return
  endif

  command! -range=0 -nargs=? TabberLabel              call <SID>TabberLabel(<count>, <line1>, <f-args>)
  command! -range=0 -nargs=0 TabberClearLabel         call <SID>TabberLabel(<count>, <line1>, '')
  command! -range=0 -nargs=? TabberNew                call <SID>TabberNew(<count>, <line1>, <f-args>)
  command! -nargs=0          TabberSelectLastActive   call <SID>TabberSelectLastActive()
  command! -range=0 -nargs=1 TabberMove               call <SID>TabberMove(<count>, <line1>, <f-args>)
  command!                   TabberShiftLeft          call <SID>TabberShiftLeft()
  command!                   TabberShiftRight         call <SID>TabberShiftRight()
  command! -range=0 -nargs=? TabberSwap               call <SID>TabberSwap(<count>, <f-args>)
endfunction

function! s:initialize_autocmds() "{{{2
  augroup tabber
    autocmd!
    autocmd TabLeave * call s:save_active_tab()
  augroup END
endfunction

function! s:initialize() "{{{2
  let s:last_active_tab = 1
  call s:initialize_commands()
  call s:initialize_highlights()
  call s:initialize_dividers()
  call s:initialize_autocmds()
endfunction

" Exported Functions {{{1

function! tabber#TabLine() "{{{2

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

endfunction

" Script Utility Functions {{{1

" Tab Settings {{{1

function! s:set_label_for_tab(tab, label) "{{{2
  let properties = s:properties_for_tab(a:tab)
  let properties.label = a:label
  let properties.tab_of_predefined_label = 0
  call s:save_properties_for_tab(a:tab, properties)
endfunction

function! s:tab_of_predefined_label_for_tab(tab) "{{{2
  let settings = gettabvar(a:tab, 'tabber_properties')
  if empty(settings)
    return 0
  endif
  return settings.tab_of_predefined_label
endfunction

function! s:predefined_label_in_use_for_tab(tab) "{{{2
  let in_use = 0
  for tab in range(1, s:last_tab())
    if s:tab_of_predefined_label_for_tab(tab) == a:tab
      let in_use = 1
      break
    endif
  endfor
  return in_use
endfunction

function! s:properties_for_tab(tab) "{{{2
  let properties = gettabvar(a:tab, 'tabber_properties')
  if empty(properties)
    return s:create_properties_for_tab(a:tab)
  endif
  return properties
endfunction

function! s:save_properties_for_tab(tab, properties) "{{{2
  call settabvar(a:tab, 'tabber_properties', a:properties)
endfunction

function! s:create_properties_for_tab(tab) "{{{2
  let properties = { 'label': '', 'tab_of_predefined_label': 0 }
  if has_key(g:tabber_predefined_labels, a:tab) && !s:predefined_label_in_use_for_tab(a:tab)
    let properties.label = g:tabber_predefined_labels[a:tab]
    let properties.tab_of_predefined_label = a:tab
  elseif exists('g:tabber_default_unknown_label')
    let properties.label = g:tabber_default_unknown_label
  endif
  call s:save_properties_for_tab(a:tab, properties)
  return properties
endfunction

function! s:label_for_tab(tab) "{{{2
  return s:properties_for_tab(a:tab).label
endfunction

" Error Handling {{{1

function! s:error(message) "{{{2
  echohl ErrorMsg
  echomsg a:message
  echohl None
  let v:errmsg = a:message
endfunction

function! s:error_tab_does_not_exist(tab) "{{{2
  return s:error('Tab ' . a:tab . ' does not exist.')
endfunction

" Tab Arrangement {{{1

function! s:last_tab() "{{{2
  return tabpagenr('$')
endfunction

function! s:active_tab() "{{{2
  return tabpagenr()
endfunction

function! s:tab_exists(tab) "{{{2
  return a:tab > 0 && a:tab <= s:last_tab()
endfunction

function! s:tab_exists_or_error(tab) "{{{2
  let tab_exists = a:tab > 0 && a:tab <= s:last_tab()
  if !tab_exists
    call s:error_tab_does_not_exist(a:tab)
  endif
  return tab_exists
endfunction

function! s:save_active_tab() "{{{2
  let s:last_active_tab = s:active_tab()
endfunction

function! s:last_active_tab() "{{{2
  return s:last_active_tab
endfunction

" TabLine() Helpers {{{1

function! s:AddDivider(text, side, mode, colors, prev, curr, next) " {{{
  " From Powerline.
  let seg_prev = a:prev
  let seg_curr = a:curr
  let seg_next = a:next

  " Set default color/type for the divider
  let div_colors = get(a:colors, a:mode, a:colors['n'])
  let div_type = s:SOFT_DIVIDER

  " Define segment to compare
  let cmp_seg = a:side == s:LEFT_SIDE ? seg_next : seg_prev

  let cmp_all_colors = get(cmp_seg, 'colors', {})
  let cmp_colors = get(cmp_all_colors, a:mode, get(cmp_all_colors, 'n', {}))

  if ! empty(cmp_colors)
    " Compare the highlighting groups
    "
    " If the background color for cterm is equal, use soft divider with the current segment's highlighting
    " If not, use hard divider with a new highlighting group
    "
    " Note that if the previous/next segment is the split, a hard divider is always used
    if get(div_colors, 'ctermbg') != get(cmp_colors, 'ctermbg') || get(seg_next, 'name') ==# 'SPLIT' || get(seg_prev, 'name') ==# 'SPLIT'
      let div_type = s:HARD_DIVIDER

      " Create new highlighting group
      if div_colors['attr'] =~ 'reverse' && cmp_colors['attr'] =~ 'reverse'
        " Use FG = CURRENT FG, BG = CMP FG
        let div_colors['ctermbg'] = get(cmp_colors, 'ctermfg')
        let div_colors['guibg']   = get(cmp_colors, 'guifg')

        let div_colors['attr']    = div_colors['attr'] =~ 'bold' ? 'bold' : 'NONE'
      elseif div_colors['attr'] =~ 'reverse'
        " Use FG = CURRENT FG, BG = CMP BG
        let div_colors['ctermbg'] = get(cmp_colors, 'ctermbg')
        let div_colors['guibg']   = get(cmp_colors, 'guibg')

        let div_colors['attr']    = div_colors['attr'] =~ 'bold' ? 'bold' : 'NONE'
      elseif cmp_colors['attr'] =~ 'reverse'
        " Use FG = CMP FG, BG = CURRENT BG : reversed
        let div_colors['ctermfg'] = get(cmp_colors, 'ctermfg')
        let div_colors['guifg']   = get(cmp_colors, 'guifg')

        let div_colors['attr']    = 'reverse'

      else
        " Use FG = CURRENT BG, BG = CMP BG
        let div_colors['ctermfg'] = get(div_colors, 'ctermbg')
        let div_colors['guifg']   = get(div_colors, 'guibg')

        let div_colors['ctermbg'] = get(cmp_colors, 'ctermbg')
        let div_colors['guibg']   = get(cmp_colors, 'guibg')

        let div_colors['attr']    = 'NONE'
      endif
    endif
  endif

  " Prepare divider
  let divider_raw = deepcopy(g:Pl#Parser#Symbols[g:Powerline_symbols].dividers[a:side + div_type])
  let divider = Pl#Parser#ParseChars(divider_raw)

  " Don't add dividers for segments adjacent to split (unless it's a hard divider)
  if ((get(seg_next, 'name') ==# 'SPLIT' || get(seg_prev, 'name') ==# 'SPLIT') && div_type != s:HARD_DIVIDER)
    return ''
  endif

  if a:side == s:LEFT_SIDE
    " Left side
    " Divider to the right
    return printf('%%(%s%%#%s#%s%%)', a:text, s:HlCreate(div_colors), divider)
  else
    " Right side
    " Divider to the left
    return printf('%%(%%#%s#%s%s%%)', s:HlCreate(div_colors), divider, a:text)
  endif
endfunction " }}}
function! s:mouse_handle_for_tab(tab) "{{{2
  return '%' . a:tab . 'T'
endfunction

function! s:highlighted_text(highlight_name, text, is_active_tab) "{{{2
  return '%#' . a:highlight_name . (a:is_active_tab ? 'Sel' : '') . '#' . a:text
endfunction

function! s:window_count_for_tab(tab, is_active_tab) "{{{2
  let number_of_windows_in_tab = tabpagewinnr(a:tab, '$')
  if number_of_windows_in_tab > 1
    let text = ':' . s:highlighted_text('TabLineWindowCount', number_of_windows_in_tab, a:is_active_tab)
  else
    let text = ''
  endif
  return text
endfunction

function! s:tab_contains_modified_buffers(tab) "{{{2
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
endfunction

function! s:normal_label_for_tab(tab) "{{{2
  let tab_buffer_list = tabpagebuflist(a:tab)
  let window_number = tabpagewinnr(a:tab)
  let active_window_buffer_name = bufname(tab_buffer_list[window_number - 1])
  if !empty(active_window_buffer_name)
    if g:tabber_filename_style == 'pathshorten'
      let label = pathshorten(active_window_buffer_name)
    elseif g:tabber_filename_style == 'filename'
      let label = fnamemodify(active_window_buffer_name, ':t')
    elseif g:tabber_filename_style == 'relative'
      let label = fnamemodify(active_window_buffer_name, ':~:.')
    elseif g:tabber_filename_style == 'full'
      let label = fnamemodify(active_window_buffer_name, ':p')
    endif
  else
    let label = '[No Name]'
  endif
  return label
endfunction

" Command Handlers {{{1

function! s:create_tab(new_tab) "{{{2
  execute a:new_tab . 'tabnew'
endfunction

function! s:select_tab(tab) "{{{2
  execute 'tabnext ' . a:tab
endfunction

function! s:command_count(count, line1) "{{{2
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

function! s:TabberSelectLastActive() "{{{2
  if s:tab_exists(s:last_active_tab())
    call s:select_tab(s:last_active_tab())
  else
    call s:select_tab(1)
  endif
endfunction

function! s:prompt_user_for_label(tab) "{{{2
  let new_tab_label = ''
  if g:tabber_prompt_for_new_label
    call inputsave()
    let new_tab_label = input('Label for tab ' . a:tab . ': ')
    call inputrestore()
  endif
  return new_tab_label
endfunction

function! s:TabberNew(count, line1, ...) "{{{2
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
endfunction

function! s:TabberLabel(count, line1, ...) "{{{2
  let command_count = s:command_count(a:count, a:line1)
  let tab = empty(command_count) ? s:active_tab() : command_count
  if s:tab_exists_or_error(tab)
    if a:0 == 1
      let new_tab_label = a:1
    else
      let new_tab_label = s:prompt_user_for_label(tab)
    endif
    call s:set_label_for_tab(tab, new_tab_label)
    redraw!
  endif
endfunction

function! s:move_tab(source_tab, target_tab) "{{{2
  let active_tab = s:active_tab()
  if a:source_tab != active_tab
    execute 'tabnext ' . a:source_tab
  endif
  execute 'tabmove ' . a:target_tab
  if active_tab == a:source_tab
    let new_active_tab = a:target_tab + 1
  elseif a:source_tab > active_tab && a:target_tab < active_tab
    let new_active_tab = active_tab + 1
  elseif a:source_tab < active_tab && a:target_tab >= (active_tab - 1)
    let new_active_tab = active_tab - 1
  else
    let new_active_tab = active_tab
  endif
  execute 'tabnext ' . new_active_tab
endfunction

function! s:TabberShiftRight() "{{{2
  let active_tab = s:active_tab()
  let target_tab = active_tab
  if target_tab == s:last_tab() && g:tabber_wrap_when_shifting
    let target_tab = 0
  endif
  if target_tab < s:last_tab()
    call s:move_tab(active_tab, target_tab)
  endif
endfunction

function! s:TabberShiftLeft() "{{{2
  let active_tab = s:active_tab()
  let target_tab = active_tab - 2
  if target_tab < 0 && g:tabber_wrap_when_shifting
    let target_tab = s:last_tab()
  endif
  if target_tab >= 0
    call s:move_tab(active_tab, target_tab)
  endif
endfunction

function! s:TabberSwap(count, ...) "{{{2
  if v:count == v:count1
    "Handles key map with count.
    let source_tab = s:active_tab()
    let target_tab = v:count
  else
    "Handles key map without count and command-line with count and/or argument.
    if a:count == 0 && (a:0 == 0 || a:1 == 0)
      call s:error("Target tab required.")
      return
    endif

    let source_tab = a:0 ? a:1 : s:active_tab()
    let target_tab = a:count ? a:count : s:active_tab()
  endif

  if source_tab != target_tab && s:tab_exists_or_error(source_tab) && s:tab_exists_or_error(target_tab)
    let left_tab = min([source_tab, target_tab])
    let right_tab = max([source_tab, target_tab])
    call s:move_tab(right_tab, left_tab - 1)
    call s:move_tab(left_tab + 1, right_tab - 1)
  endif
endfunction

function! s:TabberMove(count, line1, target_tab) "{{{2
  let source_tab = s:command_count(a:count, a:line1)
  let tab = empty(source_tab) ? s:active_tab() : source_tab
  if s:tab_exists_or_error(tab)
    if source_tab != a:target_tab + 1
      call s:move_tab(tab, a:target_tab)
    endif
  endif
endfunction

call s:initialize()
