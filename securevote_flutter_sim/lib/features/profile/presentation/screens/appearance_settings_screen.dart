import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  State<AppearanceSettingsScreen> createState() =>
      _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends State<AppearanceSettingsScreen> {
  String _theme = 'dark';
  String _language = 'en';
  double _fontSize = 16.0;

  static const String _kThemeMode = 'theme_mode';
  static const String _kLanguage = 'appearance_language';
  static const String _kFontSize = 'appearance_font_size';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _theme = prefs.getString(_kThemeMode) ?? 'dark';
      _language = prefs.getString(_kLanguage) ?? 'en';
      _fontSize = prefs.getDouble(_kFontSize) ?? 16.0;
    });
  }

  Future<void> _setTheme(String value) async {
    setState(() => _theme = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeMode, value);
  }

  Future<void> _setLanguage(String value) async {
    setState(() => _language = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLanguage, value);
  }

  Future<void> _setFontSize(double value) async {
    setState(() => _fontSize = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kFontSize, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08090E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Appearance',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSection('Theme', [
            RadioGroup<String>(
              groupValue: _theme,
              onChanged: (value) {
                if (value != null) _setTheme(value);
              },
              child: Column(
                children: <Widget>[
                  _buildRadioItem('Dark Mode', 'dark'),
                  _buildInfoItem(
                    'Light Mode',
                    'Not customizable in this version.',
                  ),
                  _buildInfoItem(
                    'System Default',
                    'Not customizable in this version.',
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('Language', [
            RadioGroup<String>(
              groupValue: _language,
              onChanged: (value) {
                if (value != null) _setLanguage(value);
              },
              child: Column(
                children: <Widget>[
                  _buildLanguageItem('English', 'en'),
                  _buildInfoItem(
                    'Spanish',
                    'Not customizable in this version.',
                  ),
                  _buildInfoItem('French', 'Not customizable in this version.'),
                  _buildInfoItem('German', 'Not customizable in this version.'),
                  _buildInfoItem(
                    'Chinese',
                    'Not customizable in this version.',
                  ),
                  _buildInfoItem('Arabic', 'Not customizable in this version.'),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _buildFontSizeSection(),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.4),
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFF1A1D28),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildRadioItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Radio<String>(value: value, activeColor: const Color(0xFFB9C3FF)),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Radio<String>(value: value, activeColor: const Color(0xFFB9C3FF)),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String note) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(left: 12, right: 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  note,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFontSizeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'FONT SIZE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.4),
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFF1A1D28),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Small', style: TextStyle(color: Colors.white)),
                  Text(
                    '${_fontSize.round()}',
                    style: const TextStyle(
                      color: Color(0xFFB9C3FF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text('Large', style: TextStyle(color: Colors.white)),
                ],
              ),
              Slider(
                value: _fontSize,
                min: 12,
                max: 20,
                divisions: 8,
                activeColor: const Color(0xFFB9C3FF),
                onChanged: _setFontSize,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Font size is saved to this device only.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
