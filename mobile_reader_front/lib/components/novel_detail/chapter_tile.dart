import 'package:flutter/material.dart';
import 'package:mobile_reader_front/models/chapter.dart';
import 'package:mobile_reader_front/models/chapters_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_reader_front/views/chapter_view.dart';
import 'package:mobile_reader_front/services/novel_service.dart';
import 'package:mobile_reader_front/components/generics/custom_snackbar.dart';
import 'package:mobile_reader_front/helpers/logger.dart';

class ChapterTile extends StatefulWidget {
  final ChaptersDetails chapterDetail;
  final int chapterIndex;
  final SharedPreferences prefs;
  final String novelTitle;
  final Function onNextChapter;
  final Function onPreviousChapter;
  final List<Chapter> chaptersRead;

  const ChapterTile({
    Key? key,
    required this.chapterDetail,
    required this.chapterIndex,
    required this.prefs,
    required this.novelTitle,
    required this.onNextChapter,
    required this.onPreviousChapter,
    required this.chaptersRead,
  }) : super(key: key);

  @override
  State<ChapterTile> createState() => _ChapterTileState();
}

class _ChapterTileState extends State<ChapterTile> {
  late Future<bool> _isDownloadedFuture;

  @override
  void initState() {
    super.initState();
    _isDownloadedFuture = _isChapterDownloaded(widget.chapterDetail.title);
  }

  Future<bool> _isChapterDownloaded(String chapterTitle) async {
    return widget.prefs.getString(chapterTitle) != null;
  }

  Future<void> _downloadChapterContent(
      BuildContext context, String chapterUrl, String chapterTitle) async {
    if (await _isChapterDownloaded(chapterTitle)) {
      if (mounted) {
        showCustomSnackBar(
            context, 'Chapter already downloaded', SnackBarType.info);
      }
      return;
    }
    try {
      final content = await NovelService.fetchChapterContent(chapterUrl);
      await widget.prefs.setString(chapterTitle, content);
      if (mounted) {
        showCustomSnackBar(
            context, "Chapter downloaded successfully", SnackBarType.success);
      }
      _updateDownloadStatus();
    } catch (e) {
      Log.logger.e("Error downloading chapter: $e");
      if (mounted) {
        showCustomSnackBar(
            context, "Failed to download chapter", SnackBarType.error);
      }
    }
  }

  void _updateDownloadStatus() {
    setState(() {
      _isDownloadedFuture = _isChapterDownloaded(widget.chapterDetail.title);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isRead = widget.chaptersRead
        .any((chapter) => chapter.chapter == widget.chapterIndex);

    return ListTile(
      tileColor: isRead
          ? theme.colorScheme.surface.withOpacity(0.3)
          : theme.colorScheme.background,
      title: Text(
        widget.chapterDetail.title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onBackground,
        ),
      ),
      trailing: FutureBuilder<bool>(
        future: _isDownloadedFuture,
        builder: (context, snapshot) {
          bool isDownloaded = snapshot.data ?? false;

          return InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: isDownloaded
                ? null
                : () => _downloadChapterContent(context,
                    widget.chapterDetail.link, widget.chapterDetail.title),
            child: Icon(isDownloaded ? null : Icons.download_outlined),
          );
        },
      ),
      onTap: () async {
        final isDownloaded =
            await _isChapterDownloaded(widget.chapterDetail.title);
        if (isDownloaded) {
          final content = widget.prefs.getString(widget.chapterDetail.title);

          if (mounted) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ChapterView(
                novelTitle: widget.novelTitle,
                chapterIndex: widget.chapterIndex,
                chapterTitle: widget.chapterDetail.title,
                chapterContent: content!,
                onNextChapter: () =>
                    widget.onNextChapter(widget.chapterIndex + 1),
                onPreviousChapter: () =>
                    widget.onPreviousChapter(widget.chapterIndex - 1),
              ),
            ));
          }
        } else {
          if (mounted) {
            if (mounted) {
              showCustomSnackBar(
                  context, 'Chapter not downloaded', SnackBarType.error);
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text(widget.chapterDetail.title,
                              style: Theme.of(context).textTheme.headlineSmall),
                          Text("Vous n'avez pas téléchargé ce chapitre",
                              style: Theme.of(context).textTheme.labelLarge),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.download_outlined),
                            label: const Text('Télécharger le chapitre'),
                            onPressed: () {
                              Navigator.pop(context); // Close the bottom sheet
                              _downloadChapterContent(
                                  context,
                                  widget.chapterDetail.link,
                                  widget.chapterDetail.title);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          }
        }
      },
    );
  }
}
