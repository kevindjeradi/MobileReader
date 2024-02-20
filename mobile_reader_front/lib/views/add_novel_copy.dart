// add_novel.dart
import 'package:flutter/material.dart';
import 'package:mobile_reader_front/components/add_novel/novel_details_widget.dart';
import 'package:mobile_reader_front/components/add_novel/novel_url_field.dart';
import 'package:mobile_reader_front/components/generics/custom_loader.dart';
import 'package:mobile_reader_front/components/generics/custom_snackbar.dart';
import 'package:mobile_reader_front/provider/user_provider.dart';
import 'package:mobile_reader_front/services/api.dart';
import 'package:mobile_reader_front/services/novel_service.dart';
import 'package:provider/provider.dart';

class AddNovel extends StatefulWidget {
  final String novelSource;

  const AddNovel({super.key, required this.novelSource});

  @override
  AddNovelState createState() => AddNovelState();
}

class AddNovelState extends State<AddNovel> {
  final _formKey = GlobalKey<FormState>();
  String _novelUrl = '';
  bool _isPageLoading = false;
  bool _isNovelLoading = false;
  Map<String, dynamic>? novelDetails;

  void _fetchNovelDetails() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        setState(() {
          _isPageLoading = true;
        });
        final details = await NovelService.fetchChapters(_novelUrl);
        setState(() {
          novelDetails = details;
          _isPageLoading = false;
        });
      } catch (e) {
        if (mounted) {
          showCustomSnackBar(
              context, "Failed to fetch novel details", SnackBarType.error);
        }
      }
    }
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      NovelUrlField(
                        onSaved: (value) => _novelUrl = value,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith(
                                (states) => theme.colorScheme.surface),
                            foregroundColor: MaterialStateProperty.resolveWith(
                                (states) => theme.colorScheme.onBackground)),
                        onPressed: _fetchNovelDetails,
                        child: const Text('Récupérer les infos du novel'),
                      ),
                      if (novelDetails != null) ...[
                        NovelDetailsWidget(
                          novelDetails: novelDetails!,
                          isNovelLoading: _isNovelLoading,
                          onAddNovel: _addNovel,
                        )
                      ]
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
