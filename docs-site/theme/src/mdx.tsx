import {
  Accordion,
  Accordions,
} from 'fumadocs-ui/components/accordion';
import { File, Files, Folder } from 'fumadocs-ui/components/files';
import { Step, Steps } from 'fumadocs-ui/components/steps';
import { Tab, Tabs } from 'fumadocs-ui/components/tabs';
import defaultMdxComponents from 'fumadocs-ui/mdx';
import type { MDXComponents } from 'mdx/types';
import {
  ConceptSummary,
  ProjectLinks,
  Status,
} from './index';

export function getConceptaMDXComponents(
  components?: MDXComponents,
): MDXComponents {
  return {
    ...defaultMdxComponents,
    Accordion,
    Accordions,
    ConceptSummary,
    File,
    Files,
    Folder,
    ProjectLinks,
    Status,
    Step,
    Steps,
    Tab,
    Tabs,
    ...components,
  };
}
