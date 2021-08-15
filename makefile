SRC_DIRS := _posts _projects _pages
MD_FILES := $(shell find $(SRC_DIRS) -type f -name '*.md')
HTML_FILES :=  $(patsubst _%.md,%.html,$(MD_FILES))

PD_FLAGS = --standalone --toc --mathjax \
					 -c /assets/css/master.css \
					 --include-before-body ./assets/navigation.html \
					 --include-after-body ./assets/footer.html \
					 --highlight-style zenburn

all: $(HTML_FILES) index makefile

posts/%.html: _posts/%.md
	pandoc $(PD_FLAGS) $^ -o $@

projects/%.html: _projects/%.md
	pandoc $(PD_FLAGS) $^ -o $@

pages/%.html: _pages/%.md
	pandoc $(PD_FLAGS) $^ -o $@

index:
	python ./assets/python/generate_posts_index.py
	pandoc $(PD_FLAGS) _posts/index.md -o posts/index.html
	sed -i.bak 's/\(href=".*\).md">/\1.html">/' ./posts/index.html
	rm ./posts/index.html.bak

clean:
	rm $(HTML_FILES)

serve:
	echo Serving the site at http://127.0.0.1:8000/
	python3 -m http.server
