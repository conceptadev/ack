# Ack documentation site

This directory contains the Fumadocs application for Ack.

The canonical documentation content stays in the repository-level `docs/`
directory. This preserves Ack's existing documentation tests and keeps content
changes beside the Dart packages.

## Local development

```bash
cd docs-site
npm install --global pnpm@11.5.3
pnpm install
pnpm dev
```

Open `http://localhost:3000`.

To test the production subpath used by `https://concepta.dev/ack`:

```bash
DOCS_BASE_PATH=/ack \
NEXT_PUBLIC_SITE_URL=https://concepta.dev/ack \
pnpm build
```

## Shared theme package

`packages/docs-theme` is a pinned workspace snapshot of
`@conceptadev/docs-theme`. It is temporary while the organization package is
unpublished. Replace the workspace dependency with the released package after
the registry and release process are available.
