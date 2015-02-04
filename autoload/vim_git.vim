" Date Create: 2015-01-09 13:19:18
" Last Change: 2015-02-04 16:35:10
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Buffer = vim_lib#sys#Buffer#
let s:BufferStack = vim_lib#view#BufferStack#
let s:Sys = vim_lib#sys#System#.new()

function! vim_git#run(command) " {{{
  return s:Sys.run(g:vim_git#.bin . ' ' . a:command)
endfunction " }}}

function! vim_git#exe(command) " {{{
  call s:Sys.exe(g:vim_git#.bin . ' ' . a:command)
endfunction " }}}

function! vim_git#status(event) " {{{
  let l:buf = s:Buffer.new('Git-status')
  call l:buf.temp()
  call l:buf.option('filetype', 'git-status')
  let l:buf.render = "vim_git#run('status')"
  call l:buf.map('n', 'q', 'quit')
  call l:buf.map('n', 'a', 'addFile')
  call l:buf.map('n', 'd', 'resetFile')
  call l:buf.map('n', 'r', 'checkoutFile')
  call l:buf.map('n', 'R', 'checkoutAllFile')
  call l:buf.gactive('t')

  function! l:buf.quit(...) " {{{
    call self.delete()
  endfunction " }}}
  function! l:buf.addFile(...) " {{{
    call vim_git#run('add ' . expand('<cfile>'))
    call self.active()
  endfunction " }}}
  function! l:buf.resetFile(...) " {{{
    call vim_git#run('reset HEAD ' . expand('<cfile>'))
    call self.active()
  endfunction " }}}
  function! l:buf.checkoutFile(...) " {{{
    call vim_git#run('checkout -- ' . expand('<cfile>'))
    call self.active()
  endfunction " }}}
  function! l:buf.checkoutAllFile(...) " {{{
    call vim_git#run('checkout .')
    call self.active()
  endfunction " }}}
endfunction " }}}

function! vim_git#log(event) " {{{
  let l:buf = s:Buffer.new('Git-log')
  call l:buf.temp()
  call l:buf.option('filetype', 'git-log')
  let l:buf.render = "vim_git#run('log')"
  let l:buf.currentFile = expand('%')
  let l:buf.currentFileType = &l:filetype
  call l:buf.map('n', '<Enter>', 'checkoutCommit')
  call l:buf.map('n', 'd', 'diffFile')
  call l:buf.map('n', 'D', 'vimdiffFile')
  call l:buf.map('n', 'f', 'diffList')

  let l:bufStack = s:BufferStack.new()
  call l:bufStack.push(l:buf)
  call l:bufStack.gactive('t')

  function! l:buf.checkoutCommit(...) " {{{
    call vim_git#run('checkout ' . expand('<cword>'))
    call self.active()
  endfunction " }}}
  function! l:buf.diffFile(...) " {{{
    let l:buf = s:Buffer.new()
    call l:buf.temp()
    call l:buf.option('filetype', 'git-diff')
    let l:buf.commit = expand('<cword>')
    let l:buf.currentFile = self.currentFile
    let l:buf.render = "vim_git#run('diff ' . self.commit . ' -- ' . self.currentFile)"
    call self.stack.push(l:buf)
    call self.stack.active()
  endfunction " }}}
  function! l:buf.vimdiffFile(...) " {{{
    let git_output = vim_git#run('cat-file -p ' . expand('<cword>') . ':' . self.currentFile)
    " bufA - diff file
    let l:bufA = s:Buffer.new()
    call l:bufA.temp()
    call l:bufA.option('filetype', self.currentFileType)
    call self.stack.push(l:bufA)
    call l:bufA.ignore('n', 'q')
    call l:bufA.map('n', 'q', 'quit')
    function! l:bufA.quit(...) " {{{
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
    call l:bufB.map('n', 'q', 'quit')
    function! l:bufB.quit(...) " {{{
      call self.bufA.quit()
    endfunction " }}}
    call l:bufB.vactive('l')
    exe 'r ' . self.currentFile
    0d
    diffthis

    let l:bufA.bufB = l:bufB
  endfunction " }}}
  function! l:buf.diffList() " {{{
    echo vim_git#run('diff --name-only ' . expand('<cword>'))
  endfunction " }}}
endfunction " }}}

function! vim_git#branch(event) " {{{
  let l:buf = s:Buffer.new('Git-branch')
  call l:buf.temp()
  call l:buf.option('filetype', 'git-branch')
  let l:buf.currentFile = expand('%')
  let l:buf.currentFileType = &l:filetype
  let l:buf.render = "vim_git#run('branch -a')"
  call l:buf.map('n', '<Enter>', 'checkoutBranch')
  call l:buf.map('n', 'm', 'merge')
  call l:buf.map('n', 's', 'status')
  call l:buf.map('n', 'd', 'diff')
  call l:buf.map('n', 'D', 'vimdiff')
  call l:buf.map('n', 'f', 'fetch')
  call l:buf.map('n', 'o', 'newBranch')
  call l:buf.map('n', 'i', 'newBranch')
  call l:buf.map('n', 'a', 'newBranch')
  call l:buf.map('n', 'dd', 'deleteBranch')

  let l:menu = s:Buffer.new('Git-branch-menu')
  call l:menu.temp()
  function! l:menu.render() " {{{
    return join(['--all - показать все ветки',
               \ '--verbose - показать подробную информацию о ветках',
               \ '--merged - показать слитые с текущей веткой',
               \ '--no-merged - показать не слитые с текущей веткой'], "\n")
  endfunction " }}}
  let l:buf.menu = l:menu
  let l:menu.buf = l:buf
  call l:menu.map('n', '<Enter>', 'modif')
  function! l:menu.modif(...) " {{{
    let self.buf.render = "vim_git#run('branch " . expand('<cWORD>') . "')"
    call self.buf.select()
    call self.buf.active()
    call self.select()
  endfunction " }}}
  call l:buf.map('n', 'v', 'toogleMenu')
  function! l:buf.toogleMenu(...) " {{{
    if bufloaded(self.menu.getNum()) == 0
      call self.menu.vactive('r', '30%')
    else
      call self.menu.unload()
    endif
  endfunction " }}}

  let l:bufStack = s:BufferStack.new()
  call l:bufStack.push(l:buf)
  call l:bufStack.gactive('t')

  function! l:buf.checkoutBranch(...) " {{{
    let l:pos = getpos('.')
    call vim_git#run('checkout ' . expand('<cWORD>'))
    call self.active()
    call setpos('.', l:pos)
  endfunction " }}}
  function! l:buf.merge(...) " {{{
    try
      call vim_git#run('merge ' . expand('<cWORD>'))
      call s:Sys.print('Merge complete.', 'MoreMsg')
    catch /ShellException:.*/
    endtry
  endfunction " }}}
  function! l:buf.status(...) " {{{
    let l:buf = s:Buffer.new()
    call l:buf.temp()
    call l:buf.option('filetype', 'git-diff')
    let l:buf.branch = expand('<cWORD>')
    let l:buf.currentFile = self.currentFile
    let l:buf.currentFileType = self.currentFileType
    let l:buf.render = "vim_git#run('diff ' . self.branch . ' --name-status')"
    call l:buf.map('n', '<Enter>', 'showFile')
    call l:buf.map('n', 'd', 'diff')
    call l:buf.map('n', 'D', 'vimdiff')
    call self.stack.push(l:buf)
    call self.stack.active()

    function! l:buf.showFile(...) " {{{
      let l:buf = s:Buffer.new()
      call l:buf.temp()
      call l:buf.option('filetype', 'git-diff')
      let l:buf.branch = self.branch
      let l:buf.file = expand('<cfile>')
      let l:buf.render = "vim_git#run('show ' . self.branch . ':' . self.file)"
      call self.stack.push(l:buf)
      call self.stack.active()
    endfunction " }}}
    function! l:buf.diff(...) " {{{
      let l:buf = s:Buffer.new()
      call l:buf.temp()
      call l:buf.option('filetype', 'git-diff')
      let l:buf.branch = self.branch
      let l:buf.file = expand('<cfile>')
      let l:buf.render = "vim_git#run('diff ' . self.branch . ' -- ' . self.file)"
      call self.stack.push(l:buf)
      call self.stack.active()
    endfunction " }}}
    function! l:buf.vimdiff(...) " {{{
      let l:file = expand('<cfile>')
      let git_output = vim_git#run('show ' . self.branch . ':' . l:file)
      " bufA - diff file
      let l:bufA = s:Buffer.new()
      call l:bufA.temp()
      call l:bufA.option('filetype', self.currentFileType)
      call self.stack.push(l:bufA)
      call l:bufA.ignore('n', 'q')
      call l:bufA.map('n', 'q', 'quit')
      function! l:bufA.quit(...) " {{{
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
      call l:bufB.map('n', 'q', 'quit')
      function! l:bufB.quit(...) " {{{
        call self.bufA.quit()
      endfunction " }}}
      call l:bufB.vactive('l')
      exe 'r ' . l:file
      0d
      diffthis

      let l:bufA.bufB = bufB
    endfunction " }}}
  endfunction " }}}
  function! l:buf.diff(...) " {{{
    let l:buf = s:Buffer.new()
    call l:buf.temp()
    call l:buf.option('filetype', 'git-diff')
    let l:buf.commit = expand('<cWORD>')
    let l:buf.currentFile = self.currentFile
    let l:buf.render = "vim_git#run('diff ' . self.commit . ' -- ' . self.currentFile)"
    call self.stack.push(l:buf)
    call self.stack.active()
  endfunction " }}}
  function! l:buf.vimdiff(...) " {{{
    let git_output = vim_git#run('cat-file -p ' . expand('<cWORD>') . ':' . self.currentFile)
    " bufA - diff file
    let l:bufA = s:Buffer.new()
    call l:bufA.temp()
    call l:bufA.option('filetype', self.currentFileType)
    call self.stack.push(l:bufA)
    call l:bufA.ignore('n', 'q')
    call l:bufA.map('n', 'q', 'quit')
    function! l:bufA.quit(...) " {{{
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
    call l:bufB.map('n', 'q', 'quit')
    function! l:bufB.quit(...) " {{{
      call self.bufA.quit()
    endfunction " }}}
    call l:bufB.vactive('l')
    exe 'r ' . self.currentFile
    0d
    diffthis

    let l:bufA.bufB = bufB
  endfunction " }}}
  function! l:buf.fetch(...) " {{{
    let l:remoteBranch = strpart(expand('<cWORD>'), stridx(expand('<cWORD>'), '/') + 1)
    let l:p = stridx(l:remoteBranch, '/')
    let l:repository = strpart(l:remoteBranch, 0, l:p)
    let l:branch = strpart(l:remoteBranch, l:p + 1)
    call vim_git#run('fetch ' . l:repository . ' ' . l:branch . ':' . l:branch)
  endfunction " }}}
  function! l:buf.newBranch(...) " {{{
    call inputsave()
    let l:branchName = input('Enter branch name: ')
    call inputrestore()
    if l:branchName != ''
      let l:pos = getpos('.')
      call vim_git#run('branch ' . l:branchName)
      call self.active()
      call setpos('.', l:pos)
    endif
  endfunction " }}}
  function! l:buf.deleteBranch(...) " {{{
    let l:pos = getpos('.')
    call vim_git#run('branch -D ' . expand('<cWORD>'))
    call self.active()
    call setpos('.', l:pos)
  endfunction " }}}
endfunction " }}}

function! vim_git#tagList(event) " {{{
  let l:buf = s:Buffer.new('Git-tag')
  call l:buf.temp()
  call l:buf.option('filetype', 'git-tag')
  let l:buf.render = "vim_git#run('tag')"
  call l:buf.map('n', '<Enter>', 'checkoutTag')
  call l:buf.map('n', 's', 'show')
  call l:buf.map('n', 'q', 'quit')
  call l:buf.gactive('t')

  function! l:buf.quit(...) " {{{
    call self.delete()
  endfunction " }}}
  function! l:buf.checkoutTag(...) " {{{
    call vim_git#run('checkout ' . expand('<cWORD>'))
    call self.delete()
  endfunction " }}}
  function! l:buf.show(...) " {{{
    echo vim_git#run('show -s --format=%an::%H%n%s ' . expand('<cWORD>'))
  endfunction " }}}
endfunction " }}}

function! vim_git#commit(event) " {{{
  let l:buf = s:Buffer.new()
  call l:buf.gactive('t')
  exe 'e ' . tempname()
  autocmd BufWritePost <buffer> call vim_git#run('commit -F ' . expand('%'))
endfunction " }}}

function! vim_git#commitAll(event) " {{{
  call vim_git#addAll(a:event)
  call vim_git#commit(a:event)
endfunction " }}}

function! vim_git#push(event) " {{{
  call vim_git#exe('push')
endfunction " }}}

function! vim_git#pull(event) " {{{
  call vim_git#run('pull')
endfunction " }}}

function! vim_git#addCurrent(event) " {{{
  call vim_git#run('add ' . expand('%'))
endfunction " }}}

function! vim_git#addAll(event) " {{{
  call vim_git#run('add .')
endfunction " }}}
