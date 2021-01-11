
rov-intro.pdf: rov-intro.tex rov.bib
	latex rov-intro.tex
	bibtex rov-intro
	pdflatex rov-intro.tex

again:
	$(RM) rov-intro.pdf
	$(MAKE)

clean:
	$(RM) *.aux *.bbl *.blg *.log
