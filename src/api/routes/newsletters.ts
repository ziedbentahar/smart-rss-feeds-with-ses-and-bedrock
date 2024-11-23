import { getRawEmailContent } from "adapters/raw-email-store";
import { Hono } from "hono";
import { simpleParser } from "mailparser";

export const newsletters = new Hono().get("/:id", async (c) => {
    const emailId = c.req.param("id");

    if (!emailId) {
        c.status(404);
        return c.text("Not found");
    }

    const newsletterContent = await getRawEmailContent(`inbox/${emailId}`);

    if (!newsletterContent) {
        c.status(404);
        return c.text("Not found");
    }

    const parsedContent = await simpleParser(newsletterContent);

    if (!parsedContent.html) {
        throw new Error("Email content is not HTML");
    }

    return c.html(parsedContent.html);
});
