
rov-dist.pdf: rov-dist.tex rov.bib
	latex rov-dist.tex
	bibtex rov-dist
	pdflatex rov-dist.tex

again:
	$(RM) rov-dist.pdf
	$(MAKE)

clean:
	$(RM) *.aux *.bbl *.blg *.log
