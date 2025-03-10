SRC_DIRS := _posts _projects _pages
MD_FILES := $(shell find $(SRC_DIRS) -type f -name '*.md')
HTML_FILES :=  $(patsubst _%.md,%.html,$(MD_FILES))

PD_FLAGS := --standalone --toc --mathjax \
			-c /assets/css/master.css \
			--include-in-header ./assets/navigation.html \
			--include-before-body ./assets/main_start.html \
			--include-after-body ./assets/main_end.html \
			--include-after-body ./assets/footer.html # \
			# --highlight-style ./assets/pandoc/set3.theme

PD_FLAGS_WITH_COMMENTS := --include-after-body ./assets/comments.html

build: $(HTML_FILES) index Makefile assets/files/rietzCV.pdf

posts/%.html: _posts/%.md
	pandoc $(PD_FLAGS)  $(PD_FLAGS_WITH_COMMENTS) $^ -o $@

projects/%.html: _projects/%.md
	pandoc $(PD_FLAGS)  $(PD_FLAGS_WITH_COMMENTS) $^ -o $@

pages/%.html: _pages/%.md
	pandoc $(PD_FLAGS) $^ -o $@

index:
	npm run generatePostsIndex
	pandoc $(PD_FLAGS)  _posts/index.md -o posts/index.html
	sed -i.bak 's/\(href=".*\).md">/\1.html">/' ./posts/index.html
	rm ./posts/index.html.bak

assets/files/rietzCV.pdf: pages/cv.html
	npm run printResume

clean:
	rm $(HTML_FILES)

serve:
	npx http-server
