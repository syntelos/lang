
mst-intro.pdf: mst-intro.tex
	latex mst-intro.tex
#	bibtex mst-intro
	pdflatex mst-intro.tex

again:
	$(RM) mst-intro.pdf
	$(MAKE)

clean:
	$(RM) *.aux *.bbl *.blg *.dvi *.log
