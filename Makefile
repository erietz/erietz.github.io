SRC_DIRS := src/_posts src/_projects src/_pages
SRC_MD_FILES := $(shell find $(SRC_DIRS) -type f -name '*.md')
SRC_HTML_FILES := $(shell find $(SRC_DIRS) -type f -name '*.html')
DEST_HTML_FILES := $(patsubst src/_%.md,%.html,$(SRC_MD_FILES)) $(patsubst src/_%.html,%.html,$(SRC_HTML_FILES))

PD_FLAGS := --standalone --toc --mathjax \
			-c /assets/css/master.css \
			--include-in-header ./assets/navigation.html \
			--include-before-body ./assets/main_start.html \
			--include-after-body ./assets/main_end.html \
			--include-after-body ./assets/footer.html # \
			# --highlight-style ./assets/pandoc/set3.theme
PD_FLAGS_WITH_COMMENTS := --include-after-body ./assets/comments.html


build: $(DEST_HTML_FILES) src/_posts/index.md Makefile assets/files/rietzCV.pdf


projects/%.html: src/_projects/%.md
	pandoc $(PD_FLAGS)  $(PD_FLAGS_WITH_COMMENTS) $^ -o $@

projects/%.html: src/_projects/%.html
	cp $^ $@

pages/%.html: src/_pages/%.md
	pandoc $(PD_FLAGS) $^ -o $@

pages/%.html: src/_pages/%.html
	cp $^ $@

posts/%.html: src/_posts/%.md
	pandoc $(PD_FLAGS)  $(PD_FLAGS_WITH_COMMENTS) $^ -o $@

# This needs built after the dest html files are generated because of the sed
# command.
SRC_POSTS := $(shell find src/_posts -type f -name '*.md' ! -name 'index.md')
src/_posts/index.md: $(SRC_POSTS)
	npm run generatePostsIndex
	pandoc $(PD_FLAGS)  src/_posts/index.md -o posts/index.html
	sed -i.bak 's/\(href=".*\).md">/\1.html">/' ./posts/index.html
	rm ./posts/index.html.bak

assets/files/rietzCV.pdf: pages/cv.html
	npm run printResume

clean:
	rm $(DEST_HTML_FILES)
	rm -f src/_posts/index.md
	rm assets/files/rietzCV.pdf

serve:
	npx http-server
