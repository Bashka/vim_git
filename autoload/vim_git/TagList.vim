" Date Create: 2015-02-07 23:37:33
" Last Change: 2015-02-19 13:30:20
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Buffer = vim_lib#sys#Buffer#
let s:System = vim_lib#sys#System#.new()
let s:Content = vim_lib#sys#Content#.new()

let s:screen = s:Buffer.new('#Git-tag#')
call s:screen.temp()
call s:screen.option('filetype', 'git-tag')
function! s:screen.render() " {{{
  return '" Tag list (Press ? for help) "' . "\n\n" . vim_git#run('tag -l -n')
endfunction " }}}

call s:screen.map('n', '<Enter>', 'checkout')
call s:screen.map('n', 'a', 'createSoft')
call s:screen.map('n', 'A', 'createHard')
call s:screen.map('n', 'dd', 'delete')
call s:screen.map('n', 's', 'show')

"" {{{
" Делает текущим комит, который помечает данный тег.
"" }}}
function! s:screen.checkout() " {{{
  call vim_git#checkoutTag(expand('<cWORD>'))
endfunction " }}}
"" {{{
" Создает тег для текущего комита.
"" }}}
function! s:screen.createSoft() " {{{
  call s:System.echo('Create soft tag.', 'ModeMsg')
  let l:tagName = s:System.read('Enter tag name: ')
  if l:tagName != ''
    call vim_git#softTag(l:tagName)
    call self.redraw()
  endif
endfunction " }}}
"" {{{
" Создает аннотирующий тег для текущего комита.
"" }}}
function! s:screen.createHard() " {{{
  call s:System.echo('Create hard tag.', 'ModeMsg')
  let l:tagName = s:System.read('Enter tag name: ')
  if l:tagName != ''
    let l:buf = s:Buffer.new(tempname())
    let l:buf.tagName = l:tagName
    let l:buf.tagList = self
    function! l:buf.createTag() " {{{
      call vim_git#run('tag --file=' . expand('%') . ' -a ' . self.tagName)
      call self.tagList.active()
      call self.delete()
    endfunction " }}}
    call l:buf.au('BufWritePost', 'createTag')
    call l:buf.gactive('t')
  endif
endfunction " }}}
"" {{{
" Удаляет тег.
"" }}}
function! s:screen.delete() " {{{
  if s:System.confirm('Realy delete tag "' . expand('<cWORD>') . '"?')
    call vim_git#deleteTag(expand('<cWORD>'))
    call self.redraw()
  endif
endfunction " }}}
"" {{{
" Показывает информацию по тегу.
"" }}}
function! s:screen.show() " {{{
  call vim_git#showTag(expand('<cWORD>'))
endfunction " }}}

call s:screen.map('n', '?', 'showHelp')
" Подсказки. {{{
let s:screen.help = ['" Manual "',
                   \ '',
                   \ '" Enter - checkout current tag',
                   \ '" a - create tag for current commit',
                   \ '" A - create annotation tag for current commit',
                   \ '" dd - delete current tag',
                   \ '" s - show tag',
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

let vim_git#TagList# = s:screen
