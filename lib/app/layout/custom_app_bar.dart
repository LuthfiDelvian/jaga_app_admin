import 'package:flutter/material.dart';
import 'package:jaga_app/app/pages/more/pages/chat_page.dart';
import 'package:jaga_app/app/pages/more/pages/notifications_page.dart';
import 'package:jaga_app/app/pages/settings/pages/settings_page.dart';

PreferredSizeWidget? buildCustomAppBar(BuildContext context, int selectedPage) {
  if (selectedPage != 0) return null;

  return AppBar(
    leading: IconButton(
      icon: const Icon(Icons.comment, color: Colors.amber),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatPage()),
        );
      },
    ),
    title: const Icon(Icons.person, color: Colors.purple),
    centerTitle: true,
    actions: [
      IconButton(
        icon: const Icon(Icons.notifications, color: Colors.red),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsPage()),
          );
        },
      ),
      IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsPage()),
          );
        },
      ),
    ],
    backgroundColor: Colors.grey,
  );
}