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


module.exports = router;