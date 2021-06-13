MD_FILES := $(shell find _posts -type f -name '*.md')
HTML_FILES := $(MD_FILES:.md=.html)
HTML_FILES :=  $(subst _posts/,posts/,$(HTML_FILES))

PD_FLAGS = -s --toc \
					 -c /assets/css/master.css \
					 -B ./assets/navigation.html \
					 --highlight-style breezedark

all: $(HTML_FILES) makefile
	sed -i.bak 's/\(href=".*\).md">/\1.html">/' ./posts/index.html
	rm ./posts/index.html.bak

posts/%.html: _posts/%.md
	pandoc $(PD_FLAGS) $^ -o $@

clean:
	rm $(HTML_FILES)

serve:
	@echo Serving at http://127.0.0.1:8000/
	python3 -m http.server
