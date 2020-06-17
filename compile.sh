#!/bin/bash

# Compile README from Markdown to LaTeX
# Created by Jacob Strieb
# June 2020

set -e

# XXX: Adjust below if not running in Windows Subsystem for Linux with native
# Windows Pandoc and pdfLaTeX
PANDOC=pandoc.exe
PDFLATEX=pdflatex.exe

# Set the input and output file based on command-line arguments
INFILE="README.md"
if [ -n "$1" ]; then
  INFILE="$1"
else
  echo "Please specify an input file to convert!"
  echo "Usage: $0 <infile>"
  echo "Defaulting to \"README.md\"..."
fi
# Strip everything from the last period to the end of the string (inclusive)
OUTFILE="$(echo $INFILE | sed 's/\(.*\)\.[^\.]*$/\1/')"".tex"

# Output TeX file
$PANDOC \
  --template=template.tex \
  "$INFILE" \
  --output "$OUTFILE"

# Compile LaTeX to PDF -- do it twice for TOC update purposes
$PDFLATEX "$OUTFILE"
$PDFLATEX "$OUTFILE"
