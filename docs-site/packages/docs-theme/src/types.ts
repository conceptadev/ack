export type LinkPlacement = 'all' | 'menu' | 'nav';

export interface DocsRepository {
  url: string;
  branch?: string;
  contentPath?: string;
}

export interface DocsProject {
  id: string;
  name: string;
  description?: string;
  docsUrl: string;
  repository?: DocsRepository;
}

export interface DocsSocialLink {
  label: string;
  url: string;
  placement?: LinkPlacement;
}

export interface DocsConfig {
  organization: {
    name: string;
    homeUrl?: string;
  };
  site: {
    title: string;
    description: string;
    url: string;
    docsPath?: `/${string}`;
  };
  project: DocsProject;
  projects?: DocsProject[];
  socialLinks?: DocsSocialLink[];
}

export type PageStatus =
  | 'beta'
  | 'deprecated'
  | 'draft'
  | 'experimental'
  | 'stable';
