import axios from "axios";
import cheerio from 'cheerio';
import { CompletedNovelDetails } from "../../types/completedNovelDetails.interface";

const BASE_URL = 'https://novelfull.net';

export async function fetchCompletedNovels(baseUrl: string) {
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