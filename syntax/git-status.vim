runtime syntax/diff.vim
set syntax=git-base

syntax match gitStatusBranch    /On branch .*/

syntax match gitStatusUndracked /\t\zs.\+/
syntax match gitStatusNewFile   /\t\zsnew file: .\+/
syntax match gitStatusModified  /\t\zsmodified: .\+/

syntax match Comment /Modified:/
syntax match Comment /Changes not staged for commit:/
syntax match Comment /Changes to be committed:/
syntax match Comment /Untracked files:/
syntax match Comment /New file:/

highlight link gitStatusBranch      Title
highlight link gitStatusUndracked   diffOnly
highlight link gitStatusNewFile     diffAdded
highlight link gitStatusModified    diffChanged
