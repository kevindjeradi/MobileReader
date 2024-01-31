import 'package:flutter/material.dart';
import 'package:mobile_reader_front/views/home.dart';
import 'package:mobile_reader_front/views/library.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  NavigationScreenState createState() => NavigationScreenState();
}

class NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const Home(),
    const Text('Rechercher (à venir)'),
    const Library(),
    const Text('Réglages (à venir)'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Rechercher',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'Bibliothèque',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Réglages',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
