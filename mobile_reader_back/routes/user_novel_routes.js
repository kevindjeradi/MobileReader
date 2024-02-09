// user_novel_routes.js
const express = require('express');
const User = require('../models/User');
const checkAuth = require('../middleware/checkAuth');

const router = express.Router();

// Route to add a novel to the user's list
router.post('/user/addNovel', checkAuth, async (req, res) => {
    const userId = req.userId; // Assuming userId is extracted from the token by checkAuth middleware
    const { novelTitle, description, numberOfChapters } = req.body;

    try {
        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        const novelExists = user.novels.some(novel => novel.novelTitle === novelTitle);
        if (!novelExists) {
            const novel = {
                novelTitle,
                description,
                numberOfChapters,
                lastReadChapter: 0,
                lastReadAt: Date.now(),
                chaptersRead: []
            };
            user.novels.push(novel);
            await user.save();
            res.status(200).json({ message: 'Novel added successfully', novel });
        } else {
            res.status(200).json({ message: 'Novel already exists', novelTitle });
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
            user.novels[novelIndex].lastReadAt = Date.now(); // Update lastReadAt to current time
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

// Route to add a chapter to the chaptersRead list of a novel
router.post('/user/addChapterRead', checkAuth, async (req, res) => {
    const userId = req.userId; // Assuming userId is extracted from the token by checkAuth middleware
    const { novelTitle, chapter, progress } = req.body; // Extracting details from request body

    try {
        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Find the novel by title
        const novel = user.novels.find(n => n.novelTitle === novelTitle);
        if (novel) {
            // Add the new chapter to chaptersRead, default readAt to now if not provided
            const newChapter = {
                chapter,
                progress,
                readAt: Date.now() // Default to current time
            };
            novel.chaptersRead.push(newChapter);
            await user.save();
            res.status(200).json({ message: 'Chapter added to chaptersRead successfully', novelTitle, newChapter });
        } else {
            res.status(404).json({ message: 'Novel not found in user list', novelTitle });
        }
    } catch (error) {
        console.error('Error adding chapter to chaptersRead:', error);
        res.status(500).json({ message: 'Error adding chapter to chaptersRead', error: error.message });
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

module.exports = router;