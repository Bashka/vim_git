set syntax=git-base

syntax match gitLogCommit /^commit \x\{40}/
syntax match gitLogCommit /^\* \zs\x\{7}\ze/
syntax match gitLogAuthor /^Author: \zs\w\+\ze/
syntax match gitLogAuthor /by \zs\w\+\ze\]/

highlight link gitLogCommit Statement
highlight link gitLogAuthor Comment
