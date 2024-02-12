// user.dart
import 'novel.dart';

class User {
  final String username;
  final String uniqueIdentifier;
  final DateTime dateJoined;
  final String profileImage;
  final String theme;
  final List<Map<String, dynamic>> friends;
  final List<Novel> novels;
  final List<Novel> historyNovels;

  User({
    required this.username,
    required this.uniqueIdentifier,
    required this.dateJoined,
    required this.profileImage,
    required this.theme,
    required this.friends,
    required this.novels,
    required this.historyNovels,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? '',
      uniqueIdentifier: json['uniqueIdentifier'] ?? '',
      dateJoined: json['dateJoined'] != null
          ? DateTime.parse(json['dateJoined'])
          : DateTime.now(),
      profileImage: json['profileImage'] ?? '',
      theme: json['theme'] ?? '',
      friends: json['friends'] != null
          ? List<Map<String, dynamic>>.from(json['friends'])
          : [],
      novels: json['novels'] != null
          ? List<Novel>.from(
              json['novels'].map((novel) => Novel.fromJson(novel)))
          : [],
      historyNovels: List<Novel>.from(
          json['history']?.map((novel) => Novel.fromJson(novel)) ??
              []), // Add this line
    );
  }
}
