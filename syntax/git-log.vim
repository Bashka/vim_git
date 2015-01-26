syntax match Comment /^".*/
syntax match gitLogCommit +^commit \x\{40}+

highlight link gitLogCommit Statement
