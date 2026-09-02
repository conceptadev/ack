import {
  access,
  copyFile,
  mkdir,
  readFile,
  readdir,
  rm,
  stat,
  writeFile,
} from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import matter from 'gray-matter';

const appRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const repoRoot = path.resolve(appRoot, '..');
const generatedRoot = path.join(appRoot, '.generated', 'docs');
const publicAssetRoot = path.join(appRoot, 'public', '_ack-docs');

const repositoryUrl =
  process.env.ACK_DOCS_REPOSITORY_URL ?? 'https://github.com/conceptadev/ACK';
const repositoryBranch = process.env.ACK_DOCS_BRANCH ?? 'main';

const documentationDirectories = [
  'docs',
  'documentation',
  'guide',
  'guides',
  'wiki',
];
const packageDirectories = ['packages', 'modules', 'plugins', 'crates'];
const topLevelDocuments = [
  'ARCHITECTURE.md',
  'CHANGELOG.md',
  'CODE_OF_CONDUCT.md',
  'CONTRIBUTING.md',
  'ROADMAP.md',
  'SECURITY.md',
];
const excludedSegments = new Set([
  '.dart_tool',
  '.git',
  '.gradle',
  '.next',
  '.turbo',
  'build',
  'coverage',
  'dist',
  'docs-site',
  'node_modules',
  'out',
  'target',
  'vendor',
]);
const markdownExtensions = new Set(['.md', '.mdx', '.markdown']);

async function exists(filePath) {
  try {
    await access(filePath);
    return true;
  } catch {
    return false;
  }
}

function toPosix(filePath) {
  return filePath.split(path.sep).join('/');
}

function humanize(value) {
  return value
    .replace(/\.(md|mdx|markdown)$/i, '')
    .replace(/[-_]+/g, ' ')
    .replace(/\b\w/g, (letter) => letter.toUpperCase());
}

async function walkMarkdown(directory) {
  if (!(await exists(directory))) return [];

  const output = [];
  const entries = await readdir(directory, { withFileTypes: true });

  for (const entry of entries) {
    if (excludedSegments.has(entry.name)) continue;

    const entryPath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      output.push(...(await walkMarkdown(entryPath)));
      continue;
    }

    if (entry.isFile() && markdownExtensions.has(path.extname(entry.name).toLowerCase())) {
      output.push(entryPath);
    }
  }

  return output;
}

async function walkReadmes(directory) {
  if (!(await exists(directory))) return [];

  const output = [];
  const entries = await readdir(directory, { withFileTypes: true });

  for (const entry of entries) {
    if (!entry.isDirectory() || excludedSegments.has(entry.name)) continue;

    const entryPath = path.join(directory, entry.name);
    for (const name of ['README.md', 'README.mdx', 'readme.md']) {
      const readme = path.join(entryPath, name);
      if (await exists(readme)) output.push(readme);
    }

    output.push(...(await walkReadmes(entryPath)));
  }

  return output;
}

async function collectSources() {
  const sources = [];
  const rootReadme = path.join(repoRoot, 'README.md');
  if (await exists(rootReadme)) sources.push(rootReadme);

  for (const name of topLevelDocuments) {
    const filePath = path.join(repoRoot, name);
    if (await exists(filePath)) sources.push(filePath);
  }

  for (const directory of documentationDirectories) {
    sources.push(...(await walkMarkdown(path.join(repoRoot, directory))));
  }

  for (const directory of packageDirectories) {
    sources.push(...(await walkReadmes(path.join(repoRoot, directory))));
  }

  return [...new Set(sources.map((source) => path.resolve(source)))].sort();
}

function destinationFor(sourcePath) {
  const relative = toPosix(path.relative(repoRoot, sourcePath));
  const lower = relative.toLowerCase();

  if (lower === 'readme.md' || lower === 'readme.mdx') return 'index.mdx';

  let destination = relative;
  const firstSegment = destination.split('/')[0]?.toLowerCase();
  if (documentationDirectories.includes(firstSegment)) {
    destination = destination.split('/').slice(1).join('/');
  }

  const basename = path.posix.basename(destination).toLowerCase();
  if (basename === 'readme.md' || basename === 'readme.mdx') {
    destination = path.posix.join(path.posix.dirname(destination), 'index.mdx');
  } else {
    destination = destination.replace(/\.(md|mdx|markdown)$/i, '.mdx');
  }

  if (!destination || destination === 'index.mdx') {
    return lower.startsWith('docs/') ? 'documentation-overview.mdx' : 'index.mdx';
  }

  return destination;
}

