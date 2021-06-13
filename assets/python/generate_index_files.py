#!/usr/bin/env python3

def generate_index_file(filepath, page_title):
    root = Path('/'.join(filepath.parts[:-1]))
    files = Path(root).glob('*.md')
    files = [f for f in files if 'index.md' not in f.name]
    index = root / 'index.md'

    with open(index, 'w') as f:
        f.write('---\n')
        f.write(f'title: {page_title}\n')
        f.write('---\n')
        f.write('\n')

        for file in files:
            title = file.read_text().split('\n')[1].split(':')[1].strip()
            f.write(f'- [{title}]({str(file.name)})\n')

if __name__ == '__main__':
    from pathlib import Path

    post_index = Path('_posts/index.md')
    projects_index = Path('_projects/index.md')

    generate_index_file(post_index, 'Posts')
    generate_index_file(projects_index, 'Projects')
