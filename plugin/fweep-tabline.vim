" fweep-tabline.vim - Powerline-style tabline and tab utilities.
" Author: Jim Stewart <http://github.com/fweep/>

if exists('g:loaded_fweep_tabline') || &cp || v:version < 700
  finish
endif
let g:loaded_fweep_tabline = 1

function! s:SetOptDefault(opt, val)
  "Taken from Tim Pope's rails.vim.
  if !exists("g:tabline_" . a:opt)
    let g:{'tabline_' . a:opt} = a:val
  endif
endfunction

call s:SetOptDefault('predefined_labels', {})
