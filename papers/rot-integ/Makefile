
rot-integ.pdf: rot-integ.tex rot.bib
	latex rot-integ.tex
	bibtex rot-integ
	pdflatex rot-integ.tex

again:
	$(RM) rot-integ.pdf
	$(MAKE)

clean:
	$(RM) *.aux *.bbl *.blg *.log