function titleFromBody(body, destination) {
  const heading = body.match(/^#\s+(.+)$/m)?.[1]?.trim();
  if (heading) return heading.replace(/[`*_]/g, '');

  const basename = path.posix.basename(destination, '.mdx');
  if (basename === 'index') {
    const parent = path.posix.basename(path.posix.dirname(destination));
    return parent === '.' ? 'ACK' : humanize(parent);
  }

  return humanize(basename);
}

function descriptionFromBody(body, title) {
  const paragraph = body
    .split(/\n\s*\n/)
    .map((value) => value.trim())
    .find(
      (value) =>
        value &&
        !value.startsWith('#') &&
        !value.startsWith('```') &&
        !value.startsWith('<') &&
        !value.startsWith('!['),
    );

  if (!paragraph) return `${title} documentation for ACK.`;

  return paragraph
    .replace(/\[([^\]]+)\]\([^\)]+\)/g, '$1')
    .replace(/[`*_>#]/g, '')
    .replace(/\s+/g, ' ')
    .slice(0, 220)
    .trim();
}

function removeDuplicateHeading(body, title) {
  const lines = body.split('\n');
  const firstContentIndex = lines.findIndex((line) => line.trim().length > 0);
  if (firstContentIndex < 0) return body;

  const match = lines[firstContentIndex].match(/^#\s+(.+)$/);
  if (!match) return body;

  const heading = match[1].replace(/[`*_]/g, '').trim().toLowerCase();
  if (heading !== title.trim().toLowerCase()) return body;

  lines.splice(firstContentIndex, 1);
  return lines.join('\n').replace(/^\s+/, '');
}

function splitTarget(target) {
  const hashIndex = target.indexOf('#');
  const queryIndex = target.indexOf('?');
  const cutIndexes = [hashIndex, queryIndex].filter((index) => index >= 0);
  const cutAt = cutIndexes.length > 0 ? Math.min(...cutIndexes) : target.length;

  return {
    pathname: target.slice(0, cutAt),
    suffix: target.slice(cutAt),
  };
}

function isExternalTarget(target) {
  return /^(?:[a-z][a-z\d+.-]*:|#|\/\/)/i.test(target);
}

function docsRoute(destination) {
  let route = destination.replace(/\.mdx$/i, '');
  route = route.replace(/\/(?:index)$/i, '');
  if (route === 'index') route = '';
  return `/docs${route ? `/${route}` : ''}`;
}

function publicAssetUrl(relativePath) {
  return `/_ack-docs/${toPosix(relativePath)
    .split('/')
    .map(encodeURIComponent)
    .join('/')}`;
}

async function copyAsset(sourcePath) {
  const relative = path.relative(repoRoot, sourcePath);
  if (relative.startsWith('..')) return null;

  const destination = path.join(publicAssetRoot, relative);
  await mkdir(path.dirname(destination), { recursive: true });
  await copyFile(sourcePath, destination);
  return publicAssetUrl(relative);
}

async function rewriteLinks(body, sourcePath, sourceMap) {
  const markdownLink = /(!?)\[([^\]]*)\]\(([^)\s]+)(?:\s+["'][^"']*["'])?\)/g;
  const replacements = [];

  for (const match of body.matchAll(markdownLink)) {
    const [full, imageMarker, label, rawTarget] = match;
    if (isExternalTarget(rawTarget) || rawTarget.startsWith('/')) continue;

    const { pathname: targetPath, suffix } = splitTarget(rawTarget);
    if (!targetPath) continue;

    let decodedTarget = targetPath;
    try {
      decodedTarget = decodeURIComponent(targetPath);
    } catch {
      // Keep the original target when it is not valid percent-encoding.
    }

    const resolved = path.resolve(path.dirname(sourcePath), decodedTarget);
    const mapped = sourceMap.get(resolved);
    let replacementTarget;

    if (mapped) {
      replacementTarget = `${docsRoute(mapped)}${suffix}`;
    } else if (await exists(resolved)) {
      const fileStats = await stat(resolved);
      if (imageMarker && fileStats.isFile()) {
        const assetUrl = await copyAsset(resolved);
        if (assetUrl) replacementTarget = `${assetUrl}${suffix}`;
      } else {
        const relative = toPosix(path.relative(repoRoot, resolved));
        const kind = fileStats.isDirectory() ? 'tree' : 'blob';
        replacementTarget = `${repositoryUrl}/${kind}/${repositoryBranch}/${relative}${suffix}`;
      }
    }

    if (replacementTarget) {
      replacements.push({
        start: match.index,
        end: match.index + full.length,
        value: `${imageMarker}[${label}](${replacementTarget})`,
      });
    }
  }

  let output = body;
  for (const replacement of replacements.reverse()) {
    output =
      output.slice(0, replacement.start) +
      replacement.value +
      output.slice(replacement.end);
  }

  return output;
}

