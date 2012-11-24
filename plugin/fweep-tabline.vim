" fweep-tabline.vim - Powerline-style tabline and tab utilities.
" Author: Jim Stewart <http://github.com/fweep/>

if exists('g:loaded_fweep_tabline') || &cp || v:version < 700
  finish
endif
let g:loaded_fweep_tabline = 1

if !exists('g:tabline_sticky_labels')
  let g:tabline_sticky_labels = 0
endif
