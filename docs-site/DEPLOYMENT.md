# Documentation deployment

The Fumadocs application produces a static site in `docs-site/out`.

## Production build

```bash
cd docs-site
npm install --global pnpm@11.5.3
pnpm install --frozen-lockfile
DOCS_BASE_PATH=/ack \
NEXT_PUBLIC_SITE_URL=https://concepta.dev/ack \
pnpm build
```

Publish the contents of `docs-site/out` at the `/ack` path on
`https://concepta.dev`.

The build uses Next.js `basePath` support, so scripts, styles, search data,
Open Graph routes, and Markdown routes are emitted for that subpath.

## Cutover requirement

The existing site is hosted by docs.page. This migration removes `docs.json`,
so merge and hosting cutover must be coordinated. Do not merge until the
`concepta.dev/ack` route is configured to serve the generated static output.

## Shared package follow-up

The site currently uses the pinned workspace snapshot in
`docs-site/packages/docs-theme`. Once `@conceptadev/docs-theme` is published,
replace the workspace dependency with the released version and remove the local
snapshot.
