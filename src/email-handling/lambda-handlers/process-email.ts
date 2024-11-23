import { S3ObjectCreatedNotificationEvent } from "aws-lambda";
import { getRawEmailContent } from "adapters/raw-email-store";
import { generateMarkdown } from "services/html-to-markdown";
import { basename } from "path";
import { addNewItemToFeed } from "adapters/subscriptions-feed-store";
import { addShortenedLink } from "adapters/shortened-links-store";
import { generateNewsletterGist } from "services/newsletter-gist-generation";
import { getFeedConfigurationsBySenderEmail } from "adapters/feed-config";
import { parseEmail } from "services/parse-email";

const { nanoid } = require("nanoid");

export const lambdaHandler = async (event: S3ObjectCreatedNotificationEvent) => {
    const rawContent = await getRawEmailContent(event.detail.object.key);
    const emailId = basename(event.detail.object.key);

    if (!rawContent) {
        throw new Error("Email content not found");
    }

    const { newsletterEmailFrom, newsletterEmailTo, html, date, subject } = await parseEmail(rawContent);

    let feedsConfigs = await getFeedConfigurationsBySenderEmail(newsletterEmailFrom);

    if (feedsConfigs.length === 0) {
        console.warn(`No feed config found for ${newsletterEmailFrom}`);
        return;
    }

    let shortenedLinks = new Map<string, string>();
    const markdown = generateMarkdown(html, {
        shortenLinks: true,
        shortener: (href) => {
            let shortened = nanoid();
            shortenedLinks.set(shortened, href);
            return shortened;
        },
    });
    for (const [shortened, original] of shortenedLinks) {
        await addShortenedLink(original, shortened);
    }

    const output = await generateNewsletterGist(markdown);

    if (!output) {
        throw new Error("Failed to generate newsletter gist");
    }

    await Promise.allSettled(
        feedsConfigs.map(async (feedConfig) => {
            await addNewItemToFeed(feedConfig.feedId, {
                feedId: feedConfig.feedId,
                date,
                title: subject,
                emailFrom: newsletterEmailFrom!,
                id: emailId,
                ...output,
            });
        })
    ).catch((e) => {
        console.error(e);
    });

    await addNewItemToFeed(newsletterEmailTo, {
        feedId: newsletterEmailTo,
        date,
        title: subject,
        emailFrom: newsletterEmailFrom!,
        id: emailId,
        ...output,
    });

    return {
        newsletter: {
            id: emailId,
            from: newsletterEmailFrom,
            to: newsletterEmailTo,
            subject: subject,
            date,
        },
    };
};

export const handler = lambdaHandler;
