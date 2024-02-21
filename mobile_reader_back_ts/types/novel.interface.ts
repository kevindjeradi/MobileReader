// types/novel.interface.ts
export interface INovel {
    novelTitle: string;
    author: string;
    coverUrl: string;
    description: string;
    isFavorite: boolean;
    numberOfChapters: number;
    chaptersDetails: Array<{ title: string; link: string; }>;
    lastReadChapter: number;
    lastReadAt: Date;
    chaptersRead: Array<{ chapter: number; readAt: Date; }>;
}