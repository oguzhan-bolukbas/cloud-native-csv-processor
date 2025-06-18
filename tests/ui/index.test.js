const request = require('supertest');
const { app, server } = require('../../src/app');

describe('GET / (HTML page)', () => {
  afterAll(() => server.close());

  it('should serve the index.html file', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toBe(200);
    expect(res.text).toContain('<h1>Upload CSV File</h1>');
  });
});
