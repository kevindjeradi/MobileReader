import 'package:flutter/material.dart';
import 'package:mobile_reader_front/components/book_tile.dart';
import 'package:mobile_reader_front/provider/user_provider.dart';
import 'package:provider/provider.dart';

class Library extends StatelessWidget {
  const Library({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final novels = userProvider.novels;

    final favoriteNovels = novels.where((novel) => novel.isFavorite).toList();

    Widget favoritesSection = favoriteNovels.isNotEmpty
        ? SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: favoriteNovels.length,
              itemBuilder: (context, index) {
                return BookTile(
                  showFavorite: false,
                  novel: favoriteNovels[index],
                );
              },
            ),
          )
        : SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
            child: const Center(child: Text("Vous n'avez aucun favori")),
          );

    Widget librarySection = novels.isNotEmpty
        ? Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: novels.length,
              itemBuilder: (context, index) {
                return BookTile(
                  novel: novels[index],
                );
              },
            ),
          )
        : SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
            child: const Center(
                child: Text(
                    "Vous n'avez ajouté aucun novel dans votre bibliothèque")),
          );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onBackground,
        title: const Text('Bibliothèque'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Favoris',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          favoritesSection,
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Vos novels enregistrés',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          librarySection,
        ],
      ),
    );
  }
}
