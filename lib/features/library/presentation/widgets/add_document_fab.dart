import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/utils/app_theme.dart';
import '../providers/document_provider.dart';

class AddDocumentFab extends ConsumerWidget {
  const AddDocumentFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () => _showAddDocumentOptions(context, ref),
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 8,
      child: const Icon(Icons.add, size: 28),
    );
  }

  void _showAddDocumentOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLarge)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              
              // Title
              Text(
                'Add Document',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              
              // Options
              _buildOption(
                context: context,
                icon: Icons.file_upload_outlined,
                title: 'Upload from Device',
                subtitle: 'Choose PDF from your device',
                onTap: () => _pickFileFromDevice(context, ref),
              ),
              const SizedBox(height: AppTheme.spacingM),
              
              _buildOption(
                context: context,
                icon: Icons.cloud_upload_outlined,
                title: 'Import from Cloud',
                subtitle: 'Google Drive, Dropbox, etc.',
                onTap: () => _importFromCloud(context),
              ),
              const SizedBox(height: AppTheme.spacingM),
              
              _buildOption(
                context: context,
                icon: Icons.camera_alt_outlined,
                title: 'Scan Document',
                subtitle: 'Use camera to scan pages',
                onTap: () => _scanDocument(context),
              ),
              
              const SizedBox(height: AppTheme.spacingL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFileFromDevice(BuildContext context, WidgetRef ref) async {
    Navigator.pop(context);
    
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        if (file.path != null) {
          // Show loading snackbar
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Adding ${file.name}...')),
                  ],
                ),
                duration: const Duration(seconds: 30), // Long duration for processing
              ),
            );
          }

          // Add document using provider
          final documentsNotifier = ref.read(documentsProvider.notifier);
          final success = await documentsNotifier.addDocumentFromPath(file.path!);
          
          if (context.mounted) {
            // Clear the loading snackbar
            ScaffoldMessenger.of(context).clearSnackBars();
            
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${AppConstants.documentAddedSuccess}: ${file.name}'),
                  backgroundColor: AppTheme.secondaryColor,
                  action: SnackBarAction(
                    label: 'View',
                    textColor: Colors.white,
                    onPressed: () {
                      // TODO: Navigate to document reader
                    },
                  ),
                ),
              );
            } else {
              final error = ref.read(documentsProvider).error ?? 'Unknown error occurred';
              final userFriendlyError = _getUserFriendlyErrorMessage(error);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to add document: $userFriendlyError'),
                  backgroundColor: AppTheme.errorColor,
                  duration: const Duration(seconds: 6),
                  action: SnackBarAction(
                    label: 'Retry',
                    textColor: Colors.white,
                    onPressed: () => _pickFileFromDevice(context, ref),
                  ),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _importFromCloud(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cloud import - Coming Soon')),
    );
  }

  void _scanDocument(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document scanning - Coming Soon')),
    );
  }

  /// Convert technical error messages to user-friendly ones
  String _getUserFriendlyErrorMessage(String error) {
    final lowerError = error.toLowerCase();
    
    if (lowerError.contains('too large') || lowerError.contains('size')) {
      return 'File is too large (max ${AppConstants.maxPdfSizeMB}MB)';
    }
    
    if (lowerError.contains('corrupted') || lowerError.contains('invalid') || lowerError.contains('not a valid pdf')) {
      return 'File is not a valid PDF document';
    }
    
    if (lowerError.contains('permission') || lowerError.contains('access')) {
      return 'Permission denied - check file access';
    }
    
    if (lowerError.contains('storage') || lowerError.contains('space')) {
      return 'Not enough storage space available';
    }
    
    if (lowerError.contains('encryption') || lowerError.contains('security')) {
      return 'Security error - please try again';
    }
    
    if (lowerError.contains('network') || lowerError.contains('connection')) {
      return 'Network error - check your connection';
    }
    
    if (lowerError.contains('not found') || lowerError.contains('file not found')) {
      return 'File could not be found';
    }
    
    // If no specific error pattern matches, return a generic but helpful message
    return 'Unable to process file - please try a different PDF';
  }
}