# This makefile probably requires GNU make. Sorry.
KSY_COMPILER ?= kaitai-struct-compiler
KSY_MERGE=python3 ./ksy-merge.py
FILETYPES = $(basename $(notdir $(wildcard filetypes/*.ksy)))
TARGETS ?= $(addprefix $(OUTDIR)/, $(addsuffix .py, $(FILETYPES)))

OUTDIR=output

all: $(OUTDIR) $(TARGETS)

test: $(TARGETS)
	python3 ./m2dump.py

# We're just going to force it to rebuild everything every time, so we don't
# have to deal with the complexity of having a way to dynamically track
# included files as dependencies

$(OUTDIR):
	@mkdir -p $(OUTDIR)

.PRECIOUS: $(OUTDIR)/%.ksy
$(OUTDIR)/%.ksy: filetypes/%.ksy FORCE
	$(KSY_MERGE) $< >$@

$(OUTDIR)/%.py: $(OUTDIR)/%.ksy
	$(KSY_COMPILER) --outdir $(OUTDIR) --target python $<

$(OUTDIR)/%.svg: $(OUTDIR)/%.dot
	dot -Tsvg $< >$@

$(OUTDIR)/%.dot: $(OUTDIR)/%.ksy
	$(KSY_COMPILER)  --outdir $(OUTDIR) --target graphviz $<

clean: FORCE
	rm -f $(OUTDIR)/*.ksy $(TARGETS)

FORCE:
