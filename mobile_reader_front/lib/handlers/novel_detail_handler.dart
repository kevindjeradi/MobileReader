import 'package:flutter/material.dart';
import 'package:mobile_reader_front/models/chapters_details.dart';
import 'package:mobile_reader_front/models/novel.dart';
import 'package:mobile_reader_front/services/novel_service.dart';
import 'package:mobile_reader_front/views/chapter_view.dart';
import 'package:mobile_reader_front/components/generics/custom_snackbar.dart';
import 'package:mobile_reader_front/views/novel_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NovelDetailHandler {
  final Novel novel;
  final SharedPreferences prefs;
  final BuildContext context;

  NovelDetailHandler({
    required this.novel,
    required this.prefs,
    required this.context,
  });

  Future<bool> isChapterDownloaded(String chapterTitle) async {
    return prefs.getString(chapterTitle) != null;
  }

  Future<bool> downloadChapterContent(String chapterUrl, String chapterTitle,
      {bool showMessage = false}) async {
    if (await isChapterDownloaded(chapterTitle)) {
      if (context.mounted && showMessage) {
        showCustomSnackBar(
            context, 'Le chapitre à déjà été enregistré', SnackBarType.info);
      }
      return true;
    }

    try {
      final content = await NovelService.fetchChapterContent(chapterUrl);
      await prefs.setString(chapterTitle, content);
      if (context.mounted && showMessage) {
        showCustomSnackBar(
            context, "Le chapitre à bien été téléchargé", SnackBarType.success);
      }
      return true;
    } catch (e) {
      if (context.mounted && showMessage) {
        showCustomSnackBar(context, "Le chapitre n'a pas pu être téléchargé",
            SnackBarType.error);
      }
      return false;
    }
  }

  Future<Map<String, bool>> preloadChapterStatuses() async {
    final List<ChaptersDetails> chapters = novel.chaptersDetails;
    Map<String, bool> tempMap = {};

    for (var chapter in chapters) {
      bool downloaded = await isChapterDownloaded(chapter.title);
      tempMap[chapter.title] = downloaded;
    }

    return tempMap;
  }

  void handlePreviousChapter(int currentChapterIndex) async {
    if (currentChapterIndex < 0) {
      return;
    }

    ChaptersDetails previousChapter =
        novel.chaptersDetails[currentChapterIndex];
    final content = prefs.getString(previousChapter.title);

    if (context.mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => ChapterView(
          novelTitle: novel.novelTitle,
          chapterIndex: currentChapterIndex,
          chapterTitle: previousChapter.title,
          chapterContent: content!,
          onNextChapter: () => handleNextChapter(currentChapterIndex + 1),
          onPreviousChapter: () =>
              handlePreviousChapter(currentChapterIndex - 1),
        ),
      ));
    }
  }

  void handleNextChapter(int currentChapterIndex) async {
    if (currentChapterIndex + 1 >= novel.chaptersDetails.length) {
      return;
    }

    ChaptersDetails nextChapter = novel.chaptersDetails[currentChapterIndex];
    bool isDownloaded = await isChapterDownloaded(nextChapter.title);

    if (!isDownloaded) {
      if (context.mounted) {
        await downloadChapterContent(nextChapter.link, nextChapter.title);
        final content = prefs.getString(nextChapter.title);
        isDownloaded = await isChapterDownloaded(nextChapter.title);

        if (context.mounted && isDownloaded) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => ChapterView(
              novelTitle: novel.novelTitle,
              chapterIndex: currentChapterIndex,
              chapterTitle: nextChapter.title,
              chapterContent: content!,
              onNextChapter: () => handleNextChapter(currentChapterIndex + 1),
              onPreviousChapter: () =>
                  handlePreviousChapter(currentChapterIndex - 1),
            ),
          ));
        } else {
          if (context.mounted) {
            showCustomSnackBar(context,
                "Le chapitre n'a pas pu être téléchargé", SnackBarType.error);
          }
        }
      }
    } else {
      final content = prefs.getString(nextChapter.title);

      if (context.mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => ChapterView(
            novelTitle: novel.novelTitle,
            chapterIndex: currentChapterIndex,
            chapterTitle: nextChapter.title,
            chapterContent: content!,
            onNextChapter: () => handleNextChapter(currentChapterIndex + 1),
            onPreviousChapter: () =>
                handlePreviousChapter(currentChapterIndex - 1),
          ),
        ));
      }
    }
  }

  void navigateToLastReadChapter(BuildContext context) {
    ChaptersDetails chapterDetail =
        novel.chaptersDetails[novel.lastReadChapter];
    final content = prefs.getString(chapterDetail.title);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NovelDetail(novel: novel),
      ),
    );

    if (content != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChapterView(
            novelTitle: novel.novelTitle,
            chapterIndex: novel.lastReadChapter,
            chapterTitle: novel.chaptersDetails[novel.lastReadChapter].title,
            chapterContent: content,
            onPreviousChapter: () {
              handlePreviousChapter(novel.lastReadChapter - 1);
            },
            onNextChapter: () {
              handleNextChapter(novel.lastReadChapter + 1);
            },
          ),
        ),
      );
    }
  }
}
