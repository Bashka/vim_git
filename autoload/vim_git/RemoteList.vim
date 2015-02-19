" Date Create: 2015-02-13 09:59:28
" Last Change: 2015-02-19 13:28:20
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Buffer = vim_lib#sys#Buffer#
let s:System = vim_lib#sys#System#.new()
let s:Content = vim_lib#sys#Content#.new()

let s:screen = s:Buffer.new('#Git-remote#')
call s:screen.temp()
call s:screen.option('filetype', 'git-remote')
function! s:screen.render() " {{{
  return '" Remote list (Press ? for help) "' . "\n\n" . vim_git#run('remote -v')
endfunction " }}}

call s:screen.map('n', 'a', 'create')
call s:screen.map('n', 'dd', 'delete')
call s:screen.map('n', 'r', 'rename')
call s:screen.map('n', 'f', 'fetch')
call s:screen.map('n', 'i', 'pull')
call s:screen.map('n', 'o', 'push')

"" {{{
" Создает новый псевдоним сервера.
"" }}}
function! s:screen.create() " {{{
  call s:System.echo('Create alias for remote server.', 'ModeMsg')
  let l:alias = s:System.read('Enter alias: ')
  let l:url = s:System.read('Enter url: ')
  if l:alias != '' && l:url != ''
    call vim_git#createRemote(l:alias, l:url)
    call self.redraw()
  endif
endfunction " }}}
"" {{{
" Удаляет псевдоним сервера.
"" }}}
function! s:screen.delete() " {{{
  if s:System.confirm('Realy delete alias "' . expand('<cWORD>') . '"?')
    call vim_git#deleteRemote(expand('<cWORD>'))
    call self.redraw()
  endif
endfunction " }}}
"" {{{
" Переименовывает псевдоним сервера.
"" }}}
function! s:screen.rename() " {{{
  call s:System.echo('Rename alias for remote server.', 'ModeMsg')
  let l:aliasNew = s:System.read('Enter new alias: ')
  if l:aliasNew != ''
    call vim_git#renameRemote(expand('<cWORD>'), l:aliasNew)
    call self.redraw()
  endif
endfunction " }}}
"" {{{
" Загружает все изменения из указанного сервера.
"" }}}
function! s:screen.fetch() " {{{
  call vim_git#fetch(expand('<cWORD>'))
endfunction " }}}
"" {{{
" Загружает и сливает изменения из указанного сервера в текущую ветку.
"" }}}
function! s:screen.pull() " {{{
  call vim_git#pull(expand('<cWORD>'))
endfunction " }}}
"" {{{
" Выгружает изменения из текущей ветки в указанный сервер.
"" }}}
function! s:screen.push() " {{{
  call vim_git#push(expand('<cWORD>'))
endfunction " }}}

call s:screen.map('n', '?', 'showHelp')
" Подсказки. {{{
let s:screen.help = ['" Manual "',
                   \ '',
                   \ '" a - create new alias',
                   \ '" dd - delete alias',
                   \ '" r - rename alias',
                   \ '" f - get changes',
                   \ '" i - pull changes',
                   \ '" o - push changes',
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

let vim_git#RemoteList# = s:screen
