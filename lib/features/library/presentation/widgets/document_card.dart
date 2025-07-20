import 'package:flutter/material.dart';
import '../../../../shared/utils/app_theme.dart';
import '../../domain/entities/document.dart';

class DocumentCard extends StatelessWidget {
  final Document document;
  final VoidCallback onTap;

  const DocumentCard({
    super.key,
    required this.document,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Document Cover
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    gradient: _getGradientForDocument(document.id),
                  ),
                  child: Stack(
                    children: [
                      // PDF Icon
                      const Center(
                        child: Icon(
                          Icons.picture_as_pdf,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      
                      // Progress indicator (if reading started)
                      if (document.isStarted && !document.isCompleted)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${(document.readingProgress * 100).round()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      
                      // Completed badge
                      if (document.isCompleted)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingS),
              
              // Document Info
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      document.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Page count
                    Text(
                      '${document.totalPages} pages',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                    
                    const SizedBox(height: 2),
                    
                    // Reading status
                    Text(
                      document.readingStatus,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(document),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Progress bar
                    if (document.isStarted)
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).dividerColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: document.readingProgress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.progressColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
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

  LinearGradient _getGradientForDocument(String documentId) {
    // Generate gradient based on document ID for consistent colors
    final hash = documentId.hashCode;
    final gradients = [
      const LinearGradient(
        colors: [AppTheme.primaryColor, Color(0xFFFF8A65)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [AppTheme.secondaryColor, Color(0xFF4CAF50)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ];
    
    return gradients[hash.abs() % gradients.length];
  }

  Color _getStatusColor(Document document) {
    if (document.isCompleted) {
      return AppTheme.secondaryColor;
    } else if (document.isStarted) {
      return AppTheme.primaryColor;
    } else {
      return Colors.grey;
    }
  }
}