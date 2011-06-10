
.PHONY: clean
SOURCES = walkthrough.tex atex.tex 



pdf: $(SOURCES) clean
#	pdflatex -interaction=batchmode cvmfstech > /dev/null
	pdflatex -interaction=batchmode walkthrough	
	bibtex walkthrough 
	makeindex walkthrough.idx
	pdflatex -interaction=batchmode walkthrough > /dev/null
	pdflatex -interaction=batchmode walkthrough | grep -i 'overful|underful' || true
	thumbpdf walkthrough
	pdflatex -interaction=batchmode walkthrough > /dev/null
	pdfopt walkthrough.pdf walkthrough.pdf.opt
	rm -f walkthrough.pdf
	mv walkthrough.pdf.opt walkthrough.pdf

clean: 
	rm -f walkthrough.idx walkthrough.log walkthrough.toc cvmfs-blocks.tex 
	rm -f walkthrough.ilg walkthrough.ind walkthrough.tpt q.log texput.log cernlogo.log walkthrough.out
	rm -f walkthrough.bbl walkthrough.blg walkthrough.lol
	rm -f content/protocol.bbl content/protocol.log content/protocol.blg
	rm -f *.out
	find . -name "*.aux" -exec rm {} \;

