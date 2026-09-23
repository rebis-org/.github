-include .env
ifeq ($(LUATEX),)
$(error .env missing: copy .env.example to .env and fill in the paths)
endif

JOBS = CCLA ICLA
FONTS = lmroman10-regular.otf lmroman10-bold.otf lmmono10-regular.otf
USERFONTS ?= $(HOME)/Library/Fonts

fonts:
	@for f in $(FONTS); do \
	  cmp -s fonts/$$f "$(USERFONTS)/$$f" \
	    || { printf '%s\n' "font $$f differs from the vendored copy (run fonts/install.sh)"; exit 1; }; \
	done

digest: fonts SHA256SUMS VERSIONS

minim.fmt:
	$(LUATEX) --ini minim.ini

LOGO.pdf: $(SVG)
	$(RSVG) -f pdf -o $@ "$<"

CCLA.pdf ICLA.pdf: %.pdf: %.tex clauses.tex CLA.tex lib.lua LOGO.pdf minim.fmt
	printf '\\def\\versionhashA{%32s}\n\\def\\versionhashB{%32s}\n' '' '' | tr ' ' 'V' > $*.vh
	$(LUATEX) --fmt=minim --interaction=nonstopmode $*.tex
	$(LUA) normalize.lua $*.pdf
	HASH=$$(shasum -a 256 $*.pdf | cut -d' ' -f1); \
	A=$$(printf '%s\n' "$$HASH" | cut -c1-32); B=$$(printf '%s\n' "$$HASH" | cut -c33-64); \
	printf '\\def\\versionhashA{%s}\n\\def\\versionhashB{%s}\n' "$$A" "$$B" > $*.vh
	$(LUATEX) --fmt=minim --interaction=nonstopmode $*.tex
	$(LUA) normalize.lua $*.pdf
	QPDF="$(QPDF)" $(LUA) verify.lua $*

SHA256SUMS: CCLA.pdf ICLA.pdf
	shasum -a 256 CCLA.pdf ICLA.pdf > SHA256SUMS
	cat SHA256SUMS

archival: CCLA.pdf ICLA.pdf CCLA-A2b.pdf ICLA-A2b.pdf
	shasum -a 256 CCLA.pdf ICLA.pdf CCLA-A2b.pdf ICLA-A2b.pdf > SHA256SUMS
	cat SHA256SUMS

%-A2b.pdf: %.tex %.vh clauses.tex CLA.tex lib.lua LOGO.pdf minim.fmt
	$(LUATEX) --fmt=minim --interaction=nonstopmode --jobname=$*-A2b \
	  '\pdfalevel 2b\def\CLAARCHIVAL{}\input $*.tex'
	$(LUA) normalize.lua $@
	$(VERAPDF) -f 2b $@ | grep -q 'isCompliant="true"'

VERSIONS: CCLA.pdf ICLA.pdf
	for j in $(JOBS); do \
	  A=$$(sed -n 's/^\\def\\versionhashA{\([0-9a-f]*\)}/\1/p' $$j.vh); \
	  B=$$(sed -n 's/^\\def\\versionhashB{\([0-9a-f]*\)}/\1/p' $$j.vh); \
	  printf '%s %s\n' "$$j" "$$A$$B"; \
	done > VERSIONS
	cat VERSIONS
	for j in $(JOBS); do \
	  D=$$(pdftotext $$j.pdf - | tr -d ' \n' | grep -o '[0-9a-f]\{64\}' | head -n 1); \
	  V=$$(grep "^$$j " VERSIONS | cut -d' ' -f2); \
	  [ "$$D" = "$$V" ] || { printf '%s\n' "display mismatch in $$j.pdf"; exit 1; }; \
	  printf '%s\n' "$$j display matches registry"; \
	done

pristine: VERSIONS
	rm -rf .pristine && mkdir .pristine
	cp CCLA.tex ICLA.tex clauses.tex CLA.tex lib.lua \
	  LOGO.pdf minim.fmt normalize.lua .pristine/
	cp -r fonts .pristine/
	for j in $(JOBS); do \
	  (cd .pristine && printf '\\def\\versionhashA{%32s}\n\\def\\versionhashB{%32s}\n' '' '' | tr ' ' 'V' > $$j.vh \
	    && $(LUATEX) --fmt=minim --interaction=nonstopmode $$j.tex > /dev/null \
	    && $(LUA) normalize.lua $$j.pdf \
	    && printf '%s %s\n' "$$j" "$$(shasum -a 256 $$j.pdf | cut -d' ' -f1)"); \
	done > .pristine/SUMS
	diff VERSIONS .pristine/SUMS && printf '%s\n' 'PRISTINE MATCH'
	rm -rf .pristine

reproduce: CCLA.pdf ICLA.pdf
	mkdir -p .repro && cp CCLA.pdf ICLA.pdf .repro/
	rm -f CCLA.pdf ICLA.pdf
	$(MAKE) CCLA.pdf ICLA.pdf
	cmp .repro/CCLA.pdf CCLA.pdf && cmp .repro/ICLA.pdf ICLA.pdf && printf '%s\n' REPRODUCIBLE
	rm -rf .repro

gate: digest archival pristine reproduce

# The committed artifacts must equal a fresh build from source.
# Text changes go through `make gate` instead.
check:
	@$(MAKE) --no-print-directory digest
	@status=0; \
	git diff --quiet -- CCLA.pdf ICLA.pdf SHA256SUMS VERSIONS || status=1; \
	if [ $$status -ne 0 ]; then \
	  printf '%s\n' 'committed artifacts are stale — run make gate and commit' >&2; \
	else \
	  printf '%s\n' 'REGENERATION MATCH'; \
	fi; \
	git checkout -- CCLA.pdf ICLA.pdf SHA256SUMS VERSIONS; \
	exit $$status

filed:
	$(LUA) filed.lua $(ARGS)

clean:
	rm -f CCLA.pdf CCLA.log CCLA.vh ICLA.pdf ICLA.log ICLA.vh \
	  CCLA-A2b.pdf CCLA-A2b.log ICLA-A2b.pdf ICLA-A2b.log \
	  SHA256SUMS VERSIONS *-qdf.tmp.pdf \
	  *-filed.pdf *-filed.log *-filed.stdout filed.tex
	rm -rf .pristine .repro

.PHONY: digest clean pristine reproduce archival gate filed fonts check
