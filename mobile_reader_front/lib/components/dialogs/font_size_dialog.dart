import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSizeDialog extends StatefulWidget {
  final double initialFontSize;
  final Function(double) onFontSizeChanged;

  const FontSizeDialog({
    Key? key,
    required this.initialFontSize,
    required this.onFontSizeChanged,
  }) : super(key: key);

  @override
  FontSizeDialogState createState() => FontSizeDialogState();
}

class FontSizeDialogState extends State<FontSizeDialog> {
  late double _fontSize;

  @override
  void initState() {
    super.initState();
    _fontSize = widget.initialFontSize;
  }

  Future<void> _saveFontSize(double fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', fontSize);
    widget.onFontSizeChanged(fontSize);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Icon(Icons.font_download),
              Text(
                'Font Size',
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
            activeColor: theme.colorScheme.onBackground,
            inactiveColor: theme.colorScheme.onBackground.withOpacity(0.2),
            onChanged: (double value) {
              setState(() => _fontSize = value);
              _saveFontSize(_fontSize);
            },
          ),
        ],
      ),
    );
  }
}
