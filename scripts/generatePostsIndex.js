#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const yaml = require('yaml');
const glob = require('glob');
const readline = require('readline');

async function parseFrontmatter(filePath) {
  const frontmatterLines = [];
  const fileStream = fs.createReadStream(filePath);
  const rl = readline.createInterface({
    input: fileStream,
    crlfDelay: Infinity
  });

  const firstLine = await rl[Symbol.asyncIterator]().next();

  if (firstLine.done || firstLine.value.trim() !== '---') {
    fileStream.close();
    return null;
  }

  frontmatterLines.push(firstLine.value);

  for await (const line of rl) {
    if (line.trim() === '---') {
      break;
    }
    frontmatterLines.push(line);
  }

  fileStream.close();

  if (frontmatterLines.length > 1) {
    return yaml.parse(frontmatterLines.join('\n'));
  }

  return null;
}

async function main() {
  const indexFilePath = './_posts/index.md';

  const output = [];
  output.push('---');
  output.push('title: Posts');
  output.push('---');
  output.push('');
  output.push('<center>');
  output.push('|     |       |      |      |');
  output.push('|:--- | :---- | :--- | :--- |');

  // Get all markdown files in _posts folder, excluding index.md
  const files = glob.sync('./_posts/*.md')
    .filter(file => !file.includes('index.md'))
    .sort((a, b) => b.localeCompare(a));

  await Promise.all(files.map(async (file) => {
    const frontmatter = await parseFrontmatter(file);
    if (!frontmatter) return;

    const title = frontmatter.title;
    const categories = frontmatter.categories ? frontmatter.categories.join(', ') : '';
    const date = path.basename(file).slice(0, 10);

    output.push(`| Ɣ | ${date} | [${title}](${path.basename(file)}) | *${categories}* |`);
  }));

  output.push('</center>');

  fs.writeFileSync(indexFilePath, output.join('\n'));
  console.log('index.md file generated successfully.');
}

// Call the generateIndex function
main().catch(err => {
  console.error('Error generating index.md:', err);
});
