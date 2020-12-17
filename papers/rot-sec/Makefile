
rot-sec.pdf: rot-sec.tex rot.bib
	latex rot-sec.tex
	bibtex rot-sec
	pdflatex rot-sec.tex

again:
	$(RM) rot-sec.pdf
	$(MAKE)

clean:
	$(RM) *.aux *.bbl *.blg *.log
