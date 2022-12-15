#!/usr/bin/env python3

from pathlib import Path
import yaml

FILES = sorted(
    [f for f in Path('./_posts/').glob('*.md') if "index.md" not in f.name],
    reverse=True
)
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

    f.write('<center>')

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

    f.write('</center>')
