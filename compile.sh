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
  echo "Usage: $0 <infile.md>"
  echo "   or  $0 <infile.*> \"<title>\" \"<author>\" \"<date>\""
  echo "Defaulting to \"README.md\"..."
fi
# Strip everything from the last period to the end of the string (inclusive)
OUTFILE="$(echo $INFILE | sed 's/\(.*\)\.[^\.]*$/\1/')"".tex"

# Get additional arguments for metadata if not Markdown based on extracting the
# file extension
if echo $INFILE | sed 's/.*\.\([^\.]*\)$/\1/' | grep -i md; then
  # Assume there is metadata in the file if it is Markdown
  # Output TeX file
  $PANDOC \
    --template=template.tex \
    "$INFILE" \
    --output "$OUTFILE"
else
  # If not Markdown, look for title, author, and date arguments (respectively)
  if [ "$#" -eq 4 ]; then
    # Output TeX file
    $PANDOC \
      --template=template.tex \
      --metadata title:"$2" \
      --metadata author:"$3" \
      --metadata date:"$4" \
      "$INFILE" \
      --output "$OUTFILE"
  else
    echo "Please specify the title, author, and date in quotes!"
    echo "Usage: $0 <infile.md>"
    echo "   or  $0 <infile.*> \"<title>\" \"<author>\" \"<date>\""
    exit
  fi
fi

# Compile LaTeX to PDF -- do it twice for TOC update purposes
$PDFLATEX "$OUTFILE"
$PDFLATEX "$OUTFILE"
