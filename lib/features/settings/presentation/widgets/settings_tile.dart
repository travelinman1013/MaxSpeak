import 'package:flutter/material.dart';
import '../../../../shared/utils/app_theme.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingS,
            vertical: AppTheme.spacingM,
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppTheme.spacingM),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: enabled
                                ? null
                                : Theme.of(context).disabledColor,
                          ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: enabled
                                  ? Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color
                                  : Theme.of(context).disabledColor,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppTheme.spacingM),
                trailing!,
              ] else if (onTap != null) ...[
                const SizedBox(width: AppTheme.spacingM),
                Icon(
                  Icons.chevron_right,
                  color: enabled
                      ? Theme.of(context).textTheme.bodySmall?.color
                      : Theme.of(context).disabledColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}