import { simpleParser } from "mailparser";

async function parseEmail(rawEmailContent: string) {
    const parsedContent = await simpleParser(rawEmailContent);

    if (!parsedContent.html) {
        throw new Error("Email content is not HTML");
    }

    const newsletterEmailFrom = parsedContent.from?.value[0].address!;
    const newsletterEmailTo = Array.isArray(parsedContent.to)
        ? parsedContent.to[0].value[0].address!
        : parsedContent.to?.value[0].address!;

    return {
        html: parsedContent.html,
        newsletterEmailTo,
        newsletterEmailFrom,
        date: parsedContent.date || new Date(),
        subject: parsedContent.subject || "",
    };
}

export { parseEmail };
