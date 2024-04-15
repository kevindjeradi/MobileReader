// auth_routes.ts
import express, { Request, Response } from 'express';
import User from '../models/User';
import jwt from 'jsonwebtoken';
import { IUser } from '../types/user.interface';
import { TokenPayload } from '../types/tokenPayload.interface';
import { sendEmail } from '../helpers/mailer';
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

router.post('/forgot-password', async (req: Request, res: Response) => {
    const { email } = req.body;
    if (!email) {
        return res.status(400).json({ error: 'Email is required' });
    }

    try {
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(200).json({ message: 'Si cet email est dans notre base de données, nous vous enverrons un code de réinitialisation.' });
        }

        // Generate a 6 digits reset code that expires 5 minutes later
        const resetCode = Math.floor(100000 + Math.random() * 900000);
        const resetCodeExpire = new Date(Date.now() + 300000); // 5 minutes from now

        user.resetPasswordCode = resetCode;
        user.resetPasswordExpires = resetCodeExpire;
        await user.save();

        await sendEmail(
            user.email,
            'Mobile Reader - Réinitialisation du mot de passe',
            `Bonjour ${user.username},
            \n\nVous recevez ce message car vous (ou quelqu'un d'autre) avez demandé la reinitialisation du mot de passe pour votre compte Mobile Reader.
            \n\nVeuillez utiliser le code ci-dessous pour terminer le processus de reinitialisation de votre mot de passe.
            \n\nCode de réinitialisation: ${resetCode}
            \n\nCe code expire ne restera valide que 5 minutes à partir de la reception de cet email.
            \n\nSi vous n'avez pas demandé à changer votre mot de passe pour ce compte, vous pouvez ignorer cet email et votre mot de passe restera inchangé.
            \n\nL'équipe Mobile Reader`
        );

        res.status(200).json({ message: 'Un code de réinitialisation a été envoyé à ' + user.email + '.' });
    } catch (error) {
        res.status(500).json({ error: 'Error sending reset code' });
    }
});

router.post('/verify-reset-code', async (req: Request, res: Response) => {
    const { email, code } = req.body;
    
    try {
        const user = await User.findOne({ email: email });
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }
        
        const isCodeValid = user.resetPasswordCode !== null && user.resetPasswordCode.toString() === code.toString() && user.resetPasswordExpires !== null && new Date() < new Date(user.resetPasswordExpires);
        if (!isCodeValid) {
            return res.status(400).json({ error: 'Invalid or expired reset code' });
        }

        res.status(200).json({ message: 'Code de réinitialisation valide' });
    } catch (error) {
        console.error('Error verifying reset code: ', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

router.post('/reset-password', async (req: Request, res: Response) => {
    const { code, email, password } = req.body;

    try {
        const user = await User.findOne({
            resetPasswordCode: code,
            resetPasswordExpires: { $gt: Date.now() },
            email: email
        });

        if (!user) {
            return res.status(400).json({ error: "Le code de réinitialisation est invalide, a expiré, ou l'email est incorrect."});
        }

        user.password = password;
        user.resetPasswordCode = null;
        user.resetPasswordExpires = null;
        await user.save();

        await sendEmail(
            user.email,
            'Mobile Reader - Mot de passe mis à jour',
            `Bonjour ${user.username},
            \n\nNous vous confirmons que votre mot de passe Mobile Reader a été mis à jour avec succès.
            \n\nL'équipe Mobile Reader`
        );

        res.status(200).json({ message: 'Mot de passe mis à jour avec succès.' });
    } catch (error) {
        res.status(500).json({ error: 'Internal server error' });
    }
});

export default router;