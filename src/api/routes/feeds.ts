import { getFeedItems } from "adapters/subscriptions-feed-store";
import { NewsletterIssueGist } from "models/newsletter-gist";
import { Hono } from "hono";
import { html } from "hono/html";
import { toXML } from "jstoxml";

export const feeds = new Hono().get("/:id/rss", async (c) => {
    const feedId = c.req.param("id");

    const xmlOptions = {
        header: true,
        indent: "  ",
    };

    let feedItems: NewsletterIssueGist[] = [];

    for await (const items of getFeedItems(feedId)) {
        feedItems = [...items.map((item) => item.content), ...feedItems];
    }

    const rssFeedItems = feedItems.reduce(
        (acc, item) => {
            acc[item.id] = {
                item: {
                    title: item.title,
                    description: html`<div>
                        <section>📩 ${item.emailFrom}</section>
                        <section>📝 ${item.summary}</section>
                        <section>
                            <div>📝 Topics</div>
                            <ul>
                                ${item.topics.map((t) => {
                                    return `<li>${t}</li>`;
                                })}
                            </ul>
                        </section>
                        <section>
                            <div>
                                <a href="https://${process.env.API_HOST}/newsletters/${item.id}"
                                    >📰 Open newsletter content</a
                                >
                            </div>
                        </section>
                        <section>
                            <ul>
                                ${item.links.map((l) => {
                                    return `
                                            <li>
                                                <a href="https://${process.env.API_HOST}/links/${l.url}"
                                                    >🔗 ${l.text}</a
                                                >
                                            </li>
                                        `;
                                })}
                            </ul>
                        </section>
                    </div>`.toString(),
                    guid: item.id,
                    link: `https://${process.env.API_HOST}/newsletters/${item.id}`,
                    author: item.emailFrom,
                    pubDate: () => new Date(item.date).toUTCString(),
                },
            };
            return acc;
        },
        {} as Record<string, unknown>
    );

    const feed = toXML(
        {
            _name: "rss",
            _attrs: {
                version: "2.0",
            },
            _content: {
                channel: [
                    {
                        title: `✨ Awesome serverless updates ✨`,
                    },
                    {
                        description: `✨ Awesome serverless updates curated from community newsletters ✨`,
                    },
                    {
                        link: `https://${process.env.API_HOST}/feeds/${feedId}/rss`,
                    },
                    {
                        lastBuildDate: () => new Date(),
                    },
                    {
                        pubDate: () => new Date(),
                    },
                    {
                        language: "en",
                    },
                    Object.values(rssFeedItems),
                ],
            },
        },
        xmlOptions
    );

    return c.text(feed);
});
