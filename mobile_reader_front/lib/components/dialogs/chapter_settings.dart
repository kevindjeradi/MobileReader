// chapter_settings.dart
import 'package:flutter/material.dart';
import 'package:mobile_reader_front/components/generics/custom_snackbar.dart';
import 'package:mobile_reader_front/provider/theme_color_scheme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChapterSettings extends StatefulWidget {
  final double initialFontSize;
  final double initialAutoScrollSpeed;
  final bool isAutoScrolling;
  final Function(double) onFontSizeChanged;
  final Function(double) onAutoScrollSpeedChanged;

  const ChapterSettings({
    Key? key,
    required this.initialFontSize,
    required this.onFontSizeChanged,
    required this.isAutoScrolling,
    required this.initialAutoScrollSpeed,
    required this.onAutoScrollSpeedChanged,
  }) : super(key: key);

  @override
  ChapterSettingsState createState() => ChapterSettingsState();
}

class ChapterSettingsState extends State<ChapterSettings> {
  late double _fontSize;
  late double _autoScrollSpeed;
  bool _isNightMode = false;

  @override
  void initState() {
    super.initState();
    _fontSize = widget.initialFontSize;
    _autoScrollSpeed = widget.initialAutoScrollSpeed;
  }

  Future<void> _saveFontSize(double fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', fontSize);
    widget.onFontSizeChanged(fontSize);
  }

  Future<void> _saveAutoScrollSpeed(double speed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('autoScrollSpeed', speed);
    widget.onAutoScrollSpeedChanged(speed);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeColorSchemeProvider>(context);

    return AlertDialog(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Icon(Icons.font_download),
                  Text(
                    'Taille de la police',
                    style: theme.textTheme.headlineSmall,
                  ),
                  Text(
                    _fontSize.toStringAsFixed(0),
                    style: theme.textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Slider(
                min: 10.0,
                max: 32.0,
                value: _fontSize,
                onChanged: widget.isAutoScrolling
                    ? null
                    : (double value) {
                        setState(() => _fontSize = value);
                        _saveFontSize(_fontSize);
                      },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Icon(Icons.fast_forward),
                  Text(
                    "Vitesse de l'auto scroll",
                    style: theme.textTheme.headlineSmall,
                  ),
                  Text(
                    _autoScrollSpeed.toStringAsFixed(0),
                    style: theme.textTheme.headlineSmall,
                  ),
                ],
              ),
              Slider(
                min: 1.0,
                max: 100.0,
                value: _autoScrollSpeed,
                onChanged: (double value) {
                  setState(() => _autoScrollSpeed = value);
                  _saveAutoScrollSpeed(_autoScrollSpeed);
                },
              ),
              const SizedBox(width: 32),
              IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () {
                  String newTheme = themeProvider.currentThemeName == 'Clair'
                      ? 'Sombre'
                      : 'Clair';
                  themeProvider.updateTheme(newTheme).catchError((error) {
                    showCustomSnackBar(
                        context,
                        "Impossible de changer le thème: $error",
                        SnackBarType.error);
                  });
                  setState(() {
                    _isNightMode = newTheme == 'Sombre';
                  });
                },
                icon: Icon(
                  _isNightMode ? Icons.wb_sunny : Icons.brightness_2_outlined,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
