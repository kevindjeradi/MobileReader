// types/novelDetails.interface.ts
import { Chapter } from "./chapter.interface";

export interface NovelDetails {
    title?: string;
    author?: string;
    description?: string;
    coverUrl?: string;
    numberOfChapters?: number;
    chaptersDetails: Chapter[];
    lastReadChapter?: number;
    lastReadAt?: Date;
    chaptersRead?: { chapter: number; readAt: Date; }[];
}