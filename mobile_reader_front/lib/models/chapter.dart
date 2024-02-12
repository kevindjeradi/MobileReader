class Chapter {
  final int chapter;
  final DateTime readAt; // When the user last read this chapter

  Chapter({
    required this.chapter,
    required this.readAt,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
        chapter: json['chapter'],
        readAt: DateTime.parse(json['readAt']),
      );

  Chapter copyWith({
    int? chapter,
    double? progress,
    DateTime? readAt,
  }) {
    return Chapter(
      chapter: chapter ?? this.chapter,
      readAt: readAt ?? this.readAt,
    );
  }
}
