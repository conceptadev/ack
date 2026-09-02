import { createMDX } from 'fumadocs-mdx/next';

const configuredBasePath = process.env.DOCS_BASE_PATH ?? '';
const basePath =
  configuredBasePath === '/'
    ? ''
    : configuredBasePath.replace(/\/+$/, '');

/** @type {import('next').NextConfig} */
const config = {
  output: 'export',
  trailingSlash: true,
  reactStrictMode: true,
  basePath: basePath || undefined,
  images: {
    unoptimized: true,
  },
  transpilePackages: ['@conceptadev/docs-theme'],
  env: {
    NEXT_PUBLIC_DOCS_BASE_PATH: basePath,
  },
};

export default createMDX()(config);
