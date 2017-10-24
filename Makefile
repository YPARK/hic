# Make Hi-C data more slim

# Hi-C matrices are provided at 40kb bin resolution in NxN format for
# each chromosome for either raw contact maps, or Hi-C matrices
# normalized with HiCNorm, or HiCNorm followed by quantile
# normalization using samples from the same published or unpublished
# source. Even if a dataset was not specifically used in this study, a
# contact matrix was generated for each sample, for each study. For
# example, all samples from Zuin et al, 2014 are quantile normalized
# together.
#
# Fit-Hi-C output is provided in a 7-column format, corresponding to
# position 1, position 2, observed count, expected count, O/E,
# p-value, and q-value. Only the upper-triangle matrix entries (where
# i<=j) are provided, and only pairwise contacts within 2Mb genomic
# distance are provided.
#

TIS := $(shell ls -1 FitHiC_primary_cohort/*_chr1.sparse.matrix.gz | xargs -I file basename file _chr1.sparse.matrix.gz | sed 's/FitHiC_output.//g')
CHR := $(shell seq 1 22)
PAIRS := $(foreach tis, $(TIS), $(foreach chr, $(CHR), fdr10/$(tis)/chr$(chr).pairs.gz))

all: $(PAIRS)

slim/%.pairs.gz:
	[ -d $(dir $@) ] || mkdir -p $(dir $@)
	cat FitHiC_primary_cohort/FitHiC_output.$(shell echo $* | sed 's/\//_/g').sparse.matrix.gz | gzip -d | tail -n+2 | awk -F'\t' '$$3 > 0 { w = 40000; print (($$1 - 1) * w) FS ($$1 * w) FS  (($$2 - 1) * w) FS ($$2 * w) FS $$3 FS $$4 FS $$5 FS $$6 FS $$7 }' | gzip > $@

fdr10/%.pairs.gz: slim/%.pairs.gz
	[ -d $(dir $@) ] || mkdir -p $(dir $@)
	cat $< | gzip -d | awk '$$NF < 0.1' | gzip > $@

