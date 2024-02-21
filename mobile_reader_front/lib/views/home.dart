import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobile_reader_front/components/book_tile.dart';
import 'package:mobile_reader_front/handlers/novel_detail_handler.dart';
import 'package:mobile_reader_front/models/novel.dart';
import 'package:mobile_reader_front/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;
  late SharedPreferences prefs;
  late NovelDetailHandler novelDetailHandler;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _initPrefsAndNovelDetailHandler(Novel lastReadNovel) async {
    prefs = await SharedPreferences.getInstance();

    if (mounted) {
      novelDetailHandler = NovelDetailHandler(
        novel: lastReadNovel,
        prefs: prefs,
        context: context,
      );
    }
    setState(() {});
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final bool isCollapsed = _scrollController.hasClients &&
        _scrollController.offset >
            (MediaQuery.of(context).size.height * 0.3 - kToolbarHeight);

    if (isCollapsed != _isCollapsed) {
      setState(() {
        _isCollapsed = isCollapsed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final novels = userProvider.novels;
    final historyNovels = userProvider.historyNovels;
    String? lastReadNovelCoverUrl;

    Novel? findNovelInLibrary(String novelTitle) {
      return novels.firstWhere((novel) => novel.novelTitle == novelTitle);
    }

    if (historyNovels.isNotEmpty) {
      final lastReadNovel =
          findNovelInLibrary(historyNovels.first.novelTitle) ??
              historyNovels.first;
      lastReadNovelCoverUrl = lastReadNovel.coverUrl;
      _initPrefsAndNovelDetailHandler(lastReadNovel);
    }

    Widget historySection = historyNovels.isNotEmpty
        ? SizedBox(
            height: 350,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: historyNovels.length,
              itemBuilder: (context, index) {
                final correspondingNovel =
                    findNovelInLibrary(historyNovels[index].novelTitle);
                return BookTile(
                    showFavorite: false,
                    novel: correspondingNovel ?? historyNovels[index]);
              },
            ),
          )
        : SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
            child: const Center(child: Text("Vous n'avez rien lu")));

    Widget librarySection = novels.isNotEmpty
        ? SizedBox(
            height: 350,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: novels.length,
              itemBuilder: (context, index) {
                return BookTile(novel: novels[index]);
              },
            ),
          )
        : SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
            child: const Center(
                child: Text(
                    "Vous n'avez ajouté aucun novel dans votre bibliothèque")));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          historyNovels.isEmpty
              ? SliverAppBar(
                  backgroundColor: Theme.of(context).colorScheme.background,
                  pinned: true,
                  elevation: 0,
                  title: const Text('Accueil'),
                )
              : SliverAppBar(
                  backgroundColor: Theme.of(context).colorScheme.background,
                  expandedHeight: MediaQuery.of(context).size.height * 0.3,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  flexibleSpace: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      _isCollapsed =
                          constraints.biggest.height <= kToolbarHeight;
                      return GestureDetector(
                        onTap: () {
                          if (historyNovels.isNotEmpty && !_isCollapsed) {
                            novelDetailHandler
                                .navigateToLastReadChapter(context);
                          }
                        },
                        child: FlexibleSpaceBar(
                          centerTitle: _isCollapsed ? false : true,
                          titlePadding: _isCollapsed
                              ? const EdgeInsets.all(0)
                              : const EdgeInsets.only(bottom: 16.0),
                          background: lastReadNovelCoverUrl != null
                              ? Stack(fit: StackFit.expand, children: [
                                  ImageFiltered(
                                    imageFilter: ImageFilter.blur(
                                      sigmaX: 5,
                                      sigmaY: 5,
                                    ),
                                    child: Image.network(
                                      lastReadNovelCoverUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Image.network(
                                      lastReadNovelCoverUrl,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ])
                              : null,
                          title: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Align(
                              alignment: _isCollapsed
                                  ? Alignment.centerLeft
                                  : Alignment.bottomCenter,
                              child: Text(
                                _isCollapsed
                                    ? 'Accueil'
                                    : 'Reprendre votre dernière lecture',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: _isCollapsed
                                    ? TextAlign.left
                                    : TextAlign.center,
                                style: _isCollapsed
                                    ? Theme.of(context).textTheme.titleLarge
                                    : TextStyle(
                                        fontSize: 16,
                                        color: _isCollapsed
                                            ? Colors.black
                                            : Colors.white,
                                        shadows: const <Shadow>[
                                            Shadow(
                                              offset: Offset(0.0, 2.0),
                                              blurRadius: 5.0,
                                              color: Colors.black,
                                            ),
                                          ]),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Novels dans votre bibliothèque',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                librarySection,
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Votre historique',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                historySection,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
