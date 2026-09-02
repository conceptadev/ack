import { docsConfig } from '@/docs.config';

const basePath = process.env.NEXT_PUBLIC_DOCS_BASE_PATH ?? '';

export function withBasePath(path: string): string {
  const normalizedPath = path.startsWith('/') ? path : `/${path}`;
  if (!basePath) return normalizedPath;
  if (normalizedPath === '/') return basePath || '/';
  return `${basePath}${normalizedPath}`;
}

export function absoluteSiteUrl(path: string): string {
  const base = new URL(
    docsConfig.site.url.endsWith('/')
      ? docsConfig.site.url
      : `${docsConfig.site.url}/`,
  );

  return new URL(path.replace(/^\/+/, ''), base).toString();
}
