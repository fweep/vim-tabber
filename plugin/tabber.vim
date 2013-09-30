" tabber.vim - Powerline-style tabber and tab utilities.
" Author: Jim Stewart <http://github.com/fweep/>

if exists('g:loaded_tabber') || &cp || v:version < 700
  finish
endif
let g:loaded_tabber = 1

function! s:SetOptDefault(opt, val)
  "Taken from Tim Pope's rails.vim.
  if !exists("g:tabber_" . a:opt)
    let g:{'tabber_' . a:opt} = a:val
  endif
endfunction

call s:SetOptDefault('predefined_labels', {})
call s:SetOptDefault('prompt_for_new_label', 0)
call s:SetOptDefault('wrap_when_shifting', 0)
call s:SetOptDefault('filename_style', 'pathshorten')
call s:SetOptDefault('divider_style', 'fancy')
