" autoload/fweep-tabline.vim
" Author: Jim Stewart <http://github.com/fweep/>

if exists('g:autoloaded_fweep_tabline') || &cp
  finish
endif
let g:autoloaded_fweep_tabline = '0.2.0'

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

function! s:initialize()
  command! -nargs=+ TabLineLabel :call tabline#TabLineLabel(<f-args>)
  command! -nargs=1 TabLineClear :call tabline#TabLabelClear(<f-args>)
  command! -nargs=? TabLineNew   :call tabline#TabLineNew(<f-args>)
endfunction

call s:initialize()

"""

function! tabline#TabLineNew(...)
  let new_tab_number = tabpagenr('$') + 1
  if a:0 == 1
    call tabline#TabLineLabel(new_tab_number, a:1)
  endif
  execute new_tab_number . 'tabnew'
  redraw!
endfunction

function! s:ParseChars(arg)
  "TODO: attribution to powerline
  let arg = a:arg
  if type(arg) == type([])
    call map(arg, 'nr2char(v:val)')
    return join(arg, '')
  endif
  return arg
endfunction

function! tabline#TabLineLabel(tab_number, label)
  if !exists("s:fweep_tab_labels")
    let s:fweep_tab_labels = {}
  endif
  let s:fweep_tab_labels[a:tab_number] = a:label
  redraw!
endfunction

function! tabline#TabLabelClear(tab_number)
  if exists('s:fweep_tab_labels')
    let removed_tab_label = get(s:fweep_tab_labels, a:tab_number, '***NONEFOUND***')
    if removed_tab_label != '***NONEFOUND***'
      let removed = remove(s:fweep_tab_labels, a:tab_number) "unlet s:fweep_tab_labels[a:tab_number]
      redraw!
    endif
  endif
endfunction

function! tabline#TabLine()
  if !exists('s:fweep_tab_labels')
    let s:fweep_tab_labels = {}
  endif
  let dividers = [ [0x2b80], [0x2b81], [0x2b82], [0x2b83] ]
  let divider_hard = s:ParseChars(deepcopy(dividers[0]))
  let divider_soft = s:ParseChars(deepcopy(dividers[1]))

  let s = ''

  let current_tab_number = tabpagenr()
  let tab_count = tabpagenr('$')

  for tab_index in range(tab_count)

    let tab_number = tab_index + 1
    let buffer_list = tabpagebuflist(tab_number)
    let window_number = tabpagewinnr(tab_number)
    let buffer_name = bufname(buffer_list[window_number - 1])
    let number_of_windows = tabpagewinnr(tab_number, '$')

    let sel = ''
    if tab_number == current_tab_number
      let sel = 'Sel'
    endif

    let tab_highlight = '%#FweepTabLine' . sel . '#'
    let s .= tab_highlight . ' '
    let s .= '%' . tab_number . 'T'
    let s .= '%#FweepTabLineTabNumber' . sel . '#' .tab_number . tab_highlight

    if number_of_windows > 1
      let s .= ':' . '%#FweepTabLineWindowCount' . sel . '#' . number_of_windows . tab_highlight
    endif

    let modified = 0
    for buffer_number in buffer_list
      let buffer_modified = getbufvar(buffer_number, '&modified')
      if buffer_modified
        let modified = 1
      endif
    endfor

    if modified
      let s .= ' ' . '%#FweepTabLineModifiedFlag' . sel . '#+' . tab_highlight
    endif

    if buffer_name != ''
      let default_tab_label = pathshorten(buffer_name)
    else
      let default_tab_label = '[No Name]'
    endif

    "FIXME: figure out why this doesn't work:
    " let user_label = get(s:fweep_tab_labels, tab_number)
    " if user_label == 0
    let user_label = get(s:fweep_tab_labels, tab_number, "***NONEFOUND***")
    if user_label == "***NONEFOUND***"
      let tab_label = default_tab_label
    else
      let tab_label = '%#FweepTabLineUserLabel' . sel . '#' . user_label . tab_highlight
    endif

    let s .= ' ' . tab_label

    let s .= '%T '

    if (current_tab_number == tab_number || current_tab_number == (tab_number + 1))
      let s .= '%#FweepTabLineDivider' . sel . '#' . divider_hard . tab_highlight
    elseif tab_number != tab_count
      let s .= divider_soft
    endif

    "divider

  endfor

  let s .= '%#FweepTabLineFill#%=%999XX'

  return s
endfunction
