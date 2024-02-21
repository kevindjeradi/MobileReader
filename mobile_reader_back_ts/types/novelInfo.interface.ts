// types/chapter.interface.ts
import { Chapter } from "./chapter.interface";

export interface NovelInfo {
    title?: string;
    author?: string;
    description?: string;
    coverUrl?: string;
    chapters: Chapter[];
}