MD_POSTS := $(shell find _posts -type f -name '*.md')
HTML_POSTS := $(MD_POSTS:.md=.html)
HTML_POSTS :=  $(subst _posts/,posts/,$(HTML_POSTS))

MD_PROJECTS := $(shell find _projects -type f -name '*.md')
HTML_PROJECTS := $(MD_PROJECTS:.md=.html)
HTML_PROJECTS :=  $(subst _projects/,projects/,$(HTML_PROJECTS))

PD_FLAGS = --standalone --toc --mathjax \
					 -c /assets/css/master.css \
					 -c "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" \
					 --include-before-body ./assets/navigation.html \
					 --include-after-body ./assets/footer.html \
					 --highlight-style breezedark

all: $(HTML_POSTS) $(HTML_PROJECTS) index makefile

posts/%.html: _posts/%.md
	pandoc $(PD_FLAGS) $^ -o $@

projects/%.html: _projects/%.md
	pandoc $(PD_FLAGS) $^ -o $@

index:
	python ./assets/python/generate_posts_index.py
	pandoc $(PD_FLAGS) _posts/index.md -o posts/index.html
	sed -i.bak 's/\(href=".*\).md">/\1.html">/' ./posts/index.html
	rm ./posts/index.html.bak

clean:
	rm $(HTML_POSTS) $(HTML_PROJECTS)

serve:
	@echo Serving at http://127.0.0.1:8000/
	python3 -m http.server
