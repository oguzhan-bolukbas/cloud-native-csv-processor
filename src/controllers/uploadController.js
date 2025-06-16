const fs = require('fs');
const readline = require('readline');
const path = require('path');

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
    if (!line.trim()) continue; // skip empty lines
    const [id, name, price] = line.split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/); // split by comma not inside quotes
    
    rows.push({
        product_id: id.replace(/"/g, ''),
        product_name: name.replace(/"/g, ''),
        price: price.replace(/"/g, ''),
    });
    }

    res.status(200).json({ rows });

  } catch (err) {
    console.error('CSV parsing error:', err);
    res.status(500).send('Failed to read CSV file.');
  }
};
