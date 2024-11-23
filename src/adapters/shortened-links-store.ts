import { DynamoDBClient, GetItemCommand, PutItemCommand } from "@aws-sdk/client-dynamodb";

const dynamoDbClient = new DynamoDBClient({});

const addShortenedLink = async (originalLink: string, shortenedLinkId: string) => {
    try {
        await dynamoDbClient.send(
            new PutItemCommand({
                TableName: process.env.SHORTENED_LINKS_TABLE_NAME,
                Item: {
                    shortenedLinkId: { S: shortenedLinkId },
                    originalLink: { S: originalLink },
                },
            })
        );
    } catch (error) {
        console.error("Error adding item to feed:", error);
        throw error;
    }
};

const getOriginalLink = async (shortenedLinkId: string) => {
    try {
        const data = await dynamoDbClient.send(
            new GetItemCommand({
                TableName: process.env.SHORTENED_LINKS_TABLE_NAME,
                Key: {
                    shortenedLinkId: { S: shortenedLinkId },
                },
            })
        );

        if (data.Item) {
            return data.Item.originalLink.S!;
        } else {
            return null;
        }
    } catch (error) {
        console.error("Error getting original link:", error);
        throw error;
    }
};

export { addShortenedLink, getOriginalLink };
