vim-tabber
=============

A Vim plugin for labeling and manipulating tabs, visually styled after
[Powerline](http://github.com/Lokaltog/vim-powerline), with additional
tab management utilities.

Features
--------

* User-definable tab labels.
* Default labels based on tab numbers.
* Tab numbers and window counts in each tab.
* A command for selecting the last active tab.
* Powerline-inspired styling and glyphs.

Installation
------------

Install via [pathogen.vim](https://github.com/tpope/vim-pathogen):

    cd ~/.vim/bundle
    git clone git://github.com/fweep/vim-tabber.git

Add this to your .vimrc:

    set tabline=%!tabber#TabLine()

Setting Labels
--------------

Tab labels default to pathshorten() on the active buffer name.  If the buffer has no name, "\[No Name\]"
is displayed.  You can override the default label for a tab and set your own.  The tab will use your label
until you clear it or close the tab.

To set a label for the current tab:

    :TabberLabel My Tab Name

To remove the label from the current tab:

    :TabberClear

You can also set/remove labels on other tabs by prefixing the command with the tab number:

    :4TabberLabel New Name For Tab Four
    :4TabberClear

New Tabs
--------

To create a new tab with a label:

    :TabberNew Refactoring Controller

You can supply an optional count prefix to TabberNew, to specify where the new tab should be opened.
This behavior is the same as Vim's `:tabnew`.  See `:help tabnew`.

    :TabberNew New Tab After Current Tab
    :0TabberNew New First Tab
    :2TabberNew New Third Tab
    :999TabberNew New Last Tab

Last Active Tab
---------------

To move to the last active tab:

    :TabberSelectLastActive

Predefining Labels
------------------

You can predefine label names that will be used when a matching tab number opens:

    let g:tabber_predefined_labels = { 1: 'Models', 2: 'Views', 3: 'Controllers' }

If Vim opens with one tab, it will be labeled "Models".  When you open a second tab, it will
be named "Controllers".  When you open a fourth tab, it will use the normal naming rules.

If the tabs are re-arranged (e.g. by inserting a tab before a labeled one), the label will
stay with the tab it was originally assigned to.

If a default label is no longer in use&mdash;either because you renamed it, or because the
tab was closed&mdash;the next tab to open in that slot will be assigned the default label.

Default Labels
--------------

You can set a default label for tabs created with `:TabberNew`:

    set g:tabber_default_user_label = 'Scratch'

You can set a default label for new tabs that are created without a label:

    set g:tabber_default_unknown_label = 'Temp'

This will apply to tabs created by `:tabnew`, by other plugins, etc.  It will apply
to labels created by `:TabberNew` if `g:tabber_default_user_label` is not set.

Predefined labels always take precedence over these options.

Other Options
-------------

Prompt for a label if `:TabLineNew` is called with no arguments, and no defaults apply:

    let g:tabber_prompt_for_new_label = 1

Example Bindings
----------------

Bind \<C-t\> to open a new tab at the end of the tab list with the label "Scratch":

    nnoremap <C-t> :999TabberNew Scratch<CR>

Bind \<C-e\> to switch to the last active tab:

    nnoremap <C-e> :TabberSelectLastActive<CR>

Compatibility
-------------

Tested with Vim 7.3.

Limitations
-----------

Tab labels are lost when saving/restoring sessions.  If you have configured default labels,
they will be applied.

Author
------

[Jim Stewart](http://github.com/fweep)

Credits
-------

Thanks to Kim Silkebækken for writing the excellent Powerline plugin!  Some of Tabber's
code was copied from or modeled after Powerline.  Thanks also to Tim Pope and others for
providing great code from which to learn Vimscript.

License
-------

Copyright (C) 2012 Jim Stewart

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions
of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
