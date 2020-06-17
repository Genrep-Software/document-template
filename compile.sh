#!/bin/bash

# Compile README from Markdown to LaTeX
# Created by Jacob Strieb
# June 2020

set -e

# XXX: Adjust below if not running in Windows Subsystem for Linux with native
# Windows Pandoc and pdfLaTeX
PANDOC=pandoc.exe
PDFLATEX=pdflatex.exe

# Output TeX file
$PANDOC \
  --template=template.tex \
  README.md \
  --output README.tex

# Compile LaTeX to PDF -- do it twice for TOC update purposes
$PDFLATEX README.tex
$PDFLATEX README.tex
