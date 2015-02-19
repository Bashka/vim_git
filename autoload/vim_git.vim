" Date Create: 2015-01-09 13:19:18
" Last Change: 2015-02-19 10:32:37
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Buffer = vim_lib#sys#Buffer#
let s:BufferStack = vim_lib#view#BufferStack#
let s:Sys = vim_lib#sys#System#.new()

"" {{{
" Метод выполняет заданную команду Git и возвращает результат ее работы.
" @param string command Команда Git.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
" @return string Результат работы команды.
"" }}}
function! vim_git#run(command) " {{{
  return s:Sys.run(g:vim_git#.bin . ' ' . a:command)
endfunction " }}}

"" {{{
" Метод выполняет заданную команду Git с переходом в командную оболочку.
" @param string command Команда Git.
"" }}}
function! vim_git#exe(command) " {{{
  call s:Sys.exe(g:vim_git#.bin . ' ' . a:command)
endfunction " }}}

" add {{{
"" {{{
" Метод добавляет текущий файл в индекс.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#addCurrent() " {{{
  call vim_git#run('add ' . expand('%'))
endfunction " }}}

"" {{{
" Метод добавляет файл в индекс.
" @param string file Адрес целевого файла.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#addFile(file) " {{{
  call vim_git#run('add ' . a:file)
endfunction " }}}

"" {{{
" Метод добавляет все файлы проекта в индекс (новые, удаленные, измененные, перемещенные).
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#addAll() " {{{
  call vim_git#run('add -A')
endfunction " }}}
" }}}

" commit {{{
"" {{{
" Метод выполняет комит индекса.
" Для записи коментария комита создается временный файл в новом буфере.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#commit() " {{{
  let l:buf = s:Buffer.new()
  call l:buf.gactive('t')
  exe 'e ' . tempname()
  autocmd BufWritePost <buffer> call vim_lib#sys#System#.new().print(vim_git#run('commit --file=' . expand('%')))
endfunction " }}}

"" {{{
" Метод выполняет комит индекса.
" @param string message Описание комита.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#fastCommit(message) " {{{
  call vim_git#run('commit -m "' . a:message . '"')
endfunction " }}}

"" {{{
" Метод выполняет комит индекса изменяя последний комит.
" Для записи коментария комита создается временный файл в новом буфере.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#amendCommit() " {{{
  let l:buf = s:Buffer.new()
  call l:buf.gactive('t')
  exe 'e ' . tempname()
  autocmd BufWritePost <buffer> call vim_lib#sys#System#.new().print(vim_git#run('commit --amend --file=' . expand('%')))
endfunction " }}}

"" {{{
" Метод выполняет комит индекса предварительно индексируя все изменения.
" Для записи коментария комита создается временный файл в новом буфере.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#commitAll() " {{{
  call vim_git#addAll()
  call vim_git#commit()
endfunction " }}}

"" {{{
" Метод выполняет комит индекса изменяя последний комит и предварительно индексируя все изменения.
" Для записи коментария комита создается временный файл в новом буфере.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#amendCommitAll() " {{{
  call vim_git#addAll()
  call vim_git#amendCommit()
endfunction " }}}
" }}}

" reset {{{
"" {{{
" Метод сбрасывает весь индекс.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#resetIndex() " {{{
  call vim_git#run('reset')
endfunction " }}}

"" {{{
" Метод исключает файл из индекса.
" @param string file Исключаемый файл.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#resetFile(file) " {{{
  call vim_git#run('reset -q -- ' . a:file)
endfunction " }}}

"" {{{
" Метод исключает текущий файл из индекса.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#resetCurrentFile() " {{{
  call vim_git#run('reset -- ' . expand('%'))
endfunction " }}}

"" {{{
" Метод мягко (soft) удаляет историю комитов, начиная с данного.
" @param string commit Комит с которого начнется удаление истории.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#hardResetCommit(commit) " {{{
  call vim_git#run('reset --soft ' . a:commit)
endfunction " }}}

"" {{{
" Метод удаляет историю комитов, начиная с данного.
" @param string commit Комит с которого начнется удаление истории.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#hardResetCommit(commit) " {{{
  call vim_git#run('reset --hard ' . a:commit)
endfunction " }}}
" }}}

" checkout {{{
"" {{{
" Метод отменяет все несохраненные изменения в файле.
" @param string file Адрес целевого файла.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#undoFile(file) " {{{
  call vim_git#run('checkout HEAD -- ' . a:file)
endfunction " }}}

"" {{{
" Метод отменяет все несохраненные изменения.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#undoChanges() " {{{
  call vim_git#run('checkout -f HEAD')
endfunction " }}}

"" {{{
" Метод делает заданный комит текущим.
" @param string commit Целевой комит.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#checkoutCommit(commit) " {{{
  call vim_git#run('checkout ' . a:commit)
endfunction " }}}

"" {{{
" Метод возвращает состояние к предыдущему комиту.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#checkoutHead() " {{{
  call vim_git#run('checkout ORIG_HEAD')
endfunction " }}}

"" {{{
" Метод делает помеченный комит текущим.
" @param string tag Метка комита.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#checkoutTag(tag) " {{{
  call vim_git#run('checkout ' . a:tag)
endfunction " }}}

"" {{{
" Метод делает последний комит заданной ветки текущим.
" @param string branch Целевая ветка.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#checkoutBranch(branch) " {{{
  call vim_git#run('checkout ' . a:branch)
endfunction " }}}
" }}}

" tag {{{
"" {{{
" Метод создает легковесную метку для последнего комита.
" @param string name Имя метки.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#softTag(name) " {{{
  call vim_git#run('tag ' . a:name)
endfunction " }}}

"" {{{
" Метод создает легковесную метку для заданного комита.
" @param string commit Целевой комит.
" @param string name Имя метки.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#softTagCommit(commit, name) " {{{
  call vim_git#run('tag ' . a:name , ' ' . a:commit)
endfunction " }}}

"" {{{
" Метод создает аннотированную метку для последнего комита.
" Для записи коментария метки создается временный файл в новом буфере.
" @param string name Имя метки.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#hardTag(name) " {{{
  let l:buf = s:Buffer.new()
  let g:vim_git#tagName = a:name
  call l:buf.gactive('t')
  exe 'e ' . tempname()
  autocmd BufWritePost <buffer> call vim_git#run('tag --file=' . expand('%') . ' -a ' . vim_git#tagName)
endfunction " }}}

"" {{{
" Метод создает аннотированную метку для заданного комита.
" Для записи коментария метки создается временный файл в новом буфере.
" @param string commit Целевой комит.
" @param string name Имя метки.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#hardTagCommit(commit, name) " {{{
  let l:buf = s:Buffer.new()
  let g:vim_git#tagName = a:name
  let g:vim_git#commit = a:commit
  call l:buf.gactive('t')
  exe 'e ' . tempname()
  autocmd BufWritePost <buffer> call vim_git#run('tag --file=' . expand('%') . ' -a ' . vim_git#tagName . ' ' . vim_git#commit)
endfunction " }}}

"" {{{
" Метод удаляет метку.
" @param string name Имя удаляемой метки.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#deleteTag(name) " {{{
  call vim_git#run('tag -d ' . a:name)
endfunction " }}}

"" {{{
" Метод показывает информацию о метке.
" @param string name Имя целевой метки.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#showTag(name) " {{{
  call s:Sys.print(vim_git#run('show -s ' . a:name))
endfunction " }}}

"" {{{
" Метод формирует список меток в новом окне.
"" }}}
function! vim_git#tagList() " {{{
  let l:screen = g:vim_git#TagList#
  if l:screen.getWinNum() != -1
    " Закрыть окно, если оно уже открыто.
    call l:screen.unload()
  else
    call l:screen.vactive('R', 40)
  endif
endfunction " }}}
" }}}

" status {{{
"" {{{
" Метод отображает текущее состояние репозитория в новом окне.
"" }}}
function! vim_git#status() " {{{
  let l:screen = g:vim_git#Status#
  if l:screen.current().getWinNum() != -1
    " Закрыть окно, если оно уже открыто.
    call l:screen.clear(1)
    call l:screen.current().unload()
  else
    call l:screen.gactive('t')
  endif
endfunction " }}}
" }}}

" log {{{
"" {{{
" Метод отображает историю изменений текущей ветки в новом окне.
"" }}}
function! vim_git#log() " {{{
  let l:screen = g:vim_git#Log#
  if l:screen.current().getWinNum() != -1
    " Закрыть окно, если оно уже открыто.
    call l:screen.clear(1)
    call l:screen.current().unload()
  else
    call l:screen.gactive('t')
  endif
endfunction " }}}

"" {{{
" Метод возвращает историю изменений текущей ветки.
"" }}}
function! vim_git#classicLog() " {{{
  let l:size = (g:vim_git#.logSize == 0)? '' : '-' . g:vim_git#.logSize
  return vim_git#run('log ' . l:size)
endfunction " }}}

"" {{{
" Метод возвращает историю изменений текущей ветки в виде графа.
"" }}}
function! vim_git#graphLog() " {{{
  let l:size = (g:vim_git#.logSize == 0)? '' : '-' . g:vim_git#.logSize
  return vim_git#run('log ' . l:size . ' --graph --pretty="format:%h [%ar by %an] - %s "')
endfunction " }}}
" }}}

" branch {{{
"" {{{
" Метод создает новую ветку.
" @param string name Имя создаваемой ветки.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#createBranch(name) " {{{
  call vim_git#run('branch ' . a:name)
  call vim_git#checkoutBranch(a:name)
endfunction " }}}

"" {{{
" Метод удаляет ветку.
" @param string name Имя удаляемой ветки.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#softDeleteBranch(name) " {{{
  call vim_git#run('branch -d ' . a:name)
endfunction " }}}

"" {{{
" Метод удаляет ветку, даже если она не была слита с другой веткой.
" @param string name Имя удаляемой ветки.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#hardDeleteBranch(name) " {{{
  call vim_git#run('branch -D ' . a:name)
endfunction " }}}

"" {{{
" Метод удаляет ветку на удаленном сервере.
" @param string alias Псевдоним сервера.
" @param string name Имя удаляемой ветки.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#deleteRemoteBranch(alias, name) " {{{
  call vim_git#exe('push ' . a:alias . ' :' . a:name)
endfunction " }}}

"" {{{
" Метод переименовывает заданную ветку.
" @param string name Имя целевой ветки.
" @param string newname Новое имя ветки.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#renameBranch(name, newname) " {{{
  call vim_git#run('branch -M ' . a:name . ' ' . l:newname)
endfunction " }}}

"" {{{
" Метод сливает указанную ветку с текущей.
" @param string name Имя сливаемой ветки.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#merge(branch) " {{{
  call vim_git#run('merge ' . a:branch)
endfunction " }}}

"" {{{
" Метод отображает список веток репозитория в новом окне.
"" }}}
function! vim_git#branchList() " {{{
  let l:screen = g:vim_git#BranchList#
  if l:screen.current().getWinNum() != -1
    " Закрыть окно, если оно уже открыто.
    call l:screen.clear(1)
    call l:screen.current().unload()
  else
    call l:screen.gactive('t')
  endif
endfunction " }}}
" }}}

" remote {{{
"" {{{
" Метод создаен пресводинм сервера.
" @param string name Псевдоним.
" @param string url URL адрес сервера.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#createRemote(name, url) " {{{
    call vim_git#run('remote add ' . a:name . ' ' . a:url)
endfunction " }}}

"" {{{
" Метод удаляет псевдоним сервера.
" @param string name Удаляемый псевдоним.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#deleteRemote(name) " {{{
  call vim_git#run('remote rm ' . a:name)
endfunction " }}}

"" {{{
" Метод изменяет псевдоним сервера.
" @param string name Псевдоним.
" @param string newname Новый псевдоним.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#renameRemote(name, newname) " {{{
  call vim_git#run('remote rename ' . a:name . ' ' . a:newname)
endfunction " }}}

"" {{{
" Метод загружает все изменения из указанного сервера.
" @param string name Псевдоним целевого сервера.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#fetch(name) " {{{
  call vim_git#exe('fetch ' . a:name)
endfunction " }}}

"" {{{
" Метод загружает все изменения из указанного сервера и сливает их с текущей веткой.
" @param string name Псевдоним целевого сервера.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#pull(name) " {{{
  call vim_git#exe('pull ' . a:name)
endfunction " }}}

"" {{{
" Метод загружает все изменения из сервера и сливает их с текущей веткой. Текущая ветка должна являться отслеживаемой.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#pullCurrent() " {{{
  call vim_git#exe('pull')
endfunction " }}}

"" {{{
" Метод загружает ветку из указанного сервера в текущую.
" @param string server Псевдоним целевого сервера.
" @param string branch Имя ветки.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#pullBranch(server, branch) " {{{
  call vim_git#exe('pull ' . a:server . ' ' . a:branch)
endfunction " }}}

"" {{{
" Метод выгружает все изменения на указанный сервер.
" @param string name Псевдоним целевого сервера.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#push(name) " {{{
  call vim_git#exe('push ' . a:name)
endfunction " }}}

"" {{{
" Метод выгружает все изменения на сервер. Текущая ветка должна быть отслеживаемой.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#pushCurrent() " {{{
  call vim_git#exe('push')
endfunction " }}}

"" {{{
" Метод выгружает заданную ветку на сервер.
" @param string server Псевдоним целевого сервера.
" @param string branch Имя ветки.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды.
"" }}}
function! vim_git#pushBranch(server, branch) " {{{
  call vim_git#exe('push --set-upstream ' . a:server . ' ' . a:branch . ':' . a:branch)
endfunction " }}}

"" {{{
" Метод формирует список псевдонимов серверов.
"" }}}
function! vim_git#remoteList() " {{{
  let l:screen = g:vim_git#RemoteList#
  if l:screen.getWinNum() != -1
    " Закрыть окно, если оно уже открыто.
    call l:screen.unload()
  else
    call l:screen.gactive('t')
  endif
endfunction " }}}
" }}}
