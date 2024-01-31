import 'package:flutter/material.dart';
import 'package:mobile_reader_front/components/book_tile.dart';

class Library extends StatelessWidget {
  const Library({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Bibiliothèque'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Favoris',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 250,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const <Widget>[
                BookTile(
                  width: 200,
                  coverUrl: 'https://via.placeholder.com/100x150',
                  title: 'When A Mage Revolts',
                  author: 'Yin Si',
                  progress: 0.8,
                  favorite: false,
                ),
                SizedBox(width: 8),
                BookTile(
                  width: 200,
                  coverUrl: 'https://via.placeholder.com/100x150',
                  title: 'True Martial World',
                  author: 'Cocooned Cow',
                  progress: 0.98,
                  favorite: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Téléchargés',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 250,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const <Widget>[
                BookTile(
                  width: 200,
                  coverUrl: 'https://via.placeholder.com/100x150',
                  title: 'When A Mage Revolts',
                  author: 'Yin Si',
                  progress: 0.8,
                  favorite: false,
                ),
                SizedBox(width: 8),
                BookTile(
                  width: 200,
                  coverUrl: 'https://via.placeholder.com/100x150',
                  title: 'True Martial World',
                  author: 'Cocooned Cow',
                  progress: 0.98,
                  favorite: true,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
