// user_novel_routes.js
const express = require('express');
const User = require('../models/User');
const checkAuth = require('../middleware/checkAuth');

const router = express.Router();

// Route to add a novel to the user's list
router.post('/user/addNovel', checkAuth, async (req, res) => {
    const userId = req.userId; // Assuming userId is extracted from the token by checkAuth middleware
    const { novelDetails } = req.body;

    const { novelTitle, description, coverUrl, author, numberOfChapters, chaptersDetails } = novelDetails;

    try {
        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        const novelExists = user.novels.some(novel => novel.novelTitle === novelTitle);
        if (!novelExists) {
            const novel = {
                novelTitle,
                author,
                coverUrl,
                description,
                numberOfChapters,
                chaptersDetails,
                lastReadChapter: 0,
                lastReadAt: Date.now(),
                chaptersRead: []
            };
            user.novels.push(novel);
            await user.save();
            res.status(200).json({ message: 'Novel added successfully', novel, novelAdded: true });
        } else {
            res.status(200).json({ message: 'Novel already exists', novelTitle, novelAdded: false });
        }
    } catch (error) {
        console.error('Error adding novel to user:', error);
        res.status(500).json({ message: 'Error adding novel to user', error: error.message });
    }
});

// Route to update the isFavorite status of a novel
router.patch('/user/updateFavoriteStatus', checkAuth, async (req, res) => {
    const userId = req.userId; // Assuming userId is extracted from the token by checkAuth middleware
    const { novelTitle, isFavorite } = req.body; // Extract novelTitle and isFavorite status from request body

    try {
        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Find the novel in the user's novels list and update its isFavorite status
        const novelIndex = user.novels.findIndex(novel => novel.novelTitle === novelTitle);
        if (novelIndex !== -1) {
            user.novels[novelIndex].isFavorite = isFavorite;
            await user.save();
            res.status(200).json({ message: 'Novel favorite status updated successfully', novelTitle, isFavorite });
        } else {
            res.status(404).json({ message: 'Novel not found in user list', novelTitle });
        }
    } catch (error) {
        console.error('Error updating novel favorite status:', error);
        res.status(500).json({ message: 'Error updating novel favorite status', error: error.message });
    }
});

// Route to update the last read chapter and lastReadAt date for a novel
router.patch('/user/updateLastRead', checkAuth, async (req, res) => {
    const userId = req.userId; // Assuming userId is extracted from the token by checkAuth middleware
    const { novelTitle, lastReadChapter } = req.body; // Extract novelTitle and lastReadChapter from request body

    try {
        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Find the novel in the user's novels list and update lastReadChapter and lastReadAt
        const novelIndex = user.novels.findIndex(novel => novel.novelTitle === novelTitle);
        if (novelIndex !== -1) {
            user.novels[novelIndex].lastReadChapter = lastReadChapter;
            user.novels[novelIndex].lastReadAt = Date.now();
            await user.save();
            res.status(200).json({ message: 'Novel last read updated successfully', novelTitle, lastReadChapter });
        } else {
            res.status(404).json({ message: 'Novel not found in user list', novelTitle });
        }
    } catch (error) {
        console.error('Error updating novel last read:', error);
        res.status(500).json({ message: 'Error updating novel last read', error: error.message });
    }
});

// Route to add a chapter to the chaptersRead list or update an existing one
router.post('/user/addChapterRead', checkAuth, async (req, res) => {
    const userId = req.userId; // Assuming userId is extracted from the token by checkAuth middleware
    const { novelTitle, chapter } = req.body; // Extracting details from request body

    try {
        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Find the novel by title
        const novelIndex = user.novels.findIndex(n => n.novelTitle === novelTitle);
        if (novelIndex === -1) {
            return res.status(404).json({ message: 'Novel not found in user list', novelTitle });
        }

        const novel = user.novels[novelIndex];
        const chapterIndex = novel.chaptersRead.findIndex(c => c.chapter === chapter);

        if (chapterIndex !== -1) {
            // Chapter exists, update readAt
            novel.chaptersRead[chapterIndex].readAt = Date.now();
        } else {
            // Chapter does not exist, add new
            novel.chaptersRead.push({
                chapter,
                readAt: Date.now() // Default to current time
            });
        }

        await user.save();
        res.status(200).json({ message: 'Chapter read updated successfully', novelTitle, chapter });
    } catch (error) {
        console.error('Error adding/updating chapter to/in chaptersRead:', error);
        res.status(500).json({ message: 'Error adding/updating chapter to/in chaptersRead', error: error.message });
    }
});

// Route to remove a chapter from the chaptersRead list of a novel
router.delete('/user/removeChapterRead', checkAuth, async (req, res) => {
    const userId = req.userId; // Assuming userId is extracted from the token by checkAuth middleware
    const { novelTitle, chapter } = req.body; // Extracting details from request body

    try {
        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Find the novel by title
        const novel = user.novels.find(n => n.novelTitle === novelTitle);
        if (novel) {
            // Filter out the chapter to be removed
            const initialLength = novel.chaptersRead.length;
            novel.chaptersRead = novel.chaptersRead.filter(c => c.chapter !== chapter);
            if (initialLength === novel.chaptersRead.length) {
                // If the lengths are equal, no chapter was removed
                return res.status(404).json({ message: 'Chapter not found in chaptersRead', novelTitle, chapter });
            }

            await user.save();
            res.status(200).json({ message: 'Chapter removed from chaptersRead successfully', novelTitle, chapter });
        } else {
            res.status(404).json({ message: 'Novel not found in user list', novelTitle });
        }
    } catch (error) {
        console.error('Error removing chapter from chaptersRead:', error);
        res.status(500).json({ message: 'Error removing chapter from chaptersRead', error: error.message });
    }
});

// Route to add or update a novel in the user's history, ensuring the most recently read novel is first
router.post('/user/addOrUpdateHistory', checkAuth, async (req, res) => {
    const userId = req.userId; // Assuming userId is extracted from the token by checkAuth middleware
    const { novelTitle } = req.body; // Now we are only expecting novelTitle in the request body

    try {
        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Attempt to find the novel in the user's existing novels list by title
        const novel = user.novels.find(n => n.novelTitle === novelTitle);
        if (novel) {
            // If the novel exists in the user's list, prepare the history entry
            const historyEntry = {
                novelTitle: novel.novelTitle,
                author: novel.author,
                coverUrl: novel.coverUrl,
                description: novel.description,
                numberOfChapters: novel.numberOfChapters,
                lastReadChapter: novel.lastReadChapter,
                lastReadAt: Date.now(), // Update lastReadAt to current time
            };

            // Check if the novel already exists in the history
            const existingIndex = user.history.findIndex(n => n.novelTitle === novelTitle);
            if (existingIndex !== -1) {
                // Remove the existing entry
                user.history.splice(existingIndex, 1);
            }

            // Add the updated entry to the beginning of the history
            user.history.unshift(historyEntry);
        } else {
            // Novel not found in the user's novels list
            return res.status(404).json({ message: 'Novel not found in user list' });
        }

        await user.save();
        console.log('User novel history updated');
        res.status(200).json({ message: 'History updated successfully' });
    } catch (error) {
        console.error('Error updating user history:', error);
        res.status(500).json({ message: 'Error updating user history', error: error.message });
    }
});

module.exports = router;