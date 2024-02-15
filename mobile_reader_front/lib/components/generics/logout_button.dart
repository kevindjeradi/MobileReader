import 'package:flutter/material.dart';
import 'package:mobile_reader_front/components/generics/custom_navigation.dart';
import 'package:mobile_reader_front/provider/auth_provider.dart';
import 'package:mobile_reader_front/views/auth/login_page.dart';
import 'package:provider/provider.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      children: [
        ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith(
                  (states) => theme.colorScheme.surface),
              foregroundColor: MaterialStateProperty.resolveWith(
                  (states) => theme.colorScheme.onBackground)),
          onPressed: () async {
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            await authProvider.logout();
            if (context.mounted) {
              CustomNavigation.pushReplacement(context, const LoginPage());
            }
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout),
              SizedBox(width: 10),
              Text("Se déconnecter"),
            ],
          ),
        ),
      ],
    );
  }
}
