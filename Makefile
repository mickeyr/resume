TEX_SOURCES := $(wildcard *.tex)
PDFS := $(TEX_SOURCES:.tex=.pdf)

# -halt-on-error so a broken document fails the build instead of being skipped;
# the old `for f in *.tex` loop returned only the last file's exit status, which
# let a broken resume.tex pass CI as long as a later file compiled.
XELATEX := xelatex -interaction=nonstopmode -halt-on-error

.PHONY: all clean
all: $(PDFS)

%.pdf: %.tex
	$(XELATEX) $<

# Section and shared-content files are \import-ed / \input, so the top-level PDFs
# must rebuild when they change
SHARED := shared/content.tex

resume.pdf: $(wildcard resume/*.tex) awesome-cv.cls
coverletter.pdf: awesome-cv.cls
resume-twocol.pdf: altacv.cls $(SHARED)
resume-moderncv-banking.pdf: shared/moderncv-body.tex $(SHARED)
resume-moderncv-classic.pdf: shared/moderncv-body.tex $(SHARED)

clean:
	rm -f *.aux *.log *.out *.pdf
