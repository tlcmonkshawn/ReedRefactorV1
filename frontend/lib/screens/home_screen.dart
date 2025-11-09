import 'package:flutter/material.dart';
import 'package:bootiehunter/widgets/app_icon.dart';
import 'package:bootiehunter/providers/bootie_provider.dart';
import 'package:bootiehunter/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('R.E.E.D. Bootie Hunter'),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              if (authProvider.currentUser?.canFinalize ?? false) {
                return IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: () {
                    Navigator.pushNamed(context, '/prompts');
                  },
                  tooltip: 'AI Prompts Config',
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 3,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          Consumer<BootieProvider>(
            builder: (context, provider, _) => AppIcon(
              icon: Icons.inventory,
              label: 'Booties',
              onTap: () {
                Navigator.pushNamed(context, '/booties');
              },
              badgeCount: provider.pendingCount,
            ),
          ),
          AppIcon(
            icon: Icons.phone,
            label: 'Phone',
            onTap: () {
              Navigator.pushNamed(context, '/phone');
            },
          ),
          AppIcon(
            icon: Icons.message,
            label: 'Messages',
            onTap: () {
              Navigator.pushNamed(context, '/messages');
            },
            badgeCount: 2, // TODO: Get from state
          ),
          AppIcon(
            icon: Icons.calculate,
            label: 'Calculator',
            onTap: () {
              // TODO: Open calculator
            },
          ),
          AppIcon(
            icon: Icons.facebook,
            label: 'Facebook',
            onTap: () {
              // TODO: Open Facebook streaming
            },
          ),
          AppIcon(
            icon: Icons.video_library,
            label: 'YouTube',
            onTap: () {
              // TODO: Open YouTube streaming
            },
          ),
          AppIcon(
            icon: Icons.gamepad,
            label: 'Twitch',
            onTap: () {
              // TODO: Open Twitch streaming
            },
          ),
          AppIcon(
            icon: Icons.camera_alt,
            label: 'Instagram',
            onTap: () {
              // TODO: Open Instagram streaming
            },
          ),
        ],
      ),
    );
  }
}

