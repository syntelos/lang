
rot-cont.pdf: rot-cont.tex rot.bib
	latex rot-cont.tex
	bibtex rot-cont
	pdflatex rot-cont.tex

again:
	$(RM) rot-cont.pdf
	$(MAKE)

clean:
	$(RM) *.aux *.bbl *.blg *.log
