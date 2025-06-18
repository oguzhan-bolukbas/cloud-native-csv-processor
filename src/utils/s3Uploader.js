const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
const fs = require('fs');
const path = require('path');
const { v4: uuidv4 } = require('uuid');

const s3 = new S3Client({ region: process.env.AWS_REGION });

exports.uploadFileToS3 = async (localPath, originalName) => {
  const fileStream = fs.createReadStream(localPath);
  const filename = `uploads/${uuidv4()}-${originalName}`;

  const params = {
    Bucket: process.env.S3_BUCKET_NAME,
    Key: filename,
    Body: fileStream,
    ContentType: 'text/csv',
  };

  const command = new PutObjectCommand(params);
  await s3.send(command);

  return {
    Bucket: params.Bucket,
    Key: params.Key,
    Location: `https://${params.Bucket}.s3.amazonaws.com/${params.Key}`,
  };
};
