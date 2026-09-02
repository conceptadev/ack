import type { DocsConfig, DocsRepository } from './types';

function trimSlashes(value: string): string {
  return value.replace(/^\/+|\/+$/g, '');
}

function joinPath(...parts: Array<string | undefined>): string {
  return parts
    .filter((part): part is string => Boolean(part))
    .map(trimSlashes)
    .filter(Boolean)
    .join('/');
}

function getRepository(config: DocsConfig): DocsRepository | undefined {
  return config.project.repository;
}

function repositoryBaseUrl(repository: DocsRepository): string {
  return repository.url.replace(/\/+$/, '');
}

export function createRepositoryUrl(config: DocsConfig): string | undefined {
  const repository = getRepository(config);
  return repository ? repositoryBaseUrl(repository) : undefined;
}

export function createSourceUrl(
  config: DocsConfig,
  pagePath: string,
): string | undefined {
  const repository = getRepository(config);
  if (!repository) return undefined;

  const branch = encodeURIComponent(repository.branch ?? 'main');
  const path = joinPath(repository.contentPath, pagePath);
  return `${repositoryBaseUrl(repository)}/blob/${branch}/${path}`;
}

export function createEditUrl(
  config: DocsConfig,
  pagePath: string,
): string | undefined {
  const repository = getRepository(config);
  if (!repository) return undefined;

  const branch = encodeURIComponent(repository.branch ?? 'main');
  const path = joinPath(repository.contentPath, pagePath);
  return `${repositoryBaseUrl(repository)}/edit/${branch}/${path}`;
}
