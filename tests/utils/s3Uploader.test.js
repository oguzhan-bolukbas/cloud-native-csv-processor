jest.mock('@aws-sdk/client-s3', () => {
  return {
    S3Client: jest.fn(() => ({
      send: jest.fn().mockResolvedValue({}),
    })),
    PutObjectCommand: jest.fn(),
  };
});

const { uploadFileToS3 } = require('../../src/utils/s3Uploader');
const path = require('path');

describe('uploadFileToS3', () => {
  it('uploads file to S3 and returns metadata', async () => {
    const result = await uploadFileToS3(
      path.join(__dirname, '../test-data.csv'),
      'test.csv'
    );
    expect(result).toHaveProperty('Bucket');
    expect(result).toHaveProperty('Key');
    expect(result).toHaveProperty('Location');
  });
});
