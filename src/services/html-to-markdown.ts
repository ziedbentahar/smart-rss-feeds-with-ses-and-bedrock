import TurndownService from "turndown";

const generateMarkdown = (
    html: string,
    options: { shortenLinks: true; shortener: (href: string) => string } | { shortenLinks: false }
): string => {
    const turndownService = new TurndownService({});

    turndownService.addRule("styles-n-headers", {
        filter: ["style", "head", "script"],
        replacement: function (_) {
            return "";
        },
    });

    if (options.shortenLinks) {
        turndownService.addRule("shorten-links", {
            filter: "a",
            replacement: function (content, node) {
                const href = node.getAttribute("href");
                if (href) {
                    const shortened = options.shortener(href);
                    return `[${content}](${shortened})`;
                }
                return content;
            },
        });
    }

    const markdown = turndownService.turndown(html);

    return markdown;
};

export { generateMarkdown };
