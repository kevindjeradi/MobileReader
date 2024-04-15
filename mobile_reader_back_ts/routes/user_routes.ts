// userRoutes.ts
import express, { Request, Response } from 'express';
import User from '../models/User'; // Adjust the import path as necessary
import jwt from 'jsonwebtoken';
import multer, { FileFilterCallback } from 'multer';
import path from 'path';
import checkAuth from '../middleware/checkAuth';
import { IUser } from '../types/user.interface';
import { TokenPayload } from '../types/tokenPayload.interface';

const router = express.Router();

// Assume dotenv config is set up globally or import it here
import dotenv from 'dotenv';
dotenv.config();

const JWT_SECRET = process.env.JWT_SECRET as string;

// Configure multer for profile image upload
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'images/');
    },
    filename: (req, file, cb) => {
        const userId = req.userId as string; // userId is injected by checkAuth middleware
        cb(null, `user_${userId}${path.extname(file.originalname)}`);
    },
});

const upload = multer({ storage });

router.get('/user/details', checkAuth, async (req: Request, res: Response) => {
    const userId = req.userId as string;

    try {
        const user = await User.findById(userId) as IUser;
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        const friendsDetails = await User.find({
            'uniqueIdentifier': { $in: user.friends }
        }).select('username dateJoined profileImage');

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

        res.json(userDetails);
    } catch (error) {
        const errorMessage = error instanceof Error ? error.message : 'An unknown error occurred';
        res.status(500).json({ error: errorMessage });
    }
    
});

router.post('/user/addFriend', checkAuth, async (req: Request, res: Response) => {
    const userId = req.userId as string;
    const { friendId } = req.body;

    try {
        const user = await User.findById(userId) as IUser;
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        if (user.friends.includes(friendId)) {
            return res.status(400).json({ error: 'Already friends' });
        }

        user.friends.push(friendId);
        await user.save();
        res.json({ message: 'Friend added successfully' });
    } catch (error) {
        const errorMessage = error instanceof Error ? error.message : 'An unknown error occurred';
        res.status(500).json({ error: errorMessage });
    }
    
});

router.get('/user/exists/:uniqueIdentifier', async (req: Request, res: Response) => {
    const uniqueIdentifier = req.params.uniqueIdentifier;

    try {
        const user = await User.findOne({ uniqueIdentifier }).select('username profileImage');
        if (user) {
            res.json({ exists: true, username: user.username, profileImage: user.profileImage });
        } else {
            res.json({ exists: false });
        }
    } catch (error) {
        res.status(500).json({ error: 'Internal Server Error' });
    }
});

router.post('/user/profileImage', checkAuth, upload.single('profileImage'), async (req: Request, res: Response) => {
    const userId = req.userId as string;

    try {
        const updatedUser = await User.findOneAndUpdate(
            { _id: userId },
            { $set: { profileImage: `/images/${req.file?.filename}` } },
            { new: true }
        );

        if (!updatedUser) {
            return res.status(404).json({ error: 'User not found' });
        }

        res.status(200).json({
            message: 'Profile image set successfully',
            profileImage: updatedUser.profileImage,
        });
    } catch (error) {
        const errorMessage = error instanceof Error ? error.message : 'An unknown error occurred';
        res.status(500).json({ error: errorMessage });
    }
    
});

router.patch('/user/profileImage', checkAuth, upload.single('profileImage'), async (req: Request, res: Response) => {
    const userId = req.userId as string;

    try {
        const updatedUser = await User.findOneAndUpdate(
            { _id: userId },
            { $set: { profileImage: `/images/${req.file?.filename}` } },
            { new: true }
        );

        if (!updatedUser) {
            return res.status(404).json({ error: 'User not found' });
        }

        res.status(200).json({
            message: 'Profile image updated successfully',
            profileImage: updatedUser.profileImage,
        });
    } catch (error) {
        const errorMessage = error instanceof Error ? error.message : 'An unknown error occurred';
        res.status(500).json({ error: errorMessage });
    }
});

router.patch('/user/updateTheme', checkAuth, async (req: Request, res: Response) => {
    const userId = req.userId as string;
    const { theme } = req.body;

    try {
        await User.findOneAndUpdate({ _id: userId }, { $set: { 'settings.theme': theme } });
        res.status(200).json({ message: 'Theme updated successfully' });
    } catch (error) {
        const errorMessage = error instanceof Error ? error.message : 'An unknown error occurred';
        res.status(500).json({ error: errorMessage });
    }
});

export default router;