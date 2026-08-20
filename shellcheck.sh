#!/usr/bin/env sh

shellcheck \
	shellcheck.sh \
	.chezmoiscripts/*.sh \
	dot_claude/hooks/*.sh \
	tests/*.sh
