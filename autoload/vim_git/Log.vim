" Date Create: 2015-02-10 10:12:11
" Last Change: 2015-12-15 22:14:50
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Buffer = vim_lib#sys#Buffer#
let s:System = vim_lib#sys#System#
let s:Content = vim_lib#sys#Content#.new()
let s:BufferStack = vim_lib#view#BufferStack#

let s:screen = s:Buffer.new('#Git-log#')
call s:screen.temp()
call s:screen.option('filetype', 'git-log')
function! s:screen.render() " {{{
  if g:vim_git#.logType == 'classic'
    let l:LogFun = function('vim_git#classicLog')
  else
    let l:LogFun = function('vim_git#' . g:vim_git#.logType . 'Log')
  endif
  let l:limitMsg = (g:vim_git#.logSize == 0 )? 'no' : g:vim_git#.logSize
  return '" Log [' . l:limitMsg . ' limit] (Press ? for help) "' . "\n\n" . l:LogFun()
endfunction " }}}

call s:screen.map('n', '<Enter>', 'checkout')
call s:screen.map('n', 'u', 'checkoutHead')
call s:screen.map('n', 'd', 'diff')
call s:screen.map('n', 's', 'show')
call s:screen.map('n', 'v', 'toogleType')
call s:screen.map('n', 'f', 'filter')

"" {{{
" Делает заданный комит текущим.
"" }}}
function! s:screen.checkout() " {{{
  call vim_git#checkoutCommit(expand('<cword>'))
  call self.active()
endfunction " }}}
"" {{{
" Возвращает состояние к предыдущему комиту.
"" }}}
function! s:screen.checkoutHead() " {{{
  call vim_git#checkoutHead()
  call self.active()
endfunction " }}}
"" {{{
" Отображает расхождение между текущим и заданным комитом.
"" }}}
function! s:screen.diff() " {{{
  let l:buf = s:Buffer.new('#Git-diff#')
  call l:buf.temp()
  call l:buf.option('filetype', 'git-diff')
  let l:buf.render = "vim_git#run('diff " . expand('<cword>') . "')"
  call self.stack.push(l:buf)
  call self.stack.active()
endfunction " }}}
"" {{{
" Отображает список файлов, измененных от данного комита.
"" }}}
function! s:screen.show() " {{{
  let l:buf = vim_git#CommitInfo#new(expand('<cword>'))
  call self.stack.push(l:buf)
  call self.stack.active()
endfunction " }}}
"" {{{
" Изменяет тип вывода лога.
"" }}}
function! s:screen.toogleType() " {{{
  if g:vim_git#.logType == 'classic'
    let g:vim_git#.logType = 'graph'
  else
    let g:vim_git#.logType = 'classic'
  endif
  call self.redraw()
endfunction " }}}
function! s:screen.filter() " {{{
  call s:System.echo('Filters:', 'ModeMsg')
  call s:System.echo('0. Author [' . g:vim_git#.logAuthor . ']')
  call s:System.echo('1. Before [' . g:vim_git#.logBefore . ']')
  call s:System.echo('2. After [' . g:vim_git#.logAfter . ']')
  call s:System.echo('3. Size [' . g:vim_git#.logSize . ']')
  call s:System.echo('9. Clear filters')
  let l:type = s:System.read('Select filter type: ')
  if l:type != ''
    if l:type == 0
      let g:vim_git#.logAuthor = s:System.read('Set filter "author": ')
      call self.active()
    elseif l:type == 1
      let g:vim_git#.logBefore = s:System.read('Set filter "before": ')
      call self.active()
    elseif l:type == 2
      let g:vim_git#.logAfter = s:System.read('Set filter "after": ')
      call self.active()
    elseif l:type == 3
      let g:vim_git#.logSize = s:System.read('Set filter "size": ')
      call self.active()
    elseif l:type == 9
      let g:vim_git#.logAuthor = ''
      let g:vim_git#.logBefore = ''
      let g:vim_git#.logAfter = ''
      let g:vim_git#.logSize = 20
      call self.active()
    endif
  endif
endfunction " }}}

call s:screen.map('n', '?', 'showHelp')
" Подсказки. {{{
let s:screen.help = ['" Manual "',
                   \ '',
                   \ '" Enter - checkout commit',
                   \ '" u - checkout orig head',
                   \ '" d - show diff commit',
                   \ '" s - show commit info',
                   \ '" v - toogle log type',
                   \ '" f - set filters',
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
let vim_git#Log# = s:bufStack
