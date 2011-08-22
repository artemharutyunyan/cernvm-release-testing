
.PHONY: clean
SOURCES = walkthrough.tex atex.tex 
DEVSOURCES = walkthrough-dev.tex atex.tex 


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

dev-pdf: $(DEVSOURCES) clean
#	pdflatex -interaction=batchmode cvmfstech > /dev/null
	pdflatex -interaction=batchmode walkthrough-dev	
	bibtex walkthrough-dev 
	makeindex walkthrough-dev.idx
	pdflatex -interaction=batchmode walkthrough-dev > /dev/null
	pdflatex -interaction=batchmode walkthrough-dev | grep -i 'overful|underful' || true
	thumbpdf walkthrough-dev
	pdflatex -interaction=batchmode walkthrough-dev > /dev/null
	pdfopt walkthrough-dev.pdf walkthrough-dev.pdf.opt
	rm -f walkthrough-dev.pdf
	mv walkthrough-dev.pdf.opt walkthrough-dev.pdf

clean: 
	rm -f walkthrough*.idx walkthrough*.log walkthrough*.toc cvmfs-blocks*.tex 
	rm -f walkthrough*.ilg walkthrough*.ind walkthrough*.tpt q*.log texput*.log cernlogo*.log walkthrough*.out
	rm -f walkthrough*.bbl walkthrough*.blg walkthrough*.lol
	rm -f content/protocol*.bbl content/protocol*.log content/protocol*.blg
	rm -f *.out
	find . -name "*.aux" -exec rm {} \;

