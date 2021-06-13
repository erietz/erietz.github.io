MD_FILES := $(shell find src -type f -name '*.md')
MD_DIRS := $(shell find src -type d)
HTML_DIRS := $(subst src/,./,$(MD_DIRS))
HTML_DIRS := $(subst src,./,$(MD_DIRS))
HTML_FILES := $(MD_FILES:.md=.html)
HTML_FILES :=  $(subst src/,,$(HTML_FILES))

PD_FLAGS = -s --toc -c /css/master.css -B navigation.html
#--metadata title="$(notdir $@)" 

all: html_dirs $(HTML_FILES) makefile
	sed -i.bak 's/\(href=".*\).md">/\1.html">/' index.html
	rm index.html.bak

%.html: src/%.md
	pandoc $(PD_FLAGS) $^ -o $@

html_dirs: $(MD_DIRS)
	@mkdir -p $(HTML_DIRS)

clean:
	rm -rf $(HTML_DIRS) $(HTML_FILES)

serve:
	@echo Serving at http://127.0.0.1:8000/
	python3 -m http.server --directory ./html_version/src

#serve:
#	@echo Serving at http://127.0.0.1:8000/
#	python3 -m http.server
