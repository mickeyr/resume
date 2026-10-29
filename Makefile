TEX_SOURCES := $(wildcard *.tex)
PDFS := $(TEX_SOURCES:.tex=.pdf)

# Word output for ATS uploads. Only the single-column resume-ats.tex converts
# cleanly: pandoc reads structure, and the other candidates bury theirs in
# class-specific macros and unbreakable boxes.
DOCX := resume-ats.docx

# -halt-on-error so a broken document fails the build instead of being skipped;
# the old `for f in *.tex` loop returned only the last file's exit status, which
# let a broken resume.tex pass CI as long as a later file compiled.
XELATEX := xelatex -interaction=nonstopmode -halt-on-error

.PHONY: all clean
all: $(PDFS) $(DOCX)

%.pdf: %.tex
	$(XELATEX) $<

# Section and shared-content files are \import-ed / \input, so the top-level PDFs
# must rebuild when they change
SHARED := shared/content.tex

resume.pdf: $(wildcard resume/*.tex) awesome-cv.cls $(SHARED)
coverletter.pdf: awesome-cv.cls $(SHARED)
resume-twocol.pdf: altacv.cls $(SHARED)
resume-moderncv-banking.pdf: shared/moderncv-body.tex $(SHARED)
resume-moderncv-classic.pdf: shared/moderncv-body.tex $(SHARED)
resume-ats.pdf: $(SHARED)

resume-ats.docx: resume-ats.tex docx-cleanup.lua $(SHARED)
	pandoc --standalone --lua-filter=docx-cleanup.lua $< -o $@

clean:
	rm -f *.aux *.log *.out *.pdf *.docx
