import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_reader_front/helpers/auth_check.dart';
import 'package:mobile_reader_front/provider/auth_provider.dart';
import 'package:mobile_reader_front/provider/theme_color_scheme_provider.dart';
import 'package:mobile_reader_front/provider/user_provider.dart';
import 'package:mobile_reader_front/theme/theme_light.dart';
import 'package:mobile_reader_front/views/auth/login_page.dart';
import 'package:mobile_reader_front/views/auth/register_page.dart';
import 'package:mobile_reader_front/views/navigation_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => ThemeColorSchemeProvider()),
    ChangeNotifierProvider(create: (context) => AuthProvider()),
    ChangeNotifierProvider(create: (context) => UserProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeColorSchemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'K Reader',
      theme: themeLight(themeProvider.colorScheme, themeProvider.textTheme),
      themeMode: ThemeMode.light,
      home: const AuthCheck(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const NavigationScreen(),
      },
    );
  }
}