function ensureUniqueDestinations(sources) {
  const output = new Map();
  const used = new Set();

  for (const source of sources) {
    let destination = destinationFor(source);
    if (used.has(destination)) {
      const relative = toPosix(path.relative(repoRoot, source));
      destination = relative.replace(/\.(md|mdx|markdown)$/i, '.mdx');
      destination = destination.replace(/\/readme\.mdx$/i, '/index.mdx');
    }

    used.add(destination);
    output.set(source, destination);
  }

  return output;
}

async function writeMetaFiles(destinations) {
  const directories = new Map();

  for (const destination of destinations) {
    const directory = path.posix.dirname(destination);
    const page = path.posix.basename(destination, '.mdx');
    const pages = directories.get(directory) ?? new Set();
    pages.add(page);
    directories.set(directory, pages);

    let current = directory;
    while (current !== '.') {
      const parent = path.posix.dirname(current);
      const folder = path.posix.basename(current);
      const siblings = directories.get(parent) ?? new Set();
      siblings.add(folder);
      directories.set(parent, siblings);
      current = parent;
    }
  }

  for (const [directory, entries] of directories) {
    const ordered = [...entries].sort((left, right) => {
      if (left === 'index') return -1;
      if (right === 'index') return 1;
      return left.localeCompare(right);
    });

    const metadata = {
      title: directory === '.' ? 'ACK' : humanize(path.posix.basename(directory)),
      pages: ordered,
    };
    const outputDirectory =
      directory === '.' ? generatedRoot : path.join(generatedRoot, directory);
    await mkdir(outputDirectory, { recursive: true });
    await writeFile(
      path.join(outputDirectory, 'meta.json'),
      `${JSON.stringify(metadata, null, 2)}\n`,
    );
  }
}

async function main() {
  const sources = await collectSources();
  await rm(path.join(appRoot, '.generated'), { recursive: true, force: true });
  await rm(publicAssetRoot, { recursive: true, force: true });
  await mkdir(generatedRoot, { recursive: true });
  await mkdir(publicAssetRoot, { recursive: true });

  if (sources.length === 0) {
    const fallback = matter.stringify(
      'Documentation content has not been added to this repository yet.\n',
      {
        title: 'ACK',
        description: 'Documentation for ACK.',
        sourcePath: 'README.md',
      },
    );
    await writeFile(path.join(generatedRoot, 'index.mdx'), fallback);
    await writeMetaFiles(['index.mdx']);
    return;
  }

  const sourceMap = ensureUniqueDestinations(sources);
  const manifest = [];

  for (const source of sources) {
    const destination = sourceMap.get(source);
    const raw = await readFile(source, 'utf8');
    const parsed = matter(raw);
    const title = parsed.data.title ?? titleFromBody(parsed.content, destination);
    const description =
      parsed.data.description ?? descriptionFromBody(parsed.content, title);
    const sourcePath = toPosix(path.relative(repoRoot, source));
    const bodyWithoutHeading = removeDuplicateHeading(parsed.content, title);
    const body = await rewriteLinks(bodyWithoutHeading, source, sourceMap);
    const output = matter.stringify(body.trimStart(), {
      ...parsed.data,
      title,
      description,
      sourcePath,
    });
    const outputPath = path.join(generatedRoot, destination);

    await mkdir(path.dirname(outputPath), { recursive: true });
    await writeFile(outputPath, output);
    manifest.push({ source: sourcePath, destination });
  }

  await writeMetaFiles(sourceMap.values());
  await writeFile(
    path.join(appRoot, '.generated', 'manifest.json'),
    `${JSON.stringify(manifest, null, 2)}\n`,
  );

  console.log(`Synchronized ${manifest.length} Markdown files into Fumadocs.`);
}

await main();
