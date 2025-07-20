import 'package:equatable/equatable.dart';
import '../../../../shared/providers/theme_provider.dart';

class AppSettings extends Equatable {
  final AppThemeMode themeMode;
  final bool hapticFeedback;
  final bool showOnboarding;
  final double defaultFontSize;
  final bool autoPlayOnSelection;
  final bool backgroundPlayback;
  final bool showProgressIndicator;

  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.hapticFeedback = true,
    this.showOnboarding = true,
    this.defaultFontSize = 18.0,
    this.autoPlayOnSelection = false,
    this.backgroundPlayback = true,
    this.showProgressIndicator = true,
  });

  AppSettings copyWith({
    AppThemeMode? themeMode,
    bool? hapticFeedback,
    bool? showOnboarding,
    double? defaultFontSize,
    bool? autoPlayOnSelection,
    bool? backgroundPlayback,
    bool? showProgressIndicator,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      showOnboarding: showOnboarding ?? this.showOnboarding,
      defaultFontSize: defaultFontSize ?? this.defaultFontSize,
      autoPlayOnSelection: autoPlayOnSelection ?? this.autoPlayOnSelection,
      backgroundPlayback: backgroundPlayback ?? this.backgroundPlayback,
      showProgressIndicator: showProgressIndicator ?? this.showProgressIndicator,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        hapticFeedback,
        showOnboarding,
        defaultFontSize,
        autoPlayOnSelection,
        backgroundPlayback,
        showProgressIndicator,
      ];
}