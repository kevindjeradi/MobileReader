import 'package:flutter/material.dart';
import 'package:mobile_reader_front/components/generics/custom_snackbar.dart';
import 'package:mobile_reader_front/provider/theme_color_scheme_provider.dart';
import 'package:provider/provider.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeColorSchemeProvider>(context);

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.settings,
                    color: theme.colorScheme.primary, size: 30),
                const SizedBox(width: 10),
                Text(
                  'Paramètres du compte',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onBackground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 30.0, thickness: 2.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    "Changer le thème",
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: themeProvider.currentThemeName,
                    icon: Icon(
                      Icons.arrow_drop_down_outlined,
                      size: 24,
                      color: theme.colorScheme.onBackground,
                    ),
                    elevation: 8,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
                    dropdownColor: theme.colorScheme.surface,
                    onChanged: (String? newValue) {
                      themeProvider.updateTheme(newValue!).then((_) {
                        showCustomSnackBar(context, "Thème changé avec succès!",
                            SnackBarType.success);
                      }).catchError((error) {
                        showCustomSnackBar(
                            context,
                            "Erreur lors du changement de thème: $error",
                            SnackBarType.error);
                      });
                    },
                    items: themeProvider.availableThemes
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style:
                              TextStyle(color: theme.colorScheme.onBackground),
                        ),
                      );
                    }).toList(),
                    borderRadius: BorderRadius.circular(15),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
