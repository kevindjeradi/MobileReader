import mongoose, { Schema } from 'mongoose';
import { CompletedNovelDetails } from '../types/completedNovelDetails.interface';

const completedNovelSchema = new Schema<CompletedNovelDetails>({
    title: { type: String, required: true },
    novelUrl: { type: String, required: true },
    chapterCount: { type: Number, required: true },
    imageUrl: { type: String, required: true },
});

const CompletedNovel = mongoose.model<CompletedNovelDetails>('CompletedNovel', completedNovelSchema);

export default CompletedNovel;