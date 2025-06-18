const fs = require('fs');
const readline = require('readline');
const path = require('path');
const { parseCsvLine } = require('../utils/csvParser');
const { uploadFileToS3 } = require('../utils/s3Uploader');


exports.parseCsv = async (req, res) => {
  if (!req.file) {
    return res.status(400).send('No file uploaded.');
  }

  const filePath = path.resolve(req.file.path);
  const rows = [];

  // CSV parsing
  try {
    const rl = readline.createInterface({
      input: fs.createReadStream(filePath),
      crlfDelay: Infinity,
    });

    for await (const line of rl) {
      const parsed = parseCsvLine(line);
      if (parsed) {
        rows.push(parsed);
      }
    }
  } catch (err) {
    console.error('CSV parsing error:', err);
    return res.status(500).json({
      error: 'Failed to read or parse CSV file',
      details: err && err.message ? err.message : err
    });
  }

  // S3 upload
  try {
    const s3Result = await uploadFileToS3(filePath, req.file.originalname);
    res.status(200).json({
      rows,
      uploaded_to_s3: {
        bucket: s3Result.Bucket,
        key: s3Result.Key,
        location: s3Result.Location,
      },
    });
  } catch (err) {
    console.error('S3 upload error:', err);
    res.status(500).json({
      error: 'Failed to upload file to S3',
      details: err && err.message ? err.message : err
    });
  }
};
