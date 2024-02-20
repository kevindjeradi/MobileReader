// add_novel.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_reader_front/components/add_novel/novel_details_widget.dart';
import 'package:mobile_reader_front/components/generics/custom_loader.dart';
import 'package:mobile_reader_front/components/generics/custom_snackbar.dart';
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
    try {
      final results = await NovelService.searchNovels(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
        });
      }
    } catch (e) {
      if (mounted) {
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
    if (_searchResults.isEmpty) {
      return const SizedBox();
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final novel = _searchResults[index];
        return ListTile(
          title: Text(novel['title']),
          leading: Image.network(novel['imageUrl'], width: 50, height: 50),
          onTap: () => _fetchNovelDetails(novel['novelUrl']),
        );
      },
    );
  }

  void _addNovel() async {
    if (novelDetails != null) {
      final payload = {
        'novelTitle': novelDetails!['title'],
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
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
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
        title: const Text('Ajouter un novel'),
        elevation: 0,
        backgroundColor: theme.colorScheme.background,
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
                    _buildSearchResults(),
                    if (_isPageLoading) const CustomLoader(),
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
