import type { Metadata } from 'next';
import type { DocsConfig } from './types';

function absoluteUrl(path: string, siteUrl: string): string {
  return new URL(path, siteUrl.endsWith('/') ? siteUrl : `${siteUrl}/`).toString();
}

export interface PageMetadataInput {
  title: string;
  description?: string;
  path: string;
  imageUrl?: string;
}

export function createSiteMetadata(config: DocsConfig): Metadata {
  const siteUrl = new URL(config.site.url);

  return {
    metadataBase: siteUrl,
    title: {
      default: config.site.title,
      template: `%s | ${config.site.title}`,
    },
    description: config.site.description,
    applicationName: config.site.title,
    alternates: {
      canonical: siteUrl,
    },
    openGraph: {
      type: 'website',
      siteName: config.site.title,
      title: config.site.title,
      description: config.site.description,
      url: siteUrl,
    },
    twitter: {
      card: 'summary_large_image',
      title: config.site.title,
      description: config.site.description,
    },
    robots: {
      index: true,
      follow: true,
    },
  };
}

export function createPageMetadata(
  config: DocsConfig,
  input: PageMetadataInput,
): Metadata {
  const pageUrl = absoluteUrl(input.path, config.site.url);

  return {
    title: input.title,
    description: input.description,
    alternates: {
      canonical: pageUrl,
    },
    openGraph: {
      type: 'article',
      siteName: config.site.title,
      title: input.title,
      description: input.description,
      url: pageUrl,
      images: input.imageUrl ? [input.imageUrl] : undefined,
    },
    twitter: {
      card: 'summary_large_image',
      title: input.title,
      description: input.description,
      images: input.imageUrl ? [input.imageUrl] : undefined,
    },
  };
}
