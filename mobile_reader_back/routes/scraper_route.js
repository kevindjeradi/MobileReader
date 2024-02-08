// scraper_route.js
const express = require('express');
const axios = require('axios');
const cheerio = require('cheerio');
const router = express.Router();

const BASE_URL = 'https://novelfull.net';

// Route to fetch chapters list
router.get('/chapters', async (req, res) => {
    // Accept novelUrl from query parameters instead of hardcoding
    const novelUrl = req.query.novelUrl;

    // const novelUrl = `${BASE_URL}/library-of-heavens-path.html`;

    // Validate the input to ensure a URL has been provided
    if (!novelUrl) {
        return res.status(400).json({ message: 'Novel URL is required' });
    }

    try {
        let chapters = await fetchChapters(novelUrl);
        res.json(chapters);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

async function fetchChapters(initialUrl) {
    let chapters = [];
    let currentPageUrl = initialUrl;
    let hasNextPage = true;

    while (hasNextPage) {
        const { data } = await axios.get(currentPageUrl);
        const $ = cheerio.load(data);

        $('ul.list-chapter li').each((i, elem) => {
            const chapter = {
                title: $(elem).find('a').attr('title'),
                link: BASE_URL + $(elem).find('a').attr('href'),
            };
            chapters.push(chapter);
        });

        // Check for the next page. Adjust the selector as needed based on the site's structure.
        const nextPageLink = $('.pagination.pagination-sm li.next a').attr('href');
        if (nextPageLink) {
            currentPageUrl = BASE_URL + nextPageLink;
        } else {
            hasNextPage = false;
        }
    }

    return chapters;
}

// Route to fetch chapter content
router.get('/chapter-content', async (req, res) => {
    const { chapterUrl } = req.query; // Expecting a query parameter for the chapter URL
    if (!chapterUrl) {
        return res.status(400).json({ message: 'Chapter URL is required' });
    }

    try {
        const content = await fetchChapterContent(chapterUrl);
        res.json({ content });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

async function fetchChapterContent(url) {
    const { data } = await axios.get(url);
    const $ = cheerio.load(data);

    $('#chapter-content script, #chapter-content .ads, #chapter-content any-other-selector').remove();

    let contentHtml = $('#chapter-content').html();

    contentHtml = contentHtml
        .replace(/\t/g, '') // Remove all tab characters
        .replace(/\\+/g, '') // Remove backslashes, adjust regex as needed for your case
        .replace(/\"(.*?)\"/g, '<i>$1</i>') // Replace escaped quotes with <i>
        .replace(/\s{2,}/g, ' '); // Replace multiple whitespace characters with a single space

    return contentHtml;
}

module.exports = router;
