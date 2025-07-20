import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/utils/app_theme.dart';

class LibraryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LibraryAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        AppConstants.appName,
        style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          // TODO: Open drawer/side menu
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menu - Coming Soon')),
          );
        },
        tooltip: 'Menu',
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // TODO: Open search
            showSearch(
              context: context,
              delegate: DocumentSearchDelegate(),
            );
          },
          tooltip: 'Search',
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            context.go(AppConstants.settingsRoute);
          },
          tooltip: 'Settings',
        ),
        const SizedBox(width: AppTheme.spacingS),
      ],
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Simple search delegate for now
class DocumentSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return const Center(
      child: Text('Search functionality coming soon'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(
      child: Text('Start typing to search your documents'),
    );
  }
}