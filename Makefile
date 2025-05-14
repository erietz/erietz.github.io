SRC_ROOT := src
SRC_DIRS := $(SRC_ROOT)/posts $(SRC_ROOT)/projects $(SRC_ROOT)/pages
SRC_MD_FILES := $(shell find $(SRC_DIRS) -type f -name '*.md')
SRC_HTML_FILES := $(shell find $(SRC_DIRS) -type f -name '*.html')

# Convert source paths to output paths
DEST_HTML_FILES := $(patsubst $(SRC_ROOT)/%,%,$(SRC_MD_FILES:.md=.html)) \
                   $(patsubst $(SRC_ROOT)/%,%,$(SRC_HTML_FILES))

PD_FLAGS := \
	--standalone \
	--toc \
	--mathjax \
	-c /assets/css/master.css \
	--include-in-header ./assets/navigation.html \
	--include-before-body ./assets/main_start.html \
	--include-after-body ./assets/main_end.html \
	--include-after-body ./assets/footer.html

PD_FLAGS_WITH_COMMENTS := --include-after-body ./assets/comments.html

build: $(DEST_HTML_FILES) posts/index.html assets/files/rietzCV.pdf

# Pattern rules for Markdown files
%.html: $(SRC_ROOT)/posts/%.md
	pandoc $(PD_FLAGS) $(PD_FLAGS_WITH_COMMENTS) $< -o $@

%.html: $(SRC_ROOT)/projects/%.md
	pandoc $(PD_FLAGS) $(PD_FLAGS_WITH_COMMENTS) $< -o $@

%.html: $(SRC_ROOT)/pages/%.md
	pandoc $(PD_FLAGS) $< -o $@

# Pattern rules for raw HTML files
%.html: $(SRC_ROOT)/posts/%.html
	cp $< $@

%.html: $(SRC_ROOT)/projects/%.html
	cp $< $@

%.html: $(SRC_ROOT)/pages/%.html
	cp $< $@

# Generate posts index
posts/index.html: $(SRC_ROOT)/posts/index.md
	pandoc $(PD_FLAGS) $< -o $@
	sed -i.bak 's/\(href=".*\).md">/\1.html">/' $@
	rm $@.bak

# Rebuild index.md if any post changes (excluding index.md itself)
$(SRC_ROOT)/posts/index.md: $(filter-out $(SRC_ROOT)/posts/index.md,$(SRC_MD_FILES))
	npm run generatePostsIndex

# Resume PDF generation
assets/files/rietzCV.pdf: pages/cv.html
	npm run printResume

clean:
	rm -f $(DEST_HTML_FILES)
	rm -f $(SRC_ROOT)/posts/index.md
	rm -f posts/index.html
	rm -f assets/files/rietzCV.pdf

serve:
	npx http-server
