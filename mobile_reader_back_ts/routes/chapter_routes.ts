import express, { Request, Response } from 'express';
import User from '../models/User';
import checkAuth from '../middleware/checkAuth';
import { IUser } from '../types/user.interface';
import { ChapterRead } from '../types/chapterRead.interface';

const router = express.Router();

// Route to update the last read chapter of a novel
router.patch('/user/updateLastRead', checkAuth, async (req: Request, res: Response) => {
    const userId = req.userId;
    const { novelTitle, lastReadChapter } = req.body;

    if (!userId) {
        return res.status(401).send({ message: 'Unauthorized' });
    }

    try {
        const user = await User.findById(userId) as IUser;
        if (!user) {
            return res.status(404).send({ message: 'User not found' });
        }

        const novelIndex = user.novels.findIndex(novel => novel.novelTitle === novelTitle);
        if (novelIndex !== -1) {
            user.novels[novelIndex].lastReadChapter = lastReadChapter;
            user.novels[novelIndex].lastReadAt = new Date();
            await user.save();
            res.status(200).send({ message: 'Novel last read updated successfully' });
        } else {
            res.status(404).send({ message: 'Novel not found' });
        }
    } catch (error) {
        console.error('Error updating novel last read:', error);
        res.status(500).send({ message: 'Error updating novel last read', error: error instanceof Error ? error.message : 'Unknown error' });
    }
});

// Route to add a chapter to the chaptersRead list or update an existing one
router.post('/user/addChapterRead', checkAuth, async (req: Request, res: Response) => {
    const userId = req.userId;
    const { novelTitle, chapter, readAt } = req.body;

    if (!userId) {
        return res.status(401).send({ message: 'Unauthorized' });
    }

    try {
        const user = await User.findById(userId) as IUser;
        if (!user) {
            return res.status(404).send({ message: 'User not found' });
        }

        const novel = user.novels.find(n => n.novelTitle === novelTitle);
        if (!novel) {
            return res.status(404).send({ message: 'Novel not found' });
        }
        else {
            const chapterIndex = novel.chaptersRead.findIndex(c => c.chapter === chapter);

            if (chapterIndex !== -1) {
                // Chapter exists, update
                novel.chaptersRead[chapterIndex].readAt = new Date();
            }
            else {
                const chapterRead: ChapterRead = {
                    chapter,
                    readAt: readAt ? new Date(readAt) : new Date(),
                };
        
                novel.chaptersRead.push(chapterRead);
            }
        }

        await user.save();
        res.status(200).send({ message: 'Chapter read added successfully' });
    } catch (error) {
        console.error('Error adding chapter read:', error);
        res.status(500).send({ message: 'Error adding chapter read', error: error instanceof Error ? error.message : 'Unknown error' });
    }
});

// Route to remove a chapter read from a novel
router.delete('/user/removeChapterRead', checkAuth, async (req: Request, res: Response) => {
    const userId = req.userId;
    const { novelTitle, chapter } = req.body;

    if (!userId) {
        return res.status(401).send({ message: 'Unauthorized' });
    }

    try {
        const user = await User.findById(userId) as IUser;
        if (!user) {
            return res.status(404).send({ message: 'User not found' });
        }

        const novel = user.novels.find(n => n.novelTitle === novelTitle);
        if (!novel) {
            return res.status(404).send({ message: 'Novel not found' });
        }

        const index = novel.chaptersRead.findIndex(c => c.chapter === chapter);
        if (index === -1) {
            return res.status(404).send({ message: 'Chapter read not found' });
        }

        novel.chaptersRead.splice(index, 1);
        await user.save();
        res.status(200).send({ message: 'Chapter read removed successfully' });
    } catch (error) {
        console.error('Error removing chapter read:', error);
        res.status(500).send({ message: 'Error removing chapter read', error: error instanceof Error ? error.message : 'Unknown error' });
    }
});

export default router;