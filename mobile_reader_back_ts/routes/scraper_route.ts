import express, { Request, Response } from 'express';
import axios from 'axios';
import cheerio from 'cheerio';
import { NovelDetails } from '../types/novelDetails.interface';
import { Chapter } from '../types/chapter.interface';
import { NovelInfo } from '../types/novelInfo.interface';
import { CompletedNovelDetails } from '../types/completedNovelDetails.interface';

const router = express.Router();

const BASE_URL = 'https://novelfull.net';

// Route to fetch chapters list
router.get('/chapters', async (req: Request, res: Response) => {
    const novelUrl = req.query.novelUrl as string;

    if (!novelUrl) {
        return res.status(400).json({ message: 'Novel URL is required' });
    }

    try {
        let novelInfo: NovelInfo = await fetchChapters(novelUrl);
        res.json(novelInfo);
    } catch (error) {
        const message = error instanceof Error ? error.message : 'An unknown error occurred';
        res.status(500).json({ message });
    }
});

async function fetchChapters(initialUrl: string): Promise<NovelInfo> {
    let novelInfo: NovelInfo = { chapters: [] };
    let currentPageUrl = initialUrl;
    let hasNextPage = true;

    const initialPageResponse = await axios.get(currentPageUrl);
    const $ = cheerio.load(initialPageResponse.data);

    novelInfo.title = $('h3.title').first().text().trim();
    novelInfo.author = $('div.info > div').first().find('a').map((i, el) => $(el).text().trim()).get().join(', ');
    novelInfo.description = $('div.desc-text').first().text().trim();
    novelInfo.coverUrl = BASE_URL + $('div.book img').attr('src');

    while (hasNextPage) {
        const { data } = await axios.get(currentPageUrl);
        const $ = cheerio.load(data);

        $('ul.list-chapter li').each((i, elem) => {
            const chapter: Chapter = {
                title: $(elem).find('a').attr('title') || '',
                link: BASE_URL + ($(elem).find('a').attr('href') || ''),
            };
            novelInfo.chapters.push(chapter);
        });

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
router.get('/chapter-content', async (req: Request, res: Response) => {
    const chapterUrl = req.query.chapterUrl as string;
    if (!chapterUrl) {
        return res.status(400).json({ message: 'Chapter URL is required' });
    }

    try {
        const content = await fetchChapterContent(chapterUrl);
        res.json({ content });
    } catch (error) {
        const message = error instanceof Error ? error.message : 'An unknown error occurred';
        res.status(500).json({ message });
    }
});

async function fetchChapterContent(url: string): Promise<string> {
    const { data } = await axios.get(url);
    const $ = cheerio.load(data);

    $('#chapter-content script, #chapter-content .ads, #chapter-content div[id^="pf-"]').remove();
    $('#chapter-content p').each(function () {
        if ($(this).text().trim() === '') {
            $(this).remove();
        }
    });

    let contentHtml = $('#chapter-content').html() || '';
    contentHtml = contentHtml
        .replace(/\t/g, '')
        .replace(/\\+/g, '')
        .replace(/\"(.*?)\"/g, '<i>$1</i>')
        .replace(/\s{2,}/g, ' ');

    return contentHtml;
}

// Route to search novels
router.get('/search', async (req: Request, res: Response) => {
    const keyword = req.query.keyword as string;

    if (!keyword) {
        return res.status(400).json({ message: 'Search keyword is required' });
    }

    const searchUrl = `${BASE_URL}/search?keyword=${encodeURIComponent(keyword)}`;

    try {
        const novels = await fetchSearchResults(searchUrl);
        res.json(novels);
    } catch (error) {
        const message = error instanceof Error ? error.message : 'An unknown error occurred';
        res.status(500).json({ message });
    }
});

async function fetchSearchResults(url: string) {
    const { data } = await axios.get(url);
    const $ = cheerio.load(data);

    let novels: Array<{ imageUrl: string; title: string; novelUrl: string }> = [];

    $('.list-truyen .row').each((index, element) => {
        const imageUrlSuffix = $(element).find('img.cover').attr('src') || '';
        const title = $(element).find('h3.truyen-title a').text().trim();
        const novelUrlSuffix = $(element).find('h3.truyen-title a').attr('href') || '';

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

router.get('/completed-novels', async (req: Request, res: Response) => {
    const completedNovelsUrl = `${BASE_URL}/completed-novel`;

    try {
        const novels = await fetchCompletedNovels(completedNovelsUrl);
        res.json(novels);
    } catch (error) {
        const message = error instanceof Error ? error.message : 'An unknown error occurred';
        res.status(500).json({ message });
    }
});

async function fetchCompletedNovels(baseUrl: string) {
    let currentPageUrl = baseUrl;
    let hasNextPage = true;
    let novels: Array<CompletedNovelDetails> = [];

    while (hasNextPage) {
        const { data } = await axios.get(currentPageUrl);
        const $ = cheerio.load(data);

        $('.list.list-truyen.col-xs-12 .row').each((index, element) => {
            const imageUrlSuffix = $(element).find('.col-xs-3 img.cover').attr('src') || '';
            const title = $(element).find('.col-xs-7 h3.truyen-title a').text().trim();
            const novelUrlSuffix = $(element).find('.col-xs-7 h3.truyen-title a').attr('href') || '';
            const chapterCountText = $(element).find('.col-xs-2.text-info .chapter-text b').text().trim();
            const chapterCount = parseInt(chapterCountText, 10) || 0;

            if (!imageUrlSuffix || !title || !novelUrlSuffix || isNaN(chapterCount) || chapterCount < 500) {
                return;
            }

            const imageUrl = BASE_URL + imageUrlSuffix;
            const novelUrl = BASE_URL + novelUrlSuffix;

            novels.push({ imageUrl, title, novelUrl, chapterCount });
        });

        // Find the next page link. If it doesn't exist, set hasNextPage to false.
        const nextPageLink = $('.pagination.pagination-sm li.next a').attr('href');
        if (nextPageLink) {
            currentPageUrl = BASE_URL + nextPageLink;
        } else {
            hasNextPage = false;
        }
    }

    // Sort novels by chapterCount in descending order
    novels.sort((a, b) => b.chapterCount - a.chapterCount);

    return novels;
}

export default router;