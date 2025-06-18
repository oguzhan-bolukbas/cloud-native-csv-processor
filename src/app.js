require('dotenv').config();
const express = require('express');
const path = require('path');
const uploadRoutes = require('./routes/upload');

const app = express();
const port = process.env.PORT || 3000;

app.use(express.static(path.join(__dirname, 'public'))); // Serve HTML
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use('/uploads', express.static('src/uploads')); // serve uploaded files
app.use('/api', uploadRoutes);

const server = app.listen(port, () => {
  console.log(`🚀 Server running at http://localhost:${port}`);
});

module.exports = { app, server };
