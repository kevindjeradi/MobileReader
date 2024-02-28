import express, { Request, Response } from 'express';
import User from '../models/User';
import jwt from 'jsonwebtoken';
import { IUser } from '../types/user.interface';
import { TokenPayload } from '../types/tokenPayload.interface';

const router = express.Router();

// Assume dotenv config is set up globally or import it here
import dotenv from 'dotenv';
dotenv.config();

const JWT_SECRET = process.env.JWT_SECRET as string;

router.post('/signup', async (req: Request, res: Response) => {
    try {
        const { username, password, email } = req.body;
        
        const existingUser = await User.findOne({ username });
        const existingEmail = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ error: 'Username already exists' });
        }
        if (existingEmail) {
            return res.status(400).json({ error: 'Email already used' });
        }

        const user = new User({ username, email, password });
        await user.save();

        const token = jwt.sign({ userId: user._id }, JWT_SECRET, { expiresIn: '1h' });

        res.status(201).json({ message: 'User created successfully', token });
    } catch (error) {
        const errorMessage = error instanceof Error ? error.message : 'An unknown error occurred';
        res.status(500).json({ error: errorMessage });
    }
    
});

router.post('/login', async (req: Request, res: Response) => {
    const { username, password } = req.body;
    const user = await User.findOne({ username }) as IUser;
    if (!user || !await user.isCorrectPassword(password)) {
        return res.status(401).json({ error: 'Invalid username or password' });
    }

    const token = jwt.sign({ userId: user._id }, JWT_SECRET, { expiresIn: '30d' });
    res.json({ token });
});

router.post('/validate', async (req: Request, res: Response) => {
    const { token } = req.body;
    if (!token) {
        return res.status(401).json({ error: 'Token is required' });
    }

    try {
        const decoded = jwt.verify(token, JWT_SECRET) as TokenPayload;
        res.status(200).json({ valid: true, userId: decoded.userId });
    } catch (error) {
        res.status(401).json({ valid: false, error: 'Invalid Token' });
    }
});

export default router;