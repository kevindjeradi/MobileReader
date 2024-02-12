class ChaptersDetails {
  final String title;
  final String link;

  ChaptersDetails({
    required this.title,
    required this.link,
  });

  factory ChaptersDetails.fromJson(Map<String, dynamic> json) =>
      ChaptersDetails(
        title: json['title'],
        link: json['link'],
      );
}
