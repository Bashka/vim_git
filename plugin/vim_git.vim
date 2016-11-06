" Date Create: 2015-01-09 16:02:43
" Last Change: 2015-06-04 23:18:24
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Plugin = vim_lib#sys#Plugin#

let s:p = s:Plugin.new('vim_git', '1')

" Опции. {{{
"" {{{
" @var string Имя утилиты Git.
"" }}}
let s:p.bin = 'git'
"" {{{
" @var integer Число комитов, отображаемых в истории (git log). Если ограничивать историю не требуется, используется значение 0.
"" }}}
let s:p.logSize = 20
"" {{{
" @var string Тип вывода истории комитов. Возможно одно из следующих значений: graph - граф; classic - обычный лог.
"" }}}
let s:p.logType = 'graph'
"" {{{
" @var string Фильтр лога по автору.
"" }}}
let s:p.logAuthor = ''
"" {{{
" @var string Фильтр лога по дате "до".
"" }}}
let s:p.logAfter = ''
"" {{{
" @var string Фильтр лога по дате "после".
"" }}}
let s:p.logBefore = ''
" }}}
" Меню. {{{
"" {{{
" Отобразить статус репозитория.
"" }}}
call s:p.menu('Status', 'status', '1')
"" {{{
" Добавить текущий файл в индекс.
"" }}}
call s:p.menu('Index.Add', 'addCurrent', '2.1')
"" {{{
" Добавить все измененные файлы в индекс.
"" }}}
call s:p.menu('Index.Add_all', 'addAll', '2.2')
"" {{{
" Удалить все файлы из индекса.
"" }}}
call s:p.menu('Index.Reset', 'resetIndex', '2.3')
"" {{{
" Удалить текущий файл из индекса.
"" }}}
call s:p.menu('Index.Reset_file', 'resetCurrentFile', '2.4')
"" {{{
" Отменить все изменения.
"" }}}
call s:p.menu('Index.Undo', 'undoChanges', '2.5')
"" {{{
" Отобразить историю комитов.
"" }}}
call s:p.menu('Log', 'log', '3')
"" {{{
" Вернуться к предыдущему комиту.
"" }}}
call s:p.menu('Commit.Checkout_head', 'checkoutHead', '4.1')
"" {{{
" Создать комит.
"" }}}
call s:p.menu('Commit.Commit', 'commit', '4.2')
"" {{{
" Добавить все инзмененные файлы в индекс и создать комит.
"" }}}
call s:p.menu('Commit.Commit_all', 'commitAll', '4.3')
"" {{{
" Создать замещающий комит.
"" }}}
call s:p.menu('Commit.Amend_commit', 'amendCommit', '4.4')
"" {{{
" Добавить все инзмененные файлы в индекс и создать замещающий комит.
"" }}}
call s:p.menu('Commit.Amend_commit_all', 'amendCommitAll', '4.5')
"" {{{
" Отобразить список веток.
"" }}}
call s:p.menu('Branch.List', 'branchList', '5')
"" {{{
" Отобразить список псевдонимов серверов.
"" }}}
call s:p.menu('Remote.List', 'remoteList', '6.1')
"" {{{
" Выгрузить текущую ветку на сервер.
"" }}}
call s:p.menu('Remote.Push', 'pushCurrent', '6.2')
"" {{{
" Загрузить изменения с сервера в текущую ветку.
"" }}}
call s:p.menu('Remote.Pull', 'pullCurrent', '6.3')
"" {{{
" Отобразить список меток.
"" }}}
call s:p.menu('Tag.List', 'tagList', '7')
"" {{{
" Инициализировать новый репозиторий.
"" }}}
call s:p.menu('Init', 'init', '8')
"" {{{
" Отобразить документацию плагина.
"" }}}
call s:p.menu('Help', 'help', '9')
" }}}

call s:p.reg()
