import 'package:flutter/material.dart';

// static settings screen.

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
            _buildRadioItem('Dark Mode', 'dark', enabled: true),
            _buildComingSoonItem('Light Mode'),
            _buildComingSoonItem('System Default'),
          ]),
          const SizedBox(height: 24),
          _buildSection('Language', [
            _buildLanguageItem('English', 'en', enabled: true),
            _buildComingSoonItem('Spanish'),
            _buildComingSoonItem('French'),
            _buildComingSoonItem('German'),
            _buildComingSoonItem('Chinese'),
            _buildComingSoonItem('Arabic'),
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

  Widget _buildRadioItem(String title, String value, {bool enabled = true}) {
    return InkWell(
      onTap: enabled ? () => setState(() => _theme = value) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _theme,
              onChanged: enabled ? (val) => setState(() => _theme = val!) : null,
              activeColor: const Color(0xFFB9C3FF),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: enabled ? Colors.white : Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageItem(String title, String value, {bool enabled = true}) {
    return InkWell(
      onTap: enabled ? () => setState(() => _language = value) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _language,
              onChanged: enabled ? (val) => setState(() => _language = val!) : null,
              activeColor: const Color(0xFFB9C3FF),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: enabled ? Colors.white : Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonItem(String title) {
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
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white.withValues(alpha: 0.05),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              'COMING SOON',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.4),
                letterSpacing: 0.5,
              ),
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
                onChanged: (value) => setState(() => _fontSize = value),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
