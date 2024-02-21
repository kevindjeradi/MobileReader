import express, { Request, Response } from 'express';
import User from '../models/User';
import checkAuth from '../middleware/checkAuth';
import { IUser } from '../types/user.interface';
import { NovelDetails } from '../types/novelDetails.interface';
import { IHistory } from '../types/history.interface';

const router = express.Router();

// Route to add a novel to the user's list
router.post('/user/addNovel', checkAuth, async (req: Request, res: Response) => {
    const userId = req.userId;
    const novelDetails: NovelDetails = req.body.novelDetails;

    if (!userId) {
        return res.status(401).send({ message: 'Unauthorized' });
    }

    try {
        const user = await User.findById(userId) as IUser;
        if (!user) {
            return res.status(404).send({ message: 'User not found' });
        }

        const novelExists = user.novels.some(novel => novel.novelTitle === novelDetails.title);
        if (novelExists) {
            console.log('Novel already exists');
            return res.status(200).json({ message: 'Novel already exists', title: novelDetails.title, novelAdded: false });

        }

        console.log('Adding novel to user');
        const novel = {
            novelTitle: novelDetails.title || '',
            author: novelDetails.author || '',
            coverUrl: novelDetails.coverUrl || '',
            description: novelDetails.description || '',
            isFavorite: false,
            numberOfChapters: novelDetails.numberOfChapters || 0,
            chaptersDetails: novelDetails.chaptersDetails,
            lastReadChapter: 0,
            lastReadAt: new Date(),
            chaptersRead: []
        }
        user.novels.push(novel);
        await user.save();
        console.log('Novel added successfully');
        res.status(200).json({ message: 'Novel added successfully', novel, novelAdded: true });
    } catch (error) {
        console.error('Error adding novel to user:', error);
        res.status(500).send({ message: 'Error adding novel to user', error: error instanceof Error ? error.message : 'Unknown error' });
    }
});

// Route to update the favorite status of a novel
router.patch('/user/updateFavoriteStatus', checkAuth, async (req: Request, res: Response) => {
    const userId = req.userId;
    const { novelTitle, isFavorite } = req.body;

    if (!userId) {
        return res.status(401).send({ message: 'Unauthorized' });
    }

    try {
        const user = await User.findById(userId) as IUser;
        if (!user) {
            return res.status(404).send({ message: 'User not found' });
        }

        const novel = user.novels.find(novel => novel.novelTitle === novelTitle);
        if (novel) {
            novel.isFavorite = isFavorite;
            await user.save();
            res.status(200).send({ message: 'Novel favorite status updated successfully' });
        } else {
            res.status(404).send({ message: 'Novel not found' });
        }
    } catch (error) {
        console.error('Error updating novel favorite status:', error);
        res.status(500).send({ message: 'Error updating novel favorite status', error: error instanceof Error ? error.message : 'Unknown error' });
    }
});

// Route to add or update a novel in the user's history, ensuring the most recently read novel is first
router.post('/user/addOrUpdateHistory', checkAuth, async (req: Request, res: Response) => {
    const userId = req.userId;
    const { novelTitle } = req.body;

    if (!userId) {
        return res.status(401).json({ message: 'Unauthorized' });
    }

    try {
        const user = await User.findById(userId) as IUser | null;
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Find the novel in the user's novels list by title
        const novel = user.novels.find(n => n.novelTitle === novelTitle);
        if (novel) {
            // Prepare the history entry using the details from the found novel
            const historyEntry: IHistory = {
                novelTitle: novel.novelTitle,
                author: novel.author,
                coverUrl: novel.coverUrl,
                description: novel.description,
                isFavorite: novel.isFavorite,
                numberOfChapters: novel.numberOfChapters,
                lastReadChapter: novel.lastReadChapter,
                lastReadAt: new Date(),
                chaptersRead: novel.chaptersRead,
            };

            // Check if the novel already exists in the history
            const existingIndex = user.history.findIndex(h => h.novelTitle === novelTitle);
            if (existingIndex !== -1) {
                // Remove the existing entry
                user.history.splice(existingIndex, 1);
            }

            // Add the updated entry to the beginning of the history
            user.history.unshift(historyEntry);

            await user.save();
            res.status(200).json({ message: 'History updated successfully' });
        } else {
            // Novel not found in the user's novels list
            return res.status(404).json({ message: 'Novel not found in user list' });
        }
    } catch (error) {
        console.error('Error updating user history:', error);
        res.status(500).json({ message: 'Error updating user history', error: error instanceof Error ? error.message : 'Unknown error' });
    }
});

export default router;