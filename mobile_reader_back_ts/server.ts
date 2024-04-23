import express from 'express';
import mongoose from 'mongoose';
import cors from 'cors';
import path from 'path';
import userRoutes from './routes/user_routes';
import authRoutes from './routes/auth_routes';
import scraperRoutes from './routes/scraper_route';
import novelRoutes from './routes/novel_routes';
import chapterRoutes from './routes/chapter_routes';
import { setupDailyTasks } from './scheduled_tasks/daily_tasks';

declare global {
    namespace Express {
        interface Request {
            userId?: string;
        }
    }
}

require('dotenv').config();

const app = express();
const PORT = process.env.PORT ? parseInt(process.env.PORT, 10) : 3000;
const dbURI = process.env.MONGO_URI || '';
const APP_URL = process.env.APP_URL || '';

mongoose.connect(dbURI)
    .then(() => console.log('Connected to MongoDB'))
    .catch(err => console.error('Could not connect to MongoDB', err));

app.use(cors());
console.log('cors initialized');

app.use(express.json({ limit: '50mb' }));
console.log('express json size limit initialized');

app.use('/images', express.static(path.join(__dirname, 'images')));
console.log('image folder initialized');

app.use('/', authRoutes);
console.log('Auth routes initialized');

app.use('/', userRoutes);
console.log('User routes initialized');

app.use('/', novelRoutes);
console.log('Novel routes initialized');

app.use('/', chapterRoutes);
console.log('Chapter routes initialized');

app.use('/api', scraperRoutes);
console.log('Scraper routes initialized');

setupDailyTasks();
console.log('Daily tasks set up');

app.listen(PORT, '0.0.0.0', function () {
    console.log(`Server is running on ${APP_URL}${PORT}`);
});
console.log('Server started');
