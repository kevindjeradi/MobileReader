// novel.dart
import 'package:mobile_reader_front/models/chapter.dart';
import 'package:mobile_reader_front/models/chapters_details.dart';

class Novel {
  final String novelTitle;
  final String author;
  final String coverUrl;
  final String description;
  final bool isFavorite;
  final int numberOfChapters;
  final List<ChaptersDetails> chaptersDetails;
  final int lastReadChapter;
  final DateTime lastReadAt;
  final List<Chapter> chaptersRead;

  Novel({
    required this.novelTitle,
    required this.author,
    required this.coverUrl,
    required this.description,
    required this.isFavorite,
    required this.numberOfChapters,
    required this.chaptersDetails,
    required this.lastReadChapter,
    required this.lastReadAt,
    required this.chaptersRead,
  });

  factory Novel.fromJson(Map<String, dynamic> json) => Novel(
        novelTitle: json['novelTitle'],
        author: json['author'],
        coverUrl: json['coverUrl'],
        description: json['description'] ?? 'description vide',
        isFavorite: json['isFavorite'],
        numberOfChapters: json['numberOfChapters'],
        chaptersDetails: json['chaptersDetails'] != null
            ? List<ChaptersDetails>.from(json['chaptersDetails']
                .map((chapter) => ChaptersDetails.fromJson(chapter)))
            : [],
        lastReadChapter: json['lastReadChapter'],
        lastReadAt: DateTime.parse(json['lastReadAt']),
        chaptersRead: json['chaptersRead'] != null
            ? List<Chapter>.from(json['chaptersRead']
                .map((chapter) => Chapter.fromJson(chapter)))
            : [],
      );

  Novel copyWith({
    String? novelTitle,
    String? author,
    String? coverUrl,
    String? description,
    bool? isFavorite,
    int? numberOfChapters,
    List<ChaptersDetails>? chaptersDetails,
    int? lastReadChapter,
    DateTime? lastReadAt,
    List<Chapter>? chaptersRead,
  }) {
    return Novel(
      novelTitle: novelTitle ?? this.novelTitle,
      author: author ?? this.author,
      coverUrl: coverUrl ?? this.coverUrl,
      description: description ?? this.description,
      isFavorite: isFavorite ?? this.isFavorite,
      numberOfChapters: numberOfChapters ?? this.numberOfChapters,
      chaptersDetails: chaptersDetails ?? this.chaptersDetails,
      lastReadChapter: lastReadChapter ?? this.lastReadChapter,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      chaptersRead: chaptersRead ?? this.chaptersRead,
    );
  }
}
