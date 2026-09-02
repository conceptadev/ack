import {
  createPageMetadata,
  createRepositoryFileUrl,
  Status,
} from '@conceptadev/docs-theme';
import {
  DocsBody,
  DocsDescription,
  DocsPage,
  DocsTitle,
  MarkdownCopyButton,
  PageLastUpdate,
  ViewOptionsPopover,
} from 'fumadocs-ui/layouts/docs/page';
import { createRelativeLink } from 'fumadocs-ui/mdx';
import type { Metadata } from 'next';
import { notFound } from 'next/navigation';
import { getMDXComponents } from '@/components/mdx';
import { docsConfig } from '@/docs.config';
import {
  getPageImageUrl,
  getPageMarkdownUrl,
  source,
} from '@/lib/source';

interface DocumentationPageProps {
  params: Promise<{
    slug?: string[];
  }>;
}

export default async function DocumentationPage(
  props: DocumentationPageProps,
) {
  const params = await props.params;
  const page = source.getPage(params.slug);
  if (!page) notFound();

  const MDX = page.data.body;
  const markdownUrl = getPageMarkdownUrl(page).url;
  const githubUrl = createRepositoryFileUrl(
    docsConfig.project.repository,
    page.data.sourcePath,
  );

  return (
    <DocsPage toc={page.data.toc} full={page.data.full}>
      <div className="mb-2 flex flex-wrap items-center gap-2">
        <DocsTitle className="mb-0 flex-1">{page.data.title}</DocsTitle>
        {page.data.status ? <Status value={page.data.status} /> : null}
      </div>
      <DocsDescription className="mb-0">
        {page.data.description}
      </DocsDescription>
      <div className="mb-8 mt-5 flex flex-wrap items-center gap-2 border-b pb-6">
        <MarkdownCopyButton markdownUrl={markdownUrl} />
        <ViewOptionsPopover
          markdownUrl={markdownUrl}
          githubUrl={githubUrl}
        />
        {page.data.lastReviewed ? (
          <PageLastUpdate className="ml-auto" date={page.data.lastReviewed} />
        ) : null}
      </div>
      <DocsBody>
        <MDX
          components={getMDXComponents({
            a: createRelativeLink(source, page),
          })}
        />
      </DocsBody>
    </DocsPage>
  );
}

export function generateStaticParams() {
  return source.generateParams();
}

export async function generateMetadata(
  props: DocumentationPageProps,
): Promise<Metadata> {
  const params = await props.params;
  const page = source.getPage(params.slug);
  if (!page) notFound();

  return createPageMetadata(docsConfig, {
    title: page.data.title,
    description: page.data.description,
    path: page.slugs.join('/'),
    image: getPageImageUrl(page).url,
  });
}
