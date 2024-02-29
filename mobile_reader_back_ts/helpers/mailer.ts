import nodemailer from 'nodemailer';
import { google } from 'googleapis';
import dotenv from 'dotenv';
dotenv.config();

const OAuth2Client = new google.auth.OAuth2(
    process.env.CLIENT_ID,
    process.env.CLIENT_SECRET,
    'https://developers.google.com/oauthplayground' // Default Redirect URI
);

OAuth2Client.setCredentials({
    refresh_token: process.env.REFRESH_TOKEN,
});

export const createTransporter = async () => {
    const accessToken = await new Promise<string>((resolve, reject) => {
        OAuth2Client.getAccessToken((err, token) => {
            if (err) {
                reject('Failed to create access token');
            }
            resolve(token!);
        });
    });

    return nodemailer.createTransport({
        service: 'gmail',
        auth: {
            type: 'OAuth2',
            user: process.env.GMAIL_EMAIL,
            accessToken,
            clientId: process.env.CLIENT_ID,
            clientSecret: process.env.CLIENT_SECRET,
            refreshToken: process.env.REFRESH_TOKEN
        },
    });
};

export const sendEmail = async (to: string, subject: string, text: string) => {
    try {
        const transporter = await createTransporter();
        const mailOptions = {
            from: process.env.GMAIL_EMAIL,
            to: to,
            subject: subject,
            text: text,
        };

        await transporter.sendMail(mailOptions);
    } catch (error) {
        console.error('Error sending email: ', error);
        throw new Error('Failed to send email');
    }
};