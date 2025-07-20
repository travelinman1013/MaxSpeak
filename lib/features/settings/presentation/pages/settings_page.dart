import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/utils/app_theme.dart';
import '../../../../core/utils/service_locator.dart';
import '../../../../core/services/settings_service.dart';
import '../../../tts/domain/entities/tts_voice.dart';
import '../../../tts/domain/usecases/manage_tts_settings.dart';
import '../../../../core/usecases/usecase.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../widgets/theme_selector_dialog.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late bool _hapticFeedback;
  late bool _readingSounds;
  late bool _autoSaveProgress;
  late bool _syncAcrossDevices;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final settingsService = SettingsService.instance;
    _hapticFeedback = settingsService.hapticFeedback;
    _readingSounds = settingsService.readingSounds;
    _autoSaveProgress = settingsService.autoSaveProgress;
    _syncAcrossDevices = settingsService.syncAcrossDevices;
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              HapticFeedback.lightImpact();
              // Refresh settings functionality
            },
            tooltip: 'Refresh Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section - Enhanced with font size control
            SettingsSection(
              title: 'Appearance',
              icon: Icons.palette_outlined,
              children: [
                SettingsTile(
                  title: 'Theme Mode',
                  subtitle: currentTheme.displayName,
                  leading: Icon(
                    _getThemeIcon(currentTheme),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () => _showThemeSelector(context, ref),
                ),
                const SizedBox(height: AppTheme.spacingS),
                SettingsTile(
                  title: 'Color Scheme',
                  subtitle: 'Orange & Green (Default)',
                  leading: Icon(
                    Icons.color_lens_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showColorSchemeDialog(context);
                  },
                ),
                const SizedBox(height: AppTheme.spacingS),
                SettingsTile(
                  title: 'Reading Font Size',
                  subtitle: 'Optimize text for comfortable reading',
                  leading: Icon(
                    Icons.text_fields,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showFontSizeDialog(context);
                  },
                ),
                const SizedBox(height: AppTheme.spacingS),
              ],
            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),

            const SizedBox(height: AppTheme.spacingL),

            // Reading Preferences Section - Enhanced with new options
            SettingsSection(
              title: 'Reading Preferences',
              icon: Icons.book_outlined,
              children: [
                SettingsTile(
                  title: 'Haptic Feedback',
                  subtitle: 'Vibrate on interactions',
                  leading: Icon(
                    Icons.vibration,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  trailing: Switch.adaptive(
                    value: _hapticFeedback,
                    onChanged: (value) async {
                      if (value) {
                        HapticFeedback.lightImpact();
                      }
                      await SettingsService.instance.setHapticFeedback(value);
                      setState(() {
                        _hapticFeedback = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                SettingsTile(
                  title: 'Reading Sounds',
                  subtitle: 'Audio feedback for actions',
                  leading: Icon(
                    Icons.volume_up_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  trailing: Switch.adaptive(
                    value: _readingSounds,
                    onChanged: (value) async {
                      if (_hapticFeedback) {
                        HapticFeedback.lightImpact();
                      }
                      await SettingsService.instance.setReadingSounds(value);
                      setState(() {
                        _readingSounds = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                SettingsTile(
                  title: 'Auto-Save Progress',
                  subtitle: 'Automatically save reading position',
                  leading: Icon(
                    Icons.save_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  trailing: Switch.adaptive(
                    value: _autoSaveProgress,
                    onChanged: (value) async {
                      if (_hapticFeedback) {
                        HapticFeedback.lightImpact();
                      }
                      await SettingsService.instance.setAutoSaveProgress(value);
                      setState(() {
                        _autoSaveProgress = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                SettingsTile(
                  title: 'Sync Across Devices',
                  subtitle: 'Sync library and progress',
                  leading: Icon(
                    Icons.cloud_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  trailing: Switch.adaptive(
                    value: _syncAcrossDevices,
                    onChanged: (value) async {
                      if (_hapticFeedback) {
                        HapticFeedback.lightImpact();
                      }
                      await SettingsService.instance.setSyncAcrossDevices(value);
                      setState(() {
                        _syncAcrossDevices = value;
                      });
                      
                      // Show info for future feature
                      if (value && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cloud sync will be available in a future update'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
              ],
            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),

            const SizedBox(height: AppTheme.spacingL),

            // TTS Settings Section - New section matching design
            SettingsSection(
              title: 'Text-to-Speech Settings',
              icon: Icons.mic_outlined,
              children: [
                SettingsTile(
                  title: 'Default Voice',
                  subtitle: 'Samantha (US English)',
                  leading: Icon(
                    Icons.person_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showVoiceSelectionDialog(context);
                  },
                ),
                const SizedBox(height: AppTheme.spacingS),
                SettingsTile(
                  title: 'Speech Rate',
                  subtitle: '1.5x Normal Speed',
                  leading: Icon(
                    Icons.speed_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showSpeechRateDialog(context);
                  },
                ),
                const SizedBox(height: AppTheme.spacingS),
                SettingsTile(
                  title: 'Pitch & Volume',
                  subtitle: 'Advanced audio settings',
                  leading: Icon(
                    Icons.tune_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showAdvancedTTSDialog(context);
                  },
                ),
                const SizedBox(height: AppTheme.spacingS),
              ],
            ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),

            const SizedBox(height: AppTheme.spacingL),

            // About Section - Enhanced with better descriptions
            SettingsSection(
              title: 'About',
              icon: Icons.info_outline,
              children: [
                SettingsTile(
                  title: 'App Version',
                  subtitle: 'MaxSpeak v1.0.0 (Alpha)',
                  leading: Icon(
                    Icons.smartphone_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showAboutDialog(context);
                  },
                ),
                const SizedBox(height: AppTheme.spacingS),
                SettingsTile(
                  title: 'Privacy Policy',
                  subtitle: 'How we protect your data',
                  leading: Icon(
                    Icons.shield_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(context, '/privacy-policy');
                  },
                ),
                const SizedBox(height: AppTheme.spacingS),
                SettingsTile(
                  title: 'Terms of Service',
                  subtitle: 'Legal terms and conditions',
                  leading: Icon(
                    Icons.description_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(context, '/terms-of-service');
                  },
                ),
                const SizedBox(height: AppTheme.spacingS),
                SettingsTile(
                  title: 'Reset All Settings',
                  subtitle: 'Restore default configuration',
                  leading: Icon(
                    Icons.refresh_outlined,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _showResetDialog(context, ref);
                  },
                ),
                const SizedBox(height: AppTheme.spacingS),
              ],
            ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),

            // Add bottom padding for better UX
            const SizedBox(height: AppTheme.spacingXL),
          ],
        ),
      ),
    );
  }

  IconData _getThemeIcon(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.auto_mode;
    }
  }

  void _showThemeSelector(BuildContext context, WidgetRef ref) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => ThemeSelectorDialog(ref: ref),
    );
  }

  void _showColorSchemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Color Scheme'),
        content: const Text(
          'Color scheme customization will be available in a future update. Currently using the MaxSpeak Orange & Green theme optimized for reading.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context) {
    double currentFontSize = SettingsService.instance.readingFontSize;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Reading Font Size'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Adjust the font size for comfortable reading.'),
              const SizedBox(height: 16),
              const Text('This will affect text in the PDF reader.'),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Small'),
                  Expanded(
                    child: Slider(
                      value: currentFontSize,
                      min: 12.0,
                      max: 24.0,
                      divisions: 12,
                      onChanged: (value) {
                        setState(() {
                          currentFontSize = value;
                        });
                      },
                    ),
                  ),
                  const Text('Large'),
                ],
              ),
              Text('Current: ${currentFontSize.round()}px'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Sample reading text',
                  style: TextStyle(fontSize: currentFontSize),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await SettingsService.instance.setReadingFontSize(currentFontSize);
                if (_hapticFeedback) {
                  HapticFeedback.lightImpact();
                }
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Font size set to ${currentFontSize.round()}px')),
                );
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  void _showVoiceSelectionDialog(BuildContext context) async {
    try {
      final getVoicesUseCase = getIt<GetAvailableVoices>();
      final result = await getVoicesUseCase.call(const NoParams());
      
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading voices: ${failure.message}')),
          );
        },
        (voices) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Select Voice'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  itemCount: voices.length,
                  itemBuilder: (context, index) {
                    final voice = voices[index];
                    return ListTile(
                      title: Text(voice.name),
                      subtitle: Text('${voice.language} • Quality: ${voice.quality}/5'),
                      leading: Icon(
                        voice.gender == 'female' ? Icons.person_4 : Icons.person,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _setVoice(voice);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _setVoice(TtsVoice voice) async {
    try {
      final setVoiceUseCase = getIt<SetTtsVoice>();
      final result = await setVoiceUseCase.call(voice);
      
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error setting voice: ${failure.message}')),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Voice changed to ${voice.name}')),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showSpeechRateDialog(BuildContext context) {
    double currentRate = 1.5; // Default value
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Speech Rate'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Adjust the speech speed for comfortable listening.'),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('0.5x'),
                  Expanded(
                    child: Slider(
                      value: currentRate,
                      min: 0.5,
                      max: 3.0,
                      divisions: 25,
                      onChanged: (value) {
                        setState(() {
                          currentRate = value;
                        });
                      },
                    ),
                  ),
                  const Text('3.0x'),
                ],
              ),
              Text('Current: ${currentRate.toStringAsFixed(1)}x'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _setSpeechRate(currentRate);
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setSpeechRate(double rate) async {
    try {
      final setSpeechRateUseCase = getIt<SetSpeechRate>();
      final result = await setSpeechRateUseCase.call(rate);
      
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error setting speech rate: ${failure.message}')),
          );
        },
        (_) {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Speech rate set to ${rate.toStringAsFixed(1)}x')),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showAdvancedTTSDialog(BuildContext context) {
    double currentPitch = 1.0;
    double currentVolume = 1.0;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Advanced TTS Settings'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Fine-tune your text-to-speech experience'),
                const SizedBox(height: 20),
                
                // Pitch Control
                const Text('Pitch', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Low'),
                    Expanded(
                      child: Slider(
                        value: currentPitch,
                        min: 0.5,
                        max: 2.0,
                        divisions: 15,
                        onChanged: (value) {
                          setState(() {
                            currentPitch = value;
                          });
                        },
                      ),
                    ),
                    const Text('High'),
                  ],
                ),
                Text('Current: ${currentPitch.toStringAsFixed(1)}'),
                
                const SizedBox(height: 20),
                
                // Volume Control
                const Text('Volume', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Quiet'),
                    Expanded(
                      child: Slider(
                        value: currentVolume,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        onChanged: (value) {
                          setState(() {
                            currentVolume = value;
                          });
                        },
                      ),
                    ),
                    const Text('Loud'),
                  ],
                ),
                Text('Current: ${(currentVolume * 100).round()}%'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _setAdvancedTTSSettings(currentPitch, currentVolume);
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setAdvancedTTSSettings(double pitch, double volume) async {
    try {
      final setPitchUseCase = getIt<SetPitch>();
      final setVolumeUseCase = getIt<SetVolume>();
      
      // Set pitch
      final pitchResult = await setPitchUseCase.call(pitch);
      pitchResult.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error setting pitch: ${failure.message}')),
          );
          return;
        },
        (_) {},
      );
      
      // Set volume
      final volumeResult = await setVolumeUseCase.call(volume);
      volumeResult.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error setting volume: ${failure.message}')),
          );
          return;
        },
        (_) {},
      );
      
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Advanced TTS settings applied successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'MaxSpeak',
      applicationVersion: '1.0.0 (Alpha)',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: const Icon(
          Icons.record_voice_over,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: [
        const Text(
          'MaxSpeak is an affordable PDF text-to-speech reader designed to compete with premium apps at 85% lower cost.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Built with Flutter for cross-platform compatibility and featuring advanced TTS capabilities.',
        ),
      ],
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_hapticFeedback) {
                HapticFeedback.mediumImpact();
              }
              
              // Reset theme
              ref.read(themeProvider.notifier).setTheme(AppThemeMode.system);
              
              // Reset all persistent settings
              await SettingsService.instance.resetAllSettings();
              
              // Reload settings
              _loadSettings();
              setState(() {});
              
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All settings reset to default values'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
