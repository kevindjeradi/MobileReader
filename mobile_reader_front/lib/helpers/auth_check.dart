import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_reader_front/components/generics/custom_loader.dart';
import 'package:mobile_reader_front/provider/auth_provider.dart';
import 'package:mobile_reader_front/provider/theme_color_scheme_provider.dart';
import 'package:mobile_reader_front/provider/user_provider.dart';
import 'package:mobile_reader_front/services/api.dart';
import 'package:mobile_reader_front/views/auth/login_page.dart';
import 'package:mobile_reader_front/views/navigation_screen.dart';
import 'package:provider/provider.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({Key? key}) : super(key: key);

  @override
  AuthCheckState createState() => AuthCheckState();
}

class AuthCheckState extends State<AuthCheck> {
  late Future<void> _checkAuth;
  bool _showRetry = false;
  Timer? _authTimer;

  @override
  void initState() {
    super.initState();
    _initializeAuthCheck();
  }

  @override
  void dispose() {
    _authTimer?.cancel();
    super.dispose();
  }

  void _initializeAuthCheck() {
    _checkAuth =
        Provider.of<AuthProvider>(context, listen: false).checkAuthStatus();
    setState(() {
      _showRetry = false;
    });
    _authTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && !_showRetry) {
        setState(() {
          _showRetry = true;
        });
      }
    });

    _checkAuth.then((_) {
      _authTimer?.cancel();
    }).catchError((error) {
      _authTimer?.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _checkAuth,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          if (authProvider.isAuthenticated) {
            final userProvider =
                Provider.of<UserProvider>(context, listen: false);
            final themeProvider =
                Provider.of<ThemeColorSchemeProvider>(context, listen: false);

            return FutureBuilder(
              future: Api.populateUserProvider(userProvider),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.done) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    themeProvider.setThemeByName(userProvider.theme);
                  });

                  return const NavigationScreen();
                } else {
                  return const CustomLoader();
                }
              },
            );
          } else {
            return const LoginPage();
          }
        } else if (_showRetry) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Problème de connexion"),
                  ElevatedButton(
                    onPressed: () {
                      _initializeAuthCheck();
                    },
                    child: const Text("Réessayer ?"),
                  ),
                ],
              ),
            ),
          );
        } else {
          // If the future is not done and the retry indicator is false, show loader
          return const Scaffold(body: CustomLoader());
        }
      },
    );
  }
}
