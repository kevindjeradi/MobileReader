import 'package:flutter/material.dart';
import 'package:mobile_reader_front/components/book_tile.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'En cours',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const Center(
          child: SizedBox(
            height: 300,
            child: BookTile(
              width: 400,
              coverUrl: 'https://via.placeholder.com/100x150',
              title: 'When A Mage Revolts',
              author: 'Yin Si',
              progress: 0.8,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Historique',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
              ),
              SizedBox(width: 8),
              BookTile(
                width: 200,
                coverUrl: 'https://via.placeholder.com/100x150',
                title: 'True Martial World',
                author: 'Cocooned Cow',
                progress: 0.98,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
