import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../shared/utils/app_theme.dart';

class AddDocumentFab extends StatelessWidget {
  const AddDocumentFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddDocumentOptions(context),
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 8,
      child: const Icon(Icons.add, size: 28),
    );
  }

  void _showAddDocumentOptions(BuildContext context) {
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
                onTap: () => _pickFileFromDevice(context),
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

  Future<void> _pickFileFromDevice(BuildContext context) async {
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
          // TODO: Add document to library
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Adding ${file.name}...'),
                action: SnackBarAction(
                  label: 'View',
                  onPressed: () {
                    // TODO: Navigate to document
                  },
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
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
}