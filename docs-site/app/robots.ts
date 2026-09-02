import type { MetadataRoute } from 'next';
import { docsConfig } from '@/docs.config';

export default function robots(): MetadataRoute.Robots {
  return {
    rules: {
      userAgent: '*',
      allow: '/',
    },
    sitemap: new URL('/sitemap.xml', docsConfig.site.url).toString(),
  };
}
