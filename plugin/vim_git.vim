" Date Create: 2015-01-09 16:02:43
" Last Change: 2015-02-03 10:47:21
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Plugin = vim_lib#sys#Plugin#

let s:p = s:Plugin.new('vim_git', '1')

let s:p.bin = 'git'

call s:p.reg()
