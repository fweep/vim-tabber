fweep-tabline
=============

A Vim plugin for labeling and manipulating tabs, visually styled after
[Powerline](http://github.com/Lokaltog/vim-powerline), with additional
tab management utilities.

Features
--------

* Powerline-inspired styling and glyphs.
* User-definable tab labels.
* Tab numbers and window counts in each tab.
* A command for selecting the last active tab.

Installation
------------

Install via [pathogen.vim](https://github.com/tpope/vim-pathogen):

    cd ~/.vim/bundle
    git clone git://github.com/fweep/fweep-tabline.git

Add this to your .vimrc:

    set tabline=%!tabline#TabLine()

Labels
------

Tab labels default to pathshorten() on the active buffer name.  If the buffer has no name, "\[No Name\]"
is displayed.  You can override the default label for a tab and set your own.  The tab will use your label
until you clear it or close the tab.

To set a label for the current tab:

    :TabLineLabel My Tab Name

To remove the label from the current tab:

    :TabLineClear

You can also set/remove labels on other tabs by prefixing the command with the tab number:

    :4TabLineLabel New Name For Tab Four
    :4TabLineClear

New Tabs
--------

To create a new tab with a label:

    :TabLineNew Refactoring Controller

You can supply an optional count prefix to TabLineNew, to specify where the new tab should be opened.
This behavior is the same as Vim's `:tabnew`.  See `:help tabnew`.

    :TabLineNew New Tab After Current Tab
    :0TabLineNew New First Tab
    :2TabLineNew New Third Tab
    :999TabLineNew New Last Tab

Last Active Tab
---------------

To move to the last active tab:

    :TabLineSelectLastActive

Example Bindings
----------------

Bind \<C-t\> to open a new tab at the end of the tab list with the label "Scratch":

    nnoremap <C-t> :999TabLineNew Scratch<CR>

Bind \<C-e\> to switch to the last active tab:

    nnoremap <C-e> :TabLineSelectLastActive<CR>

Compatibility
-------------

Tested with Vim 7.3.

Limitations
-----------

Tab labels are lost when saving/restoring sessions.

Author
------

[Jim Stewart](http://github.com/fweep)

Credits
-------

Thanks to Kim Silkebækken for writing the excellent Powerline plugin!  Much of TabLine's
code was copied from or modeled after Powerline.

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
