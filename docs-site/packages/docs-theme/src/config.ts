import type { DocsConfig, DocsProject } from './types';

const PROJECT_ID_PATTERN = /^[a-z0-9][a-z0-9-]*$/;

function assertAbsoluteHttpUrl(value: string, name: string): void {
  let url: URL;
  try {
    url = new URL(value);
  } catch {
    throw new Error(`${name} must be an absolute HTTP(S) URL.`);
  }

  if (url.protocol !== 'http:' && url.protocol !== 'https:') {
    throw new Error(`${name} must use HTTP or HTTPS.`);
  }
}

function assertAbsoluteOrRootRelativeUrl(value: string, name: string): void {
  if (value.startsWith('/')) return;
  assertAbsoluteHttpUrl(value, name);
}

function assertProject(project: DocsProject, name: string): void {
  if (!PROJECT_ID_PATTERN.test(project.id)) {
    throw new Error(`${name}.id must contain lowercase letters, numbers, and hyphens.`);
  }

  if (!project.name.trim()) {
    throw new Error(`${name}.name must not be empty.`);
  }

  assertAbsoluteOrRootRelativeUrl(project.docsUrl, `${name}.docsUrl`);

  if (project.repository) {
    assertAbsoluteHttpUrl(project.repository.url, `${name}.repository.url`);
  }
}

export function defineDocsConfig<const T extends DocsConfig>(config: T): T {
  if (!config.organization.name.trim()) {
    throw new Error('organization.name must not be empty.');
  }

  if (!config.site.title.trim() || !config.site.description.trim()) {
    throw new Error('site.title and site.description must not be empty.');
  }

  assertAbsoluteHttpUrl(config.site.url, 'site.url');
  if (config.organization.homeUrl) {
    assertAbsoluteHttpUrl(config.organization.homeUrl, 'organization.homeUrl');
  }

  if (config.site.docsPath && !config.site.docsPath.startsWith('/')) {
    throw new Error('site.docsPath must start with "/".');
  }

  assertProject(config.project, 'project');

  const seen = new Set<string>();
  for (const [index, project] of (config.projects ?? []).entries()) {
    assertProject(project, `projects[${index}]`);
    if (seen.has(project.id)) {
      throw new Error(`projects contains the duplicate id "${project.id}".`);
    }
    seen.add(project.id);
  }

  for (const [index, link] of (config.socialLinks ?? []).entries()) {
    if (!link.label.trim()) {
      throw new Error(`socialLinks[${index}].label must not be empty.`);
    }
    assertAbsoluteOrRootRelativeUrl(link.url, `socialLinks[${index}].url`);
  }

  return config;
}

export function getDocsPath(config: DocsConfig): `/${string}` {
  return config.site.docsPath ?? '/docs';
}

export function getProjects(config: DocsConfig): DocsProject[] {
  const projects = config.projects ?? [];
  if (projects.some((project) => project.id === config.project.id)) {
    return projects;
  }

  return [config.project, ...projects];
}
