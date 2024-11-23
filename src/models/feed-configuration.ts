import { z } from "zod";

const feedConfigSchema = z.object({
    feedName: z.string(),
    newsletterSendersAllowList: z.array(z.string()),
});

export type FeedConfig = z.infer<typeof feedConfigSchema>;
