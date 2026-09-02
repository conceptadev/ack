import { loader } from 'fumadocs-core/source';
import {
  metaSchema,
  pageSchema,
} from 'fumadocs-core/source/schema';
import { defineDocs } from 'fumadocs-mdx/macro';
import { z } from 'zod';
import { absoluteSiteUrl } from '@/lib/routes';

const docs = defineDocs({
  dir: 'content/docs',
  docs: {
    schema: pageSchema.extend({
      status: z
        .enum(['beta', 'deprecated', 'draft', 'experimental', 'stable'])
        .optional(),
      owner: z.string().min(1).optional(),
      lastReviewed: z.coerce.date().optional(),
      audience: z.array(z.string()).default([]),
      tags: z.array(z.string()).default([]),
    }),
    postprocess: {
      includeProcessedMarkdown: true,
    },
  },
  meta: {
    schema: metaSchema,
  },
});

export const source = loader({
  baseUrl: '/',
  source: docs.toFumadocsSource(),
});

export function getPageImageUrl(page: (typeof source)['$inferPage']) {
  const segments = [...page.slugs, 'image.png'];

  return {
    segments,
    url: `/${['og', ...segments].join('/')}`,
  };
}

export function getPageMarkdownUrl(page: (typeof source)['$inferPage']) {
  const segments = [...page.slugs, 'content.md'];

  return {
    segments,
    url: `/${['llms.mdx', ...segments].join('/')}`,
  };
}

export async function getLLMText(page: (typeof source)['$inferPage']) {
  const processed = await page.data.getText('processed');

  return `# ${page.data.title} (${absoluteSiteUrl(page.url)})\n\n${processed}`;
}
