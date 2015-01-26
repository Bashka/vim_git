" Date Create: 2015-01-09 13:19:18
" Last Change: 2015-01-26 10:40:31
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Buffer = vim_lib#sys#Buffer#
let s:BufferStack = vim_lib#view#BufferStack#

function! vim_git#run(command) " {{{
	" workardound for MacVim, on which shell does not inherit environment variables
  let l:response = system(((has('mac') && &shell =~ 'sh$')? 'EDITOR="" ' : '') . g:git#bin . ' ' . a:command)
  if v:shell_error
    echohl Error | echo l:response | echohl None
    return ''
  else
    return l:response
  endif
endfunction " }}}

function! vim_git#exe(command) " {{{
	" workardound for MacVim, on which shell does not inherit environment variables
  execute '!' ((has('mac') && &shell =~ 'sh$')? 'EDITOR="" ' : '') . g:git#bin . ' ' . a:command
endfunction " }}}

function! vim_git#status() " {{{
  let l:buf = s:Buffer.new()
  call l:buf.temp()
  call l:buf.option('filetype', 'git-status')
  let l:buf.render = "vim_git#run('status')"
  call l:buf.listen('n', 'q', 'delete')
  call l:buf.listen('n', 'a', 'addFile')
  call l:buf.listen('n', 'd', 'resetFile')
  call l:buf.listen('n', 'r', 'checkoutFile')
  call l:buf.listen('n', 'R', 'checkoutAllFile')
  call l:buf.gactive('t')

  function! l:buf.addFile() " {{{
    call vim_git#run('add ' . expand('<cfile>'))
    call self.active()
  endfunction " }}}
  function! l:buf.resetFile() " {{{
    call vim_git#run('reset HEAD ' . expand('<cfile>'))
    call self.active()
  endfunction " }}}
  function! l:buf.checkoutFile() " {{{
    call vim_git#run('checkout -- ' . expand('<cfile>'))
    call self.active()
  endfunction " }}}
  function! l:buf.checkoutAllFile() " {{{
    call vim_git#run('checkout .')
    call self.active()
  endfunction " }}}
endfunction " }}}

function! vim_git#log() " {{{
  let l:buf = s:Buffer.new()
  call l:buf.temp()
  call l:buf.option('filetype', 'git-log')
  let l:buf.render = "vim_git#run('log')"
  let l:buf.currentFile = expand('%')
  let l:buf.currentFileType = &l:filetype
  call l:buf.listen('n', '<Enter>', 'checkoutCommit')
  call l:buf.listen('n', 'd', 'diffFile')
  call l:buf.listen('n', 'D', 'vimdiffFile')
  call l:buf.listen('n', 'f', 'diffList')

  let l:bufStack = s:BufferStack.new()
  call l:bufStack.push(l:buf)
  call l:bufStack.gactive('t')

  function! l:buf.checkoutCommit() " {{{
    call vim_git#run('checkout ' . expand('<cword>'))
    call self.active()
  endfunction " }}}
  function! l:buf.diffFile() " {{{
    let l:buf = s:Buffer.new()
    call l:buf.temp()
    call l:buf.option('filetype', 'git-diff')
    let l:buf.commit = expand('<cword>')
    let l:buf.currentFile = self.currentFile
    let l:buf.render = "vim_git#run('diff ' . self.commit . ' -- ' . self.currentFile)"
    call self.stack.push(l:buf)
    call self.stack.active()
  endfunction " }}}
  function! l:buf.vimdiffFile() " {{{
    let git_output = vim_git#run('cat-file -p ' . expand('<cword>') . ':' . self.currentFile)
    " bufA - diff file
    let l:bufA = s:Buffer.new()
    call l:bufA.temp()
    call l:bufA.option('filetype', self.currentFileType)
    call self.stack.push(l:bufA)
    call l:bufA.listen('n', 'q', 'quit')
    function! l:bufA.quit() " {{{
      call self.bufB.delete()
      echom 1
      call self.stack.delete()
    endfunction " }}}
    call self.stack.active()
    silent put=git_output
    0d
    diffthis

    " bufB - current file
    let l:bufB = s:Buffer.new()
    call l:bufB.temp()
    call l:bufB.option('filetype', self.currentFileType)
    let l:bufB.bufA = l:bufA
    call l:bufB.listen('n', 'q', 'quit')
    function! l:bufB.quit() " {{{
      call self.bufA.quit()
    endfunction " }}}
    call l:bufB.vactive('l')
    exe 'r ' . self.currentFile
    0d
    "diffthis

    let l:bufA.bufB = l:bufB
  endfunction " }}}
  function! l:buf.diffList() " {{{
    echo vim_git#run('diff --name-only ' . expand('<cword>'))
  endfunction " }}}
endfunction " }}}

function! vim_git#branch() " {{{
  let l:buf = s:Buffer.new()
  call l:buf.temp()
  call l:buf.option('filetype', 'git-branch')
  let l:buf.currentFile = expand('%')
  let l:buf.currentFileType = &l:filetype
  let l:buf.render = "vim_git#run('branch -a')"
  call l:buf.listen('n', '<Enter>', 'checkoutBranch')
  call l:buf.listen('n', 'm', 'merge')
  call l:buf.listen('n', 's', 'status')
  call l:buf.listen('n', 'd', 'diff')
  call l:buf.listen('n', 'D', 'vimdiff')
  call l:buf.listen('n', 'f', 'fetch')

  let l:bufStack = s:BufferStack.new()
  call l:bufStack.push(l:buf)
  call l:bufStack.gactive('t')

  function! l:buf.checkoutBranch() " {{{
    let l:pos = getpos('.')
    call vim_git#run('checkout ' . expand('<cWORD>'))
    call self.active()
    call setpos('.', l:pos)
  endfunction " }}}
  function! l:buf.merge() " {{{
    call vim_git#run('merge ' . expand('<cWORD>'))
  endfunction " }}}
  function! l:buf.status() " {{{
    let l:buf = s:Buffer.new()
    call l:buf.temp()
    call l:buf.option('filetype', 'git-diff')
    let l:buf.branch = expand('<cWORD>')
    let l:buf.currentFile = self.currentFile
    let l:buf.currentFileType = self.currentFileType
    let l:buf.render = "git#run('diff ' . self.branch . ' --name-status')"
    call l:buf.listen('n', '<Enter>', 'showFile')
    call l:buf.listen('n', 'd', 'diff')
    call l:buf.listen('n', 'D', 'vimdiff')
    call self.stack.push(l:buf)
    call self.stack.active()

    function! l:buf.showFile() " {{{
      let l:buf = s:Buffer.new()
      call l:buf.temp()
      call l:buf.option('filetype', 'git-diff')
      let l:buf.branch = self.branch
      let l:buf.file = expand('<cfile>')
      let l:buf.render = "git#run('show ' . self.branch . ':' . self.file)"
      call self.stack.push(l:buf)
      call self.stack.active()
    endfunction " }}}
    function! l:buf.diff() " {{{
      let l:buf = s:Buffer.new()
      call l:buf.temp()
      call l:buf.option('filetype', 'git-diff')
      let l:buf.branch = self.branch
      let l:buf.file = expand('<cfile>')
      let l:buf.render = "git#run('diff ' . self.branch . ' -- ' . self.file)"
      call self.stack.push(l:buf)
      call self.stack.active()
    endfunction " }}}
    function! l:buf.vimdiff() " {{{
      let l:file = expand('<cfile>')
      let git_output = vim_git#run('show ' . self.branch . ':' . l:file)
      " bufA - diff file
      let l:bufA = s:Buffer.new()
      call l:bufA.temp()
      call l:bufA.option('filetype', self.currentFileType)
      call self.stack.push(l:bufA)
      call l:bufA.listen('n', 'q', 'quit')
      function! l:bufA.quit() " {{{
        call self.bufB.delete()
        call self.stack.delete()
      endfunction " }}}
      call self.stack.active()
      silent put=git_output
      0d
      diffthis

      " bufB - current file
      let l:bufB = s:Buffer.new()
      call l:bufB.temp()
      call l:bufB.option('filetype', self.currentFileType)
      let l:bufB.bufA = l:bufA
      call l:bufB.listen('n', 'q', 'quit')
      function! l:bufB.quit() " {{{
        call self.bufA.quit()
      endfunction " }}}
      call l:bufB.vactive('l')
      exe 'r ' . l:file
      0d
      diffthis

      let l:bufA.bufB = bufB
    endfunction " }}}
  endfunction " }}}
  function! l:buf.diff() " {{{
    let l:buf = s:Buffer.new()
    call l:buf.temp()
    call l:buf.option('filetype', 'git-diff')
    let l:buf.commit = expand('<cWORD>')
    let l:buf.currentFile = self.currentFile
    let l:buf.render = "git#run('diff ' . self.commit . ' -- ' . self.currentFile)"
    call self.stack.push(l:buf)
    call self.stack.active()
  endfunction " }}}
  function! l:buf.vimdiff() " {{{
    let git_output = vim_git#run('cat-file -p ' . expand('<cWORD>') . ':' . self.currentFile)
    " bufA - diff file
    let l:bufA = s:Buffer.new()
    call l:bufA.temp()
    call l:bufA.option('filetype', self.currentFileType)
    call self.stack.push(l:bufA)
    call l:bufA.listen('n', 'q', 'quit')
    function! l:bufA.quit() " {{{
      call self.bufB.delete()
      call self.stack.delete()
    endfunction " }}}
    call self.stack.active()
    silent put=git_output
    0d
    diffthis

    " bufB - current file
    let l:bufB = s:Buffer.new()
    call l:bufB.temp()
    call l:bufB.option('filetype', self.currentFileType)
    let l:bufB.bufA = l:bufA
    call l:bufB.listen('n', 'q', 'quit')
    function! l:bufB.quit() " {{{
      call self.bufA.quit()
    endfunction " }}}
    call l:bufB.vactive('l')
    exe 'r ' . self.currentFile
    0d
    diffthis

    let l:bufA.bufB = bufB
  endfunction " }}}
  function! l:buf.fetch() " {{{
    let l:remoteBranch = strpart(expand('<cWORD>'), stridx(expand('<cWORD>'), '/') + 1)
    let l:p = stridx(l:remoteBranch, '/')
    let l:repository = strpart(l:remoteBranch, 0, l:p)
    let l:branch = strpart(l:remoteBranch, l:p + 1)
    call vim_git#run('fetch ' . l:repository . ' ' . l:branch . ':' . l:branch)
  endfunction " }}}
endfunction " }}}

function! vim_git#tagList() " {{{
  let l:buf = s:Buffer.new()
  call l:buf.temp()
  call l:buf.option('filetype', 'git-tag')
  let l:buf.render = "vim_git#run('tag')"
  call l:buf.listen('n', '<Enter>', 'checkoutTag')
  call l:buf.listen('n', 's', 'show')
  call l:buf.listen('n', 'q', 'delete')
  call l:buf.gactive('t')

  function! l:buf.checkoutTag() " {{{
    call vim_git#run('checkout ' . expand('<cWORD>'))
    call self.delete()
  endfunction " }}}
  function! l:buf.show() " {{{
    echo vim_git#run('show -s --format=%an::%H%n%s ' . expand('<cWORD>'))
  endfunction " }}}
endfunction " }}}
