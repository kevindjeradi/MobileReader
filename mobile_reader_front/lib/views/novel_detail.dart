// novel_detail.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile_reader_front/components/generics/custom_snackbar.dart';
import 'package:mobile_reader_front/components/novel_detail/chapter_tile.dart';
import 'package:mobile_reader_front/components/generics/expandable_text.dart';
import 'package:mobile_reader_front/components/generics/custom_loader.dart';
import 'package:mobile_reader_front/components/novel_detail/novel_detail_sliver_app_bar.dart';
import 'package:mobile_reader_front/handlers/novel_detail_handler.dart';
import 'package:mobile_reader_front/models/chapters_details.dart';
import 'package:mobile_reader_front/models/novel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NovelDetail extends StatefulWidget {
  final Novel novel;

  const NovelDetail({Key? key, required this.novel}) : super(key: key);

  @override
  State<NovelDetail> createState() => _NovelDetailState();
}

class _NovelDetailState extends State<NovelDetail> {
  late Map<String, bool> chaptersDownloaded = {};
  late SharedPreferences prefs;
  late NovelDetailHandler novelDetailHandler;
  int currentPage = 0;
  final int chaptersPerPage = 120;
  int get totalPages =>
      (widget.novel.numberOfChapters / chaptersPerPage).ceil();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initPrefsAndNovelDetailHandler();
  }

  Future<void> _initPrefsAndNovelDetailHandler() async {
    prefs = await SharedPreferences.getInstance();

    if (mounted) {
      novelDetailHandler = NovelDetailHandler(
        novel: widget.novel,
        prefs: prefs,
        context: context,
      );
    }
    chaptersDownloaded = await novelDetailHandler.preloadChapterStatuses();
    setState(() {});
  }

  Future<void> _downloadUnreadChapters() async {
    final int startChapterIndex = currentPage * chaptersPerPage;
    final int endChapterIndex =
        min((currentPage + 1) * chaptersPerPage, widget.novel.numberOfChapters);
    late bool success;

    setState(() {
      isLoading = true;
    });

    for (int i = startChapterIndex; i < endChapterIndex; i++) {
      final ChaptersDetails chapter = widget.novel.chaptersDetails[i];
      final bool isDownloaded =
          await novelDetailHandler.isChapterDownloaded(chapter.title);
      if (!isDownloaded) {
        success = await novelDetailHandler.downloadChapterContent(
            chapter.link, chapter.title,
            showMessage: false);
      }
    }
    if (mounted) {
      showCustomSnackBar(
          context,
          success
              ? "Tous les chapitres ont été telechargés"
              : "Au moins un chapitre n'a pas pu être téléchargé",
          success ? SnackBarType.success : SnackBarType.error);
    }

    // Refresh the download status after downloading chapters
    chaptersDownloaded = await novelDetailHandler.preloadChapterStatuses();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                prefs = snapshot.data!;

                return CustomScrollView(
                  slivers: <Widget>[
                    NovelDetailSliverAppBar(novel: widget.novel),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              widget.novel.author,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ExpandableText(
                              text: widget.novel.description,
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.colorScheme.onBackground,
                              ),
                            ),
                            const Divider(thickness: 1),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Center(
                        child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith(
                                      (states) => theme.colorScheme.surface),
                              foregroundColor:
                                  MaterialStateProperty.resolveWith((states) =>
                                      theme.colorScheme.onBackground)),
                          onPressed: isLoading ? null : _downloadUnreadChapters,
                          child: const Text(
                              'Télécharger les chapitres de cette page'),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: currentPage > 0
                                ? () {
                                    setState(() {
                                      currentPage--;
                                    });
                                  }
                                : null,
                          ),
                          Text('Page ${currentPage + 1} sur $totalPages'),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: currentPage < totalPages - 1
                                ? () {
                                    setState(() {
                                      currentPage++;
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          // Calculate the actual index of the chapter in the novel's list of chapters
                          int actualIndex =
                              currentPage * chaptersPerPage + index;
                          if (actualIndex < widget.novel.numberOfChapters) {
                            ChaptersDetails chapterDetail =
                                widget.novel.chaptersDetails[actualIndex];
                            return ChapterTile(
                              chapterDetail: chapterDetail,
                              chapterIndex: actualIndex,
                              prefs: prefs,
                              novelTitle: widget.novel.novelTitle,
                              onNextChapter:
                                  novelDetailHandler.handleNextChapter,
                              onPreviousChapter:
                                  novelDetailHandler.handlePreviousChapter,
                              chaptersRead: widget.novel.chaptersRead,
                            );
                          } else {
                            return null;
                          }
                        },
                        childCount: min(
                            chaptersPerPage,
                            widget.novel.numberOfChapters -
                                currentPage * chaptersPerPage),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: currentPage > 0
                                ? () {
                                    setState(() {
                                      currentPage--;
                                    });
                                  }
                                : null,
                          ),
                          Text('Page ${currentPage + 1} sur $totalPages'),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: currentPage < totalPages - 1
                                ? () {
                                    setState(() {
                                      currentPage++;
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                    )
                  ],
                );
              } else {
                return const CustomLoader();
              }
            }),
      ),
    );
  }
}
