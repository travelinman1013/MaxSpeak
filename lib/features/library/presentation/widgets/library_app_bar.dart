import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/utils/app_theme.dart';
import '../providers/document_provider.dart';
import 'document_search_delegate.dart';

class LibraryAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const LibraryAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          Scaffold.of(context).openDrawer();
        },
        tooltip: 'Menu',
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            final documents = ref.read(documentsProvider).documents;
            showSearch(
              context: context,
              delegate: DocumentSearchDelegate(documents: documents),
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
