" Date Create: 2015-01-09 16:02:43
" Last Change: 2015-02-19 13:52:17
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
" @var string Тип вывода истории комитов. Возможно одно из следующих занчение: graph - граф; classic - обычный лог.
"" }}}
let s:p.logType = 'graph'
" }}}
" Меню. {{{
call s:p.menu('Status', 'status', '1')
call s:p.menu('Index.Add', 'addCurrent', '2.1')
call s:p.menu('Index.Add_all', 'addAll', '2.2')
call s:p.menu('Index.Reset', 'resetIndex', '2.3')
call s:p.menu('Index.Reset_file', 'resetCurrentFile', '2.4')
call s:p.menu('Index.Undo', 'undoChanges', '2.5')
call s:p.menu('Log', 'log', '3')
call s:p.menu('Commit.Checkout_head', 'checkoutHead', '4.1')
call s:p.menu('Commit.Commit', 'commit', '4.2')
call s:p.menu('Commit.Commit_all', 'commitAll', '4.3')
call s:p.menu('Commit.Amend_commit', 'amendCommit', '4.4')
call s:p.menu('Commit.Amend_commit_all', 'amendCommitAll', '4.5')
call s:p.menu('Branch.List', 'branchList', '5')
call s:p.menu('Remote.List', 'remoteList', '6.1')
call s:p.menu('Remote.Push', 'pushCurrent', '6.2')
call s:p.menu('Remote.Pull', 'pullCurrent', '6.3')
call s:p.menu('Tag.List', 'tagList', '7')
" }}}

call s:p.reg()
