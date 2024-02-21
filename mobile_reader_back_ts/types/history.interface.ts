// types/history.interface.ts
export interface IHistory {
    novelTitle: string;
    author: string;
    coverUrl: string;
    description: string;
    isFavorite: boolean;
    numberOfChapters: number;
    lastReadChapter: number;
    lastReadAt: Date;
    chaptersRead: Array<{ chapter: number; readAt: Date; }>;
}