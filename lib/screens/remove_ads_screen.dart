import 'package:flutter/material.dart';

import '../ds/app_colors.dart';
import '../ds/app_theme.dart';
import '../widgets/candy_button.dart';
import '../widgets/gradient_background.dart';

class RemoveAdsScreen extends StatelessWidget {
  const RemoveAdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(onBack: () => Navigator.of(context).pop()),
                const SizedBox(height: 16),
                Image.asset(
                  'assets/sprites/mascot.png',
                  width: 140,
                  height: 140,
                ),
                Text(
                  'Remove Ads',
                  textAlign: TextAlign.center,
                  style: AppTheme.title(34),
                ),
                const SizedBox(height: 8),
                Text(
                  'Support indie devs and play without interruptions.',
                  textAlign: TextAlign.center,
                  style: AppTheme.body(15)
                      .copyWith(color: AppColors.text.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 24),
                ..._features.map(
                  (line) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(line, style: AppTheme.subtitle(15)),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                CandyButton(
                  label: 'BUY  ·  R\$  9,90',
                  icon: Icons.shopping_bag_outlined,
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Store purchase coming soon.'),
                      duration: Duration(seconds: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const _features = <String>[
  'No banner ads',
  'No interstitial ads between phases',
  'Restores on Google Play / App Store',
];

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.text,
        ),
      ],
    );
  }
}
