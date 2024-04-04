import cron from 'node-cron';
import { updateCompletedNovels } from '../methods/completed_novels/update_completed_novels';

export function setupDailyTasks() {
    cron.schedule('0 0 * * *', async () => {
        console.log('Running the daily update of completed novels at midnight');
        try {
            await updateCompletedNovels();
        } catch (error) {
            console.error('Failed to update completed novels:', error);
        }
    });
}
