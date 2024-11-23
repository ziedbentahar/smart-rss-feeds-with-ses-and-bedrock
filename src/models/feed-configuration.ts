import { z } from "zod";

const feedConfigSchema = z.object({
    name: z.string(),
    description: z.string().optional(),
    newsletterSendersAllowList: z.array(z.string()),
});

export type FeedConfig = z.infer<typeof feedConfigSchema>;
