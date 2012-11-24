fweep-tabline
=============

A Vim plugin styled after Powerline, with additional tab management utilities.

Author
------

[Jim Stewart](http://github.com/fweep)

Credits
-------

Thanks to Kim Silkebækken for writing the excellent Powerline plugin!  Much of TabLine's
code was copied from or modeled after Powerline.

Features
--------

* Powerline-inspired styling.
* User-definable tab labels.
* Tab numbers and window counts in each tab.

### Pending

* Tab reordering.
* User-definable highlighting.
* Status display options.

Installation
------------

Install via [pathogen.vim](https://github.com/tpope/vim-pathogen):

    cd ~/.vim/bundle
    git clone git://github.com/fweep/fweep-tabline.git

Usage
-----

Add this to your .vimrc:

    set tabline=%!fweeptabline#TabLine()

Labels
------

Tab labels default to pathshorten() on the active buffer name.  If the buffer has no name, "\[No Name\]"
is displayed.  You can override the default label for a tab and set your own.  The tab will use your label
until you clear it or close the tab.

If you close a tab or otherwise cause the tabs to be renumbered, your label will still apply to the tab
number you specified when setting it.  If I can figure out how to detect a tab closing event, this behavior
will become configurable.

To set a tab label:

    call fweeptabline#SetTabLabel(tabnumber, "Your Label")

To remove a tab label:

    call fweeptabline#ClearTabLabel(tabnumber)

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
