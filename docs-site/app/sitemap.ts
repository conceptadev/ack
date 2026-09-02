import type { MetadataRoute } from 'next';
import { docsConfig } from '@/docs.config';
import { source } from '@/lib/source';

export default function sitemap(): MetadataRoute.Sitemap {
  return source.getPages().map((page) => ({
    url: new URL(page.url, docsConfig.site.url).toString(),
    lastModified: page.data.lastReviewed,
    changeFrequency: 'weekly',
    priority: page.slugs.length === 0 ? 1 : 0.7,
  }));
}
