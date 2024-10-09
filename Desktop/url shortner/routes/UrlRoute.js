const express = require('express');
const router = express.Router();
const shortid = require('shortid');
const Url = require('../models/Url');

// POST /shorten - Shorten a URL
router.post('/shorten', async (req, res) => {
    const { originalUrl } = req.body;

    if (!originalUrl) {
        return res.status(400).json({ error: 'Original URL is required' });
    }

    try {
        const shortUrl = shortid.generate();
        const url = new Url({ originalUrl, shortUrl });
        await url.save();

        return res.json({ shortUrl: `http://localhost:3000/${shortUrl}` });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: 'Server error' });
    }
});

// GET /:shortUrl - Redirect to the original URL
router.get('/:shortUrl', async (req, res) => {
    try {
        const { shortUrl } = req.params;
        const url = await Url.findOne({ shortUrl });

        if (!url) {
            return res.status(404).json({ error: 'No URL found' });
        }

        return res.redirect(url.originalUrl);
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: 'Server error' });
    }
});

module.exports = router;



