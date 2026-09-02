import type { BaseLayoutProps } from 'fumadocs-ui/layouts/shared';
import type { Metadata } from 'next';
import type { ComponentProps, ReactNode } from 'react';

export type DocsStatus =
  | 'beta'
  | 'deprecated'
  | 'draft'
  | 'experimental'
  | 'stable';

export interface DocsRepository {
  url: string;
  branch: string;
  contentPath?: string;
}

export interface DocsProjectLink {
  id: string;
  name: string;
  description?: string;
  docsUrl: string;
}

export interface DocsSocialLink {
  label: string;
  url: string;
  placement?: 'all' | 'menu' | 'nav';
}

export interface DocsConfig {
  organization: {
    name: string;
    homeUrl: string;
  };
  site: {
    title: string;
    description: string;
    url: string;
    docsPath: string;
  };
  project: DocsProjectLink & {
    repository: DocsRepository;
  };
  projects: DocsProjectLink[];
  socialLinks?: DocsSocialLink[];
}

export interface PageMetadataInput {
  title: string;
  description?: string;
  path: string;
  image?: string;
}

function trimSlashes(value: string): string {
  return value.replace(/^\/+|\/+$/g, '');
}

function pathFromParts(...parts: Array<string | undefined>): string {
  const value = parts
    .filter((part): part is string => Boolean(part))
    .map(trimSlashes)
    .filter(Boolean)
    .join('/');

  return value ? `/${value}` : '/';
}

function classNames(...values: Array<string | undefined>): string | undefined {
  const result = values.filter(Boolean).join(' ');
  return result || undefined;
}

export function defineDocsConfig<const T extends DocsConfig>(config: T): T {
  new URL(config.site.url);
  new URL(config.organization.homeUrl);
  new URL(config.project.repository.url);

  if (!config.site.docsPath.startsWith('/')) {
    throw new Error('site.docsPath must start with a forward slash.');
  }

  const ids = new Set<string>();
  for (const project of config.projects) {
    if (ids.has(project.id)) {
      throw new Error(`Duplicate project id: ${project.id}`);
    }
    ids.add(project.id);
  }

  return config;
}

export function createRepositoryFileUrl(
  repository: DocsRepository,
  sourcePath: string,
): string {
  const base = repository.url.replace(/\/$/, '');
  const filePath = [repository.contentPath, sourcePath]
    .filter((value): value is string => Boolean(value))
    .map(trimSlashes)
    .filter(Boolean)
    .join('/');

  return `${base}/blob/${encodeURIComponent(repository.branch)}/${filePath}`;
}

export function createBaseLayoutOptions(
  config: DocsConfig,
): BaseLayoutProps {
  const links: NonNullable<BaseLayoutProps['links']> = [];

  if (config.projects.length > 1) {
    links.push({
      type: 'menu',
      text: 'Projects',
      items: config.projects.map((project) => ({
        type: 'main',
        text: project.name,
        description: project.description,
        url: project.docsUrl,
        external: /^https?:\/\//.test(project.docsUrl),
      })),
    });
  }

  for (const link of config.socialLinks ?? []) {
    links.push({
      type: 'main',
      text: link.label,
      url: link.url,
      external: true,
      on: link.placement ?? 'all',
    });
  }

  return {
    nav: {
      title: config.project.name,
      url: config.project.docsUrl,
    },
    githubUrl: config.project.repository.url,
    links,
  };
}

export function createSiteMetadata(config: DocsConfig): Metadata {
  const canonical = new URL(config.site.docsPath, config.site.url);

  return {
    metadataBase: new URL(config.site.url),
    title: {
      default: config.site.title,
      template: `%s | ${config.project.name}`,
    },
    description: config.site.description,
    applicationName: config.site.title,
    alternates: {
      canonical,
    },
    openGraph: {
      type: 'website',
      siteName: config.site.title,
      title: config.site.title,
      description: config.site.description,
      url: canonical,
    },
    twitter: {
      card: 'summary_large_image',
      title: config.site.title,
      description: config.site.description,
    },
  };
}

export function createPageMetadata(
  config: DocsConfig,
  page: PageMetadataInput,
): Metadata {
  const canonicalPath = pathFromParts(config.site.docsPath, page.path);
  const canonical = new URL(canonicalPath, config.site.url);
  const image = page.image ? new URL(page.image, config.site.url) : undefined;

  return {
    title: page.title,
    description: page.description,
    alternates: {
      canonical,
    },
    openGraph: {
      type: 'article',
      siteName: config.site.title,
      title: page.title,
      description: page.description,
      url: canonical,
      images: image ? [image] : undefined,
    },
    twitter: {
      card: 'summary_large_image',
      title: page.title,
      description: page.description,
      images: image ? [image] : undefined,
    },
  };
}

export interface ConceptSummaryProps
  extends Omit<ComponentProps<'section'>, 'title'> {
  title?: ReactNode;
}

export function ConceptSummary({
  title = 'Concept summary',
  children,
  className,
  ...props
}: ConceptSummaryProps) {
  return (
    <section
      {...props}
      className={classNames('concepta-concept-summary', className)}
    >
      <strong className="concepta-concept-summary-title">{title}</strong>
      <div>{children}</div>
    </section>
  );
}

export interface StatusProps extends ComponentProps<'span'> {
  value: DocsStatus;
}

export function Status({ value, className, ...props }: StatusProps) {
  return (
    <span
      {...props}
      className={classNames(
        'concepta-status',
        `concepta-status-${value}`,
        className,
      )}
    >
      {value}
    </span>
  );
}

export interface ProjectLinksProps
  extends Omit<ComponentProps<'section'>, 'title'> {
  projects: DocsProjectLink[];
  title?: ReactNode;
}

export function ProjectLinks({
  projects,
  title = 'Related projects',
  className,
  ...props
}: ProjectLinksProps) {
  if (projects.length === 0) return null;

  return (
    <section
      {...props}
      className={classNames('concepta-project-links', className)}
    >
      <h2 className="concepta-project-links-title">{title}</h2>
      <div className="concepta-project-links-grid">
        {projects.map((project) => (
          <a
            className="concepta-project-link"
            href={project.docsUrl}
            key={project.id}
          >
            <strong>{project.name}</strong>
            {project.description ? <span>{project.description}</span> : null}
          </a>
        ))}
      </div>
    </section>
  );
}
