// user.js
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');

const userSchema = new mongoose.Schema({
    username: {
        type: String,
        unique: true,
        required: true
    },
    password: {
        type: String,
        required: true
    },
    uniqueIdentifier: {
        type: String,
        unique: true,
        default: () => uuidv4()
    },
    dateJoined: {
        type: Date,
        default: Date.now
    },
    profileImage: { type: String, default: "/images/profile.png" },
    settings: {
        theme: String,
    },
    friends: [{ type: String, ref: 'Users' }],
    novels: [{
        novelTitle: String,
        author: String,
        coverUrl: String,
        description: String,
        isFavorite: {
            type: Boolean,
            default: false,
            required: true,
        },
        numberOfChapters: Number,
        chaptersDetails: [{
            title: String,
            link: String,
        }],
        lastReadChapter: Number,
        lastReadAt: { type: Date, default: Date.now },
        chaptersRead: [{
            chapter: Number,
            readAt: { type: Date, default: Date.now },
        }],
    }],
    history: [{
        novelTitle: String,
        author: String,
        coverUrl: String,
        description: String,
        isFavorite: {
            type: Boolean,
            default: false
        },
        numberOfChapters: Number,
        lastReadChapter: Number,
        lastReadAt: { type: Date, default: Date.now },
        chaptersRead: [{
            chapter: Number,
            readAt: { type: Date, default: Date.now },
        }],
    }],
});

// Hash the password before saving
userSchema.pre('save', async function (next) {
    if (!this.isModified('password')) return next();
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
});

// Method to check password
userSchema.methods.isCorrectPassword = async function (password) {
    return bcrypt.compare(password, this.password);
};

module.exports = mongoose.model('Users', userSchema);
