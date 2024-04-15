// register_page.dart
import 'package:flutter/material.dart';
import 'package:mobile_reader_front/components/auth/register_form.dart';
import 'package:mobile_reader_front/components/generics/custom_loader.dart';
import 'package:mobile_reader_front/handlers/auth_handler.dart';
import 'package:mobile_reader_front/views/auth/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  bool _loading = false;
  late AuthHandler _authHandler;

  @override
  void initState() {
    super.initState();
    _authHandler = AuthHandler(context: context);
  }

  Future<void> _register(String username, String password, String email) async {
    setState(() {
      _loading = true;
    });

    await _authHandler.register(username, password, email);

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        if (_loading) const Center(child: CustomLoader()),
        Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text("S'inscrire",
                        style: Theme.of(context).textTheme.displayLarge),
                    const SizedBox(height: 32),
                    RegisterForm(
                      onRegister: (username, password, email) =>
                          _register(username, password, email),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                const LoginPage(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              const begin = Offset(-1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;
                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);
                              return SlideTransition(
                                  position: offsetAnimation, child: child);
                            },
                          ),
                        );
                      },
                      child: Text("Se connecter",
                          style:
                              TextStyle(color: theme.colorScheme.onBackground)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
