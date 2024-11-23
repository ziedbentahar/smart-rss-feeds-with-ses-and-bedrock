import { NewsletterGist, newsletterGist, newsletterGistSchema } from "models/newsletter-gist";
import { generatePromptForEmail } from "./prompt-generation";
import { BedrockRuntimeClient, ConverseCommand } from "@aws-sdk/client-bedrock-runtime";
const bedrockClient = new BedrockRuntimeClient();

async function generateNewsletterGist(markdown: string): Promise<NewsletterGist | null> {
    const prompt = generatePromptForEmail(markdown, JSON.stringify(newsletterGistSchema));

    const result = await bedrockClient.send(
        new ConverseCommand({
            modelId: process.env.MODEL_ID,
            system: [{ text: "You are an advanced newsletter content extraction and summarization tool." }],
            messages: [
                {
                    role: "user",
                    content: [
                        {
                            text: prompt,
                        },
                    ],
                },
                {
                    role: "assistant",
                    content: [
                        {
                            text: "{",
                        },
                    ],
                },
            ],
        })
    );

    const output = result.output?.message?.content ? `{${result.output.message.content[0].text}` : null;

    return output ? newsletterGist.parse(JSON.parse(output)) : null;
}

export { generateNewsletterGist };
