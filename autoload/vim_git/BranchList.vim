" Date Create: 2015-02-10 22:34:25
" Last Change: 2015-02-19 14:51:31
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Buffer = vim_lib#sys#Buffer#
let s:Content = vim_lib#sys#Content#.new()
let s:BufferStack = vim_lib#view#BufferStack#
let s:System = vim_lib#sys#System#.new()

let s:screen = s:Buffer.new('#Git-branch#')
call s:screen.temp()
call s:screen.option('filetype', 'git-branch')

function! s:screen.render() " {{{
  return '" Branch list (Press ? for help) "' . "\n\n" . '"" Local branch ""' . "\n\n" . vim_git#run('branch') . "\n" . '"" Remote branch ""' . "\n\n" . vim_git#run('branch -r')
endfunction " }}}

call s:screen.map('n', '<Enter>', 'checkout')
call s:screen.map('n', 'a', 'new')
call s:screen.map('n', 'dd', 'delete')
call s:screen.map('n', 'r', 'rename')
call s:screen.map('n', 'm', 'merge')
call s:screen.map('n', 'd', 'diff')
call s:screen.map('n', 's', 'show')
call s:screen.map('n', 'o', 'push')
call s:screen.map('n', 'i', 'pull')

"" {{{
" Метод определяет, является ли заданная ветка внешней.
" @param string branch Полное имя ветки.
" @return bool true - если ветка является внешней, иначе - false.
"" }}}
function! s:screen.isRemote(branch) " {{{
  return stridx(a:branch, '/') != -1
endfunction " }}}

"" {{{
" Делает заданную ветку текущей.
"" }}}
function! s:screen.checkout() " {{{
  call vim_git#checkoutBranch(expand('<cWORD>'))
  call self.redraw()
endfunction " }}}
"" {{{
" Создает новую ветку и делает ее текущей.
"" }}}
function! s:screen.new() " {{{
  call s:System.echo('Create new branch.', 'ModeMsg')
  let l:branchName = s:System.read('Enter branch name: ')
  if l:branchName != ''
    call vim_git#createBranch(l:branchName)
    call self.redraw()
  endif
endfunction " }}}
"" {{{
" Удаляет заданную ветку.
"" }}}
function! s:screen.delete() " {{{
  if s:System.confirm('Realy delete branch "' . expand('<cWORD>') . '"?')
    let l:branchName = expand('<cWORD>')
    if self.isRemote(l:branchName)
      let [l:server, l:branchName] = split(l:branchName, '/')
      call vim_git#deleteRemoteBranch(l:server, l:branchName)
    else
      call vim_git#hardDeleteBranch(l:branchName)
    endif
    call self.redraw()
  endif
endfunction " }}}
"" {{{
" Переименовывает заданную ветку.
"" }}}
function! s:screen.rename() " {{{
  call s:System.echo('Rename branch.', 'ModeMsg')
  let l:branchName = s:System.read('Enter branch new name: ')
  if l:branchName != ''
    call vim_git#renameBranch(expand('<cWORD>'), l:branchName)
    call self.redraw()
  endif
endfunction " }}}
"" {{{
" Сливает заданную ветку с текущей.
"" }}}
function! s:screen.merge() " {{{
  try
    call vim_git#merge(expand('<cWORD>'))
    call s:System.print('Merge complite', 'MoreMsg')
  catch /^ShellException.*/
  endtry
endfunction " }}}
"" {{{
" Показывает отличия между текущей и заданной ветками.
"" }}}
function! s:screen.diff() " {{{
  let l:buf = s:Buffer.new('#Git-diff#')
  call l:buf.temp()
  call l:buf.option('filetype', 'git-diff')
  let l:buf.branch = expand('<cWORD>')
  function! l:buf.render() " {{{
    let l:currentBranch = vim_git#run('rev-parse --abbrev-ref HEAD')
    return vim_git#run('diff ' . l:currentBranch[0 : -2] . '..' . self.branch)
  endfunction " }}}
  call self.stack.push(l:buf)
  call self.stack.active()
endfunction " }}}
"" {{{
" Отображает список файлов, измененных в данной ветке.
"" }}}
function! s:screen.show() " {{{
  let l:buf = vim_git#BranchInfo#new(expand('<cWORD>'))
  call self.stack.push(l:buf)
  call self.stack.active()
endfunction " }}}
"" {{{
" Выгружает заданную ветку на указанный сервер и делает ее отслеживаемой.
"" }}}
function! s:screen.push() " {{{
  call s:System.echo('Push branch.', 'ModeMsg')
  let l:servers = split(vim_git#run('remote'), "\n")
  let l:n = 0
  for l:server in l:servers
    call s:System.echo(l:n . '.' . l:server)
    let l:n += 1
  endfor
  let l:n = s:System.read('Select server: ')
  if l:n != ''
    let l:branch = expand('<cWORD>')
    call vim_git#pushBranch(l:servers[l:n], l:branch)
    call self.active()
  endif
endfunction " }}}
"" {{{
" Загружает и сливает заданную внешнейшнюю ветку с текущей и делает ее отслеживаемой.
"" }}}
function! s:screen.pull() " {{{
  let l:branchName = expand('<cWORD>')
  if self.isRemote(l:branchName)
    let [l:server, l:branch] = split(l:branchName, '/')
    call vim_git#pullBranch(l:server, l:branch)
  endif
endfunction " }}}

call s:screen.map('n', '?', 'showHelp')
" Подсказки. {{{
let s:screen.help = ['" Manual "',
                   \ '',
                   \ '" Local branch "',
                   \ '"   Enter - checkout branch',
                   \ '"   a - create new branch',
                   \ '"   r - rename branch',
                   \ '"   dd - delete branch',
                   \ '"   m - merge branch',
                   \ '"   o - push branch',
                   \ '"   d - show diff file for branch',
                   \ '"   s - show branch info',
                   \ '" Remote branch "',
                   \ '"   dd - delete branch',
                   \ '"   m - merge branch',
                   \ '"   i - pull branch',
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
let vim_git#BranchList# = s:bufStack
