// add_novel.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_reader_front/components/add_novel/novel_details_widget.dart';
import 'package:mobile_reader_front/components/generics/custom_loader.dart';
import 'package:mobile_reader_front/components/generics/custom_snackbar.dart';
import 'package:mobile_reader_front/helpers/logger.dart';
import 'package:mobile_reader_front/provider/user_provider.dart';
import 'package:mobile_reader_front/services/api.dart';
import 'package:mobile_reader_front/services/novel_service.dart';
import 'package:provider/provider.dart';

class AddNovel extends StatefulWidget {
  const AddNovel({super.key});

  @override
  AddNovelState createState() => AddNovelState();
}

class AddNovelState extends State<AddNovel> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  GlobalKey novelDetailsKey = GlobalKey();
  Timer? _debounce;
  List<dynamic> _searchResults = [];
  bool _isPageLoading = false;
  bool _isNovelLoading = false;
  bool _isSearching = false;
  bool _gettingCompletedNovels = false;
  Map<String, dynamic>? novelDetails;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (_searchController.text.length >= 3) {
        _performSearch(_searchController.text);
      } else {
        setState(() {
          _searchResults = [];
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = true; // Start searching
      if (_gettingCompletedNovels) _gettingCompletedNovels = false;
    });
    try {
      final results = await NovelService.searchNovels(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false; // Search completed
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false; // Search failed
        });
        showCustomSnackBar(
            context, "Failed to search novels", SnackBarType.error);
      }
    }
  }

  Future<void> _fetchCompletedNovels() async {
    setState(() {
      _isSearching = true; // Start searching
      if (!_gettingCompletedNovels) _gettingCompletedNovels = true;
    });
    try {
      final results = await NovelService.searchCompletedNovels();
      if (mounted) {
        setState(() {
          _searchResults = [];
          _searchResults = results;
          _isSearching = false; // Search completed
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false; // Search failed
        });
        showCustomSnackBar(
            context, "Failed to search novels", SnackBarType.error);
      }
    }
  }

  void _fetchNovelDetails(String novelUrl) async {
    try {
      setState(() {
        _isPageLoading = true;
      });
      final details = await NovelService.fetchChapters(novelUrl);
      setState(() {
        novelDetails = details;
        _isPageLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (novelDetailsKey.currentContext != null) {
          final RenderBox renderBox =
              novelDetailsKey.currentContext!.findRenderObject() as RenderBox;
          final offset = renderBox.localToGlobal(Offset.zero);

          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              offset.dy - (MediaQuery.of(context).padding.top + kToolbarHeight),
              duration: const Duration(seconds: 1),
              curve: Curves.fastOutSlowIn,
            );
          }
        }
      });
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(
            context, "Failed to fetch novel details", SnackBarType.error);
      }
    }
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty && !_gettingCompletedNovels) {
      return _searchController.text.length < 3
          ? const SizedBox()
          : const Text('Aucun résultat trouvé');
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final novel = _searchResults[index];
        return ListTile(
          title: Text(novel['title']),
          leading: Image.network(
            novel['imageUrl'],
            width: 50,
            height: 50,
            fit: BoxFit.contain,
          ),
          trailing: _gettingCompletedNovels
              ? Text(novel['chapterCount'].toString())
              : null,
          onTap: () => _fetchNovelDetails(novel['novelUrl']),
        );
      },
    );
  }

  void _addNovel() async {
    if (novelDetails != null) {
      final payload = {
        'title': novelDetails!['title'],
        'author': novelDetails!['author'],
        'coverUrl': novelDetails!['coverUrl'],
        'description': novelDetails!['description'],
        'numberOfChapters': novelDetails!['chapters'].length,
        'chaptersDetails': novelDetails!['chapters'],
      };

      try {
        setState(() {
          _isNovelLoading = true;
        });
        final response = await NovelService.addNovel(payload);
        if (response['novelAdded'] == true) {
          if (mounted) {
            final userProvider =
                Provider.of<UserProvider>(context, listen: false);
            await Api.populateUserProvider(userProvider);
          }
          if (mounted) {
            showCustomSnackBar(
                context,
                "Le novel a été ajouté à votre bibliothèque",
                SnackBarType.success);
          }
        } else if (response['novelAdded'] == false) {
          if (mounted) {
            showCustomSnackBar(context,
                "Le novel est déjà dans votre bibliothèque", SnackBarType.info);
          }
        }
        setState(() {
          _isNovelLoading = false;
        });
      } catch (e) {
        if (mounted) {
          Log.logger.e("An error occurred in _addNovel: $e");
          showCustomSnackBar(
              context, "Impossible d'ajouter le novel", SnackBarType.error);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Ajouter un novel'),
        elevation: 0,
        backgroundColor: theme.colorScheme.background,
        foregroundColor: theme.colorScheme.onBackground,
      ),
      backgroundColor: theme.colorScheme.background,
      body: _isPageLoading
          ? const CustomLoader()
          : SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Chercher un novel',
                        labelStyle:
                            TextStyle(color: theme.colorScheme.onBackground),
                        suffixIcon: const Icon(Icons.search),
                        suffixIconColor: theme.colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(child: Text("ou")),
                    const SizedBox(height: 20),
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () => _fetchCompletedNovels(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                        child: const Card(
                            child: Center(
                                child: Text("Chercher les novels terminés"))),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_isPageLoading || _isSearching)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: CustomLoader(),
                      ),
                    _buildSearchResults(),
                    if (novelDetails != null) ...[
                      NovelDetailsWidget(
                        key: novelDetailsKey,
                        novelDetails: novelDetails!,
                        isNovelLoading: _isNovelLoading,
                        onAddNovel: _addNovel,
                      )
                    ]
                  ],
                ),
              ),
            ),
    );
  }
}
