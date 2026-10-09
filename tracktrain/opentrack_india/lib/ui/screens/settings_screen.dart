import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../providers.dart';
import '../widgets/common.dart';

/// All customization: themes (Light / Dark / OLED / high-contrast outdoor),
/// language, default tracking mode, speedometer unit, timeline density and
/// the optional live-data endpoint.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const Map<String, String> _languageLabels = {
    'system': 'System',
    'en': 'English',
    'hi': 'हिन्दी',
    'bn': 'বাংলা',
    'te': 'తెలుగు',
    'ta': 'தமிழ்',
    'mr': 'मराठी',
    'kn': 'ಕನ್ನಡ',
    'gu': 'ગુજરાતી',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          SectionHeader(title: l10n.theme),
          Card(
            child: Column(
              children: [
                RadioGroup<AppThemeChoice>(
                  groupValue: settings.theme,
                  onChanged: (value) {
                    if (value != null) settings.theme = value;
                  },
                  child: Column(
                    children: [
                      for (final choice in AppThemeChoice.values)
                        RadioListTile<AppThemeChoice>(
                          value: choice,
                          title: Text(_themeLabel(l10n, choice)),
                        ),
                    ],
                  ),
                ),
                SwitchListTile(
                  value: settings.highContrast,
                  onChanged: (value) => settings.highContrast = value,
                  title: Text(l10n.highContrast),
                  secondary: const Icon(Icons.contrast),
                ),
              ],
            ),
          ),
          SectionHeader(title: l10n.language),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: DropdownButtonFormField<String>(
                initialValue: _languageLabels.containsKey(settings.language)
                    ? settings.language
                    : 'system',
                decoration: const InputDecoration(border: InputBorder.none),
                items: [
                  for (final entry in _languageLabels.entries)
                    DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) settings.language = value;
                },
              ),
            ),
          ),
          SectionHeader(title: l10n.trackingMode),
          Card(
            child: RadioGroup<TrackingModeChoice>(
              groupValue: settings.trackingMode,
              onChanged: (value) {
                if (value != null) settings.trackingMode = value;
              },
              child: Column(
                children: [
                  RadioListTile<TrackingModeChoice>(
                    value: TrackingModeChoice.auto,
                    title: Text(l10n.modeAuto),
                  ),
                  RadioListTile<TrackingModeChoice>(
                    value: TrackingModeChoice.gpsOnly,
                    title: Text(l10n.modeGps),
                  ),
                  RadioListTile<TrackingModeChoice>(
                    value: TrackingModeChoice.cellOnly,
                    title: Text(l10n.modeCell),
                  ),
                ],
              ),
            ),
          ),
          SectionHeader(title: l10n.speedUnit),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  for (final unit in SpeedUnitChoice.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(unit.label),
                        selected: settings.speedUnit == unit,
                        onSelected: (_) => settings.speedUnit = unit,
                      ),
                    ),
                ],
              ),
            ),
          ),
          SectionHeader(title: l10n.trainSchedule),
          Card(
            child: SwitchListTile(
              value: settings.compactTimeline,
              onChanged: (value) => settings.compactTimeline = value,
              title: Text(l10n.compactTimeline),
              secondary: const Icon(Icons.view_agenda_outlined),
            ),
          ),
          SectionHeader(title: l10n.liveEndpoint),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: TextEditingController(
                      text: settings.liveEndpoint,
                    )..selection = TextSelection.collapsed(
                        offset: settings.liveEndpoint.length,
                      ),
                    decoration: InputDecoration(
                      hintText: 'https://example.org/api/v1',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.url,
                    onSubmitted: (value) =>
                        settings.liveEndpoint = value.trim(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.liveEndpointHint,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
          SectionHeader(title: l10n.aboutTitle),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                l10n.aboutBody,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _themeLabel(AppLocalizations l10n, AppThemeChoice choice) {
    return switch (choice) {
      AppThemeChoice.system => l10n.themeSystem,
      AppThemeChoice.light => l10n.themeLight,
      AppThemeChoice.dark => l10n.themeDark,
      AppThemeChoice.oled => l10n.themeOled,
    };
  }
}
