// types/user.interface.ts
import mongoose from 'mongoose';
import { INovel } from './novel.interface';
import { IHistory } from './history.interface';

export interface IUser extends mongoose.Document {
    username: string;
    email: string;
    password: string;
    resetPasswordCode: Number | null;
    resetPasswordExpires: Date | null;
    uniqueIdentifier: string;
    dateJoined: Date;
    profileImage: string;
    settings: {
        theme?: string;
    };
    friends: mongoose.Types.ObjectId[];
    novels: INovel[];
    history: IHistory[];
    isCorrectPassword(password: string): Promise<boolean>;
}