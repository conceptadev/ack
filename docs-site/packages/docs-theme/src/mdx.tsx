import * as AccordionComponents from 'fumadocs-ui/components/accordion';
import * as FilesComponents from 'fumadocs-ui/components/files';
import * as StepsComponents from 'fumadocs-ui/components/steps';
import * as TabsComponents from 'fumadocs-ui/components/tabs';
import defaultMdxComponents from 'fumadocs-ui/mdx';
import type { MDXComponents } from 'mdx/types';
import { ConceptSummary } from './components/concept-summary';
import { ProjectLinks } from './components/project-links';
import { Status } from './components/status';

export function getConceptaMDXComponents(
  components?: MDXComponents,
): MDXComponents {
  return {
    ...defaultMdxComponents,
    ...AccordionComponents,
    ...FilesComponents,
    ...StepsComponents,
    ...TabsComponents,
    ConceptSummary,
    ProjectLinks,
    Status,
    ...components,
  } satisfies MDXComponents;
}

export const useMDXComponents = getConceptaMDXComponents;

declare global {
  type MDXProvidedComponents = ReturnType<typeof getConceptaMDXComponents>;
}
