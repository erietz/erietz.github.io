MD_POSTS := $(shell find _posts -type f -name '*.md')
HTML_POSTS := $(MD_POSTS:.md=.html)
HTML_POSTS :=  $(subst _posts/,posts/,$(HTML_POSTS))

MD_PROJECTS := $(shell find _projects -type f -name '*.md')
HTML_PROJECTS := $(MD_PROJECTS:.md=.html)
HTML_PROJECTS :=  $(subst _projects/,projects/,$(HTML_PROJECTS))

PD_FLAGS = -s --toc \
					 -c /assets/css/master.css \
					 -B ./assets/navigation.html \
					 --highlight-style breezedark

all: $(HTML_POSTS) $(HTML_PROJECTS) makefile
	sed -i.bak 's/\(href=".*\).md">/\1.html">/' ./posts/index.html
	sed -i.bak 's/\(href=".*\).md">/\1.html">/' ./projects/index.html
	rm ./posts/index.html.bak ./projects/index.html.bak

posts/%.html: _posts/%.md
	pandoc $(PD_FLAGS) $^ -o $@

projects/%.html: _projects/%.md
	pandoc $(PD_FLAGS) $^ -o $@

clean:
	rm $(HTML_POSTS) $(HTML_PROJECTS)

serve:
	@echo Serving at http://127.0.0.1:8000/
	python3 -m http.server
