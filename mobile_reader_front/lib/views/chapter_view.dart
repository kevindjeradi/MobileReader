// chapter_view.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:mobile_reader_front/components/dialogs/chapter_settings.dart';
import 'package:mobile_reader_front/provider/user_provider.dart';
import 'package:mobile_reader_front/services/api.dart';
import 'package:mobile_reader_front/services/novel_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChapterView extends StatefulWidget {
  final String novelTitle;
  final String chapterTitle;
  final String chapterContent;
  final int chapterIndex;
  final Function() onNextChapter;
  final Function() onPreviousChapter;

  const ChapterView({
    Key? key,
    required this.novelTitle,
    required this.chapterTitle,
    required this.chapterContent,
    required this.chapterIndex,
    required this.onNextChapter,
    required this.onPreviousChapter,
  }) : super(key: key);

  get novel => null;

  @override
  State<ChapterView> createState() => ChapterViewState();
}

class ChapterViewState extends State<ChapterView> {
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarVisible = true;
  int _lastReportedProgress = 0;
  double _fontSize = 18.0;
  double _autoScrollSpeed = 15.0;
  Timer? _debounce;
  Timer? _autoScrollTimer;
  bool _autoScrollActive = false;

  @override
  void initState() {
    super.initState();
    updateNovelHistory();
    _loadPrefs();

    _scrollController.addListener(_updateScrollProgress);
    _scrollController.addListener(_handleUserScroll);

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToSavedProgress());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _handleUserScroll() {
    if (_scrollController.position.userScrollDirection !=
        ScrollDirection.idle) {
      if (_autoScrollActive) {
        _stopAutoScroll();
      }
    }
  }

  void _toggleAutoScroll() async {
    if (!_autoScrollActive) {
      _startAutoScroll();
    } else {
      _stopAutoScroll();
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer =
        Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _autoScroll();
    });
    setState(() => _autoScrollActive = true);
  }

  void _autoScroll() {
    double newPosition =
        _scrollController.position.pixels + (_autoScrollSpeed / 100);
    if (newPosition >= _scrollController.position.maxScrollExtent) {
      newPosition = _scrollController.position.maxScrollExtent;
      _stopAutoScroll();
    }
    _scrollController.jumpTo(newPosition);
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    setState(() {
      _autoScrollActive = false;
    });
  }

  void _updateScrollProgress() async {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final minScroll = _scrollController.position.minScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      int progress;

      // At the bottom, set progress to 100%
      if (currentScroll >= maxScroll) {
        progress = 100;
      }
      // At the top, set progress to 0%
      else if (currentScroll <= minScroll) {
        progress = 0;
      } else {
        progress = (currentScroll / maxScroll * 100).clamp(0, 100).toInt();
      }

      if ((progress - _lastReportedProgress).abs() >= 4 ||
          progress == 100 && _lastReportedProgress != progress) {
        // Threshold of 4%
        _lastReportedProgress = progress;

        // Debounce saving the progress
        if (_debounce?.isActive ?? false) _debounce!.cancel();
        _debounce = Timer(const Duration(milliseconds: 500), () async {
          // Save the progress to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          final progressKey =
              '${widget.novelTitle}_${widget.chapterTitle}_progress';
          await prefs.setInt(progressKey, progress);
        });
      }
    }
  }

  void _scrollToSavedProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressKey = '${widget.novelTitle}_${widget.chapterTitle}_progress';
    final progress = prefs.getInt(progressKey) ?? 0;

    // Adding small delay to make sure the scroll position is corretly updated
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final scrollPosition = maxScroll * progress / 100;
        _scrollController.jumpTo(scrollPosition);
      } else {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _scrollToSavedProgress());
      }
    });
  }

  Future<void> updateNovelHistory() async {
    await NovelService.updateLastRead(widget.novelTitle, widget.chapterIndex);
    await NovelService.addOrUpdateHistoryByTitle(widget.novelTitle);
    await NovelService.addChapterRead(widget.novelTitle, widget.chapterIndex);

    if (mounted) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await Api.populateUserProvider(userProvider);
    }
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getDouble('fontSize') ?? 18.0;
      _autoScrollSpeed = prefs.getDouble('autoScrollSpeed') ?? 50.0;
    });
  }

  void _showSettingsDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierColor: theme.colorScheme.background.withOpacity(0.5),
      builder: (context) => ChapterSettings(
        initialFontSize: _fontSize,
        onFontSizeChanged: (newSize) {
          setState(() => _fontSize = newSize);
        },
        isAutoScrolling: _autoScrollActive,
        initialAutoScrollSpeed: _autoScrollSpeed,
        onAutoScrollSpeedChanged: (newSpeed) async {
          setState(() => _autoScrollSpeed = newSpeed);
          await (await SharedPreferences.getInstance())
              .setDouble('autoScrollSpeed', newSpeed);
          if (_autoScrollActive) {
            _stopAutoScroll();
            _startAutoScroll();
          }
        },
      ),
    );
  }

  String preprocessChapterContent(String content) {
    // Remove the first <p> tag that contains the title
    var firstPTagRemoved = false;
    var modifiedContent =
        content.replaceAllMapped(RegExp(r'<p>(.*?)<\/p>'), (Match match) {
      if (!firstPTagRemoved) {
        firstPTagRemoved = true;
        return ''; // Remove the first <p> tag by returning an empty string
      }
      return match.group(0)!; // Return other matches unmodified
    });

    // Step 2: Remove any <p> tag starting with "translator", ignoring case and leading whitespace
    modifiedContent = modifiedContent.replaceAll(
        RegExp(r'<p>\s*(translator.*?|Translator.*?)<\/p>',
            caseSensitive: false),
        '');

    return modifiedContent;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Stack(children: [
        CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: theme.colorScheme.background,
              foregroundColor: theme.colorScheme.onBackground,
              pinned: _isAppBarVisible,
              floating: true,
              leading: IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              title: Text(widget.chapterTitle),
              centerTitle: true,
              elevation: 0,
            ),
            SliverToBoxAdapter(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    _isAppBarVisible = !_isAppBarVisible;
                  });
                },
                onDoubleTap: () => _showSettingsDialog(context),
                child: Html(
                  data: preprocessChapterContent(widget.chapterContent),
                  style: {
                    "p": Style(
                      fontSize: FontSize(_fontSize),
                      color: theme.colorScheme.onBackground,
                    ),
                  },
                ),
              ),
            ),
          ],
        ),
        Positioned(
            left: 0,
            right: 0,
            bottom: 28,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 500),
              offset: _isAppBarVisible ? Offset.zero : const Offset(0, 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle),
                    child: IconButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onPressed: widget.onPreviousChapter,
                        icon: const Icon(
                          Icons.navigate_before,
                          size: 32,
                        )),
                  ),
                  const SizedBox(width: 32),
                  Container(
                    decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle),
                    child: IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      icon: Icon(
                          _autoScrollActive ? Icons.pause : Icons.fast_forward),
                      onPressed: _toggleAutoScroll,
                    ),
                  ),
                  const SizedBox(width: 32),
                  Container(
                    decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle),
                    child: IconButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onPressed: widget.onNextChapter,
                        icon: const Icon(
                          Icons.navigate_next,
                          size: 32,
                        )),
                  ),
                ],
              ),
            )),
      ]),
    );
  }
}
