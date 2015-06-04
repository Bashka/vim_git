runtime syntax/diff.vim
set syntax=git-base

syntax match gitStatusComment   +^#.*+ contains=ALL
highlight link gitStatusComment     Comment
