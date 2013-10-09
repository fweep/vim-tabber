vim-tabber
=============

A Vim plugin for labeling and manipulating tabs, visually styled after
[Powerline](http://github.com/Lokaltog/vim-powerline).

![screenshot](https://raw.github.com/fweep/vim-tabber/gh-pages/vim-tabber-screenshot.png)

Features
--------

* User-definable tab labels.
* Default labels based on tab numbers.
* Tab number and window count in each tab.
* Commands to shift tabs left/right, move tabs, and jump to the last
  active tab.
* Powerline-inspired styling and glyphs.

Installation
------------

Install via [pathogen.vim](https://github.com/tpope/vim-pathogen):

    cd ~/.vim/bundle
    git clone https://github.com/fweep/vim-tabber.git

Add this to your .vimrc:

    set tabline=%!tabber#TabLine()

### MacVim/GUI Mode

If using GUI mode (e.g. MacVim), you also need:

    set guioptions-=e

This will use a traditional terminal Vim tabline rather than real GUI
widget tabs.

Setting Labels
--------------

Tab labels default to `pathshorten()` on the active buffer name.  If the
buffer has no name, "\[No Name\]" is displayed.  You can override the
default label for a tab and set your own.  The tab will use your label
until you clear it or close the tab.

To set a label for the current tab:

    :TabberLabel My Tab Name

To remove the label from the current tab:

    :TabberClear

You can also set/remove labels on other tabs by prefixing the command
with the tab number:

    :4TabberLabel New Name For Tab Four
    :4TabberClear

New Tabs
--------

To create a new tab with a label:

    :TabberNew Refactoring Controller

You can supply an optional count prefix to TabberNew, to specify where
the new tab should be opened.  This behavior is the same as Vim's
`:tabnew`.  See `:help tabnew`.

    :TabberNew New Tab After Current Tab
    :0TabberNew New First Tab
    :2TabberNew New Third Tab
    :999TabberNew New Last Tab

Navigating Tabs
---------------

To move to the last active tab:

    :TabberSelectLastActive

Moving Tabs
-----------

Shift current tab left/right:

    :TabberShiftLeft
    :TabberShiftRight

Move active tab to a new location:

    :TabberMove <target tab number>

This is identical to ``:tabmove``.

Move tab 2 to tab 4:

    :2TabberMove 3

Note that the tab is placed _after_ the target tab, to follow the
``:tabmove`` convention.  You can still use ``:tabmove`` as well.

To swap tab 1 and tab 3:

    :1TabberSwap 3
    :3TabberSwap 1

If tab 1 is the current tab:

    :3TabberSwap
    :TabberSwap 3

With `,ts` mapped to `:TabberSwap<CR>`:

    3,ts

Predefining Labels
------------------

You can predefine label names that will be used when a matching tab
number opens:

    let g:tabber_predefined_labels = { 1: 'Models', 2: 'Views', 3: 'Controllers' }

If Vim opens with one tab, it will be labeled "Models".  When you open a
second tab, it will be named "Controllers".  When you open a fourth tab,
it will use the normal naming rules.

If the tabs are re-arranged (e.g. by inserting a tab before a labeled
one), the label will stay with the tab it was originally assigned to.

If a default label is no longer in use&mdash;either because you renamed
it, or because the tab was closed&mdash;the next tab to open in that
slot will be assigned the default label.

Default Labels
--------------

You can set a default label for tabs created with `:TabberNew`:

    set g:tabber_default_user_label = 'Scratch'

You can set a default label for new tabs that are created without a label:

    set g:tabber_default_unknown_label = 'Temp'

This will apply to tabs created by `:tabnew`, by other plugins, etc.  It
will apply to labels created by `:TabberNew` if
`g:tabber_default_user_label` is not set.

Predefined labels always take precedence over these options.

Other Options
-------------

Prompt for a label if `:TabberNew` or `:TabberLabel` is called with no
arguments, and no defaults apply:

    let g:tabber_prompt_for_new_label = 1

Wrap tabs when shifting:

    let g:tabber_wrap_when_shifting = 1

Control what's shown in unlabeled tabs.  If the current directory is
`~jim` and `~/.vim/bundle/vim-tabber/README.md` is loaded in the active
window for the tab:

    let g:tabber_filename_style = 'pathshorten' " .v/b/v/README.md
    let g:tabber_filename_style = 'full'        " /home/jim/.vim/bundle/vim-tabber/README.md
    let g:tabber_filename_style = 'relative'    " .vim/bundle/vim-tabber/README.md
    let g:tabber_filename_style = 'filename'    " README.md

Use different divider styles:

    let g:tabber_divider_style = 'compatible'
    let g:tabber_divider_style = 'unicode'
    let g:tabber_divider_style = 'fancy'

Example Bindings
----------------

Bind <kbd>Ctrl</kbd>-<kbd>t</kbd> to open a new tab at the end of the tab list with the label
"Scratch":

    nnoremap <C-t> :999TabberNew Scratch<CR>

Bind <kbd>Ctrl</kbd>-<kbd>e</kbd> to switch to the last active tab:

    nnoremap <C-e> :TabberSelectLastActive<CR>

Compatibility
-------------

Tested with Vim and MacVim versions 7.3 and 7.4 in terminal mode, and
MacVim GUI mode with `set guioptions-=e`. GUI mode with UI widget tabs
(the default) does not work, as it does not invoke the `tabline`
mechanism.

Limitations
-----------

Tab labels are lost when saving/restoring sessions.  If you have
configured default labels, they will be applied.

How I Use It
------------

These mappings mask the Vim default <kbd>Ctrl</kbd>-<kbd>t</kbd> for navigating the tag
stack, and possibly conflict with other bindings you may have, but
should show what can be done with the plugin.  The maps allow me to move
tabs around with a count prefix without leaving normal mode.

In `~/.vimrc`:

    if filereadable('.vimrc-project')
      source .vimrc-project
    endif

    set tabline=%!tabber#TabLine()

    let g:tabber_wrap_when_shifting = 1

    nnoremap <silent> <C-t>            :999TabberNew<CR>
    nnoremap <silent> <Leader><Leader> :TabberSelectLastActive<CR>
    nnoremap <silent> <Leader>tn       :TabberNew<CR>
    nnoremap <silent> <Leader>tm       :TabberMove<CR>
    nnoremap <silent> <Leader>tc       :tabclose<CR>
    nnoremap <silent> <Leader>tl       :TabberShiftLeft<CR>
    nnoremap <silent> <Leader>tr       :TabberShiftRight<CR>
    nnoremap <silent> <Leader>ts       :TabberSwap<CR>
    nnoremap <silent> <Leader>1        :tabnext 1<CR>
    nnoremap <silent> <Leader>2        :tabnext 2<CR>
    nnoremap <silent> <Leader>3        :tabnext 3<CR>
    nnoremap <silent> <Leader>4        :tabnext 4<CR>
    nnoremap <silent> <Leader>5        :tabnext 5<CR>
    nnoremap <silent> <Leader>6        :tabnext 6<CR>
    nnoremap <silent> <Leader>7        :tabnext 7<CR>
    nnoremap <silent> <Leader>8        :tabnext 8<CR>
    nnoremap <silent> <Leader>9        :tabnext 9<CR>

In `.vimrc-project` in a Rails app root directory:

    let g:tabber_predefined_labels = { 1: 'Controllers', 2: 'Views', 3: 'Models' }

Wish List
---------

Right now, Tabber totally replaces your tabline.  I'd like to figure out
a way to plug this in to the regular tabline, so users can more easily
configure it.  The built-in tabline is already pretty configurable.

It'd be great if Tabber were as configurable as Powerline.  I'm thinking
about making Powerline a requirement, and leveraging all of its
functions, including themes, etc.  Since Lokaltog is in the middle of a
Powerline rewrite, I'll wait and see what comes of that.  He might
include tabline support.

This could be split up into two plugins: one for styling and one for the
tab manipulation utilities.

Author
------

[Jim Stewart](http://github.com/fweep)

Acknowledgements
-------

Thanks to Kim Silkebækken for writing the excellent Powerline plugin!
Some of Tabber's code was copied from or modeled after Powerline, to
match color schemes and symbols.  Thanks also to Tim Pope and others for
providing great code from which to learn Vimscript.

MIT License
-------

Copyright (C) 2012 Jim Stewart

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
