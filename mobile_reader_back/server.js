// server.js
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const path = require('path');
const checkAuth = require('./middleware/checkAuth');
const userRoutes = require('./routes/userRoutes');
const scraperRoutes = require('./routes/scraper_route');

const app = express();
const PORT = process.env.PORT || 3000;

// Load environment variables from .env file
require('dotenv').config();
const dbURI = process.env.MONGO_URI;
const APP_URL = process.env.APP_URL;

mongoose.connect(dbURI)
    .then(() => console.log('Connected to MongoDB'))
    .catch(err => console.error('Could not connect to MongoDB', err));

app.use(cors());
app.use(express.json());

app.use('/images', express.static(path.join(__dirname, 'images')));

app.use('/', userRoutes);
app.use('/api', scraperRoutes);

app.listen(PORT, '0.0.0.0', function () {
    console.log(`Server is running on ${APP_URL}${PORT}`);
}
);