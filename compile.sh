#!/bin/bash

# Compile to LaTeX based on a company-wide template
# Created by Jacob Strieb
# June 2020

set -e

# XXX: Adjust below if not running in Windows Subsystem for Linux with native
# Windows Pandoc and pdfLaTeX
PANDOC=pandoc.exe
PDFLATEX=pdflatex.exe

# Echo usage if the user asks for help
if echo "$1" \
  | grep --ignore-case --quiet "^\-h$\|^\-\-help$"; then
  echo "Usage: $0 <infile.md>"
  echo "   or  $0 <Google Docs URL> \"<title>\""
  echo "   or  $0 <infile.*> \"<title>\" \"<author>\" \"<date>\""
  exit
fi

# If the input is a Google docs/drive URL, handle and exit
if echo "$1" \
  | grep --ignore-case --quiet \
    "^https\?:\/\/[a-z]*\.google\.com\/document\/d\/"; then
  if [ -z "$2" ]; then
    echo "Usage: $0 <infile.md>"
    echo "   or  $0 <Google Docs URL> \"<title>\""
    echo "   or  $0 <infile.*> \"<title>\" \"<author>\" \"<date>\""
    exit
  fi

  EXPORT_FORMAT="docx"

  # Generate an export URL
  echo "Generating export URL..."
  EXPORT_URL="$(echo $1 | grep -o --ignore-case \
    '^https\?:\/\/[a-z]*\.google\.com\/document\/d\/[a-z0-9\_-]*\/')""export?format=$EXPORT_FORMAT"
  echo "Exporting from $EXPORT_URL..."

  OUTFILE="out.tex"
  TEMPFILE="out-temp.tex"
  INFILE="in.$EXPORT_FORMAT"

  # Download the document
  curl --output "$INFILE" --location "$EXPORT_URL"

  # Convert to LaTeX
  $PANDOC \
    --extract-media "." \
    --template "template.tex" \
    --metadata title:"$2" \
    --metadata author:"Genrep Software, LLC." \
    --metadata date:"$(date +'%A, %B %d, %Y')" \
    "$INFILE" \
    --output "$TEMPFILE"

  # FIXME: this needs to be improved
  # Strip unnecessary quote environments
  cat "$TEMPFILE" \
    | sed "s/\\\\\(begin\|end\){quote}//g" > "$OUTFILE"

  # Compile LaTeX to PDF -- do it twice for TOC update purposes
  $PDFLATEX "$OUTFILE"
  $PDFLATEX "$OUTFILE"

  exit
fi

# Set the input and output file based on command-line arguments
INFILE="README.md"
if [ -n "$1" ]; then
  INFILE="$1"
else
  echo "Please specify an input file to convert!"
  echo
  echo "Usage: $0 <infile.md>"
  echo "   or  $0 <Google Docs URL> \"<title>\""
  echo "   or  $0 <infile.*> \"<title>\" \"<author>\" \"<date>\""
  echo
  echo "Defaulting to \"README.md\"..."
fi
# Strip everything from the last period to the end of the string (inclusive)
OUTFILE="$(echo $INFILE | sed 's/\(.*\)\.[^\.]*$/\1/')"".tex"

# Get additional arguments for metadata if not Markdown based on extracting the
# file extension
if echo $INFILE \
  | sed 's/.*\.\([^\.]*\)$/\1/' \
  | grep --ignore-case --quiet md; then
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
    echo
    echo "Usage: $0 <infile.md>"
    echo "   or  $0 <Google Docs URL> \"<title>\""
    echo "   or  $0 <infile.*> \"<title>\" \"<author>\" \"<date>\""
    exit
  fi
fi

# Compile LaTeX to PDF -- do it twice for TOC update purposes
$PDFLATEX "$OUTFILE"
$PDFLATEX "$OUTFILE"
