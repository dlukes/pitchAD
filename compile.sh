#!/usr/bin/env zsh

pandoc -sS teze.md -o teze.pdf --latex-engine=xelatex -Vlang=cs -Vpapersize=A4
