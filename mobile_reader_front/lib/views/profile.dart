import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:mobile_reader_front/components/generics/logout_button.dart';
import 'package:mobile_reader_front/components/profile/profile_image_section.dart';
import 'package:mobile_reader_front/components/profile/qr_code_section.dart';
import 'package:mobile_reader_front/components/profile/settings.dart';
import 'package:mobile_reader_front/provider/user_provider.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  static final String baseUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:3000';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onBackground,
        title: const Text('Profil'),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(8.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ProfileImageSection(),
                      QrCodeSection(),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  Card(
                    elevation: 2.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'Vous nous avez rejoint le ${DateFormat('dd/MM/yyyy').format(userProvider.dateJoined)}',
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  const Settings(),
                  const SizedBox(height: 16.0),
                  const LogoutButton(),
                ]),
          );
        },
      ),
    );
  }
}
