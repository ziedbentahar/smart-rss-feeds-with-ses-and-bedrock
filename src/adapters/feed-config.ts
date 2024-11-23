import { DynamoDBClient, GetItemCommand, PutItemCommand, QueryCommand } from "@aws-sdk/client-dynamodb";
import { FeedConfig } from "models/feed-configuration";

const dynamoDbClient = new DynamoDBClient({});

const updateFeedConfiguration = async (feedId: string, config: FeedConfig) => {
    try {
        await dynamoDbClient.send(
            new PutItemCommand({
                TableName: process.env.FEED_CONFIG_TABLE_NAME,
                Item: {
                    feedId: { S: feedId },
                    config: { S: JSON.stringify(config) },
                },
            })
        );
    } catch (error) {
        console.error(`Error adding feed config ${feedId}:`, error);
        throw error;
    }
};

const getFeedConfiguration = async (feedId: string): Promise<FeedConfig | null> => {
    try {
        const data = await dynamoDbClient.send(
            new GetItemCommand({
                TableName: process.env.FEED_CONFIG_TABLE_NAME,
                Key: {
                    feedId: { S: feedId },
                },
            })
        );

        if (data.Item && data.Item.config?.S) {
            return JSON.parse(data.Item.config.S) as FeedConfig;
        } else {
            return null;
        }
    } catch (error) {
        console.error(`Error getting feed ${feedId}:`, error);
        throw error;
    }
};

const getFeedConfigurationsBySenderEmail = async (
    senderEmail: string
): Promise<{ feedId: string; config: FeedConfig }[]> => {
    try {
        const data = await dynamoDbClient.send(
            new QueryCommand({
                TableName: process.env.FEED_CONFIG_TABLE_NAME,
                IndexName: process.env.SENDER_EMAIL_GSI,
                KeyConditionExpression: "senderEmail = :senderEmail",
                ExpressionAttributeValues: {
                    ":senderEmail": { S: senderEmail },
                },
            })
        );

        if (data.Items) {
            return data.Items.map((item) => {
                return { feedId: item.feedId.S!, config: JSON.parse(item.config.S!) as FeedConfig };
            });
        } else {
            return [];
        }
    } catch (error) {
        console.error(`Error getting feeds config from senderEmail ${senderEmail}:`, error);
        throw error;
    }
};

export { updateFeedConfiguration, getFeedConfiguration, getFeedConfigurationsBySenderEmail };
