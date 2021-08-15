#!/usr/bin/env python3

from pathlib import Path
import yaml

FILES = sorted(Path('./_posts/').glob('*.md'), reverse=True)
FILES = [f for f in FILES if 'index.md' not in f.name]
INDEX = Path('./_posts/index.md')

def parse_frontmatter(file):
    with open(file, 'r') as f:
        line = next(f)
        if line != '---\n':
            return
        frontmatter = ''
        line = next(f)
        while line != '---\n':
            frontmatter += line
            line = next(f)
        return yaml.safe_load(frontmatter)

with open(INDEX, 'w') as f:
    f.write('---\n')
    f.write('title: Posts\n')
    f.write('---\n')
    f.write('\n')

    f.write('<div style="width: 50%; margin: auto">')


    f.write('|     |       |      |      |\n')
    f.write('|:--- | :---- | :--- | :--- |\n')
    for file in FILES:
        frontmatter = parse_frontmatter(file)
        title = frontmatter.get('title')
        categories = frontmatter.get('categories')
        if categories is None:
            categories = ''
        else:
            categories = ', '.join(categories)

        date = file.name[:10]
        f.write(f'| Ɣ | {date} | [{title}]({str(file.name)}) | *{categories}* | \n')

    f.write('</div>')
