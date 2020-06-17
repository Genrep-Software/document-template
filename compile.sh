#!/bin/bash

# Compile README from Markdown to LaTeX
# Created by Jacob Strieb
# June 2020

set -e

PANDOC=pandoc.exe

# Output TeX file
$PANDOC \
  --template=template.tex \
  README.md \
  -o README.tex

# Compile LaTeX to PDF -- do it twice for TOC update purposes
pdflatex.exe README.tex
pdflatex.exe README.tex
