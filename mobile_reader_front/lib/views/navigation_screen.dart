import 'package:flutter/material.dart';
import 'package:mobile_reader_front/views/add_novel.dart';
import 'package:mobile_reader_front/views/home.dart';
import 'package:mobile_reader_front/views/library.dart';
import 'package:mobile_reader_front/views/profile.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  NavigationScreenState createState() => NavigationScreenState();
}

class NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const Home(),
    const AddNovel(),
    const Library(),
    const Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
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
              icon: Icon(Icons.people),
              label: 'Profil',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          backgroundColor: Theme.of(context).colorScheme.background,
          selectedItemColor: Theme.of(context).colorScheme.onBackground,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
