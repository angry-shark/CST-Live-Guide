#!/bin/bash

build_count() {
    bc -q <<< $(cat build.txt)+1 > build.txt
}

makepdf() {
    mkdir build$1
    pdflatex --shell-escape -synctex=1 -interaction=nonstopmode -output-directory=build${1%/} ."$1"/"$2".tex
}

makemd() {
    mkdir build$1
    pandoc -t latex -o build${1%/}/"$2".pdf ."$1"/"$2".md
}

makepreamble() {
    mkdir build
    echo "\documentclass[12pt, a4paper]{book}"  >  build/book.tex
    echo                                        >> build/book.tex
    echo "\usepackage{pdfpages}"                >> build/book.tex
    echo                                        >> build/book.tex
    echo "\begin{document}"                     >> build/book.tex
    echo "\pagenumbering{gobble}"               >> build/book.tex
}

makefinal() {
    echo "\end{document}"                       >> build/book.tex
    makepdf /build book
    retval=$?
    mkdir output
    cp build/build/book.pdf output/book.pdf
    return $retval
}

includepdf() {
    # TODO: make TableOfContents
    echo "\includepdf[pagecommand={\thispagestyle{plain}}]{build/$1/$2.pdf}"         >> build/book.tex
    makepdf /"${1%/}" "$2"
}

includemd() {
    # TODO: make TableOfContents
    echo "\includepdf[pagecommand={\thispagestyle{plain}}]{build/$1/$2.pdf}"         >> build/book.tex
    makemd /"${1%/}" "$2"
}

build_count

# Preamble
rm -r build
rm -r output
makepreamble

# Write book
# for example: 
# includepdf 1-NumberBasics b
includepdf / cover
echo "\tableofcontents"                         >> build/book.tex
echo "\newpage"                                 >> build/book.tex
echo "\pagenumbering{arabic}"                   >> build/book.tex

# End
makefinal
xdg-open output/book.pdf
