const fs = require('fs');
const readline = require('readline');
const path = require('path');
const { parseCsvLine } = require('../utils/csvParser');

exports.parseCsv = async (req, res) => {
  if (!req.file) {
    return res.status(400).send('No file uploaded.');
  }

  const filePath = path.resolve(req.file.path);
  const rows = [];

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

    res.status(200).json({ rows });
  } catch (err) {
    console.error('CSV parsing error:', err);
    res.status(500).send('Failed to read CSV file.');
  }
};
