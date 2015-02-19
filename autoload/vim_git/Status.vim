" Date Create: 2015-02-09 23:32:54
" Last Change: 2015-02-19 13:29:47
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Buffer = vim_lib#sys#Buffer#
let s:System = vim_lib#sys#System#.new()
let s:Content = vim_lib#sys#Content#.new()
let s:BufferStack = vim_lib#view#BufferStack#

let s:screen = s:Buffer.new('#Git-status#')
call s:screen.temp()
call s:screen.option('filetype', 'git-status')
function! s:screen.render() " {{{
  return '" Status (Press ? for help) "' . "\n\n" . vim_git#run('status')
endfunction " }}}

call s:screen.map('n', 'a', 'add')
call s:screen.map('n', 'A', 'addAll')
call s:screen.map('n', 'dd', 'delete')
call s:screen.map('n', 'da', 'deleteAll')
call s:screen.map('n', 'u', 'reset')
call s:screen.map('n', 'U', 'resetAll')
call s:screen.map('n', 'd', 'diff')
call s:screen.map('n', 'D', 'vimdiff')

"" {{{
" Добавление файла в индекс.
"" }}}
function! s:screen.add() " {{{
  call vim_git#addFile(expand('<cfile>'))
  call self.redraw()
endfunction " }}}
"" {{{
" Добавление всех файлов проекта в индекс.
"" }}}
function! s:screen.addAll() " {{{
  call vim_git#addAll()
  call self.redraw()
endfunction " }}}
"" {{{
" Удаление файла из индекса.
"" }}}
function! s:screen.delete() " {{{
  call vim_git#resetFile(expand('<cfile>'))
  call self.redraw()
endfunction " }}}
"" {{{
" Удаление файла из индекса.
"" }}}
function! s:screen.delete() " {{{
  call vim_git#resetFile(expand('<cfile>'))
  call self.redraw()
endfunction " }}}
"" {{{
" Удаление всех файлов из индекса.
"" }}}
function! s:screen.deleteAll() " {{{
  call vim_git#resetIndex()
  call self.redraw()
endfunction " }}}
"" {{{
" Отменяет изменения в файле.
"" }}}
function! s:screen.reset() " {{{
  if s:System.confirm('Realy reset file "' . expand('<cfile>') . '"?')
    call vim_git#undoFile(expand('<cfile>'))
    call self.redraw()
  endif
endfunction " }}}
"" {{{
" Отменяет изменения во всех файлах.
"" }}}
function! s:screen.resetAll() " {{{
  if s:System.confirm('Realy reset all files?')
    call vim_git#undoChanges()
    call self.redraw()
  endif
endfunction " }}}
"" {{{
" Отображает изменения, внесенные в файл.
"" }}}
function! s:screen.diff() " {{{
  let l:buf = s:Buffer.new('#Git-diff#')
  call l:buf.temp()
  call l:buf.option('filetype', 'git-diff')
  let l:buf.render = "vim_git#run('diff HEAD -- " . expand('<cfile>') . "')"
  call self.stack.push(l:buf)
  call self.active()
endfunction " }}}
"" {{{
" Отображает изменения, внесенные в файл с помощью редактора Vim.
"" }}}
function! s:screen.vimdiff() " {{{
  let l:file = expand('<cfile>')
  " source - source file
  let l:source = s:Buffer.new('#Source file - ' . l:file)
  call l:source.temp()
  call self.stack.push(l:source)
  let l:source._delete = l:source.delete
  function! l:source.delete() " {{{
    call self.editFile.delete()
    call self._delete()
  endfunction " }}}
  call self.stack.active()
  silent put=vim_git#run('cat-file -p HEAD:' . l:file)
  0d
  filetype detect
  diffthis

  " edit - edited file
  let l:edit = s:Buffer.new('#Edited file - ' . l:file)
  call l:edit.temp()
  let l:edit.sourceFile = l:source
  call l:edit.map('n', '<C-y>', 'quit')
  function! l:edit.quit() " {{{
    call self.sourceFile.stack.delete()
  endfunction " }}}
  call l:edit.vactive('r')
  exe 'r ' . l:file
  0d
  filetype detect
  diffthis

  let l:source.editFile = l:edit
endfunction " }}}

call s:screen.map('n', '?', 'showHelp')
" Подсказки. {{{
let s:screen.help = ['" Manual "',
                   \ '',
                   \ '" a - add file in index',
                   \ '" dd - delete file from index',
                   \ '" u - reset file',
                   \ '" U - reset all files',
                   \ '" d - show changes in the file',
                   \ '" D - show changes in the file with Vim',
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

let s:bufStack = s:BufferStack.new()
call s:bufStack.push(s:screen)
call s:screen.ignoreMap('n', '<C-y>') " Последний экран стека должен выгружаться, а не удаляться.
let vim_git#Status# = s:bufStack
