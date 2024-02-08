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
    profileImage: {type: String, default: "/images/profile.png"},
    settings: {
        theme: String,
    },
    friends: [{ type: String, ref: 'Users' }],
    novels: [{
        novelTitle: String, // novel title
        description: String, // novel description
        numberOfChapters: Number, // number of chapters
        lastReadChapter: Number, // number of the last chapter the user was reading
        lastReadChapterProgress: Number, // A value indicating how far the user has read in the last chapter
        lastReadAt: { type: Date, default: Date.now }, // When the user last read this novel
        chaptersRead: [{
            chapter: Number, // Chapter number
            progress: Number, // Optional, can track reading progress within each chapter
            readAt: { type: Date, default: Date.now }, // When the user read this chapter
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
