import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/utils/app_theme.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingM,
            vertical: AppTheme.spacingS,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.book_outlined,
                selectedIcon: Icons.book,
                label: 'Library',
                index: 0,
                context: context,
              ),
              _buildNavItem(
                icon: Icons.headphones_outlined,
                selectedIcon: Icons.headphones,
                label: 'Now Playing',
                index: 1,
                context: context,
              ),
              _buildNavItem(
                icon: Icons.bar_chart_outlined,
                selectedIcon: Icons.bar_chart,
                label: 'Stats',
                index: 2,
                context: context,
              ),
              _buildNavItem(
                icon: Icons.star_outline,
                selectedIcon: Icons.star,
                label: 'Premium',
                index: 3,
                context: context,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required BuildContext context,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected
        ? AppTheme.primaryColor
        : Theme.of(context).bottomNavigationBarTheme.unselectedItemColor;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: AppConstants.fastAnimationDuration,
              child: Icon(
                isSelected ? selectedIcon : icon,
                color: color,
                size: 24,
                key: ValueKey(isSelected),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
