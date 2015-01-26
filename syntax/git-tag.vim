runtime syntax/diff.vim
setlocal filetype=

syntax match Comment /^".*/
syntax match gitStatusComment   +^#.*+ contains=ALL
highlight link gitStatusComment     Comment
