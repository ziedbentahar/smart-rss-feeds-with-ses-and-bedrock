import { getOriginalLink } from "adapters/shortened-links-store";
import { Hono } from "hono";

export const links = new Hono().get("/:id", async (c) => {
    const shrotenedLinkId = c.req.param("id");

    if (!shrotenedLinkId) {
        c.status(404);
        return c.text("Not found");
    }

    const originalLink = await getOriginalLink(shrotenedLinkId);

    if (!originalLink) {
        c.status(404);
        return c.text("Not found");
    }

    return c.redirect(originalLink);
});
