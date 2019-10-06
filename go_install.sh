#!/bin/sh

# Official CLI tools
go get golang.org/x/tools/cmd/...

# REPL
go get -u github.com/motemen/gore/cmd/gore
go get -u github.com/mdempsky/gocode   # for code completion
go get -u github.com/k0kubun/pp        # or github.com/davecgh/go-spew/spew
