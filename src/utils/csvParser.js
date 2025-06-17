exports.parseCsvLine = (line) => {
  if (!line || !line.trim()) return null;

  const [id, name, price] = line.split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/);

  return {
    product_id: id.replace(/"/g, ''),
    product_name: name.replace(/"/g, ''),
    price: price.replace(/"/g, ''),
  };
};
