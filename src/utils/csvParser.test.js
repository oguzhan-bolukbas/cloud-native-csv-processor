const { parseCsvLine } = require('../../src/utils/csvParser');

describe('parseCsvLine()', () => {
  it('parses a valid quoted CSV line into an object', () => {
    const line = '"211627629","Purple Safi Kaftan","4900.0000"';
    const result = parseCsvLine(line);
    expect(result).toEqual({
      product_id: '211627629',
      product_name: 'Purple Safi Kaftan',
      price: '4900.0000',
    });
  });

  it('returns null for empty lines', () => {
    expect(parseCsvLine('')).toBeNull();
    expect(parseCsvLine('   ')).toBeNull();
  });

  it('handles extra commas inside quoted fields', () => {
    const line = '"999","Shirt, Blue","199.99"';
    const result = parseCsvLine(line);
    expect(result).toEqual({
      product_id: '999',
      product_name: 'Shirt, Blue',
      price: '199.99',
    });
  });
});
