import { S3Client, GetObjectCommand } from "@aws-sdk/client-s3";

const s3Client = new S3Client({});

const getRawEmailContent = async (key: string) => {
    const command = new GetObjectCommand({
        Bucket: process.env.EMAILS_BUCKET,
        Key: key,
    });
    const response = await s3Client.send(command);
    const content = await response.Body?.transformToString("utf-8");
    return content;
};

export { getRawEmailContent };
