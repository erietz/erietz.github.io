MD_FILES := $(shell find src -type f -name '*.md')
MD_DIRS := $(shell find src -type d)
HTML_DIRS := $(addprefix html_version/,$(MD_DIRS))
HTML_FILES := $(MD_FILES:.md=.html)
HTML_FILES := $(addprefix html_version/,$(HTML_FILES))

PD_FLAGS = -s --toc -c /css/master.css -B navigation.html
#--metadata title="$(notdir $@)" 

all: html_dirs $(HTML_FILES) makefile
	sed -i.bak 's/\(href=".*\).md">/\1.html">/' html_version/src/index.html
	rm html_version/src/index.html.bak
	cp -r ./css ./html_version/src

html_version/%.html: %.md
	pandoc $(PD_FLAGS) $^ -o $@

html_dirs: $(MD_DIRS)
	@mkdir -p $(HTML_DIRS)

clean:
	rm -rf ./html_version
	mkdir -p html_version/src
	cp -r ./css html_version/src/
	cp -r ./src/media html_version/src/media

serve:
	@echo Serving at http://127.0.0.1:8000/
	python3 -m http.server --directory ./html_version/src

#serve:
#	@echo Serving at http://127.0.0.1:8000/
#	python3 -m http.server
