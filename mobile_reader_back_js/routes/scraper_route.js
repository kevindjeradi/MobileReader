// scraper_route.js
const express = require('express');
const axios = require('axios');
const cheerio = require('cheerio');
const router = express.Router();

const BASE_URL = 'https://novelfull.net';

// Route to fetch chapters list
router.get('/chapters', async (req, res) => {
    const novelUrl = req.query.novelUrl;

    // const novelUrl = `${BASE_URL}/library-of-heavens-path.html`;

    // Validate the input to ensure a URL has been provided
    if (!novelUrl) {
        return res.status(400).json({ message: 'Novel URL is required' });
    }

    try {
        let novelInfo = await fetchChapters(novelUrl);
        res.json(novelInfo);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

async function fetchChapters(initialUrl) {
    let novelInfo = {};
    let currentPageUrl = initialUrl;
    let hasNextPage = true;

    novelInfo.chapters = [];

    // Fetch initial page content to initialize $
    const initialPageResponse = await axios.get(currentPageUrl);
    const $ = cheerio.load(initialPageResponse.data);

    // Extract novel title
    novelInfo.title = $('h3.title').first().text().trim();

    // Extract author(s)
    novelInfo.author = $('div.info > div').first().find('a').map((i, el) => $(el).text().trim()).get().join(', ');

    // Extract novel description
    novelInfo.description = $('div.desc-text').first().text().trim();

    // Extract cover URL
    novelInfo.coverUrl = BASE_URL + $('div.book img').attr('src');

    // Extract list of chapters and chapters links
    while (hasNextPage) {
        const { data } = await axios.get(currentPageUrl);
        const $ = cheerio.load(data);

        $('ul.list-chapter li').each((i, elem) => {
            const chapter = {
                title: $(elem).find('a').attr('title'),
                link: BASE_URL + $(elem).find('a').attr('href'),
            };
            novelInfo.chapters.push(chapter);
        });

        // Check for the next page.
        const nextPageLink = $('.pagination.pagination-sm li.next a').attr('href');
        if (nextPageLink) {
            currentPageUrl = BASE_URL + nextPageLink;
        } else {
            hasNextPage = false;
        }
    }

    return novelInfo;
}

// Route to fetch chapter content
router.get('/chapter-content', async (req, res) => {
    const { chapterUrl } = req.query;
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

    $('#chapter-content script, #chapter-content .ads, #chapter-content div[id^="pf-"]').remove();

    // Remove empty <p> tags
    $('#chapter-content p').each(function () {
        if ($(this).text().trim() === '') {
            $(this).remove();
        }
    });

    let contentHtml = $('#chapter-content').html();

    contentHtml = contentHtml
        .replace(/\t/g, '') // Remove all tab characters
        .replace(/\\+/g, '') // Remove backslashes
        .replace(/\"(.*?)\"/g, '<i>$1</i>') // Replace escaped quotes with <i>
        .replace(/\s{2,}/g, ' '); // Replace multiple whitespace characters with a single space

    return contentHtml;
}

// Route to search novels
router.get('/search', async (req, res) => {
    const { keyword } = req.query;

    if (!keyword) {
        return res.status(400).json({ message: 'Search keyword is required' });
    }

    const searchUrl = `${BASE_URL}/search?keyword=${encodeURIComponent(keyword)}`;

    try {
        const novels = await fetchSearchResults(searchUrl);
        res.json(novels);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

async function fetchSearchResults(url) {
    const { data } = await axios.get(url);
    const $ = cheerio.load(data);

    let novels = [];

    $('.list-truyen .row').each((index, element) => {
        const imageUrlSuffix = $(element).find('img.cover').attr('src');
        const title = $(element).find('h3.truyen-title a').text().trim();
        const novelUrlSuffix = $(element).find('h3.truyen-title a').attr('href');

        // Check if any of the crucial information is missing or undefined
        if (!imageUrlSuffix || !title || !novelUrlSuffix) {
            // Skip this entry if any crucial information is missing
            return;
        }

        const imageUrl = BASE_URL + imageUrlSuffix;
        const novelUrl = BASE_URL + novelUrlSuffix;

        novels.push({ imageUrl, title, novelUrl });
    });

    return novels;
}

module.exports = router;
