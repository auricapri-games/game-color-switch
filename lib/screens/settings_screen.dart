import 'package:auricapri_games_common/auricapri_games_common.dart' as common;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ds/app_colors.dart';
import '../ds/app_theme.dart';
import '../widgets/gradient_background.dart';
import 'legal_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _sound = true;
  bool _haptics = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _sound = prefs.getBool('opt_sound') ?? true;
      _haptics = prefs.getBool('opt_haptics') ?? true;
    });
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('opt_sound', _sound);
    await prefs.setBool('opt_haptics', _haptics);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _Header(title: 'Settings', onBack: () => Navigator.of(context).pop()),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    SwitchListTile(
                      title: Text('Sound', style: AppTheme.subtitle(16)),
                      secondary: const Icon(
                        Icons.volume_up_rounded,
                        color: AppColors.primary,
                      ),
                      value: _sound,
                      activeColor: AppColors.primary,
                      onChanged: (v) {
                        setState(() => _sound = v);
                        _persist();
                      },
                    ),
                    SwitchListTile(
                      title: Text('Haptics', style: AppTheme.subtitle(16)),
                      secondary: const Icon(
                        Icons.vibration,
                        color: AppColors.primary,
                      ),
                      value: _haptics,
                      activeColor: AppColors.primary,
                      onChanged: (v) {
                        setState(() => _haptics = v);
                        _persist();
                      },
                    ),
                    const SizedBox(height: 8),
                    const common.LocalStorageNotice(),
                    common.LegalLink(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const LegalScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.text,
          ),
          const SizedBox(width: 4),
          Text(title, style: AppTheme.title(24)),
        ],
      ),
    );
  }
}
