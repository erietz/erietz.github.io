#!/usr/bin/env python3

from pathlib import Path

FILES = sorted(Path('./_posts/').glob('*.md'), reverse=True)
FILES = [f for f in FILES if 'index.md' not in f.name]
INDEX = Path('./_posts/index.md')

with open(INDEX, 'w') as f:
    f.write('---\n')
    f.write('title: Posts\n')
    f.write('---\n')
    f.write('\n')

    f.write('|     |       |      |\n')
    f.write('|:--- | :---- | ---: |\n')
    for file in FILES:
        title = file.read_text().split('\n')[1].split(':')[1].strip()
        date = file.name[:10]
        f.write(f'| Ɣ | [{title}]({str(file.name)}) | {date} | \n')
