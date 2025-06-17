const path = require('path');
const request = require('supertest');
const { app, server } = require('../src/app');

describe('POST /api/upload', () => {
  afterAll(() => {
    server.close();
  });

  it('should upload and parse a CSV file', async () => {
    const res = await request(app)
      .post('/api/upload')
      .attach('csvFile', path.join(__dirname, 'test-data.csv'));

    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('rows');
    expect(Array.isArray(res.body.rows)).toBe(true);
    expect(res.body.rows.length).toBeGreaterThan(0);

    const row = res.body.rows[0];
    expect(row).toHaveProperty('product_id');
    expect(row).toHaveProperty('product_name');
    expect(row).toHaveProperty('price');
  });

  it('should fail if no file is provided', async () => {
    const res = await request(app).post('/api/upload');
    expect(res.statusCode).toBe(400);
    expect(res.text).toContain('No file uploaded');
  });
});
