import { z } from "zod";
import zodToJsonSchema from "zod-to-json-schema";

const linkSchema = z.object({
    text: z.string(),
    url: z.string(),
});

const itemSchema = z.object({
    title: z.string(),
    content: z.string(),
    link: linkSchema,
});

export const newsletterGist = z.object({
    summary: z.string(),
    topics: z.array(z.string()),
    links: z.array(linkSchema),
});

export type NewsletterGist = z.infer<typeof newsletterGist>;
export const newsletterGistSchema = zodToJsonSchema(newsletterGist);

const newsletterIssueInfo = z.object({
    id: z.string(),
    title: z.string(),
    emailFrom: z.string(),
    date: z.date(),
    feedId: z.string(),
});

export const newsletterIssueGist = newsletterGist.merge(newsletterIssueInfo);

export type NewsletterIssueGist = z.infer<typeof newsletterIssueGist>;
