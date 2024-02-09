// userRoutes.js
const express = require('express');
const User = require('../models/User');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const path = require('path');
const checkAuth = require('../middleware/checkAuth');

const router = express.Router();

require('dotenv').config();
const JWT_SECRET = process.env.JWT_SECRET;

// Configure multer for profile image upload
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, 'images/')
    },
    filename: function (req, file, cb) {
        const userId = req.userId;
        cb(null, `user_${userId}${path.extname(file.originalname)}`);
    }
})

const upload = multer({ storage: storage })

router.post('/signup', async (req, res) => {
    try {
        const { username, password } = req.body;
        
        // Check if user with the same username already exists
        const existingUser = await User.findOne({ username });
        if (existingUser) {
            return res.status(400).json({ error: 'Username already exists' });
        }
        
        const user = new User({ username, password });
        await user.save();

        // Generate token after successful registration
        const token = jwt.sign({ userId: user._id }, JWT_SECRET, { expiresIn: '1h' });

        res.status(201).json({ message: 'User created successfully', token });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.post('/login', async (req, res) => {
    const { username, password } = req.body;
    const user = await User.findOne({ username });
    if (!user || !await user.isCorrectPassword(password)) {
        return res.status(401).json({ error: 'Invalid username or password' });
    }

    const token = jwt.sign({ userId: user._id }, JWT_SECRET, { expiresIn: '30d' });
    res.json({ token });
});

router.get('/user/details', async (req, res) => {
    // Verify the token and extract the userId
    try {
        const token = req.headers.authorization.split(' ')[1];
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId;

        // Find the user by their ID
        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

// Fetch friends' details using uniqueIdentifier
const friendsDetails = await User.find({
    'uniqueIdentifier': { $in: user.friends }
}).select('username dateJoined profileImage');

        // Return the required details
        const userDetails = {
            username: user.username,
            uniqueIdentifier: user.uniqueIdentifier,
            dateJoined: user.dateJoined,
            profileImage: user.profileImage,
            theme: user.settings.theme,
            friends: friendsDetails,
            novels: user.novels,
            history: user.history,
        };

        console.log(userDetails);
        res.json(userDetails);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// friends
router.post('/user/addFriend', checkAuth, async (req, res) => {
    const userId = req.userId; // Extracted from the JWT token by your middleware
    const { friendId } = req.body;

    try {
        const user = await User.findById(userId);
        if (!user) {
            console.log("User not found");
            return res.status(404).json({ error: 'User not found' });
        }

        // Check if already friends
        if (user.friends.includes(friendId)) {
            console.log("Already friends");
            return res.status(400).json({ error: 'Already friends' });
        }
        console.log("Trying to add friend");
        // Add friend
        user.friends.push(friendId);
        console.log("Added friend");
        await user.save();
        console.log("Saved friend");

        res.json({ message: 'Friend added successfully' });
    } catch (error) {
        console.log("Add friend error: " + error.message);
        res.status(500).json({ error: error.message });
    }
});

router.get('/user/exists/:uniqueIdentifier', async (req, res) => {
    try {
        const uniqueIdentifier = req.params.uniqueIdentifier;
        const user = await User.findOne({ uniqueIdentifier: uniqueIdentifier }).select('username profileImage');

        if (user) {
            res.json({ exists: true, username: user.username, profileImage: user.profileImage });
        } else {
            res.json({ exists: false });
        }
    } catch (error) {
        res.status(500).json({ error: 'Internal Server Error' });
    }
});

// Validate Token Route
router.post('/validate', async (req, res) => {
    try {
        const { token } = req.body;
        if (!token) {
            return res.status(401).json({ error: 'Token is required' });
        }

        // Verify the token
        const decoded = jwt.verify(token, JWT_SECRET);
        
        res.status(200).json({ valid: true, userId: decoded.userId });
    } catch (error) {
        res.status(401).json({ valid: false, error: 'Invalid Token' });
    }
});

// Route to set profile image for the first time
router.post('/user/profileImage', checkAuth, upload.single('profileImage'), async (req, res) => {
    try {
        const userId = req.userId;

        // Update the user's profileImage field using findOneAndUpdate
        const updatedUser = await User.findOneAndUpdate(
            { _id: userId },
            { $set: { profileImage: `/images/${req.file.filename}` } },
            { new: true } // This option returns the updated user document
        );

        if (!updatedUser) {
            return res.status(404).json({ error: 'User not found' });
        }

        res.status(200).json({
            message: 'Profile image set successfully',
            profileImage: updatedUser.profileImage,
        });
    } catch (error) {
        console.error(error);
        console.log("error in post user/profileImage: " + error);
        res.status(500).json({ error: error.message });
    }
});

// Route to update profile image
router.patch('/user/profileImage', checkAuth, upload.single('profileImage'), async (req, res) => {
    try {
        const userId = req.userId;

        // Update the user's profileImage field using findOneAndUpdate
        const updatedUser = await User.findOneAndUpdate(
            { _id: userId },
            { $set: { profileImage: `/images/${req.file.filename}` } },
            { new: true } // This option returns the updated user document
        );

        if (!updatedUser) {
            return res.status(404).json({ error: 'User not found' });
        }

        res.status(200).json({
            message: 'Profile image updated successfully',
            profileImage: updatedUser.profileImage,
        });
    } catch (error) {
        console.error(error);
        console.log("error in patch user/profileImage: " + error);
        res.status(500).json({ error: error.message });
    }
});

router.patch('/user/updateTheme', async (req, res) => {
    try {
        const token = req.headers.authorization.split(' ')[1];
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId;
        const { theme } = req.body;

        // Update only the theme setting
        await User.findOneAndUpdate({ _id: userId }, { $set: { 'settings.theme': theme } });

        res.status(200).json({ message: 'Theme updated successfully' });
    } catch (error) {
        console.log("Updated theme error: " + error.message);
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;