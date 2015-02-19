" Date Create: 2015-02-11 09:32:04
" Last Change: 2015-02-18 10:16:55
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Buffer = vim_lib#sys#Buffer#
let s:Content = vim_lib#sys#Content#.new()

function! vim_git#BranchInfo#new(branch) " {{{
  let s:screen = s:Buffer.new('#Git-branch-diff#')
  call s:screen.temp()
  call s:screen.option('filetype', 'git-commit')
  let s:screen.currentBranch = vim_git#run('rev-parse --abbrev-ref HEAD')[0 : -2]
  let s:screen.diffBranch = a:branch
  function! s:screen.render() " {{{
    return '" Branch (Press ? for help) "' . "\n\n" . vim_git#run('diff --name-status ' . self.currentBranch . '..' . self.diffBranch)
  endfunction " }}}

  call s:screen.map('n', 'd', 'diff')
  call s:screen.map('n', 'D', 'vimdiff')

  "" {{{
  " Отображает различия между текущим состоянием файла, и состоянием в заданном комите.
  "" }}}
  function! s:screen.diff() " {{{
    let l:buf = s:Buffer.new('#Git-diff#')
    call l:buf.temp()
    call l:buf.option('filetype', 'git-diff')
    let l:buf.render = "vim_git#run('diff " . self.currentBranch . ".." . self.diffBranch . " -- " . expand('<cfile>') . "')"
    call self.stack.push(l:buf)
    call self.stack.active()
  endfunction " }}}
  "" {{{
  " Отображает различия между текущим состоянием файла, и состоянием в заданной ветке с помощью редактора Vim.
  "" }}}
  function! s:screen.vimdiff() " {{{
    let l:file = expand('<cfile>')
    let l:source = s:Buffer.new('#Current state file - ' . l:file)
    call l:source.temp()
    call self.stack.push(l:source)
    let l:source._delete = l:source.delete
    function! l:source.delete() " {{{
      call self.editFile.delete()
      call self._delete()
    endfunction " }}}
    call self.stack.active()
    exe 'r ' . l:file
    0d
    filetype detect
    diffthis

    let l:edit = s:Buffer.new('#Past state file - ' . l:file)
    call l:edit.temp()
    let l:edit.sourceFile = l:source
    call l:edit.map('n', '<C-y>', 'quit')
    function! l:edit.quit() " {{{
      call self.sourceFile.stack.delete()
    endfunction " }}}
    call l:edit.vactive('r')
    silent put=vim_git#run('cat-file -p ' . self.diffBranch . ':' . l:file)
    0d
    filetype detect
    diffthis

    let l:source.editFile = l:edit
  endfunction " }}}

  call s:screen.map('n', '?', 'showHelp')
  " Подсказки. {{{
  let s:screen.help = ['" Manual "',
                     \ '',
                     \ '" d - show diff file for branch',
                     \ '" D - show diff file for branch with Vim',
                     \ ''
                     \]
  " }}}
  function! s:screen.showHelp() " {{{
    if s:Content.line(1) != self.help[0]
    let self.pos = s:Content.pos()
      call s:Content.add(1, self.help)
    else
      call self.active()
    call s:Content.pos(self.pos)
    endif
  endfunction " }}}

  return s:screen
endfunction " }}}
