import CompletedNovel from '../../models/CompletedNovels';
import { fetchCompletedNovels } from './fetch_completed_novels';

const BASE_URL = 'https://novelfull.net';

export async function updateCompletedNovels() {
    const completedNovelsUrl = `${BASE_URL}/completed-novel`;
    try {
        const novels = await fetchCompletedNovels(completedNovelsUrl);
        const operationResults = [];
        
        for (const novel of novels) {
            console.log(`Processing novel: ${novel.title}`);
            const result = await CompletedNovel.findOneAndUpdate(
                { novelUrl: novel.novelUrl },
                novel,
                {
                    new: true, 
                    upsert: true,
                    runValidators: true,
                    setDefaultsOnInsert: true
                }
            );
            console.log(`Result for novel: ${novel.title}`, result);
            operationResults.push(result);
        }
        console.log('Completed novels processed in database', operationResults.length);
        // Depending on how you want to use this function, you may or may not need a return value
        return operationResults; 
    } catch (error) {
        const message = error instanceof Error ? error.message : 'An unknown error occurred';
        console.error('Error:', message);
        throw error; // Rethrowing the error so it can be logged or handled wherever this function is called
    }
}
