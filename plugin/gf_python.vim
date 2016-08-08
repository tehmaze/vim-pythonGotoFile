"
"                          _______
"    ____________ _______ _\__   /_________        ___  _____
"   |    _   _   \   _   |   ____\   _    /       |   |/  _  \
"   |    /   /   /   /   |  |     |  /___/    _   |   |   /  /
"   |___/___/   /___/____|________|___   |   |_|  |___|_____/
"           \__/                     |___|    
"
" Copyright (C) 2012 Wijnand Modderman-Lenstra <maze@pyth0n.org>
"
" Permission is hereby granted, free of charge, to any person obtaining a copy of
" this software and associated documentation files (the "Software"), to deal in
" the Software without restriction, including without limitation the rights to
" use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
" of the Software, and to permit persons to whom the Software is furnished to do
" so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in all
" copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
" SOFTWARE.

" Version check
if v:version < 700
    finish
endif

" Load once
if exists("g:loaded_python_goto_file")
    finish
else
    let g:loaded_python_goto_file = 1
endif

if has("python3")
    " `gf` jumps to the filename under the cursor.  Point at an import statement
    " and jump to it!
    python << EOF
import os
import sys
import types
import vim

# Make sure we search in current directory first
sys.path.insert(0, os.getcwd())

def python_goto_file():
    cw = vim.eval('expand("<cfile>")')
    try:
        try:
            md = __import__(cw)
        except ImportError:
            if '.' in cw:
                md = __import__(cw.rsplit('.', 1)[0])
            else:
                raise

        for m in cw.split('.')[1:]:
            nd = getattr(md, m)
            if type(nd) == types.ModuleType:
                md = nd
            else:
                break

    except ImportError, e:
        print >>sys.stderr, 'E447: Can not goto "%s": %s' % (cw, str(e))
        return

    # Convert .pyc and .pyo to .py
    try:
        gf = md.__file__.rstrip('co')
    except AttributeError:
        print >>sys.stderr, 'E210: Can not goto "%s": built-in module' % (cw,)
        return

    if os.path.isfile(gf):
        gf = gf.replace(' ', '\\ ')
        vim.command('vsplit %s' % (gf,))

EOF
    map gf :python3 python_goto_file()<cr>
endif

" vim:ft=vim:fdm=marker
