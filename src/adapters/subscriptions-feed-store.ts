import { DynamoDBClient, PutItemCommand, QueryCommand, QueryCommandInput } from "@aws-sdk/client-dynamodb";
import { NewsletterIssueGist } from "models/newsletter-gist";

const dynamoDbClient = new DynamoDBClient({});

const addNewItemToFeed = async (feedId: string, newsletterIssueGist: NewsletterIssueGist) => {
    try {
        await dynamoDbClient.send(
            new PutItemCommand({
                TableName: process.env.FEEDS_TABLE_NAME,
                Item: {
                    feedId: { S: feedId },
                    date: { S: newsletterIssueGist.date.toISOString() },
                    content: { S: JSON.stringify(newsletterIssueGist) },
                },
            })
        );
    } catch (error) {
        console.error("Error adding item to feed:", error);
        throw error;
    }
};

async function* getFeedItems(feedId: string) {
    const params: QueryCommandInput = {
        TableName: process.env.FEEDS_TABLE_NAME,
        KeyConditionExpression: "feedId = :feedId",
        ExpressionAttributeValues: {
            ":feedId": { S: feedId },
        },
        Limit: 25,
        ExclusiveStartKey: undefined,
    };

    let lastEvaluatedKey = undefined;

    try {
        do {
            if (lastEvaluatedKey) {
                params.ExclusiveStartKey = lastEvaluatedKey;
            }

            const data = await dynamoDbClient.send(new QueryCommand(params));

            if (data.Items) {
                yield data.Items.map((item) => ({
                    feedId: item.feedId.S!,
                    date: item.date.S!,
                    content: JSON.parse(item.content.S!) as NewsletterIssueGist,
                }));
            }

            lastEvaluatedKey = data.LastEvaluatedKey;
        } while (lastEvaluatedKey);
    } catch (error) {
        console.error("Error getting feed items:", error);
        throw error;
    }
}

export { addNewItemToFeed, getFeedItems };
