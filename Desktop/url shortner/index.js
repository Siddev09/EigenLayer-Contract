const express = require('express');
const mongoose = require('mongoose');
const urlRoutes = require('./routes/UrlRoute');

const app = express();

// Middleware to parse JSON
app.use(express.json());

// MongoDB connection
mongoose.connect('mongodb://localhost:27017/urlShortener').then(() => console.log('MongoDB connected'))
    .catch((err) => console.error('MongoDB connection error', err));

// Use URL routes
app.use('/', urlRoutes);

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});


