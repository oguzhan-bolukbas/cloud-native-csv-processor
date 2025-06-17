exports.parseCsvLine = (line) => {
  if (!line || !line.trim()) return null;

  // Split on commas not enclosed in quotes (handles fields with commas inside quotes)
  const [id, name, price] = line.split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/);

  return {
    product_id: id.replace(/"/g, ''),
    product_name: name.replace(/"/g, ''),
    price: price.replace(/"/g, ''),
  };
};
