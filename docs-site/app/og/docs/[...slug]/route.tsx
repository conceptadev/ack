import { ImageResponse } from 'next/og';
import { notFound } from 'next/navigation';
import { generate as DefaultImage } from 'fumadocs-ui/og';
import { docsConfig } from '@/docs.config';
import { getPageImageUrl, source } from '@/lib/source';

export const revalidate = false;

interface OpenGraphRouteProps {
  params: Promise<{
    slug: string[];
  }>;
}

export async function GET(_request: Request, context: OpenGraphRouteProps) {
  const { slug } = await context.params;
  const page = source.getPage(slug.slice(0, -1));
  if (!page) notFound();

  return new ImageResponse(
    <DefaultImage
      title={page.data.title}
      description={page.data.description}
      site={docsConfig.project.name}
    />,
    {
      width: 1200,
      height: 630,
    },
  );
}

export function generateStaticParams() {
  return source.getPages().map((page) => ({
    slug: getPageImageUrl(page).segments,
  }));
}
